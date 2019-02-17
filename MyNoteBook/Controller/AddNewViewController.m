//
//  AddNewViewController.m
//  MyNoteBook
//
//  Created by Riber on 15/6/25.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//

#import "AddNewViewController.h"

#define SystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define WindowSize [UIScreen mainScreen].bounds.size

@interface AddNewViewController () <UITextViewDelegate,UIGestureRecognizerDelegate>

@end

@implementation AddNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"添加新事件";
    
    if((SystemVersion >= 7.0)){
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = NO;
        //self.modalPresentationCapturesStatusBarAppearance = NO;
    }
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"保存" style: UIBarButtonItemStylePlain target:self action:@selector(saveNewNote:)];
    self.navigationItem.rightBarButtonItem = item;

    self.dateLabel.text = [self getCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];

    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, 150, 40)];
    _textLabel.text = @"请输入添加的内容";
    _textLabel.textColor = [UIColor darkGrayColor];
    _textLabel.font = [UIFont systemFontOfSize:14];
    [_textView addSubview:_textLabel];
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // 在键盘上新增一个完成按钮
    UIView *keyBoardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(keyBoardView.frame.size.width-20, 0, 40, 40);
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    doneButton.backgroundColor = [UIColor clearColor];
    [doneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(hiddenKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    
    [keyBoardView addSubview:doneButton];
    keyBoardView.backgroundColor = [UIColor whiteColor];
    
    self.textView.inputAccessoryView = keyBoardView;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style: UIBarButtonItemStylePlain target:self action:@selector(backItem:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //[self createHandOff];
    
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

- (void)hiddenKeyBoard {
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    if (SystemVersion >= 8.0) {
//        [self createHandOff];
//    }
}

//- (void)createHandOff {
//    self.userActivity = [[NSUserActivity alloc] initWithActivityType:@"com.appcoda.handoffdemo.edit-contact"];
//    self.userActivity.title = @"edit";
//    [self.userActivity becomeCurrent];
//}

- (void)backItem:(UIBarButtonItem *)item {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)saveNewNote:(UIBarButtonItem *)item {
    
    if (SystemVersion >= 8.0) {
        self.userActivity.needsSave = YES;
    }
    
    // 键盘退出
    [self.view endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(sendNoteToMain:)]) {
        [self.delegate sendNoteToMain:self];
    } else {
        NSLog(@"失败");
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateUserActivityState:(NSUserActivity *)activity {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.textView.text, @"content", self.dateLabel.text, @"date", nil];
    [activity addUserInfoEntriesFromDictionary:dic];
    
    [super updateUserActivityState:activity];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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

// return键
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if ([text isEqualToString:@"\n"]) {
//        [self saveNewNote:nil];
//        return NO; // return键不再换行
//    }
//
//    if (text.length > 0) {
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.text.length > 0) {
        _textLabel.hidden = YES;
    }

//    if ([textView.text isEqualToString:@"请在这里输入内容"]) {
//        textView.text = nil;
//    }
}

@end
