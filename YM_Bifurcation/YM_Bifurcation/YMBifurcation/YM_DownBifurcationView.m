//
//  YM_DownBifurcationView.m
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DownBifurcationView.h"

@interface YM_DownBifurcationView ()

@end

@implementation YM_DownBifurcationView

- (instancetype)initWithLeftWin:(BOOL)leftWin {
    if ([super init]) {
        self.backgroundColor = [UIColor clearColor];
        _leftWin = leftWin;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - setter
- (void)setLeftWin:(BOOL)leftWin {
    _leftWin = leftWin;
    [self drawRect:self.bounds];
}

- (void)drawRect:(CGRect)rect {
    // 获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    
    // 左侧队伍胜利（先右后左）
    if (_leftWin) {
        // 设置线的颜色
        CGContextSetStrokeColorWithColor(context, deselect_Color.CGColor);
        // 移动点
        CGContextMoveToPoint(context, rect.size.width / 2.0, rect.size.height * 0.4);
        // ——
        CGContextAddLineToPoint(context, rect.size.width - 1, rect.size.height * 0.4);
        // |
        CGContextAddLineToPoint(context, rect.size.width - 1, rect.size.height);
        CGContextStrokePath(context);
        
        // 设置线的颜色
        CGContextSetStrokeColorWithColor(context, selected_Color.CGColor);
        // 移动点
        CGContextMoveToPoint(context, 1, rect.size.height);
        // |
        CGContextAddLineToPoint(context, 1, rect.size.height * 0.4);
        // ——
        CGContextAddLineToPoint(context, rect.size.width / 2.0, rect.size.height * 0.4);
        // |
        CGContextAddLineToPoint(context, rect.size.width / 2.0, 0);
    }
    // 右侧队伍胜利（先左后右）
    else {
        // 设置线的颜色
        CGContextSetStrokeColorWithColor(context, deselect_Color.CGColor);
        
        // 进行画线，由左往右画
        CGContextMoveToPoint(context, 1, rect.size.height);
        // |
        CGContextAddLineToPoint(context, 1, rect.size.height * 0.4);
        // ——
        CGContextAddLineToPoint(context, rect.size.width / 2.0, rect.size.height * 0.4);
        CGContextStrokePath(context);
        
        // 设置线的颜色
        CGContextSetStrokeColorWithColor(context, selected_Color.CGColor);
        // 点移动到分叉交汇点
        CGContextMoveToPoint(context, rect.size.width / 2.0, 0);
        // |
        CGContextAddLineToPoint(context, rect.size.width / 2.0, rect.size.height * 0.4);
        // ——
        CGContextAddLineToPoint(context, rect.size.width - 1, rect.size.height * 0.4);
        // |
        CGContextAddLineToPoint(context, rect.size.width - 1, rect.size.height);
    }
    
    // 开始绘图
    CGContextStrokePath(context);
}

@end
