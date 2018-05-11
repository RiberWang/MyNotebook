//
//  AppDelegate.m
//  MyNoteBook
//
//  Created by Riber on 15/6/24.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//  版权所有（C）2015年 314420972@qq.com。保留所有权利。

#import "AppDelegate.h"
#import "ViewController.h"
#import "MyNavController.h"
#import "LocalRemind.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#import "WXApi.h"

#import "WeiboSDK.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[MyNavController alloc] initWithRootViewController:[[ViewController alloc] init]];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *dateString = [formatter stringFromDate:date];
    
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/lastdate"];
    [dateString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // 打电话
    CTCallCenter *center = [[CTCallCenter alloc] init];
    center.callEventHandler = ^(CTCall *call){

        
        NSLog(@"call:%@", call.callState);
    };
    
    [self registerLocalAPNS];
    
    // 接收通知参数 此时程序没有运行 会走这个方法 拿到LocalNotification
    UILocalNotification *LocalNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    NSDictionary *userInfo = LocalNotification.userInfo;
    NSLog(@"userInfo:%@", userInfo);
    
    // 创建handoff
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        [self createHandOff];
    }
    
    [self registerShareSDK];
    
    [UINavigationBar appearance].translucent = YES;

    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
//    [UINavigationBar appearance].barStyle = UIBarStyleDefault;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)registerShareSDK {
    //1275ebaece310
    [ShareSDK registerApp:@"ef27d99a0100" activePlatforms:@[
                                                             @(SSDKPlatformTypeSinaWeibo),
                                                             @(SSDKPlatformSubTypeQZone),
                                                             @(SSDKPlatformTypeCopy),
                                                             @(SSDKPlatformTypeQQ),
                                                             @(SSDKPlatformTypeWechat)
                                                            ]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     
                     {
                             
                         case SSDKPlatformTypeWechat:
                             
                             //[ShareSDKConnector connectWeChat:[WXApi class]];
                             [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class]
                                        tencentOAuthClass:[TencentOAuth class]];
                             break;
                         case SSDKPlatformTypeSinaWeibo:
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                             break;
                         default:
                             break;
                     }
                     
                 } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
                     
                     switch (platformType)
                     {

//                         case SSDKPlatformTypeSinaWeibo:
//                             //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
//                             [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
//                                                       appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
//                                                     redirectUri:@"http://www.sharesdk.cn"
//                                                        authType:SSDKAuthTypeBoth];
//                             break;
//                         case SSDKPlatformTypeWechat:
//                             [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
//                                                   appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
//                             break;
                         case SSDKPlatformTypeQQ:
                             [appInfo SSDKSetupQQByAppId:@"1105317439"
                                                  appKey:@"3XWxuZXPV6RV3NEa"
                                                authType:SSDKAuthTypeBoth];
                             break;
                         case SSDKPlatformTypeSinaWeibo:
                             //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                             //  3875938777 b791c41546354bca5f705882df7a2a70
                             [appInfo SSDKSetupSinaWeiboByAppKey:@"647948000"
                                                       appSecret:@"4fbcbc32a561d31c2df43ec4ea6ea009"
                                                     redirectUri:@"http://www.weibo.com"
                                                        authType:SSDKAuthTypeBoth];
                             break;
                         case SSDKPlatformTypeWechat:
                             [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
                                                   appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
                             break;

                         default:
                             break;

                     }
                 }];
}

// 注册本地推送
- (void)registerLocalAPNS {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        UIUserNotificationSettings *notificationSetting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSetting];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    // 添加本地推送
    [[LocalRemind sharedLocalRemind] addLocalRemindStartOfTime:nil andName:@"本地推送"];
}

// 创建handoff
- (void)createHandOff {
    self.userActivity = [[NSUserActivity alloc] initWithActivityType:@"com.riberwang.mynotebook.main"];
    self.userActivity.title = @"main";
    [self.userActivity becomeCurrent];
}

- (void)updateUserActivityState:(NSUserActivity *)activity {
    activity.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"handoff_date", nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

// 进入前台后设置消息信息
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 进入后台 监听
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enterBackground" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 此时程序在运行 处于后台 后处理这个方法 拿到notification
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //NSLog(@"%@", notification);
    [UIApplication sharedApplication].applicationIconBadgeNumber = application.scheduledLocalNotifications.count;

    //[[UIApplication sharedApplication] cancelLocalNotification:notification];
    
    // 这里真实需要处理交互的地方
    // 获取通知所带的数据
//    NSString *notMess = [notification.userInfo objectForKey:@"message"];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                    message:notMess
//                                                   delegate:nil
//                                          cancelButtonTitle:@"取消"
//                                          otherButtonTitles:@"确定", nil];
//    [alert show];
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    return false;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    
    return YES;
}

- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity {
    NSLog(@"%@", userActivity.userInfo);
}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    return [ShareSDK han];
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString* prefix = @"MyNoteBookWidget://action=";
    if ([[url absoluteString] rangeOfString:prefix].location != NSNotFound) {
        NSString* action = [[url absoluteString] substringFromIndex:prefix.length];
        if ([action isEqualToString:@"GotoHomePage"]) {
            NSLog(@"Enter HomePage");
        }
        else if([action isEqualToString:@"GotoOrderPage"]) {
//            BasicHomeViewController *vc = (BasicHomeViewController*)self.window.rootViewController;
//            [vc.tabbar selectAtIndex:2];
            NSLog(@"Enter OrderPage");
        }
    }
    
    return  YES;
}

@end
