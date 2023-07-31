//
//  YM_BaseView.m
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import "YM_BaseView.h"

@interface YM_BaseView ()

@end

@implementation YM_BaseView

- (void)dealloc {
    NSLog(@"视图 %@ 释放", self);
}

- (void)layoutView {
    
}

- (void)removeFromSuperview {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

#pragma mark override
/// 手势穿透
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_gesturesPenetrate) {
        UIView *hitView = [super hitTest:point withEvent:event];
        if(hitView == self){
            return nil;
        }
        return hitView;
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([_delegate respondsToSelector:@selector(ymView:touchType:inRect:)]) {
        CGPoint point = [[touches anyObject] locationInView:self];
        BOOL isContain = CGRectContainsPoint(self.bounds, point);
        [_delegate ymView:self touchType:kTouchType_Began inRect:isContain];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([_delegate respondsToSelector:@selector(ymView:touchType:inRect:)]) {
        CGPoint point = [[touches anyObject] locationInView:self];
        BOOL isContain = CGRectContainsPoint(self.bounds, point);
        [_delegate ymView:self touchType:kTouchType_Move inRect:isContain];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([_delegate respondsToSelector:@selector(ymView:touchType:inRect:)]) {
        CGPoint point = [[touches anyObject] locationInView:self];
        BOOL isContain = CGRectContainsPoint(self.bounds, point);
        [_delegate ymView:self touchType:kTouchType_Ended inRect:isContain];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([_delegate respondsToSelector:@selector(ymView:touchType:inRect:)]) {
        CGPoint point = [[touches anyObject] locationInView:self];
        BOOL isContain = CGRectContainsPoint(self.bounds, point);
        [_delegate ymView:self touchType:kTouchType_Cancelled inRect:isContain];
    }
}

@end
