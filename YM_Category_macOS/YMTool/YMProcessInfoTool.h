//
//  YMProcessInfoTool.h
//  ToDesk_Service
//
//  Created by 海南有趣 on 2020/12/1.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YMProcessInfoModel;
@interface YMProcessInfoTool : NSObject

/// 获取进程ID
/// @return 0:root 其他:user
+ (uid_t)getUID;

/// 设置进程ID
+ (int)setUID:(uid_t)uid;

/// 获取控制台用户ID和用户名
+ (void)getConsoleUID:(NSString **)uID uName:(NSString **)uName;

/// 通过pid获取进程信息
/// @param pid 进程id
+ (YMProcessInfoModel *)ymProcessInfoModelWithPID:(pid_t)pid;

/// 获取正在运行的进程
/// @param processName 进程名
+ (NSArray <YMProcessInfoModel *> *)ymProcessInfoModelListWithName:(NSString *)processName;

/// 获取进程启动参数
/// @param pid 进程ID
+ (NSString *)ymProcessLaunchParameterWithPID:(pid_t)pid;

/// 获取指定程序是否在运行（注意：该API仅在App上有效，在Commond Line Tool中无效）
/// @param bundleID BundleID
/// @return 返回的结果不包含本身
+ (BOOL)ymApplicationRuningWithBundleID:(NSString *)bundleID;

/// 获取正在运行的指定程序的信息
/// @param bundleID BundleID
+ (NSArray <NSDictionary *> *)ymApplicationsWithBundleID:(NSString *)bundleID;

/// App是否通过Dock栏进行退出
+ (BOOL)ymAppQuitViaDock;

+ (void)processList;

@end

// 普通用户无法获取root用户的信息
@interface YMProcessInfoModel : NSObject

@property (assign, nonatomic) pid_t pid;

@property (assign, nonatomic) uid_t uid; // 用户ID

@property (assign, nonatomic) gid_t gid; // 组ID

@property (copy, nonatomic) NSString * processName;

@property (copy, nonatomic) NSString * executePath;

@property (copy, nonatomic) NSString * own;

@end


