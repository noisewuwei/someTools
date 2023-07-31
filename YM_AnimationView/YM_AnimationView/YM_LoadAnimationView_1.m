//
//  YM_LoadAnimationView_1.m
//  YM_AnimationView
//
//  Created by huangyuzhou on 2018/9/12.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_LoadAnimationView_1.h"

@interface YM_LoadAnimationView_1 ()
{
    CGFloat _width;
    CGFloat _height;
    
    // 半径
    CGFloat _radius;
}
@property (nonatomic, strong) CAShapeLayer *indefiniteAnimatedLayer;

@end

@implementation YM_LoadAnimationView_1

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
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
    [self.layer addSublayer:self.indefiniteAnimatedLayer];
    [self startAnimation];
}

#pragma mark - 动画
- (void)startAnimation {
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
    
    // 旋转蒙版
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = (id) 0;
    animation.toValue = @(M_PI*2);
    animation.duration = _duration;
    animation.timingFunction = linearCurve;
    animation.removedOnCompletion = NO;
    animation.repeatCount = INFINITY;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    [_indefiniteAnimatedLayer.mask addAnimation:animation forKey:@"rotate"];
    
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.fromValue = @0.015;
    strokeStartAnimation.toValue = @0.515;
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.fromValue = @0.485;
    strokeEndAnimation.toValue = @0.985;
    
    // 组合动画
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = _duration;
    animationGroup.repeatCount = INFINITY;
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = linearCurve;
    animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
    [_indefiniteAnimatedLayer addAnimation:animationGroup forKey:@"progress"];
}


#pragma mark - getter
- (CAShapeLayer*)indefiniteAnimatedLayer {
    if(!_indefiniteAnimatedLayer) {
        CGPoint arcCenter = CGPointMake(_width / 2.0,
                                        _height / 2.0);
        UIBezierPath * bezierPath =
        [UIBezierPath bezierPathWithArcCenter:arcCenter
                                       radius:_radius
                                   startAngle:(CGFloat) (M_PI*3/2)
                                     endAngle:(CGFloat) (M_PI/2+M_PI*5)
                                    clockwise:YES];
        
        _indefiniteAnimatedLayer = [CAShapeLayer layer];
        _indefiniteAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];

        _indefiniteAnimatedLayer.frame = CGRectMake(0.0f, 0.0f, arcCenter.x*2, arcCenter.y*2);
        _indefiniteAnimatedLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _indefiniteAnimatedLayer.position = CGPointMake(_width / 2, _height / 2);
        _indefiniteAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
        _indefiniteAnimatedLayer.strokeColor = _lineColor.CGColor;
        _indefiniteAnimatedLayer.lineWidth = _lineWidth;
        
        // 线头形状
        switch (_lineCap) {
            case kLineCap_Butt:
                _indefiniteAnimatedLayer.lineCap = kCALineCapButt;
                break;
            case kLineCap_Round:
                _indefiniteAnimatedLayer.lineCap = kCALineCapRound;
                break;
            case kLineCap_Square:
                _indefiniteAnimatedLayer.lineCap = kCALineCapSquare;
                break;
        }
        
        // 线条拐角
        _indefiniteAnimatedLayer.lineJoin = kCALineJoinRound;
        _indefiniteAnimatedLayer.lineDashPattern = _lineDashPattern; // 分割点效果
        _indefiniteAnimatedLayer.path = bezierPath.CGPath;
        
        // 添加蒙层
        CALayer *maskLayer = [CALayer layer];
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"angle-mask"] CGImage];
        maskLayer.frame = CGRectMake(0,0, _width, _height);
        _indefiniteAnimatedLayer.mask = maskLayer;
    }
    return _indefiniteAnimatedLayer;
}

@end
