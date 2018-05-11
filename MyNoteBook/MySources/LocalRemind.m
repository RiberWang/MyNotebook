//
//  LocalRemind.m
//  MyNoteBook
//
//  Created by riber on 16/1/21.
//  Copyright © 2016年 314420972@qq.com. All rights reserved.
//

#import "LocalRemind.h"

@implementation LocalRemind

// 单例
+ (id)sharedLocalRemind {
    static LocalRemind *localRemind = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (localRemind == nil) {
            localRemind = [[LocalRemind alloc] init];
        }
    });
    
    return localRemind;
}

- (void)addLocalRemindStartOfTime:(NSDate *)fireDate andName:(NSString *)name {
    [[LocalRemind sharedLocalRemind] cancelLocalRemindWithName:name];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (localNotification == nil) {
        return;
    }
   
    /*
     since1970并非是在1970年1月1日的早上零点开始算的，而是根据安装该软件的手机的系统时区所对应的时区的得出来的时间，换算成北京时间，这个since1970所得出的起始时间就是1970年1月1日早上8点
     */
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"]; // GMT UTC

    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/lastdate"];
    NSString *dateString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSDate *date = [formatter dateFromString:dateString];
    
    // 设置推送时间 为不使用app后的2天
    NSDate *remindDate = [date dateByAddingTimeInterval:24*60*60*2];
    NSLog(@"remindDate:%@", remindDate);
    localNotification.fireDate = remindDate;
    
    // 设置推送时间 为每天8:30
    //localNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:30*60];
    localNotification.repeatInterval = NSCalendarUnitDay;
    NSLog(@"fireDate:%@, repeatInterval:%zi", localNotification.fireDate, localNotification.repeatInterval);
    //设置本地通知的时区
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //设置通知的内容
    localNotification.alertBody = @"你已经好久没记录生活了~~ 点击查看";
    //设置通知动作按钮的标题
    localNotification.alertAction = @"查看";
    //设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息

    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"你已经好久没记录生活了~~" forKey:@"message"];
    localNotification.userInfo = infoDic;
    //在规定的日期触发通知
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    //立即触发一个通知
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)cancelLocalRemindWithName:(NSString *)name {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (NSDate *)formatterDate:(NSDate *)date {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy:MM:dd hh:mm:ss";
    NSString *string = [formatter stringFromDate:currentDate];
    NSDate *formatterDate = [formatter dateFromString:string];
    
    return formatterDate;
}

@end
