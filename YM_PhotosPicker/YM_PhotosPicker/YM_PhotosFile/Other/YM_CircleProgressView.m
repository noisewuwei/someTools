//
//  YM_CircleProgressView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_CircleProgressView.h"

@interface YM_CircleProgressView ()

/** 外界圆形 */
@property (nonatomic, strong) CAShapeLayer *circleLayer;

/** 内部扇形 */
@property (nonatomic, strong) CAShapeLayer *fanshapedLayer;

/** 错误 */
@property (nonatomic, strong) CAShapeLayer *errorLayer;

@end

@implementation YM_CircleProgressView


- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        CGRect rect = self.frame;
        rect.size = CGSizeMake(50, 50);
        self.frame = rect;
        [self layoutView];
    }
    return self;
}


#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    self.backgroundColor = [UIColor clearColor];
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.strokeColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8].CGColor;
    circleLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
    circleLayer.path = [self circlePath].CGPath;
    [self.layer addSublayer:circleLayer];
    self.circleLayer = circleLayer;
    
    CAShapeLayer *fanshapedLayer = [CAShapeLayer layer];
    fanshapedLayer.fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8].CGColor;
    [self.layer addSublayer:fanshapedLayer];
    self.fanshapedLayer = fanshapedLayer;
    
    CAShapeLayer *errorLayer = [CAShapeLayer layer];
    errorLayer.frame = self.bounds;
    errorLayer.hidden = YES;
    // 旋转 45 度
    errorLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_4);
    errorLayer.fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8].CGColor;
    errorLayer.path = [self errorPath].CGPath;
    [self.layer addSublayer:errorLayer];
    self.errorLayer = errorLayer;
}

#pragma mark - other
- (void)showError {
    self.errorLayer.hidden = false;
    self.fanshapedLayer.hidden = true;
}

- (void)updateProgressLayer {
    self.errorLayer.hidden = true;
    self.fanshapedLayer.hidden = false;
    
    self.fanshapedLayer.path = [self pathForProgress:self.progress].CGPath;
}


#pragma mark - setter
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self updateProgressLayer];
}

#pragma mark - getter
- (UIBezierPath *)errorPath {
    CGFloat width = 30;
    CGFloat height = 5;
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRect:CGRectMake(self.frame.size.width * 0.5 - height * 0.5, (self.frame.size.width - width) * 0.5, height, width)];
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRect:CGRectMake((self.frame.size.width - width) * 0.5, self.frame.size.width * 0.5 - height * 0.5, width, height)];
    [path2 appendPath:path1];
    return path2;
}

- (UIBezierPath *)circlePath {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:25 startAngle:0 endAngle:M_PI * 2 clockwise:true];
    path.lineWidth = 1;
    return path;
}

- (UIBezierPath *)pathForProgress:(CGFloat)progress {
    CGPoint center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGFloat radius = self.frame.size.height * 0.5 - 2.5;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint: center];
    [path addLineToPoint:CGPointMake(self.frame.size.width * 0.5, center.y - radius)];
    [path addArcWithCenter:center radius: radius startAngle: -M_PI / 2 endAngle: -M_PI / 2 + M_PI * 2 * progress clockwise:true];
    [path closePath];
    path.lineWidth = 1;
    return path;
}


@end
