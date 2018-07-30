//
//  ViewController.m
//  MyNoteBook
//
//  Created by Riber on 15/6/24.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//

#import "ViewController.h"
#import "MyCell.h"
#import "AddNewViewController.h"
#import "DetailViewController.h"
#import "FMDBManager.h"
#import "MyNote.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>

#import <ShareSDKExtension/ShareSDK+Extension.h>
#import "WXApi.h"

#import "UserInfoViewController.h"

// 屏幕尺寸
#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

// 系统当前版本
#define SystemVersion [[[UIDevice currentDevice] systemVersion] doubleValue]

#define NavMaxY (self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height + [UIApplication sharedApplication].statusBarFrame.origin.y)

// 状态栏高度
#define StatusMaxY ([UIApplication sharedApplication].statusBarFrame.size.height + [UIApplication sharedApplication].statusBarFrame.origin.y)

// 导航栏高度
#define NavHeight self.navigationController.navigationBar.frame.size.height

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate,sendNoteToMain, UISearchBarDelegate, UIGestureRecognizerDelegate> {
    FMDBManager *manager;
    
    NSMutableArray *_searchArray; // 搜索时的数组
    UISearchBar *_searchBar;
    UIView *_searchBarBgView;
    
    BOOL _isEdit; // 是否处于编辑状态
    BOOL _isSearch; // 是否处于搜索状态
    BOOL _isGoToDetail; // 解决iOS7的处于搜索状态时 进入详情 导航不见
    BOOL _isDetailAndBackground; // 处于详情页 进入后台
    CGFloat keyBoardHeight; // 搜索时的键盘高度
    CGFloat _duration;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSources; // 数据源

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

//    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
//    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];

    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    [self createUI];
    
    // 添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // 进入后台
    [[ NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:@"enterBackground" object:nil];
    
    // 摇一摇
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self becomeFirstResponder];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _isGoToDetail = NO;
    _isDetailAndBackground = NO;
    NSArray *array = [manager selectNotes];
    _dataSources = (NSMutableArray *)array;
    
    // 没数据时 编辑置灰 删除操作时 不置灰 待完善
//    if (_dataSources.count == 0) {
//        self.navigationItem.leftBarButtonItem.enabled = NO;
//    }
//    else
//    {
//        self.navigationItem.leftBarButtonItem.enabled = YES;
//    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    _duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    NSValue *keyBoardValue = userInfo[@"UIKeyboardFrameEndUserInfoKey"];
    CGRect keyboardRect = [keyBoardValue CGRectValue];
    keyBoardHeight = keyboardRect.size.height;
}

#pragma mark - 进入后台 处理
- (void)enterBackground:(NSNotification *)notification {
    // 处于搜索 进入详情页时 不进入后台操作
    if (!_isDetailAndBackground) {
        [self searchBarCancelButtonClicked:_searchBar];
    }
}

#pragma mark - 创建UI
- (void)createUI {
    // 初始化数据源
    self.dataSources = [[NSMutableArray alloc] init];
    _searchArray = [[NSMutableArray alloc] init];
    manager = [FMDBManager sharedDBManager];
    [manager createTable];
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = CGRectMake(0, 0, 60, 44);
    [titleButton setTitle:AppName forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [titleButton addTarget:self action:@selector(titleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewNote:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(pressLeftBar:)];
    
    float statusH = [UIApplication sharedApplication].statusBarFrame.size.height;

    // 初始化搜索框的背景
    _searchBarBgView = [[UIView alloc] initWithFrame:CGRectMake(0, NavMaxY-statusH, self.view.frame.size.width, 20+40)];
    _searchBarBgView.backgroundColor = [UIColor colorWithRed:198/255.0 green:198/255.0 blue:203/255.0 alpha:1];
    [self.view addSubview:_searchBarBgView];
    
    // 初始化搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, KScreenWidth, 40)];
//    _searchBar.tintColor = GRAYTEXT; // 光标颜色
//    _searchBar.barTintColor = [UIColor whiteColor]; //背景颜色
    _searchBar.placeholder = @"请输入要搜索的内容";
    _searchBar.delegate = self;
    [_searchBarBgView addSubview:_searchBar];
    
    // 去掉 searchBar 的边线
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 20+2)];
    view.backgroundColor = [UIColor colorWithRed:198/255.0 green:198/255.0 blue:203/255.0 alpha:1];
    [_searchBarBgView addSubview:view];
    
    // collectionView布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;

    // 根据屏幕尺寸来动态设置 item大小
    if (KScreenWidth <= 320)
    {
        layout.itemSize = CGSizeMake(120, 120);
    }
    else if (KScreenWidth > 320 && KScreenWidth <= 414)
    {
        layout.itemSize = CGSizeMake(100, 100);
    }
    else // ipad适配大小
    {
        layout.itemSize = CGSizeMake(150, 150);
    }
    
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _searchBarBgView.frame.size.height + _searchBarBgView.frame.origin.y, KScreenWidth, KScreenHeight-(NavMaxY-_searchBar.frame.size.height)) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor darkGrayColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_collectionView];
    
    // 注册cell
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MyCell class]) bundle:nil] forCellWithReuseIdentifier:@"MYCELL"];
    
    // 给 view 添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.collectionView addGestureRecognizer:tap];
}

