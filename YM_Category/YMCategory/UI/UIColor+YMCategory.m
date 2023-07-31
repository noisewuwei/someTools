//
//  UIColor+YMCategory.m
//  DS_Lottery
//
//  Created by huangyuzhou on 2018/9/9.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "UIColor+YMCategory.h"

@implementation UIColor (YMCategory)

/**
 十六进制颜色转换
 @param colorHex 传入如：@"#FFFFFF"
 @return 转换后的UIColor
 */
+ (UIColor *)colorWithHex:(NSString *)colorHex {
    NSString *cString = [[colorHex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6)
        return [UIColor whiteColor];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor whiteColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

/**
 十六进制颜色转换
 @param colorHex 传入如：@"#FFFFFF"
 @param alpha           透明度0~100
 @return 转换后的UIColor
 */
+ (UIColor *)colorWithHex:(NSString *)colorHex
                    alpha:(CGFloat)alpha {
    //删除字符串中的空格
    NSString *cString = [[colorHex
                          stringByTrimmingCharactersInSet:[NSCharacterSet
                                                           whitespaceAndNewlineCharacterSet]]
                         uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6) {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    // r
    NSString *rString = [cString substringWithRange:range];
    // g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    // b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:alpha];
}

/** UIColor转换为UIImage */
- (UIImage *)toImage {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@dynamic ymAlpha;
/** 获取当前颜色指定alpha的UIColor */
- (UIColor *(^)(CGFloat))ymAlpha {
    return ^UIColor * (CGFloat alpha) {
        UIColor * color = [self colorWithAlphaComponent:alpha];
        return color;
    };
}

@end


@implementation UIColor (Value)
/// 获取RGB红色值
- (CGFloat)ymRed {
    CGFloat red;
    [self getRed:&red green:nil blue:nil alpha:nil];
    return red * 255.0;
}

/// 获取RGB绿色值
- (CGFloat)ymGreen {
    CGFloat green;
    [self getRed:nil green:&green blue:nil alpha:nil];
    return green * 255.0;
}

/// 获取RGB蓝色值
- (CGFloat)ymBlue {
    CGFloat blue;
    [self getRed:nil green:nil blue:&blue alpha:nil];
    return blue * 255.0;
}

/// 获取RGB透明度
- (CGFloat)ymAlphaValue {
    CGFloat alpha;
    [self getRed:nil green:nil blue:nil alpha:&alpha];
    return alpha;
    
}

@end
