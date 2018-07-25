//
//  MyCell.m
//  MyNoteBook
//
//  Created by Riber on 15/6/24.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//

#import "MyCell.h"

@implementation MyCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    // 给cell添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.minimumPressDuration = 1;
    [self addGestureRecognizer:longPress];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
//        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定删除" otherButtonTitles:@"多选删除", nil];
//        [sheet showInView:self];
        if (self.longPressBlock) {
            self.longPressBlock();
        }
    }
}

// 删除
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//       if (self.longPressBlock) {
//        self.longPressBlock(buttonIndex);
//    }
//}

-(void)startWobble {
    self.deleteImageView.hidden = NO;
    srand([[NSDate date] timeIntervalSince1970]);
    float rand=(float)random();
    CFTimeInterval t=rand*0.0000000001;
    [UIView animateWithDuration:0.1 delay:t options:0  animations:^ {
         self.transform=CGAffineTransformMakeRotation(-0.05);
     } completion:^(BOOL finished) {
         [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction  animations:^ {
              self.transform=CGAffineTransformMakeRotation(0.05);
          } completion:nil];
     }];
}

-(void)endWobble {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^ {
         self.transform=CGAffineTransformIdentity;
         self.deleteImageView.hidden = YES;
     } completion:nil];
}

@end