#pragma mark - 导航按钮事件
- (void)titleButtonClick {
    UserInfoViewController *userInfo = [[UserInfoViewController alloc] init];
    [self.navigationController pushViewController:userInfo animated:YES];
}

- (void)pressLeftBar:(UIBarButtonItem *)item {
    if (_isEdit)
    {
        _isEdit = NO;
        item.title = @"编辑";
        UIView *view = [_searchBarBgView viewWithTag:998];
        [view removeFromSuperview];

        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        // 这样写 有的cell 不会停止抖动
//        NSArray *cellArray = [self.collectionView visibleCells];
//        for (MyCell *cell in cellArray) {
//            [cell endWobble];
//        }
        
        [_collectionView reloadData];
    }
    else
    {
        _isEdit = YES;
        item.title = @"完成";
        self.navigationItem.rightBarButtonItem.enabled = NO;

        // 使搜索框不可输入
        UIView *view = [[UIView alloc] initWithFrame:_searchBar.frame];
        view.backgroundColor = [UIColor lightGrayColor];
        view.tag = 998;
        view.alpha = 0.2;
        [_searchBarBgView addSubview:view];
        
        NSArray *cellArray = [self.collectionView visibleCells];
        for (MyCell *cell in cellArray) {
            [cell startWobble];
        }
    }
}

// 跳转添加页面
- (void)addNewNote:(UIBarButtonItem *)item {
    AddNewViewController *addNewVC = [[AddNewViewController alloc] init];
    addNewVC.delegate = self;
    addNewVC.title = @"添加新事件";
    [self.navigationController pushViewController:addNewVC animated:YES];
}

#pragma mark - 手势代理方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{

    if (_searchBar.text.length == 0)
    {
        [self.view endEditing:YES];
        _searchBar.showsCancelButton = NO;
        _isSearch = YES;
        
        [UIView animateWithDuration:_duration animations:^{
            
            // 导航栏高度
            float navHeight = self.navigationController.navigationBar.frame.size.height;
            
            // 导航条位置
            CGRect navFrame = self.navigationController.navigationBar.frame;
            navFrame.origin.y = 20;
            self.navigationController.navigationBar.frame = navFrame;
            
            // 搜索框位置
            CGRect searchBarFrame = _searchBarBgView.frame;
            searchBarFrame.origin.y = navHeight;
            _searchBarBgView.frame = searchBarFrame;
            
            // collectionView 位置
            CGRect collectionViewFrame = _collectionView.frame;
            collectionViewFrame.origin.y = navHeight + _searchBarBgView.frame.size.height;
            collectionViewFrame.size.height = self.view.frame.size.height - collectionViewFrame.origin.y;
            _collectionView.frame = collectionViewFrame;
        } completion:^(BOOL finished) {
            
            _isSearch = NO;
        }];

        return NO;
    }
    
    return NO;
}

