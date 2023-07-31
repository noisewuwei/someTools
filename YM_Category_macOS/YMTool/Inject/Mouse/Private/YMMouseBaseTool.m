//
//  YMMouseBaseTool.m
//  YM_Category_macOS
//
//  Created by 黄玉洲 on 2021/12/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YMMouseBaseTool.h"

@interface YMMouseBaseTool ()


@end

@implementation YMMouseBaseTool


/// 鼠标滚轮事件
/// @param distance 负向上、右，正向下、左
/// @param horizontal 是否为水平滚动
- (void)postMouseScrollEvent:(int32_t)distance horizontal:(BOOL)horizontal deltax:(int32_t)deltax deltay:(int32_t)deltay {
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStatePrivate);
    CGEventRef theEvent = CGEventCreateScrollWheelEvent(source, self.scrollEventUnit,
                                                        3,horizontal ? 0 : distance,
                                                        horizontal ? distance : 0);
    CGEventSetIntegerValueField(theEvent, kCGScrollWheelEventPointDeltaAxis2, deltax);
    CGEventSetIntegerValueField(theEvent, kCGScrollWheelEventPointDeltaAxis1, deltay);
    CGEventPost(kCGSessionEventTap, theEvent);
    CFRelease(theEvent);
}

/// 鼠标滚轮事件
/// @param distance 负向上、右，正向下、左
/// @param horizontal 是否为水平滚动
- (void)postMouseScrollEvent:(int32_t)distance horizontal:(BOOL)horizontal{
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStatePrivate);
    CGEventRef theEvent = CGEventCreateScrollWheelEvent(source, self.scrollEventUnit,
                                                        3,
                                                        horizontal ? 0 : distance,
                                                        horizontal ? distance : 0);
    CGEventPost(kCGSessionEventTap, theEvent);
    CFRelease(theEvent);
}

@end
