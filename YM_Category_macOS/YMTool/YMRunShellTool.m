//
//  YMRunShellTool.m
//  YMTool
//
//  Created by 黄玉洲 on 2021/6/8.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YMRunShellTool.h"
#import "YMPrivilegedTask.h"
@interface YMRunShellTool ()

@end

@implementation YMRunShellTool

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

/// 将要运行的脚本转换成root身份执行（前提是需要先进行用户名和密码登录）
/// @param script 脚本（如要调用sudo pwd，传入pwd即可）
+ (NSString *)rootScriptFromScript:(NSString *)script {
    NSString * rootScript = [NSString stringWithFormat:@"osascript -e \"do shell script \\\"%@\\\" with administrator privileges\"", script];
    return rootScript;
}

#pragma mark 普通脚本
/// 执行脚本
/// @param commands 命令
/// @param errorReason 错误原因
+ (BOOL)runScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason {
    return [self runScript:commands errorReason:errorReason output:nil exitStatus:nil];
}

/// 执行脚本
/// @param commands 命令
/// @param errorReason 错误原因
/// @param output 输出
+ (BOOL)runScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason output:(NSString **)output {
    return [self runScript:commands errorReason:errorReason output:output exitStatus:nil];
}

/// 执行脚本
/// @param commands 命令
/// @param errorReason 错误原因
/// @param output 输出
/// @param exitStatus 退出状态
+ (BOOL)runScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason output:(NSString **)output exitStatus:(int *)exitStatus {
    NSString * bundlePath = @"/private/tmp";
    NSString * fileName = [NSString stringWithFormat:@"script%d.sh", arc4random() % 10000];
    NSString * path = [NSString stringWithFormat:@"%@/%@", bundlePath, fileName];
    
    if (![self writeScriptToShell:commands path:path]) {
        if (errorReason) {
            *errorReason = @"sh文件写入失败";
        }
        return NO;
    }
    
    NSString * runScript = [NSString stringWithFormat:@"/bin/sh  %@", fileName];
    if ([self isValidShellCommand:runScript] == NO) {
        if (errorReason) {
            *errorReason = @"命令必须以可执行文件的路径开始";
        }
        [self removeScript:path];
        return NO;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:@[fileName]];
    [task setCurrentDirectoryPath:bundlePath];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    if (output) {
        NSData *outputData = [readHandle readDataToEndOfFile];
        *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    }

    if (exitStatus) {
        *exitStatus = task.terminationStatus;
    }
    
    [self removeScript:path];
    return YES;
}

#pragma mark Root脚本
/// 执行Root脚本
/// @param commands 命令
/// @param errorReason 错误原因
+ (BOOL)runRootScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason {
    return [self runRootScript:commands errorReason:errorReason output:nil exitStatus:nil];
}

/// 执行Root脚本
/// @param commands 命令
/// @param errorReason 错误原因
/// @param output 输出
+ (BOOL)runRootScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason output:(NSString **)output {
    return [self runRootScript:commands errorReason:errorReason output:output exitStatus:nil];
}

/// 执行Root脚本
/// @param commands 命令
/// @param errorReason 错误原因
/// @param output 输出
/// @param exitStatus 退出状态
+ (BOOL)runRootScript:(NSArray <NSString *> *)commands errorReason:(NSString **)errorReason output:(NSString **)output exitStatus:(int *)exitStatus {
    NSString * bundlePath = @"/private/tmp";
    NSString * fileName = [NSString stringWithFormat:@"script%d.sh", arc4random() % 10000];
    NSString * path = [NSString stringWithFormat:@"%@/%@", bundlePath, fileName];
    
    if (![self writeScriptToShell:commands path:path]) {
        if (errorReason) {
            *errorReason = @"sh文件写入失败";
        }
        return NO;
    }
    
    NSString * runScript = [NSString stringWithFormat:@"/bin/sh  %@", fileName];
    if ([self isValidShellCommand:runScript] == NO) {
        if (errorReason) {
            *errorReason = @"命令必须以可执行文件的路径开始";
        }
        [self removeScript:path];
        return NO;
    }
    
    YMPrivilegedTask *privilegedTask = [[YMPrivilegedTask alloc] init];
    [privilegedTask setLaunchPath:@"/bin/sh"];
    [privilegedTask setArguments:@[fileName]];
    [privilegedTask setCurrentDirectoryPath:bundlePath];
    OSStatus err = [privilegedTask launch];
    if (err != errAuthorizationSuccess) {
        if (errorReason) {
            *errorReason = [NSString stringWithFormat:@"errAuthorization:%d", err];
        }
        [self removeScript:path];
        return NO;
    }
    
    [privilegedTask waitUntilExit];
    
    if (output) {
        NSFileHandle *readHandle = [privilegedTask outputFileHandle];
        NSData *outputData = [readHandle readDataToEndOfFile];
        *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    }

    if (exitStatus) {
        *exitStatus = privilegedTask.terminationStatus;
    }
    [self removeScript:path];
    return YES;
}

