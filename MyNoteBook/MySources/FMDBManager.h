//
//  FMDBManager.h
//  MyNoteBook
//
//  Created by Riber on 15/6/25.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyNote.h"

@interface FMDBManager : NSObject

+ (id)sharedDBManager;
- (void)createTable;
- (void)addNewNote:(MyNote *)note;
- (void)updateMyNote:(MyNote *)note;
- (void)deleteNote:(MyNote *)note;
- (NSArray *)selectNotes;

@end
