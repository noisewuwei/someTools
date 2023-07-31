//
//  YM_BaseTool.m
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import "YM_BaseTool.h"


@interface YM_BaseTool ()

@property (assign, nonatomic) CGFloat navigationBarHeight;
@property (assign, nonatomic) UIDeviceOrientation orientationEnum;

@end

@implementation YM_BaseTool

static YM_BaseTool * instance = nil;
+ (YM_BaseTool *)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [YM_BaseTool new];
    });
    return instance;
}

#pragma mark - 机型判断
/** 判断是否是PhoneX */
+ (BOOL)isiPhoneX {
    CGSize compareSize = [UIScreen mainScreen].currentMode.size;
    //  iPhoneX、iPhoneXs、iPhoneXs Max
    if (CGSizeEqualToSize(compareSize, CGSizeMake(1125, 2436)) ||
        CGSizeEqualToSize(compareSize, CGSizeMake(2436, 1125))) {
        return YES;
    }
    // iPhone Xr
    else if (CGSizeEqualToSize(compareSize, CGSizeMake(750, 1624)) ||
             CGSizeEqualToSize(compareSize, CGSizeMake(1624, 750))) {
        return YES;
    } else if (CGSizeEqualToSize(compareSize, CGSizeMake(1242, 2688)) ||
               CGSizeEqualToSize(compareSize, CGSizeMake(2688, 1242))) {
        return YES;
    } else if (CGSizeEqualToSize(compareSize, CGSizeMake(828, 1792)) ||
               CGSizeEqualToSize(compareSize, CGSizeMake(1792, 828))) {
        return YES;
    } else {
        return NO;
    }
}

/** 获取安全区域 */
+ (CGFloat)safeAreaBottom {
    if (@available(iOS 11.0, *)) {
        return UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    } else {
        return 0;
    }
}

/**
 获取屏幕快照
 @param view 指定视图的屏幕快照
 @return 屏幕快照
 */
+ (UIImage *)screenShot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ymScreenWidth, ymScreenHeight), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

#pragma mark - 字体大小
+ (UIFont *)font:(CGFloat)fontSzie {
    if (ymIsiPad) {
        fontSzie += 3;
    } else {
        fontSzie = ymRatio(fontSzie);
    }

    if (bold) {
        return [UIFont boldSystemFontOfSize:fontSzie];
    } else {
        return [UIFont fontWithName:@"PingFang SC" size:fontSzie];
    }
}

+ (BOOL)isVertical {
    return ymScreenHeight > ymScreenWidth;
    UIDeviceOrientation orientationEnum = [UIDevice currentDevice].orientation;
    switch (orientationEnum) {
        case UIDeviceOrientationUnknown: [self share].orientationEnum = orientationEnum; return YES;
        case UIDeviceOrientationPortrait: [self share].orientationEnum = orientationEnum; return YES;
        case UIDeviceOrientationPortraitUpsideDown: [self share].orientationEnum = orientationEnum; return YES;
        case UIDeviceOrientationLandscapeLeft: [self share].orientationEnum = orientationEnum; return NO;
        case UIDeviceOrientationLandscapeRight: [self share].orientationEnum = orientationEnum; return NO;
        case UIDeviceOrientationFaceUp: {
            if ([self share].orientationEnum == UIDeviceOrientationLandscapeLeft ||
                [self share].orientationEnum == UIDeviceOrientationLandscapeRight) {
                return NO;
            } else {
                return YES;
            }
        }
        case UIDeviceOrientationFaceDown: {
            if ([self share].orientationEnum == UIDeviceOrientationLandscapeLeft ||
                [self share].orientationEnum == UIDeviceOrientationLandscapeRight) {
                return NO;
            } else {
                return YES;
            }
        }
    }
}

#pragma mark - 计算比例
+ (CGFloat)ratioSize:(CGFloat)size {
    if (ymIsiPad) {
        size = size / 2.0;
    }
    // 竖屏
    CGFloat percentage = 0;
    if ([self isVertical]) {
//        percentage = kIsPad ? size / 768.0 : size / 375.0;
        percentage = size / 375.0;
    }
    // 横屏
    else {
//        percentage = kIsPad ? size / 1024 : size / 667.0;
        percentage = size / 667.0;
    }
    return percentage * ymScreenWidth;
    
}

@end
