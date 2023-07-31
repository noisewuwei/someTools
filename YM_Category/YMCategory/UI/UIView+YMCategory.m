//
//  UIView+YMCategory.m
//  YMCategory
//
//  Created by 海南有趣 on 2020/4/24.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import "UIView+YMCategory.h"
#import "UIColor+YMCategory.h"
#pragma mark - YMCategory
@implementation UIView (YMCategory)

@end

#pragma mark - 坐标、尺寸
@implementation UIView (Frame)
#pragma mark point
- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)aPoint {
    CGRect newframe = self.frame;
    newframe.origin = aPoint;
    self.frame = newframe;
}

- (CGPoint)topLeft {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}

- (CGPoint)topRight {
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}

- (CGPoint)bottomRight {
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)bottomLeft {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGFloat)centerX {
    return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}
- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)newtop {
    CGRect newframe = self.frame;
    newframe.origin.y = newtop;
    self.frame = newframe;
}


- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)newleft {
    CGRect newframe = self.frame;
    newframe.origin.x = newleft;
    self.frame = newframe;
}


- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)newbottom {
    CGRect newframe = self.frame;
    newframe.origin.y = newbottom - self.frame.size.height;
    self.frame = newframe;
}


- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)newright {
    CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

- (CGFloat)x {
    return self.left;
}

- (CGFloat)y {
    return self.top;
}

#pragma mark size
- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)aSize {
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newheight {
    CGRect newframe = self.frame;
    newframe.size.height = newheight;
    self.frame = newframe;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newwidth {
    CGRect newframe = self.frame;
    newframe.size.width = newwidth;
    self.frame = newframe;
}


#pragma mark transform
/** 在原有的基础上缩放 */
- (void)ymScaleBy:(CGFloat)scaleFactor {
    CGRect newframe = self.frame;
    newframe.size.width *= scaleFactor;
    newframe.size.height *= scaleFactor;
    self.frame = newframe;
}

/** 根据给定的尺寸，缩放成最贴近的尺寸 */
- (void)ymFitInSize:(CGSize)aSize {
    CGFloat scale;
    CGRect newframe = self.frame;
    
    if (newframe.size.height && (newframe.size.height > aSize.height)) {
        scale = aSize.height / newframe.size.height;
        newframe.size.width *= scale;
        newframe.size.height *= scale;
    }
    
    if (newframe.size.width && (newframe.size.width >= aSize.width)) {
        scale = aSize.width / newframe.size.width;
        newframe.size.width *= scale;
        newframe.size.height *= scale;
    }
    
    self.frame = newframe;
}

@end

#pragma mark - 动画
@implementation UIView (Animation)

/** 震动效果 */
- (void)ymEarthquake {
    CGFloat t = 2.0;
    
    CGAffineTransform leftQuake  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,-t);
    CGAffineTransform rightQuake =CGAffineTransformTranslate(CGAffineTransformIdentity,-t, t);
    
    self.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(self)];
    [UIView setAnimationRepeatAutoreverses:YES];// important
    [UIView setAnimationRepeatCount:5];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    self.transform = rightQuake;// end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)earthquakeEnded:(NSString*)animationID
               finished:(NSNumber*)finished
                context:(void*)context {
    if([finished boolValue]) {
        UIView* item =(__bridge UIView*)context;
        item.transform =CGAffineTransformIdentity;
    }
}

@end

#pragma mark - 绘图
@implementation UIView (Draw)
/**
 对矩形裁剪圆角
 @param radius 半径
 */
- (void)ymDrawRoundWithRadius:(CGFloat)radius {
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                byRoundingCorners:UIRectCornerAllCorners
                                                      cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    self.layer.mask = maskLayer;
}

/**
 对矩形的指定角画圆角
 @param radius 半径
 @param rectCorners 指定角
 */
- (void)ymDrawRoundWithRadius:(CGFloat)radius
                  rectCorners:(UIRectCorner)rectCorners {
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                byRoundingCorners:rectCorners
                                                      cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    self.layer.mask = maskLayer;
}

/// 绘制边框
/// @param color 边框颜色
/// @param width 边框宽度
- (void)ymDrawBorderWithColor:(UIColor *)color
                        width:(CGFloat)width {
    // 获取视图的绘图路线
    CAShapeLayer * shapeLayer = nil;
    if ([self.layer.mask isKindOfClass:[CAShapeLayer class]]) {
        shapeLayer = self.layer.mask;
    }
    // 如果没有就采用矩形图形路线
    else {
        UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:self.bounds];
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bezierPath.CGPath;
    }
    
    // 开始画边框
    CAShapeLayer * borderLayer = [CAShapeLayer layer];
    borderLayer.frame = CGRectMake(0, 0, self.width, self.height);
    borderLayer.lineWidth = width;
    borderLayer.strokeColor = color.CGColor;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.path = shapeLayer.path;

    [self.layer insertSublayer:borderLayer atIndex:0];
}

