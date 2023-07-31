//
//  YQ_Macros.m
//  wujiVPN
//
//  Created by 黄玉洲 on 2019/3/18.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import "YQ_Macros.h"
@interface YQ_Macros ()


@end

@implementation YQ_Macros

#pragma mark - 屏幕大小尺寸相关
/** 判断是否是PhoneX */
+ (BOOL)isPhoneX {
    CGSize compareSize = [UIScreen mainScreen].currentMode.size;
    if (CGSizeEqualToSize(compareSize, CGSizeMake(1125, 2436))) {
        return YES;
    } else if (CGSizeEqualToSize(compareSize, CGSizeMake(1242, 2688))) {
        return YES;
    } else if (CGSizeEqualToSize(compareSize, CGSizeMake(828, 1792))) {
        return YES;
    } else {
        return NO;
    }
}

/** 计算比例 */
+ (CGFloat)ratioSize:(CGFloat)size {
    if (kIsiPad) {
        size = size * 1.3;
        return kScreenWidth / 768.0 * size;
    } else {
        return kScreenWidth / 375.0 * size;
    }
}

/**
 UIFont便利构造
 @param bold 是否加粗
 @param size 大小
 @param isRatio 是否比例化
 @return UIFont
 */
+ (UIFont *)fontWithBold:(BOOL)bold
                    size:(CGFloat)size
                 isRatio:(BOOL)isRatio {
    if (isRatio) {
        size = kRatio(size);
    }
    if (bold) {
        return [UIFont boldSystemFontOfSize:size];
    } else {
        return [UIFont fontWithName:@"PingFang SC" size:size];
    }
}

/**
 UIFont便利构造
 @param bold 是否加粗
 @param fontName 指定字体名
 @param size 大小
 @param isRatio 是否比例化
 @return UIFont
 */
+ (UIFont *)fontWithFontName:(NSString *)fontName
                    size:(CGFloat)size
                 isRatio:(BOOL)isRatio {
    if (isRatio) {
        size = kRatio(size);
    }
    UIFont * font = [UIFont fontWithName:fontName size:size];
    if (!font) {
        font = [self fontWithBold:NO size:size isRatio:isRatio];
    }
    return font;
}



@end
