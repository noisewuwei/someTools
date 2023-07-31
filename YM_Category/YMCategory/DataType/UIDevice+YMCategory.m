//
//  UIDevice+YMCategory.m
//  YMCategory
//
//  Created by 蒋天宝 on 2021/1/4.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import "UIDevice+YMCategory.h"
#import "NSObject+YMCategory.h"

@interface UIDevice ()

/// 朝向
@property (assign, nonatomic, class) YMOrientation ymOrientation;

/// 屏幕宽度
@property (assign, nonatomic, class) CGFloat screenWidth;

/// 屏幕高度
@property (assign, nonatomic, class) CGFloat screenHeight;

@end

@implementation UIDevice (YMCategory)

/// 改变屏幕朝向
/// @param orientation 朝向
/// tip:- (BOOL)shouldAutorotate需要设置为YES
+ (void)ymChangeOrientation:(UIInterfaceOrientation)orientation {
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:(int)orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

#pragma mark 通知
/// 注册屏幕朝向通知
+ (void)registerScreenOrientationNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

+ (void)orientationDidChange {
    if ([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height) {
        self.ymOrientation = YMOrientation_Horizontal;
    } else {
        self.ymOrientation = YMOrientation_Veritical;
    }
    NSLog(@"%d %d", [UIDevice currentDevice].orientation, self.ymOrientation);
    
//    UIDeviceOrientationUnknown = 0;
//    UIDeviceOrientationPortrait = 1;
//    UIDeviceOrientationPortraitUpsideDown = 2;
//    UIDeviceOrientationLandscapeLeft = 3;
//    UIDeviceOrientationLandscapeRight = 4;
//    UIDeviceOrientationFaceUp = 5;
//    UIDeviceOrientationFaceDown = 6;
}

/// 注销屏幕朝向通知
+ (void)resignerScreenOrientationNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark getter
static char kYmOrientation;
+ (YMOrientation)ymOrientation {
    return [self.getClassProperty(&kYmOrientation) integerValue];
}

#pragma mark setter
+ (void)setYmOrientation:(YMOrientation)ymOrientation {
    self.setClassProperty(&kYmOrientation, @(ymOrientation));
}


@end
