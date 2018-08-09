//
//  FMDBManager.m
//  MyNoteBook
//
//  Created by Riber on 15/6/25.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//  

#import "FMDBManager.h"
#import "FMDatabase.h"

@interface FMDBManager () {
    FMDatabase *fmDatabase;
}

@end

@implementation FMDBManager

static FMDBManager *manager = nil;
static dispatch_once_t predicate;

// 单例创建数据库管理类
+ (id)sharedDBManager {
    dispatch_once(&predicate, ^{
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    });
    
    return manager;
}

//+ (id)sharedInstance {
//    dispatch_once(&predicate, ^{
//        if (manager == nil) {
//            manager = [[super allocWithZone:NULL] init];
//        }
//    });
//    
//    return manager;
//}
//
//+ (instancetype)allocWithZone:(struct _NSZone *)zone {
//    return [self sharedDBManager];
//}

- (void)createTable {
        NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/Note.db"];
        fmDatabase = [[FMDatabase alloc] initWithPath:path];
        BOOL isOpen = [fmDatabase open];
        if (isOpen) {
            NSLog(@"数据库打开成功!");
        } else {
            NSLog(@"数据库打开失败!");
        }
        
        NSString *sql = @"create table if not exists MyNote(ID integer primary key autoincrement, date varchar(256), content text)";
        if ([fmDatabase executeUpdate:sql]) {
            NSLog(@"表创建成功!");
            [fmDatabase close];
        } else {
            NSLog(@"表创建失败!");
        }
}

- (void)addNewNote:(MyNote *)note {
    BOOL isOpen = [fmDatabase open];
    if (isOpen) {
        NSLog(@"数据库打开成功!");
    } else {
        NSLog(@"数据库打开失败!");
    }

    NSString *sql = @"insert into MyNote(date,content) values(?,?)";
    NSString *date = note.date;
    NSString *newNote = note.content;
    if ([fmDatabase executeUpdate:sql, date, newNote]) {
        NSLog(@"数据插入成功!");
        
        [fmDatabase close];
    } else {
        NSLog(@"数据插入失败!");
    }
}

- (void)updateMyNote:(MyNote *)note {
    BOOL isOpen = [fmDatabase open];
    if (isOpen) {
        NSLog(@"数据库打开成功!");
    } else {
        NSLog(@"数据库打开失败!");
    }
    
    NSString *sql = [NSString stringWithFormat:@"update MyNote set content = '%@', date = '%@' where ID = '%zi'", note.content, note.date, note.ID];
    if ([fmDatabase executeUpdate:sql]) {
        NSLog(@"数据更新成功!");
        
        [fmDatabase close];
    } else {
        NSLog(@"数据更新失败!");
    }
}

- (NSArray *)selectNotes {
    BOOL isOpen = [fmDatabase open];
    if (isOpen) {
        NSLog(@"数据库打开成功!");
    } else {
        NSLog(@"数据库打开失败!");
    }
    
    NSString *sql = @"select * from MyNote";
    FMResultSet *set = [fmDatabase executeQuery:sql];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    while ([set next]) {
        MyNote *tmpNote = [[MyNote alloc] init];
        tmpNote.date = [set stringForColumn:@"date"];
        tmpNote.content = [set stringForColumn:@"content"];
        tmpNote.ID = [set intForColumn:@"ID"];

        [array addObject:tmpNote];
    }
    
    [fmDatabase close];
    return array;
}

- (void)deleteNote:(MyNote *)note {
    BOOL isOpen = [fmDatabase open];
    if (isOpen) {
        NSLog(@"数据库打开成功!");
    } else {
        NSLog(@"数据库打开失败!");
    }
    
    NSString *sql = [NSString stringWithFormat:@"delete from MyNote where date = '%@'", note.date];
    if ([fmDatabase executeUpdate:sql]) {
        NSLog(@"数据删除成功!");
        
        [fmDatabase close];
    } else {
        NSLog(@"数据删除失败!");
    }
}

@end
