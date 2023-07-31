//
//  YMProcessInfoTool.m
//  ToDesk_Service
//
//  Created by 海南有趣 on 2020/12/1.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "YMProcessInfoTool.h"
#include <unistd.h>
#include <stdio.h>
#include <assert.h>
#import <sys/proc_info.h>
#import <libproc.h>
#include <SystemConfiguration/SystemConfiguration.h>
@implementation YMProcessInfoTool

/// 获取当前应用EUID
/// @return 如果返回为0，说明是Root用户；否则为普通用户
+ (uid_t)getEUID {
    return geteuid();
}

/// 设置进程ID
+ (int)setUID:(uid_t)uid {
    return setuid(uid);
}

/// 获取控制台用户ID和用户名
+ (void)getConsoleUID:(NSString **)uID uName:(NSString **)uName {
    SCDynamicStoreRef store;
    CFStringRef name;
    uid_t uid;
    #define BUFLEN 256
    char buf[BUFLEN];
    Boolean ok;
    store = SCDynamicStoreCreate(NULL, CFSTR("GetConsoleUser"), NULL, NULL);
    
    assert(store != NULL);
    name = SCDynamicStoreCopyConsoleUser(store, &uid, NULL);
    CFRelease(store);
    
    if (name != NULL) {
        ok = CFStringGetCString(name, buf, BUFLEN, kCFStringEncodingUTF8);
        assert(ok == true);
        CFRelease(name);
    } else {
        strcpy(buf, "<none>");
    }
    
    if (uID) {
        *uID = [NSString stringWithFormat:@"%u", uid];
    }

    if (uName) {
        *uName = [NSString stringWithFormat:@"%s", buf];
    }
}

/// 获取正在运行的进程
/// @param processName 进程名
+ (NSArray <NSString *> *)ymRuningProcessWithProcessName:(NSString *)processName {
    if (processName.length == 0) {
        return nil;
    }

    NSMutableArray * processList = [NSMutableArray array];
    NSString * script = [NSString stringWithFormat:@"ps aux | grep '%@' | grep -v grep", processName];
    FILE *fp = popen([script UTF8String], "r");
    if (fp) {
        char line[4096] = {0};
        int count = 0;
        while (fgets(line, 4096, fp) && count < 100) {
            NSString * processUserName = [[NSString alloc] initWithUTF8String:line];
            processUserName = [processUserName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [processList addObject:processUserName];
            count++;
        }
    }
    pclose(fp);
    return processList;
}

/// 获取指定程序是否在运行（注意：该API仅在App上有效，在Commond Line Tool中无效）
/// @param bundleID BundleID
/// @return 返回的结果不包含本身
+ (BOOL)ymApplicationRuningWithBundleID:(NSString *)bundleID {
    // 通过BundleID获取正在运行的App
    NSArray <NSRunningApplication *> * appArray = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleID];
    pid_t selfPid = [[NSRunningApplication currentApplication] processIdentifier];
    for (int i = 0; i < [appArray count]; i++) {
        NSRunningApplication * app = appArray[i];
        if ([app processIdentifier] != selfPid) {
            return YES;
        }
    }
    return NO;
}

/// 通过pid获取进程信息
/// @param pid 进程id
+ (YMProcessInfoModel *)ymProcessInfoModelWithPID:(pid_t)pid {
    int numberOfProcesses = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    pid_t pid_list[numberOfProcesses];
    bzero(pid_list, sizeof(pid_list));
    proc_listpids(PROC_ALL_PIDS, 0, pid_list, (int)sizeof(pid_list));
    
    YMProcessInfoModel * processInfoModel;
    for (int i = 0; i < numberOfProcesses; ++i) {
        pid_t temp_pid = pid_list[i];
        if (temp_pid == pid) {
            processInfoModel = [self getProcessInfoModelWithPID:temp_pid];
            break;
        }
    }

    return processInfoModel;
}

/// 获取正在运行的进程
/// @param processName 进程名
+ (NSArray <YMProcessInfoModel *> *)ymProcessInfoModelListWithName:(NSString *)processName {
    // 进程数量
    int numberOfProcesses = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    pid_t pid_list[numberOfProcesses];
    bzero(pid_list, sizeof(pid_list));
    proc_listpids(PROC_ALL_PIDS, 0, pid_list, (int)sizeof(pid_list));
    
    // 查找匹配进程
    NSMutableArray * mArray = [NSMutableArray array];
    for (int i = 0; i < numberOfProcesses; ++i) {
        pid_t pid = pid_list[i];
        if (pid == 0) { continue; }
        
        // 进程名
        char nameBuffer[PROC_PIDPATHINFO_MAXSIZE];
        bzero(nameBuffer, PROC_PIDPATHINFO_MAXSIZE);
        proc_name(pid,nameBuffer, sizeof(nameBuffer));
        NSString * pid_name = [NSString stringWithUTF8String:nameBuffer];
        if (strlen(nameBuffer) == 0) { continue; }
        
        // 匹配进程
        if ([processName isEqual:pid_name]) {
            YMProcessInfoModel * processInfoModel = [self getProcessInfoModelWithPID:pid];
            if (processInfoModel) {
                [mArray addObject:processInfoModel];
            }
        }
    }
    return mArray;
}

