//
//  UIView+YMCategory.h
//  YMCategory
//
//  Created by 海南有趣 on 2020/4/24.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - drawModel
@interface UIViewDrawModel : NSObject

@property (strong, nonatomic) UIColor * strokeColor; // 默认黑色
@property (strong, nonatomic) UIColor * fillColor;   // 默认透明
@property (assign, nonatomic) CGFloat   opacity;     // 不透明读，默认1
@property (assign, nonatomic) CGRect    frame;       // 默认跟随调用视图
@property (assign, nonatomic) CGFloat   borderWidth; // 宽度，默认1
@property (copy, nonatomic)  NSString * lineCap;     // 默认kCALineCapSquare,kCALineCapButt/kCALineCapRound
@property (strong, nonatomic) NSArray <NSNumber *> * lineDashPattern; //  虚线绘画规律，如@[@2, @2]
@property (assign, nonatomic) CGFloat   cornerRadius;// 圆角，默认0

@end

@interface UIView (YMCategory)

@end

#pragma mark - 坐标、尺寸
@interface UIView (Frame)

#pragma mark point
@property (assign, nonatomic) CGPoint origin;
@property (assign, nonatomic, readonly) CGPoint topLeft;
@property (assign, nonatomic, readonly) CGPoint topRight;
@property (assign, nonatomic, readonly) CGPoint bottomLeft;
@property (assign, nonatomic, readonly) CGPoint bottomRight;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@property (assign, nonatomic) CGFloat top;
@property (assign, nonatomic) CGFloat left;
@property (assign, nonatomic) CGFloat bottom;
@property (assign, nonatomic) CGFloat right;

@property (assign, nonatomic, readonly) CGFloat x;
@property (assign, nonatomic, readonly) CGFloat y;

#pragma mark size
@property (assign, nonatomic) CGSize  size;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat width;

#pragma mark transform
/** 在原有的基础上缩放 */
- (void)ymScaleBy:(CGFloat)scaleFactor;

/** 根据给定的尺寸，缩放成最贴近的尺寸 */
- (void)ymFitInSize:(CGSize)aSize;

@end

#pragma mark - 动画
@interface UIView (Animation)

- (void)ymEarthquake;

@end

#pragma mark - 绘图
@interface UIView (Draw)

/**
 对矩形裁剪圆角
 @param radius 半径
 */
- (void)ymDrawRoundWithRadius:(CGFloat)radius;

/**
 对矩形的指定角画圆角
 @param radius 半径
 @param rectCorners 指定角
 */
- (void)ymDrawRoundWithRadius:(CGFloat)radius
                  rectCorners:(UIRectCorner)rectCorners;

/// 绘制边框
/// @param color 边框颜色
/// @param width 边框宽度
- (void)ymDrawBorderWithColor:(UIColor *)color
                        width:(CGFloat)width;

/// 画线
/// @param point1 起点
/// @param point2 终点
/// @param lineColor 线条颜色
/// @param lineWidth 线条宽度
/// @param lineDash  虚线样式（传nil不画虚线）
/// lineDash:
/// CGFloat dash = {10, 10};     绘制10个->跳过10个如此反复
- (void)ymDrawLineWithStartPoint:(CGPoint)point1
                        endPoint:(CGPoint)point2
                       lineColor:(UIColor *)lineColor
                       lineWidth:(CGFloat)lineWidth
                        lineDash:(CGFloat *)lineDash;

/// 画边框虚线
- (void)ymDrawDotted:(UIViewDrawModel *)drawModel;

@end

#pragma mark - 其他
@interface UIView (Other)

/** 当前视图所在的控制器 */
- (UIViewController *)viewController;

/** 删除所有子视图 */
- (void)removeAllChildView;

/** 删除所有子视图包括自己 */
- (void)removeAllView;

@end

NS_ASSUME_NONNULL_END
