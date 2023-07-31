//
//  YMDeviceInfoTool.m
//  ToDesk_Service
//
//  Created by 海南有趣 on 2020/12/1.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Foundation/NSAutoreleasePool.h>
#import <SystemConfiguration/SCDynamicStoreCopySpecific.h>

#import <sys/sysctl.h>
#import <libproc.h>
#import <Metal/Metal.h>
#include <net/if_dl.h>

#if IS_LIBRARY
#import "YMToolLibrary.h"
#else
#import "YMTool.h"
#endif

#import "YMDeviceInfoTool.h"
#import "YMRunShellTool.h"



/// 风扇
#import "smcWrapper.h"

#pragma mark - YMCPUUsage
@implementation YMCPUUsage


@end




#pragma mark - YMDeviceInfoTool
@interface YMDeviceInfoTool ()
{
    natural_t   _numCPUsU;
    processor_info_array_t _cpuInfo;
    mach_msg_type_number_t _numCpuInfo;
    processor_info_array_t _prevCpuInfo;
    mach_msg_type_number_t _numPrevCpuInfo;
}

@property (strong, nonatomic) NSMutableArray  <NSNumber *> * usagePerCore;

@end

@implementation YMDeviceInfoTool

static YMDeviceInfoTool * instance = nil;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMDeviceInfoTool alloc] init];
    });
    return instance;
}

/// 获取MAC地址
+ (NSString *)ymDeviceMacAddress {
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    
    ifm = (struct if_msghdr *)buf;
    
    sdl = (struct sockaddr_dl *)(ifm + 1);
    
    ptr = (unsigned char *)LLADDR(sdl);
    
    
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    // release pointer
    if (buf != NULL) {
        free(buf);
        buf = NULL;
    }
    
    return [outstring lowercaseString];
}

