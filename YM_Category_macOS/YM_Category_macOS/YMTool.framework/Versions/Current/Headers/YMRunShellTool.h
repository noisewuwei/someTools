//
//  YMRunShellTool.h
//  YMTool
//
//  Created by 黄玉洲 on 2021/6/8.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMRunShellTool : NSObject

/// 将要运行的脚本转换成root身份执行（前提是需要先进行用户名和密码登录）
/// @param script 脚本（如要调用sudo pwd，传入pwd即可）
+ (NSString *)rootScriptFromScript:(NSString *)script;

/// 执行脚本
/// @param commands 命令
/// @param errorReason 错误原因
/// @param output 输出
/// @param exitStatus 退出状态
+ (BOOL)runScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason output:(NSString **)output exitStatus:(int *)exitStatus;

/// 执行Root脚本
/// @param commands 命令
/// @param errorReason 错误原因
+ (BOOL)runRootScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason;

/// 执行Root脚本
/// @param commands 命令
/// @param errorReason 错误原因
/// @param output 输出
+ (BOOL)runRootScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason output:(NSString **)output;

/// 执行Root脚本
/// @param commands 命令
/// @param errorReason 错误原因
/// @param output 输出
/// @param exitStatus 退出状态
+ (BOOL)runRootScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason output:(NSString **)output exitStatus:(int *)exitStatus;

#pragma mark - other
/// 通过宗卷名称获取它对应的dmg路径
/// @param volumeName 宗卷名称
/// @param reason 错误理由
+ (NSString *)ymDMGPathWithName:(NSString *)volumeName errorReason:(NSString **)reason;

@end
