//
//  TodayViewController.m
//  MyNoteBookToday
//
//  Created by Riber on 16/2/2019.
//  Copyright © 2019 314420972@qq.com. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "FMDBManager.h"

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) UIView *contentView;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 修改默认高度
    if (@available(iOS 10.0, *)) {
        self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeCompact;
        self.preferredContentSize = CGSizeMake(0, 500);
    } else {
        // Fallback on earlier versions
    }
    //    NSString *path = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.riber.notepad.today"] absoluteString] stringByAppendingPathComponent:@"Note.db"];
//    NSUserDefaults *group = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.riber.notepad.today"];
//    if ([group objectForKey:@"latestNote"]) {
//        [self createDataUI:[group valueForKey:@"latestNote"]];
//    }
//    else {
//        [self createNoDataUI];
//    }
}

#pragma mark - UI
- (void)createDataUI:(NSDictionary *)dataDic {
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.preferredContentSize.width, self.preferredContentSize.height)];
    [self.view addSubview:self.contentView];
    self.contentView.userInteractionEnabled = YES;
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.contentView.frame.size.width - 2*20, 80)];
    detailLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    detailLabel.text = dataDic[@"content"];
    detailLabel.adjustsFontSizeToFitWidth = YES;
    detailLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:detailLabel];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, detailLabel.frame.size.height, self.contentView.frame.size.width - 2*20, self.contentView.frame.size.height - 10 - 80)];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    dateLabel.text = dataDic[@"date"];
    dateLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:dateLabel];
    
    UIButton *coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
    coverButton.frame = self.contentView.bounds;
    [coverButton addTarget:self action:@selector(gotoDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:coverButton];
}

- (void)createNoDataUI
{
    //内容视图
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.preferredContentSize.width, self.preferredContentSize.height)];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];
    self.contentView.userInteractionEnabled = YES;
    
    //Label1
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.contentView.frame.size.width - 2*20, 20)];
    detailLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    detailLabel.text = @"今天天气还不错啊~~为什么不去记点东西呢？";
    detailLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:detailLabel];
    
    //切换按钮
    UIButton *mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mainButton.frame = CGRectMake(10, 40 + 20, self.contentView.frame.size.width - 2*10, 44);
    [mainButton addTarget:self action:@selector(toggleLineChartViewVisible:) forControlEvents:UIControlEventTouchUpInside];
    [mainButton setTitle:@"你已经好久没来了 -> 点我" forState:UIControlStateNormal];
    [mainButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
    [self.contentView addSubview:mainButton];
}

#pragma mark - click
- (void)gotoDetail {
    [self.extensionContext openURL:[NSURL URLWithString:[NSString stringWithFormat:@"MyNoteBookWidget://action=GotoDetailPage"]] completionHandler:^(BOOL success) {
        NSLog(@"open url result:%d",success);
    }];
}

- (void)toggleLineChartViewVisible:(id)sender
{
    [self.extensionContext openURL:[NSURL URLWithString:@"MyNoteBookWidget://action=GotoAddPage"] completionHandler:^(BOOL success) {
        NSLog(@"open url result:%d",success);
    }];
}

#pragma mark - Widget delegate
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize  API_AVAILABLE(ios(10.0)) {
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = maxSize;
    } else {
        self.preferredContentSize = CGSizeMake(0, 140);
    }
}

// 10.0及以后版本无效
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    //配置边距为0
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    [self updateUI];
    completionHandler(NCUpdateResultNewData);
}

#pragma mark - update UI
- (void)updateUI {
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    NSUserDefaults *group = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.riber.notepad.today"];
    if ([group objectForKey:@"latestNote"]) {
        [self createDataUI:[group valueForKey:@"latestNote"]];
    }
    else {
        [self createNoDataUI];
    }
}

@end
