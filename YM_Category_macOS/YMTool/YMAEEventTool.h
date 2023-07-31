//
//  YMAEEventTool.h
//  YMTool
//
//  Created by 黄玉洲 on 2021/2/4.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, kAppleEvent) {
    /// 重启
    kAppleEvent_Restart = 1,
    /// 关机
    kAppleEvent_ShutDown,
    /// 询问注销
    kAppleEvent_Logout,
    /// 直接注销
    kAppleEvent_ReallyLogout,
    /// 睡眠
    kAppleEvent_Sleep,
    /// 锁定屏幕
    kAppleEvent_LockScreen,
    /// 打开屏保
    kAppleEvent_ScreenSaverEngine,
    /// 退出所有应用然后到用户登录页
    kAppleEvent_QuitAll,
};

/// 获取系统kAEQuitReason事件原因
typedef NS_ENUM(NSInteger, kQuitReason) {
    kQuitReasonNone = 0, // 无法获取或未捕捉到
    kQuitReasonLogOut,
    kQuitReasonReallyLogOut, // 退出用户登录
    kQuitReasonQuitAll,
    kQuitReasonShutDown,     // 关机
    kQuitReasonRestart,      // 重启
};

@class NSAppleEventDescriptor;
@interface YMAEEventTool : NSObject

+ (instancetype)share;

/// 发送Apple事件（包括重启、关机等，具体查看kAppleEvent）
/// @param appleEvent 事件枚举
+ (OSStatus)ymSendAppleEvent:(kAppleEvent)appleEvent;

/// 获取应用退出原因（可以在applicationShouldTerminate:中进行调用）
+ (kQuitReason)ymAppleEventQuitReason;

/// 获取应用退出原因（可以在applicationShouldTerminate:中进行调用）
+ (kQuitReason)ymAppleEventQuitReasonFrom:(NSAppleEventDescriptor **)appleEventDescriptor;


@end
