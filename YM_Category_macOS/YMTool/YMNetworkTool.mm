//
//  YMNetworkTool.m
//  YMTool
//
//  Created by 海南有趣 on 2020/5/11.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#if IS_LIBRARY
#import "YMToolLibrary.h"
#else
#import "YMTool.h"
#endif

#import <SystemConfiguration/SCNetworkConfiguration.h>
#import <SystemConfiguration/SCDynamicStore.h>

#import <CoreWLAN/CoreWLAN.h>

#import <AppKit/AppKit.h>

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <vector>
#include <string>

#pragma mark - YMLocalIPInfo
@implementation YMLocalIPInfo

- (NSString *)description {
    NSString * description = [NSString stringWithFormat:@"ifa_name:%@ ip:%@ mask:%@ dstaddr:%@",self.ifa_name, self.ip, self.mask, self.dstaddr];
    return description;
}

@end






#pragma mark - YMNetworkProcess
@implementation YMNetworkProcess

@end






NSString * const YMNetworkDisplayNameKey = @"YMNetworkDisplayNameKey";
NSString * const YMNetworkInterfaceTypeKey = @"YMNetworkInterfaceTypeKey";
NSString * const YMNetworkInterfaceNameKey = @"YMNetworkInterfaceNameKey";
NSString * const YMNetworkBSDKey = @"YMNetworkBSDKey";
NSString * const YMNetworkMACAddressKey = @"YMNetworkMACAddressKey";

#pragma mark - YMNetworkTool
@interface YMNetworkTool ()


@end

@implementation YMNetworkTool
    
/// DNS解析
/// @param domain 域名
/// @param dns dns
/// @param dnsType 记录类型
/// @param errorReason 错误原因
/// @param output 输出
/// @param terminationStatus 0成功
+ (void)ymDNSResolution:(NSString *)domain dns:(NSString *)dns dnsType:(kDNSType)dnsType errorReason:(NSString **)errorReason output:(NSString **)output terminationStatus:(int *)terminationStatus {
    NSString * type = @"";
    switch (dnsType) {
        case kDNSType_A: type = @"A"; break;
        case kDNSType_AAAA: type = @"AAAA"; break;
        case kDNSType_CNAME: type = @"CNAME"; break;
        case kDNSType_MX: type = @"MX"; break;
        case kDNSType_NS: type = @"NS"; break;
        case kDNSType_SOA: type = @"SOA"; break;
        case kDNSType_TXT: type = @"TXT"; break;
        default: break;
    }

    NSString * tempErrorReason;
    NSString * tempOutput;
    int tempExitStatus;
    
    NSString * shell = [NSString stringWithFormat:@"nslookup -type=%@ %@ %@", type, domain, dns];
    NSArray * shells = @[shell];
    [YMRunShellTool runScript:shells errorReason:&tempErrorReason output:&tempOutput exitStatus:&tempExitStatus];
    
    if (dnsType == kDNSType_TXT) {
        NSRange prefixRange = [tempOutput rangeOfString:@"\""];
        NSRange suffixRange = [tempOutput rangeOfString:@"\"" options:NSBackwardsSearch];
        NSInteger local = (prefixRange.location+1);
        NSInteger length = (suffixRange.location - prefixRange.location-1);
        if (tempOutput.length > local && tempOutput.length >= local + length) {
            tempOutput = [tempOutput substringWithRange:NSMakeRange(local, length)];
        }
    }
    
    if (errorReason) {
        *errorReason = tempErrorReason;
    }
    if (output) {
        *output = tempOutput;
    }
    if (terminationStatus) {
        *terminationStatus = tempExitStatus;
    }
}

