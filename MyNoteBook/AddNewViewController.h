//
//  AddNewViewController.h
//  MyNoteBook
//
//  Created by Riber on 15/6/25.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddNewViewController;

@protocol sendNoteToMain <NSObject>

@required

- (void)sendNoteToMain:(AddNewViewController *)addVC;

@end

@interface AddNewViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, assign) id<sendNoteToMain> delegate;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintLeft;

@end
