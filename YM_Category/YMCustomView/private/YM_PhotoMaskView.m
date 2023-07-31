//
//  YM_PhotoMaskView.m
//  ToDesk-iOS
//
//  Created by 蒋天宝 on 2021/2/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YM_PhotoMaskView.h"

@interface YM_PhotoMaskView () {
    CGRect  _squareRect;   // 外切正方形
    CGFloat _cropWidth;
    CGFloat _cropHeight;
    
    CGFloat _cropSize;      // 圆形截图区域大小
    UIColor * _shadowColor; // 阴影色
    CGFloat   _shadowAlpha; // 阴影透明度
    UIColor * _borderColor; // 边框线颜色
}


/// 圆圈
@property (strong, nonatomic) UIView * viewMask;

/// 边框
@property (strong, nonatomic) UIView * borderView;

@end

@implementation YM_PhotoMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame cropSize:(CGFloat)cropSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        _cropSize = cropSize;
        _lineDashPattern = @[@1, @0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!_viewMask) {
        [self layoutView];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoMaskView:scrollViewRect:)]) {
        CGRect rect = CGRectMake((rect.size.width - _cropSize) / 2.0, (rect.size.height - _cropSize) / 2.0, _cropSize, _cropSize);
        [self.delegate photoMaskView:self scrollViewRect:rect];
    }
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    [self addSubview:self.viewMask];
    [self addSubview:self.borderView];
}

#pragma mark setter
- (void)setBackColor:(UIColor *)backColor {
    if (backColor) {
        _backColor = backColor;
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (shadowColor) {
        _shadowColor = shadowColor;
    }
}

- (void)setShadowAlpha:(CGFloat)shadowAlpha {
    _shadowAlpha = shadowAlpha;
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (borderColor) {
        _borderColor = borderColor;
    }
}

- (void)setLineDashPattern:(NSArray<NSNumber *> *)lineDashPattern {
    if (lineDashPattern) {
        _lineDashPattern = lineDashPattern;
    }
}

#pragma mark 懒加载
- (UIView *)viewMask {
    if (!_viewMask) {
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = _shadowColor;
        view.alpha = _shadowAlpha;
        view.userInteractionEnabled = NO;
        
        // 镂空圆形
        CGRect rect = self.bounds;
        UIBezierPath *mainPath = [UIBezierPath bezierPathWithRect:rect];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((rect.size.width - _cropSize) / 2.0, (rect.size.height - _cropSize) / 2.0, _cropSize, _cropSize) cornerRadius:_cropSize / 2];
        [mainPath appendPath:[path bezierPathByReversingPath]];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = mainPath.CGPath;
        view.layer.mask = shapeLayer;
        
        _viewMask = view;
    }
    return _viewMask;
}

- (UIView *)borderView {
    if (!_borderView) {
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.userInteractionEnabled = NO;
        view.hidden = !_borderColor;
        
        if (_borderColor) {
            CGRect rect = self.bounds;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((rect.size.width - _cropSize) / 2.0, (rect.size.height - _cropSize) / 2.0, _cropSize, _cropSize) cornerRadius:_cropSize / 2.0];
            
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = path.CGPath;
            [shapeLayer setFillColor:[UIColor clearColor].CGColor];
            [shapeLayer setStrokeColor:_borderColor.CGColor];
            [shapeLayer setLineWidth:1];
            shapeLayer.lineDashPattern = _lineDashPattern;
            shapeLayer.lineCap = @"square";
            [view.layer addSublayer:shapeLayer];
        }
        
        _borderView = view;
    }
    return _borderView;
}

@end
