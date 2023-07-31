//
//  YM_CustomNavigationController.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_CustomNavigationController.h"

@interface YM_CustomNavigationController ()

@end

@implementation YM_CustomNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
}

/** 是否允许自动旋转 */
-(BOOL)shouldAutorotate{
    if (self.isCamera) {
        return NO;
    }
    if (self.supportRotation) {
        return YES;
    }else {
        return NO;
    }
}

/** 支持的方向 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.isCamera) {
        return UIInterfaceOrientationMaskPortrait;
    }
    if (self.supportRotation) {
        return UIInterfaceOrientationMaskAll;
    }else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

@end