#pragma mark private
+ (BOOL)isValidShellCommand:(NSString *)cmd {
    NSArray *cmp = [cmd componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([[NSFileManager defaultManager] isExecutableFileAtPath:cmp[0]] ) {
        return YES;
    }
    
    return NO;
}

/// 将脚本写入sh文件
/// @param commands 命令
/// @param path 脚本
+ (BOOL)writeScriptToShell:(NSArray <NSString *> *)commands path:(NSString *)path {
    if (path.length == 0) {
        return NO;
    }
    
    NSString * scripts = @"";
    for (NSString * script in commands) {
        if (scripts.length == 0) {
            scripts = script;
        } else {
            scripts = [NSString stringWithFormat:@"%@\n%@", scripts, script];
        }
    }
    
    NSError * error;
    BOOL result = [scripts writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    return result;
}

/// 删除sh文件
/// @param path 路径
+ (BOOL)removeScript:(NSString *)path {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

#pragma mark - other
/// 通过宗卷名称获取它对应的dmg路径
/// @param volumeName 宗卷名称
/// @param reason 错误理由
+ (NSString *)ymDMGPathWithName:(NSString *)volumeName errorReason:(NSString **)reason {
    NSString * completeVolumeName = volumeName;
    NSString * bundlePath = [[NSBundle mainBundle] bundlePath];
    // 验证路径
    if ([bundlePath rangeOfString:@"/Volumes"].location != 0) {
        if (reason) {
            *reason = [NSString stringWithFormat:@"%@ Bundle路径错误!", bundlePath];
        }
        return nil;
    }
    
    // 验证路径
    if (![bundlePath containsString:volumeName]) {
        if (reason) {
            *reason = [NSString stringWithFormat:@"%@ 路径未包含宗卷：%@", bundlePath, volumeName];
        }
        return nil;
    }
    
    // 匹配完整的宗卷名称
    for (NSString * path in [bundlePath componentsSeparatedByString:@"/"]) {
        if ([path containsString:volumeName]) {
            completeVolumeName = path;
            break;
        }
    }
    
    // 获取dmg列表
    NSString * outStr1 = nil;
    NSString * script1 = [NSString stringWithFormat:@"hdiutil info -plist | grep %@", volumeName];
    [YMRunShellTool runScript:@[script1] errorReason:nil output:&outStr1 exitStatus:nil];
    outStr1 = [outStr1 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    outStr1 = [outStr1 stringByReplacingOccurrencesOfString:@"<string>" withString:@""];
    outStr1 = [outStr1 stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
    
    // 获取宗卷列表
    NSString * outStr2 = nil;
    NSString * script2 = [NSString stringWithFormat:@"hdiutil info -plist | grep /Volumes/%@", volumeName];
    [YMRunShellTool runScript:@[script2] errorReason:nil output:&outStr2 exitStatus:nil];
    outStr2 = [outStr2 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    outStr2 = [outStr2 stringByReplacingOccurrencesOfString:@"<string>" withString:@""];
    outStr2 = [outStr2 stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
    
    // 获取宗卷/dmg路径
    NSArray * volumePaths = [outStr2 componentsSeparatedByString:@"\n"];
    NSArray * dmgPaths = [outStr1 componentsSeparatedByString:@"\n"];
    NSString * dmgPath = nil; // 目标dmg路径
    for (int i = 0; i < [volumePaths count]; i++) {
        NSString * path = volumePaths[i];
        if ([path containsString:completeVolumeName] && dmgPaths.count >= i) {
            dmgPath = dmgPaths[i];
            break;
        }
    }
    
    if (dmgPath.length == 0) {
        if (reason) {
            *reason = [NSString stringWithFormat:@"未找到相应的dmg文件：%@", completeVolumeName];
        }
        return nil;
    }
    
    return dmgPath;
}

@end
