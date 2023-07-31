//
//  YMDeviceInfoTool.h
//  ToDesk_Service
//
//  Created by 海南有趣 on 2020/12/1.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - YMCPUUsage
@interface YMCPUUsage : NSObject

@property (assign, nonatomic) int pid;          // 进程ID
@property (copy, nonatomic) NSString * command; // 进程名
@property (copy, nonatomic) NSString * name;    // App名
@property (assign, nonatomic) double   usage;   // 使用占比(%)
@property (strong, nonatomic) NSImage * icon;   // 图标

@end



#pragma mark - YMDeviceInfoTool

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
+ (bool)ymCheckProcessRuningForName:(NSString *)processName;

/// 通过PID获取进程名
/// @param pid PID
+ (NSString *)ymProcessNameForProcessID:(pid_t)pid;

/// 判断是否为预登陆
+ (bool)ymPreLogin;

/// 判断是否锁定屏幕
+ (bool)ymScreenIsLock;

/// 获取登录状态
+ (bool)ymLoginDone;

/// 获取系统内存大小
+ (NSInteger)ymMemory;

/// 获取系统启动/休眠/唤醒时间
/// @param type 获取类型
+ (NSString *)ymSysctlType:(kSysctlDateType)type error:(NSString **)error;

#pragma mark 风扇
/// 设置SMC二进制路径（默认在应用中）
/// @param binaryPath 二进制文件
+ (void)setSMCBinaryPath:(NSString *)binaryPath;

/// 获取风扇转速
/// @param fanNumber 风扇编号
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
/// @return 0:自动 1:手动
+ (int)getFanMode:(int)fanNumber;


/*
 调用以下Api时，需要注意以下配置：
 如果是导入App中，并且导入的是framework，需要在Copy Files中添加framework，并且不需要调用setSMCBinaryPath:
 如果是其他情况，则需要调动setSMCBinaryPath:指定smc二进制文件的路径
 */

/// 自动控制风扇转速
/// @param isAuto 是否自动
/// @param fanNumber 风扇编号
+ (BOOL)setFanAuto:(BOOL)isAuto fanNumber:(int)fanNumber;

/// 设置风扇转速
/// @param speed 转速
/// @param fanNumber 风扇编号
+ (BOOL)setFanSpeed:(int)speed fanNumber:(int)fanNumber;

#pragma mark CPU
/// 获取CPU核总数
+ (int)ymCPUCoreCount;

/// 获取CPU线程数
+ (int)ymCPUThreadCount;

/// 获取CPU名
+ (NSString *)ymCPUName;

/// 获取CPU架构
+ (NSString *)ymCPUArchitecture;

/// 获取进程CPU使用情况（会根据使用占比由大到小排序）
/// @param limit 限制数量 0:全部返回
+ (NSArray <YMCPUUsage *> *)ymCPUUsagePerProcessWithLimit:(int)limit;

/// 获取CPU使用情况
/// @param systemUsage 系统占比
/// @param userUsage 用户占比
/// @param idleUsage 闲置占比
/// @param cpuUsagesPerCore 各核使用占比
+ (void)ymCPUUsage:(float *)systemUsage userUsage:(float *)userUsage idleUsage:(float *)idleUsage cpuUsagesPerCore:(NSArray <NSNumber *> **)cpuUsagesPerCore;

#pragma mark GPU
/// 获取GPU名(10.11支持)
+ (NSString *)ymGPUName;

/// 获取GPU列表(10.11支持)
+ (NSArray <NSString *> *)ymGPUNameList;

@end