/// 获取序列号
+ (NSString *)ymDeviceSerial {
    NSString * ret = @"";
    io_service_t platformExpert ;
    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice")) ;
    
    if (platformExpert)    {
        CFTypeRef serialNumber =
        IORegistryEntryCreateCFProperty(platformExpert, CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
        if (serialNumber)    {
            ret = [(__bridge NSString *)(CFStringRef)serialNumber copy];
            CFRelease(serialNumber);
            serialNumber = NULL;
        }
        IOObjectRelease(platformExpert); platformExpert = 0;
    }
    return ret;
}

/// 获取UUID
+ (NSString *)ymDeviceUUID {
    NSString * ret = @"";
    io_service_t platformExpert;
    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    if (platformExpert) {
        CFTypeRef uuid =
        IORegistryEntryCreateCFProperty(platformExpert, CFSTR("IOPlatformUUID"), kCFAllocatorDefault, 0);
        if (uuid) {
            ret = [(__bridge NSString *)(CFStringRef)uuid copy];
            CFRelease(uuid);
            uuid = NULL;
        }
        IOObjectRelease(platformExpert); platformExpert = 0;
    }
    
    return ret;
}

/// 获取设备名
+ (NSString *)ymDeviceName {
    return [NSHost currentHost].localizedName;
}

/// 设备型号
+ (NSString *)ymDeviceModels {
    NSString * deviceModels = @"";
    size_t len = 0;
    sysctlbyname("hw.model", NULL, &len, NULL, 0);
    if (len) {
        NSMutableData *data = [NSMutableData dataWithLength:len];
        sysctlbyname("hw.model", [data mutableBytes], &len, NULL, 0);
        deviceModels = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return deviceModels;
}

/// 获取系统版本
+ (NSString *)ymDeviceSystemVersion {
    NSString * versionString;
    NSDictionary * sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    versionString = [sv objectForKey:@"ProductVersion"];
    return versionString;
}

/// 查找进程是否正在运行
/// @param processName 进程名
+ (bool)ymCheckProcessRuningForName:(NSString *)processName {
    return [self _runningProcesses:processName];
}

/// 通过PID获取进程名
/// @param pid PID
+ (NSString *)ymProcessNameForProcessID:(pid_t)pid {
    NSString *processName = @"";
    char pathBuffer [PROC_PIDPATHINFO_MAXSIZE];
    proc_pidpath(pid, pathBuffer, sizeof(pathBuffer));
    
    char nameBuffer[256];
    
    int position = (int)strlen(pathBuffer);
    while(position >= 0 && pathBuffer[position] != '/')
    {
        position--;
    }
    
    strcpy(nameBuffer, pathBuffer + position + 1);
    
    processName = [NSString stringWithUTF8String:nameBuffer];
    return processName;
}

/// 判断是否为预登陆
+ (bool)ymPreLogin {
//    NSString * error = @"";
//    NSString * output = @"";
//    [YMRunShellTool runScript:@[@"users"] errorReason:&error output:&output exitStatus:nil];
//    if (error.length > 0)
//        NSLog(@"ymPreLogin error:%@", error);
//    return output.length <= 0;
    
    SCDynamicStoreRef store;
    CFStringRef name;
    uid_t uid;

    store = SCDynamicStoreCreate(NULL, CFSTR("GetConsoleUser"), NULL, NULL);
    name = SCDynamicStoreCopyConsoleUser(store, &uid, NULL);
    CFRelease(store);

    bool isPreLogin = true;
    if (name != NULL) {
//        CFStringGetCString(name, buf, bufflen, kCFStringEncodingUTF8);
        NSString * userName = (__bridge NSString *)name;
        isPreLogin = [userName isEqual:@"loginwindow"];
        CFRelease(name);
    } else {
        isPreLogin = true;
    }
    
    return isPreLogin;
}

/// 获取屏幕锁定状态
+ (bool)ymScreenIsLock {
    CFDictionaryRef dictionaryRef = CGSessionCopyCurrentDictionary();
    if (dictionaryRef) {
        NSDictionary * dic = (__bridge NSDictionary *)dictionaryRef;
        CFRelease(dictionaryRef);
        return [[dic objectForKey:@"CGSSessionScreenIsLocked"] intValue];
    }
    return false;
}

/// 获取登录状态
+ (bool)ymLoginDone {
    CFDictionaryRef dictionaryRef = CGSessionCopyCurrentDictionary();
    if (dictionaryRef) {
        NSDictionary * dic = (__bridge NSDictionary *)dictionaryRef;
        CFRelease(dictionaryRef);
        return [[dic objectForKey:@"kCGSessionLoginDoneKey"] intValue];
    }
    return false;
}

/// 获取系统内存大小
+ (NSInteger)ymMemory {
    NSInteger totalMemorySize = (NSInteger)[NSProcessInfo processInfo].physicalMemory;
    return totalMemorySize;
}

/// 获取系统启动/休眠/唤醒时间
/// @param type 获取类型
+ (NSString *)ymSysctlType:(kSysctlDateType)type error:(NSString **)error {
    NSString * script = @"";
    switch (type) {
        case kSysctlDateType_Boottime:
            script = @"sysctl -a |grep kern.boottime";
            break;
        case kSysctlDateType_Sleeptime:
            script = @"sysctl -a |grep kern.sleeptime";
            break;
        case kSysctlDateType_Waketime:
            script = @"sysctl -a |grep kern.waketime";
            break;
    }
    
    
    NSString * output;
    int exitStatus;
    [YMRunShellTool runScript:@[script] errorReason:error output:&output exitStatus:&exitStatus];
    
    NSRange prefixRange = [output rangeOfString:@"sec = "];
    NSRange suffixRange = [output rangeOfString:@","];
    NSInteger startIndex = prefixRange.location+prefixRange.length;
    NSInteger length = suffixRange.location - startIndex;
    if (output.length >= startIndex+length) {
        output = [output substringWithRange:NSMakeRange(startIndex, length)];
    }
    
    return output;
}

#pragma mark private
/// 查找正在运行的指定进程
/// @param tempProcessName 进程名
+ (BOOL)_runningProcesses:(NSString *)tempProcessName {
    NSArray * array = [self _ymRuningProcessList];
    for (NSDictionary * dic in array) {
        if ([dic[@"ProcessName"] isEqual:tempProcessName]) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray <NSDictionary *> *)_ymRuningProcessList {
    //指定名字参数，按照顺序第一个元素指定本请求定向到内核的哪个子系统，第二个及其后元素依次细化指定该系统的某个部分。
    //CTL_KERN，KERN_PROC,KERN_PROC_ALL 正在运行的所有进程
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL ,0};
 
 
    size_t miblen = 4;
    //值-结果参数：函数被调用时，size指向的值指定该缓冲区的大小；函数返回时，该值给出内核存放在该缓冲区中的数据量
    //如果这个缓冲不够大，函数就返回ENOMEM错误
    size_t size;
    //返回0，成功；返回-1，失败
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
 
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess) {
            if (process) {
                free(process);
                process = NULL;
            }
            return nil;
        }
 
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    
    
    if (st == 0) {
        if (size % sizeof(struct kinfo_proc) == 0) {
            int nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess) {
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i = nprocess - 1; i >= 0; i--) {
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    NSString * proc_CPU = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_estcpu];
                    double t = [[NSDate date] timeIntervalSince1970] - process[i].kp_proc.p_un.__p_starttime.tv_sec;
                    NSString * proc_useTiem = [[NSString alloc] initWithFormat:@"%f",t];
 
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setValue:processID forKey:@"ProcessID"];
                    [dic setValue:processName forKey:@"ProcessName"];
                    [dic setValue:proc_CPU forKey:@"ProcessCPU"];
                    [dic setValue:proc_useTiem forKey:@"ProcessUseTime"];
                    [array addObject:dic];
                }
 
                free(process);
                process = NULL;
                //NSLog(@"array = %@",array);
 
                return array;
            }
        }
    }
 
    return nil;
    
}