/// 获取进程启动参数
/// @param pid 进程ID
+ (NSString *)ymProcessLaunchParameterWithPID:(pid_t)pid {
    char* cmd = NULL;
    NSString * script = [NSString stringWithFormat:@"ps -ef %d | grep /", pid];
    FILE *fp = popen([script UTF8String], "r");
    if (fp) {
        char line[4096] = {0};
        while (fgets(line, 4096, fp)) {
            cmd = line;
            break;
        }
        pclose(fp);
    }
    
    if (cmd == NULL || strlen(cmd) == 0) {
        return nil;
    }
    
    return [NSString stringWithUTF8String:cmd];
}

/// 获取正在运行的指定程序的信息（注意：该API仅在App上有效，在Commond Line Tool中无效）
/// @param bundleID BundleID
+ (NSArray <NSDictionary *> *)ymApplicationsWithBundleID:(NSString *)bundleID {
    NSArray *launchedApplications = [[NSWorkspace sharedWorkspace] launchedApplications];
    return launchedApplications;
}

/// App是否通过Dock栏进行退出
+ (BOOL)ymAppQuitViaDock {
    NSAppleEventDescriptor *appleEvent = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
    // [NSApp terminate:nil];执行时会走进去
    if (!appleEvent) {
        return false;
    }
    
    if ([appleEvent eventClass] != kCoreEventClass ||
        [appleEvent eventID] != kAEQuitApplication) {
        // Not a 'quit' event
        return false;
    }
    
    // 系统关闭事件
    NSAppleEventDescriptor *reason = [appleEvent attributeDescriptorForKeyword:kAEQuitReason];
    if (reason) {
        return false;
    }
    
    pid_t senderPID = [[appleEvent attributeDescriptorForKeyword:keySenderPIDAttr] int32Value];
    if (senderPID == 0) {
        return false;
    }
    
    NSRunningApplication *sender = [NSRunningApplication runningApplicationWithProcessIdentifier:senderPID];
    if (!sender) {
        return false;
    }
    
    return [@"com.apple.dock" isEqualToString:[sender bundleIdentifier]];
}

#pragma mark - private
+ (YMProcessInfoModel *)getProcessInfoModelWithPID:(pid_t)pid {
    YMProcessInfoModel * processInfoModel = [[YMProcessInfoModel alloc] init];
    processInfoModel.pid = pid;
    
    if (pid <= 0) {
        return nil;
    }
    
    // 进程名
    char nameBuffer[PROC_PIDPATHINFO_MAXSIZE];
    bzero(nameBuffer, PROC_PIDPATHINFO_MAXSIZE);
    proc_name(pid,nameBuffer, sizeof(nameBuffer));
    NSString * pid_name = [NSString stringWithUTF8String:nameBuffer];
    
    // 进程执行路径
    char pathBuffer[PROC_PIDPATHINFO_MAXSIZE];
    bzero(pathBuffer, PROC_PIDPATHINFO_MAXSIZE);
    proc_pidpath(pid, pathBuffer, sizeof(pathBuffer));
    NSString * pid_path = [NSString stringWithUTF8String:pathBuffer];
    processInfoModel.executePath = pid_path;
    
    // 进程名获取
    processInfoModel.processName = pid_name.length > 0 ? pid_name : [[pid_path componentsSeparatedByString:@"/"] lastObject];

    // 用户ID
    struct proc_bsdinfo proc;
    int st = proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &proc, PROC_PIDTBSDINFO_SIZE);
    if (st == PROC_PIDTBSDINFO_SIZE) {
        processInfoModel.uid = proc.pbi_uid;
        processInfoModel.gid = proc.pbi_gid;
    }
    
    // 持有者获取
    NSArray * processInfos = [self ymRuningProcessWithProcessName:[NSString stringWithFormat:@"%d", pid]];
    for (NSString * processInfo in processInfos) {
        if ([processInfo containsString:pid_path]) {
            processInfoModel.own = [[processInfo componentsSeparatedByString:@" "] firstObject];
            break;
        }
    }
    
    return processInfoModel;
}

// 查找进程CMD
//std::string cmd;
//NSString * script = [NSString stringWithFormat:@"ps -ef %d | grep ToDesk", pid];
//NSString * procesInfo = @"";
//FILE *fp = popen([script UTF8String], "r");
//if (fp) {
//    char line[4096] = {0};
//    while (fgets(line, 4096, fp)) {
//        cmd = line;
//        break;
//    }
//}
//pclose(fp);

@end

@implementation YMProcessInfoModel

- (NSString *)description {
    return [NSString stringWithFormat:@"pid:%d processName:%@ executePath:%@ own:%@", self.pid, self.processName, self.executePath, self.own];
}

@end
