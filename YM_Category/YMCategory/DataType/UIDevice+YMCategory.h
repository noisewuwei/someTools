//
//  UIDevice+YMCategory.h
//  YMCategory
//
//  Created by 蒋天宝 on 2021/1/4.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YMOrientation) {
    YMOrientation_Veritical,
    YMOrientation_Horizontal,
};

/// 屏幕朝向变化通知
static NSString * ymOrientationDidChangeNotifycation = @"ymOrientationDidChangeNotifycation";

@interface UIDevice (YMCategory)

/// 朝向
@property (assign, nonatomic, class, readonly) YMOrientation ymOrientation;

/// 屏幕宽度
@property (assign, nonatomic, class, readonly) CGFloat screenWidth;

/// 屏幕高度
@property (assign, nonatomic, class, readonly) CGFloat screenHeight;

/// 改变屏幕朝向
/// @param orientation 朝向
/// tip:- (BOOL)shouldAutorotate需要设置为YES
+ (void)ymChangeOrientation:(UIInterfaceOrientation)orientation;

/// 注册屏幕朝向通知
+ (void)registerScreenOrientationNotification;

/// 注销屏幕朝向通知
+ (void)resignerScreenOrientationNotification;

@end

NS_ASSUME_NONNULL_END