/// 获取系统信息(字符数据)
/// @param typeSpecifier 如：hw.machine，参照终端执行sysctl -a
+ (NSString *)_ymSystemInfoStr:(NSString *)typeSpecifier {
    const char * type = [typeSpecifier UTF8String];
    
    size_t size;
    sysctlbyname(type, NULL, &size, NULL, 0);
    
    char *machine = (char *)malloc(size);
    sysctlbyname(type, machine, &size, NULL, 0);
    
    NSString * info = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return info;
}

/// 获取系统信息(整型数据)
/// @param typeSpecifier 如：hw.machine，参照终端执行sysctl -a
+ (int)_ymSystemInfoInt:(NSString *)typeSpecifier {
    const char * type = [typeSpecifier UTF8String];
    
    size_t size;
    sysctlbyname(type, NULL, &size, NULL, 0);
    
    int ret;
    sysctlbyname(type, &ret, &size, NULL, 0);
    return ret;
}

/// 获取系统信息(整型数据)
/// @param typeSpecifier 如：HW_NCPU
+ (int)_ymSystemInfoSysctlInt:(uint)typeSpecifier {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, (int)typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return results;
}

#pragma mark 风扇
/// 设置SMC二进制路径（默认在应用中）
/// @param binaryPath 二进制文件
+ (void)setSMCBinaryPath:(NSString *)binaryPath {
    [[smcWrapper share] setSMCBinaryPath:binaryPath];
}

/// 获取风扇转速
/// @param fanNumber  风扇编号
+ (int)getFanRPM:(int)fanNumber {
    return [[smcWrapper share] getFanRPM:fanNumber];
}

/// 获取风扇个数
+ (int)getFanNum {
    return [[smcWrapper share] getFanNum];
}

/// 风扇描述
/// @param fanNumber 风扇编号
+ (NSString*)getFanDescript:(int)fanNumber {
    return [[smcWrapper share] getFanDescript:fanNumber];
}

/// 获取最小转速
/// @param fanNumber 风扇编号
+ (int)getMinSpeed:(int)fanNumber {
    return [[smcWrapper share] getMinSpeed:fanNumber];
}

/// 获取最大转速
/// @param fanNumber 风扇编号
+ (int)getMaxSpeed:(int)fanNumber {
    return [[smcWrapper share] getMaxSpeed:fanNumber];
}

/// 获取风扇模式
/// @param fanNumber 风扇编号
/// @return 0:自动 1:手动
+ (int)getFanMode:(int)fanNumber {
    return [[smcWrapper share] getFanMode:fanNumber];
}

/// 调用SMC命令以设置转速
/// @param key 键
/// @param value 值
+ (BOOL)setExternalWithKey:(NSString *)key value:(NSString *)value {
    return [[smcWrapper share] setExternalWithKey:key value:value];
}

/// 自动控制风扇转速
/// @param isAuto 是否自动
/// @param fanNumber 风扇编号
+ (BOOL)setFanAuto:(BOOL)isAuto fanNumber:(int)fanNumber {
    return [[smcWrapper share] setFanAuto:isAuto fanNumber:fanNumber];
}

/// 设置风扇转速
/// @param speed 转速
/// @param fanNumber 风扇编号
+ (BOOL)setFanSpeed:(int)speed fanNumber:(int)fanNumber {
    return [[smcWrapper share] setFanSpeed:speed fanNumber:fanNumber];
}

#pragma mark CPU
/// 获取CPU核总数
+ (int)ymCPUCoreCount {
    return [self _ymSystemInfoInt:@"machdep.cpu.core_count"];
}

