//
//  UIColor+YMCategory.h
//  DS_Lottery
//
//  Created by huangyuzhou on 2018/9/9.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (YMCategory)

/**
 十六进制颜色转换
 @param stringToConvert 传入如：@"#FFFFFF"
 @return 转换后的UIColor
 */
+ (UIColor *)colorFromHexRGB:(NSString *)stringToConvert;

/**
 十六进制颜色转换
 @param stringToConvert 传入如：@"#FFFFFF"
 @param alpha           透明度0~100
 @return 转换后的UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
                          alpha:(CGFloat)alpha;

- (UIImage *)toImage;

@end
