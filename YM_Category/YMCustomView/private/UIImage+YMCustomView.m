//
//  UIImage+YMCustomView.m
//  YMCustomView
//
//  Created by 黄玉洲 on 2021/5/19.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import "UIImage+YMCustomView.h"

@implementation UIImage (YMCustomView)

/// 设置UIImage透明度
- (UIImage * _Nonnull (^)(CGFloat))ymAlpha {
    return ^UIImage * (CGFloat alpha){
        UIGraphicsBeginImageContextWithOptions(self.size,NO,0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGRect area = CGRectMake(0,0,self.size.width,self.size.height);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -area.size.height);
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
        CGContextSetAlpha(ctx, alpha);
        CGContextDrawImage(ctx, area,self.CGImage);
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    };
}

@end