/// 画线
/// @param point1 起点
/// @param point2 终点
/// @param lineColor 线条颜色
/// @param lineWidth 线条宽度
/// @param lineDash  虚线样式（传nil不画虚线）
/// lineDash:
/// CGFloat dash = {10, 10};     绘制10个->跳过10个如此反复
/// CGFloat dash = {10, 20, 10}; 绘制10个->跳过20个->绘制10个->跳过10个如此反复
- (void)ymDrawLineWithStartPoint:(CGPoint)point1
                        endPoint:(CGPoint)point2
                       lineColor:(UIColor *)lineColor
                       lineWidth:(CGFloat)lineWidth
                        lineDash:(CGFloat *)lineDash {

    // 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 线宽
    CGContextSetLineWidth(context, lineWidth);  //线宽
    
    // 线条颜色
    CGContextSetRGBStrokeColor(context, lineColor.ymRed / 255.0,
                                        lineColor.ymGreen / 255.0,
                                        lineColor.ymBlue / 255.0,
                                        1.0);
    
    // 开始绘图
    CGContextBeginPath(context);
    
    // 线条起点
    CGContextMoveToPoint(context, point1.x, point1.y);
    
    // 线条终点
    CGContextAddLineToPoint(context, point2.x, point2.y);
    
    // 虚线
    if (lineDash) {
        // 虚线的参数：
        // phase:   相位，虚线的起始位置＝通常使用 0 即可，从头开始画虚线
        // lengths: 长度的数组
        // count:   lengths 数组的个数
        CGContextSetLineDash(context, 0, lineDash, 1);
    }

    // 绘制线条
    CGContextStrokePath(context);
    
    //    //设置线条顶点样式
    //    CGContextSetLineCap(context, kCGLineCapRound);
    //    //设置连接点的样式
    //    CGContextSetLineJoin(context, kCGLineJoinRound);
}

/// 画边框虚线
- (void)ymDrawDotted:(UIViewDrawModel *)drawModel {
    if (drawModel.frame.size.width == 0 || drawModel.frame.size.height == 0) {
        drawModel.frame = self.bounds;
    }
    
    CAShapeLayer * border = [CAShapeLayer layer];
    border.strokeColor = drawModel.strokeColor.CGColor;
    border.fillColor = drawModel.fillColor.CGColor;
    border.path = [UIBezierPath bezierPathWithRoundedRect:drawModel.frame cornerRadius:drawModel.cornerRadius].CGPath;
    border.frame = drawModel.frame;
    border.lineWidth = drawModel.borderWidth;
    border.lineCap = drawModel.lineCap;
    border.lineDashPattern = drawModel.lineDashPattern;
    border.opacity = drawModel.opacity;
    [self.layer addSublayer:border];
}

@end

#pragma mark - 其他
@implementation UIView (Other)

/** 当前视图所在的控制器 */
- (UIViewController *)viewController {
    UIResponder * next = self.nextResponder;
    while (next != nil) {
        if ([next isKindOfClass:[UIViewController class]])
        {
            
            return (UIViewController *)next;
        }
        
        next = next.nextResponder;
    }
    
    return nil;
}

/** 删除所有子视图 */
- (void)removeAllChildView {
    [UIView removeAllChildViewInChildViews:self.subviews];
}

/** 删除所有子视图包括自己 */
- (void)removeAllView {
    [UIView removeAllChildViewInChildViews:self.subviews];
    [self removeFromSuperview];
}

/** 删除数组中所有的视图 */
+ (void)removeAllChildViewInChildViews:(NSArray *)childViews {
    if ([childViews count] > 0) {
        for (UIView * childView in childViews) {
            [childView removeFromSuperview];
        }
    }
}

@end


#pragma mark - drawModel
@implementation UIViewDrawModel

- (instancetype)init {
    if (self = [super init]) {
        _strokeColor = [UIColor blackColor];
        _fillColor = [UIColor clearColor];
        _borderWidth = 1;
        _lineCap = kCALineCapSquare;
        _opacity = 1;
    }
    return self;
}

@end
