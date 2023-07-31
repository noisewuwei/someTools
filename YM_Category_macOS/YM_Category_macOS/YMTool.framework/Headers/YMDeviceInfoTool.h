//
//  YMDeviceInfoTool.h
//  ToDesk_Service
//
//  Created by 海南有趣 on 2020/12/1.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kSysctlDateType) {
    kSysctlDateType_Boottime,   // 启动时间
    kSysctlDateType_Sleeptime,  // 休眠时间
    kSysctlDateType_Waketime    // 唤醒时间
};

@interface YMDeviceInfoTool : NSObject

/// 获取MAC地址
+ (NSString *)ymDeviceMacAddress;

/// 获取序列号
+ (NSString *)ymDeviceSerial;

/// 获取UUID
+ (NSString *)ymDeviceUUID;

/// 获取设备名
+ (NSString *)ymDeviceName;

/// 获取设备型号
+ (NSString *)ymDeviceModels;

/// 获取系统版本
+ (NSString *)ymDeviceSystemVersion;

/// 查找进程是否正在运行
/// @param processName 进程名
+ (BOOL)ymCheckProcessRuningForName:(NSString *)processName;

/// 通过PID获取进程名
/// @param pid PID
+ (NSString *)ymProcessNameForProcessID:(pid_t)pid;

/// 判断是否为预登陆
+ (BOOL)ymPreLogin;

/// 获取系统内存大小
+ (NSInteger)ymMemory;

/// 获取GPU名
+ (NSString *)ymGPUName;

/// 获取CPU核总数
+ (int)ymCPUCoreCount;

/// 获取CPU线程数
+ (int)ymCPUThreadCount;

/// 获取CPU名
+ (NSString *)ymCPUName;

/// 获取CPU架构
+ (NSString *)ymCPUArchitecture;

/// 获取系统启动/休眠/唤醒时间
/// @param type 获取类型
+ (NSString *)ymSysctlType:(kSysctlDateType)type error:(NSString **)error;


#pragma mark - 风扇
/// 获取风扇转速
/// @param fanNumber  风扇编号
+ (int)getFanRPM:(int)fanNumber;

/// 获取风扇个数
+ (int)getFanNum;

/// 风扇描述
/// @param fanNumber 风扇编号
+ (NSString*)getFanDescript:(int)fanNumber;


/// 获取最小转速
/// @param fanNumber 风扇编号
+ (int)getMinSpeed:(int)fanNumber;

/// 获取最大转速
/// @param fanNumber 风扇编号
+ (int)getMaxSpeed:(int)fanNumber;

/// 获取风扇模式
/// @param fanNumber 风扇编号
/// @return 0:手动 1:自动
+ (int)getFanMode:(int)fanNumber;

/// 调用SMC命令以设置转速
/// @param key 键
/// @param value 值
+ (void)setExternalWithKey:(NSString *)key value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
