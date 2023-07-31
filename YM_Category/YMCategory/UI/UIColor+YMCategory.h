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
 @param colorHex 传入如：@"#FFFFFF"
 @return 转换后的UIColor
 */
+ (UIColor *)colorWithHex:(NSString *)colorHex;

/**
 十六进制颜色转换
 @param colorHex 传入如：@"#FFFFFF"
 @param alpha           透明度0~100
 @return 转换后的UIColor
 */
+ (UIColor *)colorWithHex:(NSString *)colorHex
                    alpha:(CGFloat)alpha;

/** UIColor转换为UIImage */
- (UIImage *)toImage;

/** 获取当前颜色指定alpha的UIColor */
@property (copy, nonatomic) UIColor * (^ymAlpha)(CGFloat);

@end


@interface UIColor (Value)

/** RGB红色值 */
@property (assign, nonatomic, readonly) CGFloat ymRed;

/** RGB绿色值 */
@property (assign, nonatomic, readonly) CGFloat ymGreen;

/** RGB蓝色值 */
@property (assign, nonatomic, readonly) CGFloat ymBlue;

/** RGB透明度 */
@property (assign, nonatomic, readonly) CGFloat ymAlphaValue;

@end
