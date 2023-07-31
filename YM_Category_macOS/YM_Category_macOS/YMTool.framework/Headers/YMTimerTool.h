//
//  YMTimerTool.h
//  YMTool
//
//  Created by 蒋天宝 on 2021/2/19.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMTimerTool : NSObject

/// 创建计时器
/// @param queue 线程
/// 例 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
/// @param interval 时间间隔
/// @param callback 回调
+ (dispatch_source_t)createTimer:(dispatch_queue_t)queue
                        interval:(CGFloat)interval
                        callback:(void(^)(void))callback;

/// 销毁计时器
/// @param timer 指定计时器
+ (void)destoryTimer:(dispatch_source_t)timer;

@end

NS_ASSUME_NONNULL_END
