//
//  LocalRemind.h
//  MyNoteBook
//
//  Created by riber on 16/1/21.
//  Copyright © 2016年 314420972@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LocalRemind : NSObject

+ (id)sharedLocalRemind;
- (void)addLocalRemindStartOfTime:(NSDate *)date andName:(NSString *)name;
- (void)cancelLocalRemindWithName:(NSString *)name;

@end