/// 获取CPU线程数
+ (int)ymCPUThreadCount {
    return [self _ymSystemInfoInt:@"machdep.cpu.thread_count"];
}

/// 获取CPU名
+ (NSString *)ymCPUName {
    return [self _ymSystemInfoStr:@"machdep.cpu.brand_string"];
}

/// 获取CPU架构
+ (NSString *)ymCPUArchitecture {
    return [self _ymSystemInfoStr:@"hw.machine"];
}

/// 获取进程CPU使用情况（会根据使用占比由大到小排序）
/// @param limit 限制数量 0:全部返回
+ (NSArray <YMCPUUsage *> *)ymCPUUsagePerProcessWithLimit:(int)limit {
    NSTask * task = [[NSTask alloc] init];
    task.launchPath = @"/bin/ps";
    task.arguments = @[@"-Aceo pid,pcpu,comm", @"-r"];
    
    NSPipe * outputPipe = [[NSPipe alloc] init];
//    NSPipe * errorPipe = [[NSPipe alloc] init];
    
    
    YMDefer(releasePipe) {
        [outputPipe.fileHandleForReading closeFile];
//        [errorPipe.fileHandleForReading closeFile];
    };
    
    task.standardOutput = outputPipe;
//    task.standardError = errorPipe;
    
    @try {
        [task launch];
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@", exception);
        return nil;
    }
    
    NSData * outputData = [outputPipe.fileHandleForReading readDataToEndOfFile];
    NSString * output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    //    NSData * errorData = [errorPipe.fileHandleForReading readDataToEndOfFile];
//    NSString * error = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    
    if (output.length == 0) {
        return nil;
    }
    
    NSArray <NSString *> * processList = [output componentsSeparatedByString:@"\n"];
    NSMutableArray <YMCPUUsage *> * usages = [NSMutableArray array];
    for (int index = 0; index < processList.count; index++) {
        if (limit > 0 && index > limit) {
            return usages;
        }
        
        NSString * value = processList[index];
        if (value.length == 0) {
            continue;;
        }
        
        if (index != 0) {
            NSString * pidString = [self _findAndCrop:&value rex:@"\\d+ "];
            NSString * usageString = [self _findAndCrop:&value rex:@"[0-9,.]+ "];
            NSString * command = value;
            NSString * name = @"";
            NSImage * icon = nil;
            NSRunningApplication * application = [NSRunningApplication runningApplicationWithProcessIdentifier:(pid_t)[pidString integerValue]];
            if (application) {
                name = application.localizedName;
                icon = application.icon;
            }
            
            YMCPUUsage * cpuUsage = [[YMCPUUsage alloc] init];
            cpuUsage.pid = [pidString intValue];
            cpuUsage.usage = [usageString doubleValue];
            cpuUsage.command = command;
            cpuUsage.name = name;
            cpuUsage.icon = icon;
            [usages addObject:cpuUsage];
        }
    }
    
    return usages;
}

/// 获取CPU使用情况
/// @param systemUsage 系统占比
/// @param userUsage 用户占比
/// @param idleUsage 闲置占比
/// @param cpuUsagesPerCore 各核使用占比
+ (void)ymCPUUsage:(float *)systemUsage userUsage:(float *)userUsage idleUsage:(float *)idleUsage cpuUsagesPerCore:(NSArray <NSNumber *> **)cpuUsagesPerCore {
    [[self share] _ymCPUUsage:systemUsage userUsage:userUsage idleUsage:idleUsage cpuUsagesPerCore:cpuUsagesPerCore];
}

