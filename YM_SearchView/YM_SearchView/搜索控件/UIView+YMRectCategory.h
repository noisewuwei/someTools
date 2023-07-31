//
//  UIView+YMCategory.h
//  YM_Category
//
//  Created by huangyuzhou on 2018/9/9.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YMCategory)

@end

#pragma mark - UIView 坐标相关类目
CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);
@interface UIView (YMRectCategory)

@property CGPoint origin;
@property CGSize size;


@property (nonatomic ,assign) CGFloat x;
@property (nonatomic ,assign) CGFloat y;

@property (nonatomic ,assign) CGFloat centerX;
@property (nonatomic ,assign) CGFloat centerY;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;
- (void)earthquake:(UIView*)itemView;

- (UIViewController *)viewController;


/** 删除所有子视图 */
- (void)removeAllChildView;

/** 删除所有子视图包括自己 */
- (void)removeAllView;

@end

#pragma mark - UIView 画图相关类目
@interface UIView (YMDrawRectCategory)

/**
 对矩形裁剪圆角
 @param radius 半径
 */
- (void)drawRoundWithRadius:(CGFloat)radius;

/**
 对矩形的指定角画圆角
 @param radius 半径
 @param rectCorners 指定角
 */
- (void)drawRoundWithRadius:(CGFloat)radius
                rectCorners:(UIRectCorner)rectCorners;

@end


#pragma mark - layer操作
@interface UIView (YMLayerCategory)

/** 恢复动画 */
- (void)resumeAnimation;

/** 暂停动画 */
- (void)pauseAnimation;

@end