/// 获取本地所有IP信息
+ (NSMutableArray <YMLocalIPInfo *> *)ymAllLocalIPInfo {
    NSMutableArray <YMLocalIPInfo *> *localIPInfos = [NSMutableArray new];
    
    struct ifaddrs *interfaces = NULL;
    int success = getifaddrs(&interfaces);
    if (success == 0) { // 0 表示获取成功
        struct ifaddrs *temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                NSString * ifaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                std::string inetr = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr);
                std::string ntoastr = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr);
                std::string dstaddr = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr);
                
                YMLocalIPInfo * localIP = [[YMLocalIPInfo alloc] init];
                localIP.ip = [[NSString alloc] initWithCString:inetr.c_str() encoding:NSUTF8StringEncoding];
                localIP.mask = [[NSString alloc] initWithCString:ntoastr.c_str() encoding:NSUTF8StringEncoding];
                localIP.dstaddr = [[NSString alloc] initWithCString:dstaddr.c_str() encoding:NSUTF8StringEncoding];
                localIP.ifa_name = ifaName;
                [localIPInfos addObject:localIP];
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return localIPInfos;
}

/// 获取系统中所有具有网络功能的接口
+ (NSArray <NSDictionary *> *)ymAllNetworkEquipment {
    NSMutableArray <NSDictionary <NSString *,NSString *>*>*networkServiceorder = [[NSMutableArray alloc] init];

    CFArrayRef ref = SCNetworkInterfaceCopyAll();
    NSArray* networkInterfaces = (__bridge NSArray *)ref;
    for(int i = 0; i < networkInterfaces.count; i += 1) {
        SCNetworkInterfaceRef interface = (__bridge SCNetworkInterfaceRef)(networkInterfaces[i]);

        // 获取本地化名称 例如: ("Ethernet", "FireWire")
        CFStringRef displayName = SCNetworkInterfaceGetLocalizedDisplayName(interface);
        // 网络接口类型
        CFStringRef interfaceName = SCNetworkInterfaceGetInterfaceType(interface);
        // 获取bsd接口名称
        CFStringRef bsdName = SCNetworkInterfaceGetBSDName(interface);
        // MAC地址
        CFStringRef macAddress = SCNetworkInterfaceGetHardwareAddressString(interface);
        
        NSString * nameStr = @"";
        if (displayName) {
            nameStr = [NSString stringWithString:(__bridge NSString *)displayName];
        }
        
        NSString * interfaceStr = @"";
        if (interfaceName) {
            interfaceStr = [NSString stringWithString:(__bridge NSString *)interfaceName];
        }
        
        NSString * bsdStr = @"";
        if (bsdName) {
            bsdStr = [NSString stringWithString:(__bridge NSString *)bsdName];
        }
        
        NSString * macStr = @"";
        if (macAddress) {
            macStr = [NSString stringWithString:(__bridge NSString *)macAddress];
        }
        
        kNetworkInterfaceType type = kNetworkInterfaceTypeOther;
        if (CFStringCompare(interfaceName, kSCNetworkInterfaceTypeEthernet, kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            type = kNetworkInterfaceTypeEthernet;
        } else if (CFStringCompare(interfaceName, kSCNetworkInterfaceTypeIEEE80211, kCFCompareCaseInsensitive) == kCFCompareEqualTo ||
                   CFStringCompare(interfaceName, kSCNetworkInterfaceTypeWWAN, kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            type = kNetworkInterfaceTypeWifi;
        } else if (CFStringCompare(interfaceName, kSCNetworkInterfaceTypeBluetooth, kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            type = kNetworkInterfaceTypeBluetooth;
        }

        [networkServiceorder addObject:@{
            YMNetworkDisplayNameKey : nameStr,
            YMNetworkInterfaceTypeKey : [NSString stringWithFormat:@"%d", type],
            YMNetworkInterfaceNameKey : interfaceStr,
            YMNetworkBSDKey : bsdStr,
            YMNetworkMACAddressKey : macStr,
        }];
    }
    
    NSArray * array = [networkServiceorder mutableCopy];
    
    if (ref)
        CFRelease(ref);
    
    return array;
}

/// 获取系统中当前活跃的网络设备
+ (NSDictionary *)ymActiveInterface {
    NSString *currentBsdName = [self ymActiveNetworkEquipment];
    NSArray *networkServiceorder = [self ymAllNetworkEquipment];
        
    for (NSDictionary <NSString *,NSString *> * dict in networkServiceorder) {
        if ([dict[YMNetworkBSDKey] isEqualToString:currentBsdName]) {
            return dict;
        }
    }
    return nil;
}

/// 获取系统中活跃的具有网络功能的接口(en0/en1/...)
+ (NSString *)ymActiveNetworkEquipment {
    // 创建系统配置服务器互动会话
    SCDynamicStoreRef ds = SCDynamicStoreCreate(kCFAllocatorDefault, CFSTR("myApplication"), NULL, NULL);
    // 获取ip6配置信息
    CFDictionaryRef dr6 = (CFDictionaryRef)SCDynamicStoreCopyValue(ds, CFSTR("State:/Network/Global/IPv6"));
    // 获取ip4配置信息
    CFDictionaryRef dr4 = (CFDictionaryRef)SCDynamicStoreCopyValue(ds, CFSTR("State:/Network/Global/IPv4"));
    // ip6
    if (dr6) {
        // 获取配置信息Bsd接口名称
        void * router = (void *)CFDictionaryGetValue(dr6, CFSTR("PrimaryInterface"));
        NSString *routerString = [NSString stringWithString:(__bridge NSString *)router];
        CFRelease(dr6);
        CFRelease(ds);
        return routerString;
    }
    // ip4
    else if(dr4) {
        // 获取配置信息Bsd接口名称
        void * router = (void *)CFDictionaryGetValue(dr4, CFSTR("PrimaryInterface"));
        NSString *routerString = [NSString stringWithString:(__bridge NSString *)router];
        CFRelease(dr4);
        CFRelease(ds);
        return routerString;
    }
    
    CFRelease(ds);
    return 0;
}

/// 获取当前活跃的网络接口的设备名(包含Ethernet：以太网 包含Wi-Fi：Wifi)
+ (NSString *)ymActiveNetworkEquipmentName {
    NSString *currentBsdName = [self ymActiveNetworkEquipment];
    NSArray *networkServiceorder = [self ymAllNetworkEquipment];
        
    for (NSDictionary <NSString *,NSString *>*dict in networkServiceorder) {
        if ([dict[YMNetworkBSDKey] isEqualToString:currentBsdName]) {
            // 获取bsd接口对应的本地化名称
            return dict[YMNetworkDisplayNameKey];
        }
    }
    return nil;
}

/// 获取SSID
+ (NSString *)ymSSID {
    return [[CWWiFiClient sharedWiFiClient] interface].ssid;
}

/// 获取网络状态
+ (bool)ymNetworkStatus {
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    
    bool available = false;
    SCNetworkReachabilityFlags flags = 0;
    if (SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags))
    {
        if ((flags & kSCNetworkReachabilityFlagsIsLocalAddress) ||
            ((flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)))
            available = true;
    }
    return available;
}

#pragma mark IP获取
/// 获取本地IP
+ (NSString *)ymLocalIP {
    for (YMLocalIPInfo * ipInfo in [self ymAllLocalIPInfo]) {
        if ([ipInfo.ifa_name containsString:@"en"]) {
            return ipInfo.ip;
        }
    }
    return nil;
}

/// 获取公网IPv4
+ (NSString *)ymPublicIPv4 {
    NSString * publicIP = nil;
    try {
        NSURL * url = [NSURL URLWithString:@"https://api.ipify.org"];
        NSString * value = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        if (![value containsString:@"<!DOCTYPE html>"] && [self _isIPv4:value]) {
            publicIP = value;
        }
    } catch (NSException *exception) {
        NSLog(@"get public ipv4:%@", exception);
    }
    return publicIP;
}

/// 获取公网IPv6
+ (NSString *)ymPublicIPv6 {
    NSString * publicIP = nil;
    try {
        NSURL * url = [NSURL URLWithString:@"https://api64.ipify.org"];
        NSString * value = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        if (![self _isIPv4:value] && ![value isEqual:[self ymPublicIPv4]]) {
            publicIP = value;
        }
    } catch (NSException *exception) {
        NSLog(@"get public ipv6:%@", exception);
    }
    return publicIP;
}

+ (BOOL)_isIPv4:(NSString *)ipv4 {
    NSArray * ips = [ipv4 componentsSeparatedByString:@"."];
    BOOL isIPV4 = YES;
    if (ips.count == 4) {
        for (NSString * ip in ips) {
            if (!([ip integerValue] >= 0 && [ip integerValue] < 256)) {
                isIPV4 = NO;
                break;
            }
        }
    } else {
        isIPV4 = NO;
    }
    return isIPV4;
}

#pragma mark 流量统计
/// 获取进程流量
+ (NSArray <YMNetworkProcess *> *)ymProcessBandwidth {
    NSTask * task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/nettop";
    task.arguments = @[@"-P", @"-L", @"1", @"-k", @"time,interface,state,rx_dupe,rx_ooo,re-tx,rtt_avg,rcvsize,tx_win,tc_class,tc_mgt,cc_algo,P,C,R,W,arch"];
    
    NSPipe * outputPipe = [[NSPipe alloc] init];
    NSPipe * errorPipe = [[NSPipe alloc] init];
    
    YMDefer(closefile) {
        [[outputPipe fileHandleForReading] closeFile];
        [[errorPipe fileHandleForReading] closeFile];
    };
    
    task.standardOutput = outputPipe;
    task.standardError = errorPipe;
    
    try {
        [task launch];
    } catch (NSException * exception) {
        NSLog(@"%@", exception);
        return nil;
    }
    
    NSData * outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
    NSData * errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
    NSString * output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
//    NSString * error = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    
    if (output.length == 0) {
        return nil;
    }
    
    NSMutableArray <YMNetworkProcess *> * list = [NSMutableArray array];
    BOOL firstLine = false;
    for (NSString * str in [output componentsSeparatedByString:@"\n"]) {
        if (!firstLine) {
            firstLine = YES;
            continue;
        }
        
        NSArray * parsedLine = [str componentsSeparatedByString:@","];
        if (parsedLine.count < 3) {
            continue;
        }
        
        YMNetworkProcess * process = [[YMNetworkProcess alloc] init];
        process.time = [NSDate dateWithTimeIntervalSinceNow:0];
        
        NSArray * nameArray = [parsedLine[0] componentsSeparatedByString:@"."];
        if ([nameArray lastObject]) {
            process.pid = [nameArray lastObject];
        }
        
        NSRunningApplication * app = [NSRunningApplication runningApplicationWithProcessIdentifier:(pid_t)[process.pid integerValue]];
        if (app) {
            process.name = app.localizedName ?: [nameArray firstObject];
            process.icon = app.icon ?: [[NSWorkspace sharedWorkspace] iconForFile:@"/bin/bash"];
        } else {
            process.name = [nameArray firstObject];
            process.icon = [[NSWorkspace sharedWorkspace] iconForFile:@"/bin/bash"];
        }
        
        if (process.name.length == 0) {
            process.name = process.pid;
        }
        
        NSInteger download = [parsedLine[1] integerValue];
        if (download) {
            process.download = download;
        }
        
        NSInteger upload = [parsedLine[2] integerValue];
        if (upload) {
            process.upload = upload;
        }
        
        [list addObject:process];
    }
    
    list =
    [list sortedArrayUsingComparator:^NSComparisonResult(YMNetworkProcess *  _Nonnull obj1, YMNetworkProcess *  _Nonnull obj2) {
        NSInteger firstMax = MAX(obj1.download, obj1.upload);
        NSInteger secondMax = MAX(obj2.download, obj2.upload);
        NSInteger firstMin = MAX(obj1.download, obj1.upload);
        NSInteger secondMin = MAX(obj2.download, obj2.upload);
        
        if (firstMax == secondMax && firstMin == secondMin) {
            return ([obj1.time timeIntervalSince1970] < [obj2.time timeIntervalSince1970] ? NSOrderedDescending : NSOrderedAscending);
        } else if (firstMax == secondMax && firstMin != secondMin) {
            return (firstMin < secondMin ? NSOrderedDescending : NSOrderedAscending);
        }
        
        return firstMax < secondMax ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    return list;
}


@end
