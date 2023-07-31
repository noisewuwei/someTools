//
//  YM_PanGestureRecognizer.h
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
NS_ASSUME_NONNULL_BEGIN

@interface YM_PanGestureRecognizer : UIPanGestureRecognizer

/* 事件 */
@property (nonatomic, readonly) UIEvent *event;

/* 手势开始时的坐标 */
- (CGPoint)beganLocationInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
