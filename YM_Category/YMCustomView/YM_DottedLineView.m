//
//  YM_DottedLineView.m
//  ToDesk-iOS
//
//  Created by 黄玉洲 on 2020/12/27.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "YM_DottedLineView.h"

@interface YM_DottedLineView ()

@property (assign, nonatomic) CGSize lineSize;
@property (assign, nonatomic) int lineSpace;
@property (strong, nonatomic) UIColor * lineColor;
@property (assign, nonatomic) BOOL horizontal;
@property (strong, nonatomic) NSArray <NSNumber *> * lineRules;

@end

@implementation YM_DottedLineView

/// 默认画线方式
/// @param lineSize 线宽和线高
/// @param lineSpace 线间距
/// @param lineColor 线颜色
/// @param horizontal 是否水平
- (instancetype)initWithLineSize:(CGSize)lineSize
                        lineSpace:(int)lineSpace
                        lineColor:(UIColor *)lineColor
                    lineDirection:(BOOL)horizontal {
    if (self = [super init]) {
        _lineSize = lineSize;
        _lineSpace = lineSpace;
        _lineColor = lineColor;
        _horizontal = horizontal;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self drawLineWithLineSize:_lineSize
                   lineSpacing:_lineSpace
                     lineColor:_lineColor
                 lineDirection:_horizontal];
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    
}

- (void)drawLineWithLineSize:(CGSize)lineSize
                  lineSpacing:(int)lineSpacing
                    lineColor:(UIColor *)lineColor
                lineDirection:(BOOL)isHorizonal {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];

    CGPoint startPoint;
    if (isHorizonal) {
        startPoint = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame));
    } else{
        startPoint = CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) / 2);
    }
    [shapeLayer setPosition:startPoint];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:lineSize.height];
    
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineSize.width], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);

    if (isHorizonal) {
        CGPathAddLineToPoint(path, NULL,CGRectGetWidth(self.frame), 0);
    } else {
        CGPathAddLineToPoint(path, NULL, 0, CGRectGetHeight(self.frame));
    }

    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [self.layer addSublayer:shapeLayer];
}

@end
