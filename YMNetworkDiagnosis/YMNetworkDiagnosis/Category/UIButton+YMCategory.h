//
//  UIButton+YMCategory.h
//  YM_Category
//
//  Created by huangyuzhou on 2018/9/4.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YM_ImagePosition) {
    /** 图片在左，文字在右，默认 */
    YM_ImagePosition_Left = 0,
    /** 图片在右，文字在左 */
    YM_ImagePosition_Right = 1,
    /** 图片在上，文字在下 */
    YM_ImagePosition_Top = 2,
    /** 图片在下，文字在上 */
    YM_ImagePosition_Bottom = 3,
};

@interface UIButton (YMCategory)

/**
 便利构造
 @param buttonType 按钮类型
 @param isSetup 是否设置默认高亮标题颜色
 @return UIButton
 */
+ (instancetype)buttonWithType:(UIButtonType)buttonType
              isSetupHighlight:(BOOL)isSetup;

#pragma mark - 按钮图文偏移
/**
 利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
 注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
 @param spacing 图片和文字的间隔
 */
- (void)setImagePosition:(YM_ImagePosition)postion
                 spacing:(CGFloat)spacing;

#pragma mark - 设置
/** 设置默认状态和高亮状态图标 */
- (void)setNormalImage:(UIImage *)normalImage highLightImage:(UIImage *)highLightImage;

@end
