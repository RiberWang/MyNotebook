//
//  DetailViewController.m
//  MyNoteBook
//
//  Created by Riber on 15/6/25.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//

#import "DetailViewController.h"
#import "MyNote.h"
#import "FMDBManager.h"

#define WindowSize [UIScreen mainScreen].bounds.size

@interface DetailViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    // 在键盘上新增一个完成按钮
    UIView *keyBoardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    UIButton *canceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    canceButton.frame = CGRectMake(20, 0, 40, 40);
    [canceButton setTitle:@"撤销" forState:UIControlStateNormal];
    canceButton.backgroundColor = [UIColor clearColor];
    [canceButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [canceButton addTarget:self action:@selector(cancelText) forControlEvents:UIControlEventTouchUpInside];
    [keyBoardView addSubview:canceButton];

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(keyBoardView.frame.size.width-20, 0, 40, 40);
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    doneButton.backgroundColor = [UIColor clearColor];
    [doneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(hiddenKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [keyBoardView addSubview:doneButton];

    keyBoardView.backgroundColor = [UIColor whiteColor];
    
    self.textView.inputAccessoryView = keyBoardView;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"删除" style: UIBarButtonItemStylePlain target:self action:@selector(pressItem:)];
    item.tag = 0;
    self.navigationItem.rightBarButtonItem = item;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style: UIBarButtonItemStylePlain target:self action:@selector(backItem:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, 150, 40)];
    _textLabel.text = @"请输入修改的内容";
    _textLabel.hidden = YES;
    _textLabel.textColor = [UIColor grayColor];
    _textLabel.font = [UIFont systemFontOfSize:14];
    [_textView addSubview:_textLabel];
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _dateLabel.text = _myNote.date;
    _textView.text = _myNote.content;
    
    // 4 4s
    if (WindowSize.height == 480) {
        _constraintLeft.constant = 85;
        _constraintBottom.constant = 40;
    }
    // 5 5s
    else if (WindowSize.height == 568) {
        _constraintLeft.constant = 90;
        _constraintBottom.constant = 60;
    }
    
    // 6 6s
    else if (WindowSize.height == 667) {
        _constraintLeft.constant = 110;
        _constraintBottom.constant = 75;
    }
    
    // 6p 6sp
    else if (WindowSize.height == 736) {
        _constraintLeft.constant = 111;
        _constraintBottom.constant = 75;
    }
    
    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)handleNavigationTransition:(UIPanGestureRecognizer *)pan {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelText {
    [self.view endEditing:YES];
    if (_textView.text.length == 0) {
        _textLabel.hidden = YES;
    }
    _textView.text = _myNote.content;
}

- (void)hiddenKeyBoard {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    // 导航条位置
    CGRect navFrame = self.navigationController.navigationBar.frame;
    navFrame.origin.y = 20;
    self.navigationController.navigationBar.frame = navFrame;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_navBarOrginY >= 0)
    {
        // 导航条位置
        CGRect navFrame = self.navigationController.navigationBar.frame;
        navFrame.origin.y = 20;
        self.navigationController.navigationBar.frame = navFrame;
    }
    else
    {
        // 导航栏高度
        float navHeight = self.navigationController.navigationBar.frame.size.height;
        
        // 导航条位置
        CGRect navFrame = self.navigationController.navigationBar.frame;
        navFrame.origin.y = -navHeight;
        self.navigationController.navigationBar.frame = navFrame;
    }
}

- (void)pressItem:(UIBarButtonItem *)item {
    if (_textView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"更改的内容不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        if (self.clickDelBlock) {
            self.clickDelBlock(item);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backItem:(UIBarButtonItem *)item {
    
    if (_textView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"更改的内容不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        self.myNote.content = _textView.text;
        self.myNote.date = _dateLabel.text;
        self.myNote.ID = self.myNote.ID;
        if (self.clickBackBlock) {
            self.clickBackBlock(self.myNote);
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if (text.length > 0 || textView.text.length == 0) {
//        _textLabel.hidden = YES;
//    }
//    if (text.length == 0 && range.location == 0 && range.length == 1) {
//        _textLabel.hidden = NO;
//    }
    if (textView.text.length == 0) {
        _textLabel.hidden = NO;
    }
    else
    {
        _textLabel.hidden = YES;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.dateLabel.text = [self getCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

// 格式化时间
- (NSString *)getCurrentDateWithFormat:(NSString *)dateFormat {
    NSString *currentDate = nil;
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    currentDate = [formatter stringFromDate:date];
    
    return currentDate;
}

@end
