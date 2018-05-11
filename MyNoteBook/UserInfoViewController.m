//
//  UserInfoViewController.m
//  MyNoteBook
//
//  Created by Riber on 16/8/9.
//  Copyright © 2016年 314420972@qq.com. All rights reserved.
//

#import "UserInfoViewController.h"

#define SystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]

@interface UserInfoViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"作者信息";
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style: UIBarButtonItemStylePlain target:self action:@selector(backItem:)];
    self.navigationItem.leftBarButtonItem = leftItem;

    _appNameLabel.text = AppName;
    _appVersionLabel.text = AppVersion;
    
    if (SystemVersion >= 8.0) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"设置通知" style: UIBarButtonItemStylePlain target:self action:@selector(setNotification)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    else
    {
        NSLog(@"不支持");
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

- (void)backItem:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNotification {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if([[UIApplication sharedApplication] canOpenURL:url]) {
    
        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];[[UIApplication sharedApplication] openURL:url];
        
    }
}
- (IBAction)connectAppStore:(id)sender {
    // @"itms-apps://itunes.apple.com/app/id1057007765"
    NSString *urlStr = @"https://itunes.apple.com/us/app/wan-shi-ben/id1057007765?mt=8";
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url];

}

@end
