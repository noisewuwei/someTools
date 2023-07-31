//
//  YM_PanGestureRecognizer.m
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import "YM_PanGestureRecognizer.h"

@interface YM_PanGestureRecognizer ()

/* 开始坐标 */
@property (assign, nonatomic) CGPoint beganLocation;

/* 事件 */
@property (strong, nonatomic) UIEvent *event;

/* 交互开始的时间 */
@property (assign, nonatomic) NSTimeInterval beganTime;

@end

@implementation YM_PanGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.beganLocation = [touch locationInView:self.view];
    self.event = event;
    self.beganTime = event.timestamp;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    if (self.state == UIGestureRecognizerStatePossible && event.timestamp - self.beganTime > 0.3) {
    //        self.state = UIGestureRecognizerStateFailed;
    //        return;
    //    }
    [super touchesMoved:touches withEvent:event];
}

- (void)reset {
    self.beganLocation = CGPointZero;
    self.event = nil;
    self.beganTime = 0;
    [super reset];
}

/** 将开始触摸点的坐标转换成当前控制器视图上的坐标 */
- (CGPoint)beganLocationInView:(UIView *)view {
    return [view convertPoint:self.beganLocation fromView:self.view];
}

@end