- (void)_ymCPUUsage:(float *)systemUsage userUsage:(float *)userUsage idleUsage:(float *)idleUsage cpuUsagesPerCore:(NSArray <NSNumber *> **)cpuUsagesPerCore {
    NSLock * CPUUsageLock = [[NSLock alloc] init];
    
    kern_return_t result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &(_numCPUsU), &(_cpuInfo), &(_numCpuInfo));
    if (result == KERN_SUCCESS) {
        [CPUUsageLock lock];
        self.usagePerCore = [NSMutableArray array];
        
        for (int i = 0; i < _numCPUsU; i++) {
            int32_t inUse;
            int32_t total;
            if (_prevCpuInfo) {
                inUse = _cpuInfo[CPU_STATE_MAX * i + CPU_STATE_USER] -
                        _prevCpuInfo[CPU_STATE_MAX * i + CPU_STATE_USER] +
                        _cpuInfo[CPU_STATE_MAX * i + CPU_STATE_SYSTEM] -
                        _prevCpuInfo[CPU_STATE_MAX * i + CPU_STATE_SYSTEM] +
                        _cpuInfo[CPU_STATE_MAX * i + CPU_STATE_NICE] -
                        _prevCpuInfo[CPU_STATE_MAX * i + CPU_STATE_NICE];
                total = inUse + _cpuInfo[CPU_STATE_MAX * i + CPU_STATE_IDLE] - _prevCpuInfo[CPU_STATE_MAX * i + CPU_STATE_IDLE];
            } else {
                inUse = _cpuInfo[CPU_STATE_MAX * i + CPU_STATE_USER] +
                        _cpuInfo[CPU_STATE_MAX * i + CPU_STATE_SYSTEM] +
                        _cpuInfo[CPU_STATE_MAX * i + CPU_STATE_NICE];
                total = inUse + _cpuInfo[CPU_STATE_MAX * i + CPU_STATE_IDLE];
            }
            
            if (total != 0) {
                [self.usagePerCore addObject:@(inUse * 1.0 / total * 1.0)];
            }
        }
        [CPUUsageLock unlock];
                
        if(_prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * _numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCpuInfo, prevCpuInfoSize);
        }
        
        _prevCpuInfo = _cpuInfo;
        _numPrevCpuInfo = _numCpuInfo;
        
        _cpuInfo = nil;
        _numCpuInfo = 0;
    }
    
    static host_cpu_load_info_data_t previous_info = {0, 0, 0, 0};
    mach_msg_type_number_t count = HOST_CPU_LOAD_INFO_COUNT;
    host_cpu_load_info_data_t info;
    kern_return_t kr = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (host_info_t)&info, &count);
    if (kr != KERN_SUCCESS) {
        return;
    }
    
    natural_t userDiff   = info.cpu_ticks[CPU_STATE_USER] - previous_info.cpu_ticks[CPU_STATE_USER];
    natural_t niceDiff   = info.cpu_ticks[CPU_STATE_NICE] - previous_info.cpu_ticks[CPU_STATE_NICE];
    natural_t systemDiff = info.cpu_ticks[CPU_STATE_SYSTEM] - previous_info.cpu_ticks[CPU_STATE_SYSTEM];
    natural_t idleDiff   = info.cpu_ticks[CPU_STATE_IDLE] - previous_info.cpu_ticks[CPU_STATE_IDLE];
    natural_t totalTicks  = userDiff + niceDiff + systemDiff + idleDiff;
    previous_info    = info;
    
    float system = systemDiff * 1.0 / totalTicks;
    float user = userDiff * 1.0 / totalTicks;
    float idle = idleDiff * 1.0 / totalTicks;
    
    if (systemUsage && system >= 0) {
        *systemUsage = system;
    }
    
    if (userUsage && user >= 0) {
        *userUsage = user;
    }
    
    if (idleUsage && idle >= 0) {
        *idleUsage = idle;
    }
    
    if (cpuUsagesPerCore) {
        *cpuUsagesPerCore = self.usagePerCore;
    }
}

/// 通过正则表达式获取指定的内容
/// @param originStr 字符串源
/// @param rex  正则表达式规则
+ (NSString *)_findAndCrop:(NSString **)originStr rex:(NSString *)rex {
    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:rex options:0 error:nil];
    NSRange stringRange = NSMakeRange(0, (*originStr).length);
    
    NSTextCheckingResult * result = [regex firstMatchInString:(*originStr) options:0 range:stringRange];
    if (result) {
        NSString * destStr = [(*originStr) substringWithRange:result.range];
        destStr = [destStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSUInteger end = result.range.location + result.range.length;
        (*originStr) = [(*originStr) substringWithRange:NSMakeRange(end, (*originStr).length - end)];
        return destStr;
    }
    return @"";
}

#pragma mark GPU
/// 获取GPU名(10.11支持)
+ (NSString *)ymGPUName {
    if (@available(macOS 10.11, *)) {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        return device.name;
    } else {
        return nil;
    }
}

/// 获取GPU列表(10.11支持)
+ (NSArray <NSString *> *)ymGPUNameList {
    NSMutableArray * gpuList = [NSMutableArray array];
    if (@available(macOS 10.11, *)) {
        NSArray <id<MTLDevice>> * array = MTLCopyAllDevices();
        for (int i = 0; i < array.count; i++) {
            id<MTLDevice> device = array[i];
            if (device.name) {
                [gpuList addObject:device.name];
            }
        }
        return gpuList;
    } else {
        return nil;
    }
}

@end
