//
//  YMTimerTool.m
//  YMTool
//
//  Created by 黄玉洲 on 2021/2/19.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YMTimerTool.h"

@implementation YMTimerTool

/// 创建计时器
/// @param queue 线程
/// 例 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
/// @param interval 时间间隔
/// @param callback 回调
+ (dispatch_source_t)createTimer:(dispatch_queue_t)queue
                        interval:(CGFloat)interval
                        callback:(void(^)(void))callback {
    if (!queue || interval <= 0 || !callback) {
        return nil;
    }
    
    dispatch_source_t _timer = nil;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
//    dispatch_time_t start = dispatch_walltime(NULL, interval);
    dispatch_source_set_timer(_timer, start, interval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        if (callback) {
            callback();
        }
    });
    dispatch_resume(_timer);
    return _timer;
}

/// 销毁计时器
/// @param timer 指定计时器
+ (void)destoryTimer:(dispatch_source_t)timer {
    dispatch_source_cancel(timer);
    timer = nil;
}

@end
