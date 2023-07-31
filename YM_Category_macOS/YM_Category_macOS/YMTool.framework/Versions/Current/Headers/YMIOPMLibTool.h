//
//  YMIOPMLibTool.h
//  YMTool
//
//  Created by 蒋天宝 on 2021/2/4.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOReturn.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kPowerEvent) {
    /// 唤醒
    kPowerEvent_WakeUp,
    /// 开机
    kPowerEvent_PowerOn,
    /// 唤醒或开机
    kPowerEvent_WakeUPOrPowerOn,
    /// 休眠
    kPowerEvent_Sleep,
    /// 关机
    kPowerEvent_Shutdown,
    /// 重启
    kPowerEvent_Restart,
};

#pragma mark - YMIOPMLibModel
@interface YMIOPMLibModel : NSObject

@property (assign, nonatomic, readonly) NSString * appPID;
@property (assign, nonatomic, readonly) NSString * eventtype;
@property (assign, nonatomic, readonly) NSString * scheduledby;
@property (assign, nonatomic, readonly) NSDate * time;

@end

#pragma mark - YMIOPMLibTool
@interface YMIOPMLibTool : NSObject

+ (instancetype)share;

#pragma mark 指令执行
/// 立即执行指令(部分指令可能无法立即执行，所以需要延迟几秒再去调用)
/// 注意：需要Root权限才能调用
/// @param powerEvent 指令类型
+ (IOReturn)ymIOPMSchedulePowerEvent:(kPowerEvent)powerEvent;

/// 立即执行指令(部分指令可能无法立即执行，所以需要延迟几秒再去调用)
/// 注意：需要Root权限才能调用
/// @param powerEvent 指令类型
/// @param date 指定命令执行时间
+ (IOReturn)ymIOPMSchedulePowerEvent:(kPowerEvent)powerEvent date:(NSDate *)date;

#pragma mark 指令获取
/// 获取指令
+ (NSArray <YMIOPMLibModel *> *)ymIOPMCopyScheduledPowerEvents;

#pragma mark 指令取消
/// 取消先前安排的电源事件。
/// 注意：需要Root权限才能调用
/// @param model 电源事件信息
+ (IOReturn)ymIOPMCancelScheduledPowerEvent:(YMIOPMLibModel *)model;

@end

NS_ASSUME_NONNULL_END
