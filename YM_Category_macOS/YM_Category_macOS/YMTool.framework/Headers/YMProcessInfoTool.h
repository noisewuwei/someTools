//
//  YMProcessInfoTool.h
//  ToDesk_Service
//
//  Created by 海南有趣 on 2020/12/1.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMProcessInfoTool : NSObject

/// 获取EUID
/// @return 如果返回为0，说明是Root用户；否则为普通用户
+ (uid_t)getEUID;

/// 获取控制台用户ID和用户名
+ (void)getConsoleUID:(NSString **)uID uName:(NSString **)uName;

/// 获取正在运行的进程
/// @param processName 进程名
+ (NSArray <NSString *> *)ymRuningProcessWithProcessName:(NSString *)processName;

/// 获取指定程序是否在运行（注意：该API仅在App上有效，在Commond Line Tool中无效）
/// @param bundleID BundleID
/// @return 返回的结果不包含本身
+ (BOOL)ymApplicationRuningWithBundleID:(NSString *)bundleID;

/// 获取正在运行的指定程序的信息
/// @param bundleID BundleID
+ (NSArray <NSDictionary *> *)ymApplicationsWithBundleID:(NSString *)bundleID;

/// App是否通过Dock栏进行退出
+ (BOOL)ymAppQuitViaDock;

@end


