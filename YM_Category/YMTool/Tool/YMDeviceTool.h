//
//  YMDeviceTool.h
//  youqu
//
//  Created by 黄玉洲 on 2019/5/16.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kFileType) {
    /** 一个目录 */
    kFileType_Directory,
    /** 常规文件 */
    kFileType_Regular,
    /** 快捷方式 */
    kFileType_SymbolicLink,
    /** socket */
    kFileType_Socket,
    /** 特殊字符文件 */
    kFileType_CharacterSpecial,
    /** 特殊block文件 */
    kFileType_BlockSpecial,
    /** 未知类型 */
    kFileType_Unknown
};

/** 电池状态变化通知 */
static NSString * kBatteryStateDidChangeKey = @"kBatteryStateDidChangeKey";

/** 电池电量变化通知 */
static NSString * kBatteryLevelDidChangeKey = @"kBatteryLevelDidChangeKey";

/** 电池状态 */
typedef NS_ENUM(NSInteger, kBatteryState) {
    /** 未知 */
    kBatteryState_Unknown,
    /** 未充电 */
    kBatteryState_Unplugged,
    /** 正在充电（少于100%电量） */
    kBatteryState_Charging,
    /** 电池已充满 */
    kBatteryState_Full,
};

typedef NS_ENUM(NSInteger, ymDeviceType) {
    ymDeviceType_Simulator,
    ymDeviceType_AppleTV,
    ymDeviceType_AppleTV4K,
    ymDeviceType_HomePod,

    ymDeviceType_iPod1,
    ymDeviceType_iPod2,
    ymDeviceType_iPod3,
    ymDeviceType_iPod4,
    ymDeviceType_iPod5,
    
    ymDeviceType_iPad2,
    ymDeviceType_iPad3,
    ymDeviceType_iPad4,
    ymDeviceType_iPad5,
    ymDeviceType_iPadAir1,
    ymDeviceType_iPadAir2,

    ymDeviceType_iPadMini1,
    ymDeviceType_iPadMini2,
    ymDeviceType_iPadMini3,
    ymDeviceType_iPadMini4,

    ymDeviceType_iPadPro9_7,
    ymDeviceType_iPadPro12_9,
    ymDeviceType_iPadPro10_5,

    ymDeviceType_iPhone4,
    ymDeviceType_iPhone4S,
    ymDeviceType_iPhone5,
    ymDeviceType_iPhone5C,
    ymDeviceType_iPhone5S,
    ymDeviceType_iPhoneSE,
    ymDeviceType_iPhone6,
    ymDeviceType_iPhone6_Plus,
    ymDeviceType_iPhone6S,
    ymDeviceType_iPhone6S_Plus,
    ymDeviceType_iPhone7,
    ymDeviceType_iPhone7_Plus,
    ymDeviceType_iPhone8,
    ymDeviceType_iPhone8_Plus,

    ymDeviceType_iPhoneX,
    ymDeviceType_iPhoneXR,
    ymDeviceType_iPhoneXS,
    ymDeviceType_iPhoneXSMax,

    ymDeviceType_unrecognized,
};

@interface YMDeviceTool : NSObject

#pragma mark - 获取本地标识编码
/** 获取IDFA */
+ (NSString *)ymIDFA;

/** 获取IDFV */
+ (NSString *)ymIDFV;

/** 获取UUID（因每次启动都会改变，故此调用次方法会存储到钥匙串中） */
+ (NSString *)ymUUID;

//获取UQID
+ (NSString *)ymUQID;

#pragma mark - 越狱
/** 判断越狱 */
+ (BOOL)ymCheckJailbreak;

#pragma mark - 文件相关
/**
 获取文件类型
 @param path 文件路径
 @return 文件类型
 */
+ (kFileType)ymFileTypeForPath:(NSString *)path;

/**
 返回指定文件的大小
 @param filePath 文件大小
 @return 字节bytes
 */
+ (long long)ymFileSizeAtPath:(NSString*)filePath;

/**
 获取文件夹下的总体大小
 @param folderPath 文件夹路径
 @return 字节bytes
 */
+ (long long)ymFolderSizeAtPath:(NSString *)folderPath;

/**
 清理指定路径
 @param cleanPath 要清理的路径
 */
+ (void)ymCleanAtPath:(NSString *)cleanPath;

#pragma mark - 机子信息
/**
 获取物理内存
 @param isConversion 是否转换
 @return 物理内存
 */
+ (NSString *)ymPhysicalMemory:(BOOL)isConversion;

/** 处理器数量 */
+ (NSInteger)ymProcessorCount;

/** 活跃的处理器数 */
+ (NSInteger)ymActiveProcessorCount;

/** 系统运行时长 */
+ (float)ymSystemUptime;

/// 获取机型
+ (ymDeviceType)ymDeviceType;

#pragma mark - 电池信息
/** 电池状态/电量监听 */
+ (void)ymBatteryMonitoring;

/** 电池状态 */
+ (kBatteryState)ymBatteryState;

/** 电池电量 */
+ (NSInteger)ymBatteryLevel;

#pragma mark - 对象保存（该方法应该能防止App信息被清除）
/** 获取对象 */
+ (NSData *)getDataWithKey:(NSString *)key;

/** 保存对象 */
+ (void)setData:(NSData *)data key:(NSString *)key;

/** 清除对象 */
+ (void)cleanObjcWithKey:(NSString *)key;

#pragma mark - App
/// 获取App占用内存(单位MB)
/// @return 正常获取返回值>0，否则返回-1
+ (float)appMemory;

@end

NS_ASSUME_NONNULL_END
