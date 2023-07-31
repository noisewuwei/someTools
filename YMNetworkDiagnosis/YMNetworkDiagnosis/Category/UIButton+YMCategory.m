//
//  UIButton+YMCategory.m
//  YM_Category
//
//  Created by huangyuzhou on 2018/9/4.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "UIButton+YMCategory.h"
#import "UIColor+YMCategory.h"
@implementation UIButton (YMCategory)

/**
 便利构造
 @param buttonType 按钮类型
 @param isSetup 是否设置默认高亮标题颜色
 @return UIButton
 */
+ (instancetype)buttonWithType:(UIButtonType)buttonType
              isSetupHighlight:(BOOL)isSetup {
    UIButton * button = [UIButton buttonWithType:buttonType];
    if (isSetup) {
        UIColor * color = [UIColor grayColor];
//        UIColor * color = [UIColor colorFromHexRGB:@"#AE8240"];
        [button setTitleColor:color
                     forState:UIControlStateHighlighted];
    }
    return button;
}

#pragma mark - 按钮图文偏移
/**
 利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
 @param spacing 图片和文字的间隔
 */
- (void)setImagePosition:(YM_ImagePosition)postion
                 spacing:(CGFloat)spacing {
    CGFloat imgW = self.imageView.image.size.width;
    CGFloat imgH = self.imageView.image.size.height;
    CGSize origLabSize = self.titleLabel.bounds.size;
    CGFloat orgLabW = origLabSize.width;
    CGFloat orgLabH = origLabSize.height;
    CGSize trueSize = [self.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGFloat trueLabW = trueSize.width;
    //image中心移动的x距离
    CGFloat imageOffsetX = orgLabW/2 ;
    //image中心移动的y距离
    CGFloat imageOffsetY = orgLabH/2 + spacing/2;
    //label左边缘移动的x距离
    CGFloat labelOffsetX1 = imgW/2 - orgLabW/2 + trueLabW/2;
    //label右边缘移动的x距离
    CGFloat labelOffsetX2 = imgW/2 + orgLabW/2 - trueLabW/2;
    //label中心移动的y距离
    CGFloat labelOffsetY = imgH/2 + spacing/2;
    switch (postion) {
        case YM_ImagePosition_Left:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2, 0, spacing/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, -spacing/2);
            break;
        case YM_ImagePosition_Right:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, orgLabW + spacing/2, 0, -(orgLabW + spacing/2));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imgW + spacing/2), 0, imgW + spacing/2);
            break;
        case YM_ImagePosition_Top:
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX1, -labelOffsetY, labelOffsetX2);
            break;
        case YM_ImagePosition_Bottom:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -labelOffsetX1, labelOffsetY, labelOffsetX2);
            break;
        default: break;
            
    }
}

#pragma mark - 设置
/** 设置默认状态和高亮状态图标 */
- (void)setNormalImage:(UIImage *)normalImage highLightImage:(UIImage *)highLightImage {
    [self setImage:normalImage forState:UIControlStateNormal];
    [self setImage:highLightImage forState:UIControlStateHighlighted];
}


@end