#pragma mark - collectionView代理方法
// collectionView dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_searchBar.text.length == 0 || _searchBar.text == nil) {
        return _dataSources.count;
    } else {
        return _searchArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MYCELL" forIndexPath:indexPath];
    
    MyNote *tmpNote = nil;
    if (_searchBar.text.length == 0 || _searchBar.text == nil || _searchArray.count == 0) {
        tmpNote = _dataSources[indexPath.row];
    } else {
        tmpNote = _searchArray[indexPath.row];
    }
    cell.label.text = tmpNote.content;
    
    __block typeof(cell)myCell = cell;
    
    [cell setLongPressBlock:^{
        [self showShareActionSheet:myCell];
    }];
    
//    [cell setLongPressBlock:^(int index) {
//        if (index == 0) { // 单选删除
//            _isEdit = NO;
//            myCell.isEdit = _isEdit;
//            [manager deleteNote:tmpNote];
//            // 不能根据索引删除,造成越界
//            [_dataSources removeObject:tmpNote];
//            [_collectionView reloadData];
//        }
//        
//        // 实现抖动 多选删除
//        if (index == 1) {
//            // 在置为yes之前调用 并且在这里只调用一次 不会多次叠加 view
//            [self pressLeftBar:nil];
//            _isEdit = YES;
//            myCell.isEdit = _isEdit;
//            [collectionView reloadData];
//        }
//    }];
    
    
    if (_isEdit) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.title = @"Done";

        // 使 searchBar 搜索不可用 在这里写 会有问题 已弃用
//        UIView *view = [[UIView alloc] initWithFrame:_searchBar.frame];
//        view.backgroundColor = [UIColor lightGrayColor];
//        view.tag = 998;
//        view.alpha = 0.2;
//        [self.view addSubview:view];
        
        [cell startWobble];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
//        UIView *view = [self.view viewWithTag:998];
//        [view removeFromSuperview];
        
        [cell endWobble];
    }
    
    return cell;
}

- (void)showShareActionSheet:(UIView *)view
{
    /**
     * 在简单分享中，只要设置共有分享参数即可分享到任意的社交平台
     **/
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    NSArray* imageArray = @[[UIImage imageNamed:@"newIcon.png"]];
    [shareParams SSDKSetupShareParamsByText:@"我的第一个记事本"
                                     images:imageArray
                                        url:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/wan-shi-ben/id1057007765?mt=8"]
                                      title:@"万事本"
                                       type:SSDKContentTypeAuto];
    
    //1.2、自定义分享平台（非必要）
    NSMutableArray *activePlatforms = [NSMutableArray arrayWithArray:@[@(SSDKPlatformTypeQQ),
                                       @(SSDKPlatformSubTypeQZone),
                                       @(SSDKPlatformTypeWechat),                                                                       ]];
    //添加一个自定义的平台（非必要）
    SSUIShareActionSheetCustomItem *item = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"sinaweibo.png"]
                                                                                  label:@"Sina" onClick:^{                                                                                    [ShareSDK share:SSDKPlatformTypeSinaWeibo
                                                                                         parameters:shareParams
                                                                                     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                                                                                         switch (state) {
                                                                                             case SSDKResponseStateSuccess:
                                                                                             {
                                                                                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                                                                                     message:nil
                                                                                                                                                    delegate:nil
                                                                                                                                           cancelButtonTitle:@"确定"
                                                                                                                                           otherButtonTitles:nil];
                                                                                                 [alertView show];
                                                                                                 break;
                                                                                             }
                                                                                             case SSDKResponseStateFail:
                                                                                             {
if ([[error.userInfo valueForKey:@"error_code"] integerValue] == 20016 ) {
                                                                                                     
                                                                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                                                                                         message:[NSString stringWithFormat:@"%@", @"发微博太多啦，休息一会儿吧"]
                                                                                                                                                        delegate:nil
                                                                                                                                               cancelButtonTitle:@"确定"
                                                                                                                                               otherButtonTitles:nil];
                                                                                                     [alertView show];                                           }
                                                                                                 break;
                                                                                             }
                                                                                             case SSDKResponseStateCancel:
                                                                                             {
                                                                                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                                                                                                     message:nil
                                                                                                                                                    delegate:nil
                                                                                                                                           cancelButtonTitle:@"确定"
                                                                                                                                           otherButtonTitles:nil];
                                                                                                 [alertView show];
                                                                                                 break;
                                                                                             }
                                                                                             default:
                                                                                                 break;
                                                                                         }
                                                                                     }];                                //自定义item被点击的处理逻辑
                                                                                    
                                                                                }];
    
    [activePlatforms addObject:item];

    //2、分享
    [ShareSDK showShareActionSheet:view
                             items:activePlatforms
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
                           //[theController showLoadingView:YES];
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil];
                           [alertView show];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil];
                           [alertView show];
                           break;
                       }
                       default:
                           break;
                   }
                   
               }];
    
    
    //另附：设置跳过分享编辑页面，直接分享的平台。
    //        SSUIShareActionSheetController *sheet = [ShareSDK showShareActionSheet:view
    //                                                                         items:nil
    //                                                                   shareParams:shareParams
    //                                                           onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
    //                                                           }];
    //
    //        //删除和添加平台示例
    //        [sheet.directSharePlatforms removeObject:@(SSDKPlatformTypeWechat)];
    //        [sheet.directSharePlatforms addObject:@(SSDKPlatformTypeSinaWeibo)];
    
}

// collectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEdit)
    {
        [manager deleteNote:_dataSources[indexPath.row]];
        [_dataSources removeObjectAtIndex:indexPath.row];
        if (_searchArray.count != 0) {
            [_searchArray removeObjectAtIndex:indexPath.row];
        }
        
        [_collectionView reloadData];
    }
    else if (_isSearch)
    {
        // 处于搜索时 点击collectionView 退出搜索 如果是点在详情页面上 使其不进入详情页面
        _isSearch = NO;
    }
    else
    {
        DetailViewController *detailVC = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        detailVC.title = @"查看详情";

        // 处理拼音搜索时 没按确认 点击 cell 崩溃
        if (_searchArray.count == 0 || _searchBar.text.length == 0) {
            detailVC.myNote = _dataSources[indexPath.row];
        }
        else
        {
            detailVC.myNote = _searchArray[indexPath.row];
        }

        detailVC.navBarOrginY = self.navigationController.navigationBar.frame.origin.y;
        detailVC.clickDelBlock = ^(UIBarButtonItem *item) {
            if (_searchBar.text.length == 0)
            {
                [manager deleteNote:_dataSources[indexPath.row]];
                [_dataSources removeObjectAtIndex:indexPath.row];
                [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }
            else
            {
                [manager deleteNote:_searchArray[indexPath.row]];
                [_dataSources removeObject:_searchArray[indexPath.row]];
                [_searchArray removeObjectAtIndex:indexPath.row];
                [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }
        };
        detailVC.clickBackBlock = ^(MyNote *note) {
            
            [manager updateMyNote:note];

            
            [_collectionView reloadData];
        };
        
        _isGoToDetail = YES;
        _isDetailAndBackground = YES;
        
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - 添加页面代理方法
- (void)sendNoteToMain:(AddNewViewController *)addVC {
    MyNote *tmpNote = [[MyNote alloc] init];
    tmpNote.date = addVC.dateLabel.text;
    tmpNote.content = addVC.textView.text;
    
    // 判断最后一个元素不为空格
    // [[addVC.textView.text substringFromIndex:tmpNote.content.length-1] isEqualToString:@" "]
    if (addVC.textView.text.length == 0) {
        return;
    }
    
    [manager addNewNote:tmpNote];
    [_dataSources addObject:tmpNote];
    
    
    
    [_collectionView reloadData];
}

#pragma mark - searchBar deleagte
// searchBar deleagte
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (_isGoToDetail) {
        _isGoToDetail = NO;
        return YES;
    }
    
    searchBar.showsCancelButton = YES;
    NSLog(@"%@", [_searchBar.subviews[0] subviews]);
    for (id obj in [_searchBar.subviews[0] subviews]) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton *)obj;
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
    
    [_collectionView setContentOffset:CGPointZero animated:NO];
    [UIView animateWithDuration:_duration animations:^{
        // 导航栏高度
        float navHeight = self.navigationController.navigationBar.frame.size.height;
        float navY = self.navigationController.navigationBar.frame.origin.y;
        float statusY = [UIApplication sharedApplication].statusBarFrame.origin.y;
        
        if (navY >= 0) {
            // 导航条位置
            CGRect navFrame = self.navigationController.navigationBar.frame;
            navFrame.origin.y = -navHeight;
            self.navigationController.navigationBar.frame = navFrame;
            
            // 搜索框位置
            CGRect searchBarBgFrame = _searchBarBgView.frame;
            searchBarBgFrame.origin.y = statusY;
            _searchBarBgView.frame = searchBarBgFrame;
            
            // collectionView 位置
            CGRect collectionViewFrame = _collectionView.frame;
            collectionViewFrame.origin.y =  _searchBarBgView.frame.size.height + _searchBarBgView.frame.origin.y;
            collectionViewFrame.size.height = self.view.frame.size.height - collectionViewFrame.origin.y - keyBoardHeight;
            _collectionView.frame = collectionViewFrame;
        }
        
    } completion:^(BOOL finished) {
    }];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // collectionView 位置
    if (searchText.length == 0)
    {
        CGRect collectionViewFrame = _collectionView.frame;
        collectionViewFrame.origin.y =  _searchBarBgView.frame.size.height;
        collectionViewFrame.size.height = self.view.frame.size.height - collectionViewFrame.origin.y - keyBoardHeight;
        _collectionView.frame = collectionViewFrame;
    }
    else
    {
        CGRect collectionViewFrame = _collectionView.frame;
        collectionViewFrame.origin.y =  _searchBarBgView.frame.size.height;
        collectionViewFrame.size.height = self.view.frame.size.height - collectionViewFrame.origin.y - keyBoardHeight - 40;
        _collectionView.frame = collectionViewFrame;
    }
    
    [_searchArray removeAllObjects];
    for (MyNote *note in _dataSources) {
        
        // 搜索内容和文本内容都转化为拼音
        NSRange range = [[self supportPinYinSearch:[note.content lowercaseString]] rangeOfString:[self supportPinYinSearch:[searchBar.text lowercaseString]]];
        if (range.location != NSNotFound) {
            [_searchArray addObject:note];
        }
    }
    
    [_collectionView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    _isSearch = NO;
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    [_searchArray removeAllObjects];
    
    [UIView animateWithDuration:_duration animations:^{
        // 状态栏高度
        float statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        // 导航条位置
        CGRect navFrame = self.navigationController.navigationBar.frame;
        navFrame.origin.y = 20;
        self.navigationController.navigationBar.frame = navFrame;
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        // 搜索框位置
        CGRect searchBarFrame = _searchBarBgView.frame;
        searchBarFrame.origin.y = NavMaxY-statusHeight;
        _searchBarBgView.frame = searchBarFrame;
        
        // collectionView 位置
        CGRect collectionViewFrame = _collectionView.frame;
        collectionViewFrame.origin.y = NavMaxY + _searchBarBgView.frame.size.height - statusHeight;
        collectionViewFrame.size.height = self.view.frame.size.height - collectionViewFrame.origin.y;
        _collectionView.frame = collectionViewFrame;
    } completion:^(BOOL finished) {
    }];
    
    [_collectionView reloadData];
}

#pragma mark - 添加拼音搜索
- (NSString *)supportPinYinSearch:(NSString*)sourceString {
    NSMutableString *source = [sourceString mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    
    return [source stringByReplacingOccurrencesOfString:@" " withString:@""];;
}

// 摇一摇
#pragma mark - 摇一摇相关方法
// 摇一摇开始摇动
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"开始摇动");
    return;
}

// 摇一摇取消摇动
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"取消摇动");
    return;
}

// 摇一摇摇动结束
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake) { // 判断是否是摇动结束
        NSLog(@"摇动结束");
    }
    
    return;
}

@end
