//
//  YM_UpwardBifurcationView.m
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_UpwardBifurcationView.h"

@interface YM_UpwardBifurcationView ()

@end

@implementation YM_UpwardBifurcationView

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
        CGContextMoveToPoint(context, rect.size.width / 2.0, rect.size.height * 0.6);
        // ——
        CGContextAddLineToPoint(context, rect.size.width - 1, rect.size.height * 0.6);
        // |
        CGContextAddLineToPoint(context, rect.size.width - 1, 0);
        CGContextStrokePath(context);
        
        // 设置线的颜色
        CGContextSetStrokeColorWithColor(context, selected_Color.CGColor);
        // 移动点
        CGContextMoveToPoint(context, 1, 0);
        // |
        CGContextAddLineToPoint(context, 1, rect.size.height * 0.6);
        // ——
        CGContextAddLineToPoint(context, rect.size.width / 2.0, rect.size.height * 0.6);
        // |
        CGContextAddLineToPoint(context, rect.size.width / 2.0, rect.size.height);
    }
    // 右侧队伍胜利（先左后右）
    else {
        // 设置线的颜色
        CGContextSetStrokeColorWithColor(context, deselect_Color.CGColor);
        
        // 进行画线，由左往右画
        CGContextMoveToPoint(context, 1, 0);
        // |
        CGContextAddLineToPoint(context, 1, rect.size.height * 0.6);
        // ——
        CGContextAddLineToPoint(context, rect.size.width / 2.0, rect.size.height * 0.6);
        CGContextStrokePath(context);
        
        // 设置线的颜色
        CGContextSetStrokeColorWithColor(context, selected_Color.CGColor);
        // 点移动到分叉交汇点
        CGContextMoveToPoint(context, rect.size.width / 2.0, rect.size.height);
        // |
        CGContextAddLineToPoint(context, rect.size.width / 2.0, rect.size.height * 0.6);
        // ——
        CGContextAddLineToPoint(context, rect.size.width - 1, rect.size.height * 0.6);
        // |
        CGContextAddLineToPoint(context, rect.size.width - 1, 0);
    }
    
    // 开始绘图
    CGContextStrokePath(context);
}


@end
