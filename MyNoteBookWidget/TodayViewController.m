//
//  TodayViewController.m
//  MyNoteBookWidget
//
//  Created by Riber on 16/8/10.
//  Copyright © 2016年 314420972@qq.com. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *mainButton;
@property (nonatomic, strong) UIButton *detailButton;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 修改默认高度
    self.preferredContentSize = CGSizeMake(0, 200);
    
    [self createUI];

}

- (void)createUI
{
    //内容视图
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];
    self.contentView.userInteractionEnabled = YES;

    //Label1
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width-2*10, 20)];
    self.detailLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.detailLabel.text = @"今天天气还不错啊~~为什么不去记点东西呢？";
    [self.contentView addSubview:self.detailLabel];

    //切换按钮
    self.mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mainButton.frame = CGRectMake(10, _detailLabel.frame.size.height+20, self.view.frame.size.width-2*10, 44);
    [self.mainButton addTarget:self action:@selector(toggleLineChartViewVisible:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainButton setTitle:@"你已经好久没来了 -> 点我" forState:UIControlStateNormal];
    [self.mainButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
    [self.contentView addSubview:self.mainButton];

}

- (void)toggleLineChartViewVisible:(id)sender
{
    //重新布局
    [self.extensionContext openURL:[NSURL URLWithString:@"MyNoteBookWidget://action=GotoHomePage"] completionHandler:^(BOOL success) {
        NSLog(@"open url result:%d",success);
    }];

}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

@end
