//
//  UIColor+YMCustomView.m
//  YMCustomView
//
//  Created by 黄玉洲 on 2021/5/19.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import "UIColor+YMCustomView.h"

@implementation UIColor (YMCustomView)

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
