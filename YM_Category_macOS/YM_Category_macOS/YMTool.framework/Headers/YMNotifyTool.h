//
//  YMNotifyTool.h
//  YM_Category
//
//  Created by 海南有趣 on 2020/5/18.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 使用 [[NSWorkspace sharedWorkspace] notificationCenter] 注册通知 */
static NSString * kWorkspaceWillSleepNotification = @"NSWorkspaceWillSleepNotification";                            // 机器进入睡眠状态之前
static NSString * kWorkspaceDidWakeNotification = @"NSWorkspaceDidWakeNotification";                                // 机器从睡眠状态唤醒时
static NSString * kWorkspaceSessionDidResignActiveNotification = @"NSWorkspaceSessionDidResignActiveNotification";  // 关闭用户会话后
static NSString * kWorkspaceSessionDidBecomeActiveNotification = @"NSWorkspaceSessionDidBecomeActiveNotification";  // 登录用户会话后
static NSString * kWorkspaceWillPowerOffNotification = @"NSWorkspaceWillPowerOffNotification";                      // 当用户请求注销或关闭计算机电源时
static NSString * kWorkspaceScreensDidSleepNotification = @"NSWorkspaceScreensDidSleepNotification";                // 屏幕睡眠
static NSString * kWorkspaceScreensDidWakeNotification = @"NSWorkspaceScreensDidWakeNotification";                  // 屏幕唤醒

/* 使用 [NSDistributedNotificationCenter defaultCenter] 注册通知 */
static NSString * kScreensaverDidStartNotification = @"com.apple.screensaver.didstart"; // 屏保开始
static NSString * kScreensaverWillStopNotification = @"com.apple.screensaver.willstop"; // 屏保将要结束
static NSString * kScreensaverDidStopNotification = @"com.apple.screensaver.didstop";   // 屏保结束
static NSString * kScreenIsLockedNotification = @"com.apple.screenIsLocked";            // 屏幕锁住
static NSString * kScreenIsUnlockedNotification = @"com.apple.screenIsUnlocked";        // 屏幕解锁

typedef void(^YMNotifyToolActionBlock)(id observer, id object, NSDictionary * userInfo);

/// 所有响应block生命周期和观察者对象生命周期一样，一个对象多次添加同一类型或者同一标识符的观察者
/// 只会添加最后一次，响应的block回掉会随着观察者对象销毁自动销毁，建议使用枚举管理所有标识符
@interface YMNotifyTool : NSObject

/// 根据标识符添加观察者
/// 注意：在回调中使用self会导致强引用，导致无法释放。可添加weakSelf、strongSelf解决
/// @param observer 观察者
/// @param identifier 唯一标识
/// @param mainThread 首付在主线程上回调
/// @param actionBlock 监听响应
+ (void)addObserver:(id)observer
         identifier:(NSString *)identifier
         mainThread:(BOOL)mainThread
        actionBlock:(YMNotifyToolActionBlock)actionBlock;

/// 根据标识符调用
/// @param identifier 标识符
/// @param object     数据
/// @param userInfo   数据
+ (void)postIdentifier:(NSString *)identifier
                object:(id)object
              userInfo:(NSDictionary *)userInfo;


/// 删除指定对象下的指定通知（一般情况下不需要调用，除非发生强引用导致内存无法释放）
/// @param observer 观察者
/// @param identifier 唯一标识
+ (void)removeObserver:(id)observer
            identifier:(NSString *)identifier;

/// 删除指定对象下的所有通知（一般情况下不需要调用，除非发生强引用导致内存无法释放）
/// @param observer 观察者
+ (void)removeObserver:(id)observer;



@end
