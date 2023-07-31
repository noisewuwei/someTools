//
//  YMThreadNotify.h
//  YMTool
//
//  Created by 海南有趣 on 2020/4/24.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^kNotifyBlock)(NSString *identify);

/**
 用于接收线程通知的字段（使用NSNotificationCenter接收）
 需要注意的是：线程间的通知无法携带数据，所以该通知收到的只有通知的标识符
 如何使用：如果由A线程发送通知，那么需要在B线程注册kReceiveThreadNotifyKey通知，以此接收通知的标识符，得知下一步操作。
 */
static NSString * const kReceiveThreadNotifyKey = @"kReceiveThreadNotifyKey";
@interface YMThreadNotify : NSObject

/// 注册线程间通知
/// @param observer 发送者
/// @param identifier 唯一标识符
/// @param actionBlock 回调
+ (void)registerForObserver:(id)observer
                 identifier:(NSString *)identifier
                actionBlock:(void(^)(id observer))actionBlock;

/// 发送线程间通知
/// @param identifier 唯一标识符
+ (void)postIdentifier:(NSString *)identifier;


@end

NS_ASSUME_NONNULL_END
