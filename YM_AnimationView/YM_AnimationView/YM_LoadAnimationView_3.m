//
//  YM_LoadAnimationView_3.m
//  YM_AnimationView
//
//  Created by huangyuzhou on 2018/9/12.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_LoadAnimationView_3.h"

@interface YM_LoadAnimationView_3 ()
{
    CGFloat _width;
    CGFloat _height;
    
    // 半径
    CGFloat _radius;
}

@end

@implementation YM_LoadAnimationView_3


- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _lineWidth = 2;
        _lineColor = [UIColor colorWithRed:0.984 green:0.153 blue:0.039 alpha:1.000];
        _duration = 2;
        _lineDashPattern = nil;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _width = self.bounds.size.width;
    _height = self.bounds.size.height;
    _radius = _height / 2.0 - 5;
    [self layoutView];
}


#pragma mark - 界面
- (void)layoutView {
    // 获取圆
    CGPoint arcCenter = CGPointMake(_width / 2.0, _height / 2.0);
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:_radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = CGRectMake(0, 0, _width, _height);
    shapeLayer.anchorPoint = CGPointMake(0.5, 0.5);
    shapeLayer.position = CGPointMake(_width / 2.0, _height / 2.0);
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.lineWidth = _lineWidth;
    shapeLayer.strokeColor = _lineColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    // 线头形状
    switch (_lineCap) {
        case kLineCap_Butt:
            shapeLayer.lineCap = kCALineCapButt;
            break;
        case kLineCap_Round:
            shapeLayer.lineCap = kCALineCapRound;
            break;
        case kLineCap_Square:
            shapeLayer.lineCap = kCALineCapSquare;
            break;
    }
    [self.layer addSublayer:shapeLayer];
    
    
    NSString * timingFunctionName = @"";
    switch (_timingFunction) {
        case kTimingFunction_Linear:
            timingFunctionName = kCAMediaTimingFunctionLinear;
            break;
        case kTimingFunction_EaseIn:
            timingFunctionName = kCAMediaTimingFunctionEaseIn;
            break;
        case kTimingFunction_EaseOut:
            timingFunctionName = kCAMediaTimingFunctionEaseOut;
            break;
        case kTimingFunction_EaseInEaseOut:
            timingFunctionName = kCAMediaTimingFunctionEaseInEaseOut;
            break;
    }
    CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:timingFunctionName];
    
    CABasicAnimation * animation1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation1.fromValue = @(0);
    animation1.toValue = @(1);
    animation1.duration = _duration;
    animation1.timingFunction = linearCurve;
    animation1.repeatCount = MAXFLOAT;
    animation1.removedOnCompletion = NO;
    animation1.autoreverses = YES;
    [shapeLayer addAnimation:animation1 forKey:@"strokeEnd"];
    
    CABasicAnimation * animation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation2.duration = 1;
    animation2.toValue = @(-M_PI * 2);
    animation2.timingFunction = linearCurve;
    animation2.repeatCount = MAXFLOAT;
    animation2.removedOnCompletion = NO;
    [self.layer addAnimation:animation2 forKey:@"transform.rotation.z"];
    
}


@end
