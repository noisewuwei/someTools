//
//  YM_LoadAnimationView_0.m
//  YM_AnimationView
//
//  Created by huangyuzhou on 2018/9/12.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_LoadAnimationView_0.h"
#define KShapeLayerWidth self.frame.size.width
#define KShapeLayerHeight self.frame.size.height

#define kColors(r, g, b) \
[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]



@interface YM_LoadAnimationView_0 ()

@end

@implementation YM_LoadAnimationView_0


- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _lineWidth = 2;
        _lineBackColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
        _lineColor = [UIColor colorWithRed:0.984 green:0.153 blue:0.039 alpha:1.000];
        _duration = 2;
        _lineDashPattern = nil;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_radius <= 0) {
        _radius = KShapeLayerWidth / 2.0;
    }
    [self layoutView];
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    
    CGRect layerRect = CGRectMake(0, 0, KShapeLayerWidth, KShapeLayerHeight);
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:layerRect cornerRadius:_radius];
    
    // 线条背景
    CAShapeLayer *bottomShapeLayer = [CAShapeLayer layer];
    bottomShapeLayer.strokeColor = _lineBackColor.CGColor;
    bottomShapeLayer.fillColor = [UIColor clearColor].CGColor;
    bottomShapeLayer.lineWidth = _lineWidth;
    bottomShapeLayer.path = bezierPath.CGPath;
    [self.layer addSublayer:bottomShapeLayer];
    
    // 活动线条
    CAShapeLayer *ovalShapeLayer = [CAShapeLayer layer];
    ovalShapeLayer.strokeColor = _lineColor.CGColor;
    ovalShapeLayer.fillColor = [UIColor clearColor].CGColor;
    ovalShapeLayer.lineWidth = _lineWidth;
    ovalShapeLayer.path = bezierPath.CGPath;
    ovalShapeLayer.lineDashPattern = _lineDashPattern; // 分割点效果
    [self.layer addSublayer:ovalShapeLayer];
    
    // 起点动画
    CABasicAnimation * strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.fromValue = @(-1);
    strokeStartAnimation.toValue = @(1);
    
    // 终点动画
    CABasicAnimation * strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.fromValue = @(0.0);
    strokeEndAnimation.toValue = @(1.0);
    
    /// 组合动画
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
    animationGroup.duration = _duration;
    animationGroup.repeatCount = CGFLOAT_MAX;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    [ovalShapeLayer addAnimation:animationGroup forKey:nil];
    
}

@end
