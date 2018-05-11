//
//  MyCell.h
//  MyNoteBook
//
//  Created by Riber on 15/6/24.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCell : UICollectionViewCell <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *deleteImageView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, copy) void(^longPressBlock)();

@property (nonatomic, assign) BOOL isEdit; // 单元格是否处于编辑状态

-(void)startWobble;
-(void)endWobble;

@end
