//
//  MyNavController.m
//  MyNoteBook
//
//  Created by riber on 15/11/20.
//  Copyright (c) 2015年 314420972@qq.com. All rights reserved.
//

#import "MyNavController.h"

@interface MyNavController ()

@end

@implementation MyNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
