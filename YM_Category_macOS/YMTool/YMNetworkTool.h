//
//  YMNetworkTool.h
//  YMTool
//
//  Created by 海南有趣 on 2020/5/11.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, kDNSType) {
    kDNSType_A,     // 地址记录，用来指定域名的 IPv4 地址，如果需要将域名指向一个 IP 地址，就需要添加 A 记录。
    kDNSType_AAAA,  // 用来指定主机名(或域名)对应的 IPv6 地址记录。
    kDNSType_CNAME, // 如果需要将域名指向另一个域名，再由另一个域名提供 ip 地址，就需要添加 CNAME 记录。
    kDNSType_MX,    // 如果需要设置邮箱，让邮箱能够收到邮件，需要添加 MX 记录。
    kDNSType_NS,    // 域名服务器记录，如果需要把子域名交给其他 DNS 服务器解析，就需要添加 NS 记录。
    kDNSType_SOA,   // SOA 这种记录是所有区域性文件中的强制性记录。它必须是一个文件中的第一个记录。
    kDNSType_TXT,   // 可以写任何东西，长度限制为 255。绝大多数的 TXT记录是用来做 SPF 记录(反垃圾邮件)。
};

typedef NS_ENUM(int, kNetworkInterfaceType) {
    kNetworkInterfaceTypeWifi,      // Wifi
    kNetworkInterfaceTypeEthernet,  // 以太网
    kNetworkInterfaceTypeBluetooth, // 蓝牙
    kNetworkInterfaceTypeOther,     // 其他
};


#pragma mark - YMLocalIPInfo
@interface YMLocalIPInfo : NSObject

@property (copy, nonatomic) NSString * ip;       // ip地址
@property (copy, nonatomic) NSString * mask;     // 子网掩码
@property (copy, nonatomic) NSString * dstaddr;  // 广播地址

// https://stackoverflow.com/questions/29958143/what-are-en0-en1-p2p-and-so-on-that-are-displayed-after-executing-ifconfig
@property (copy, nonatomic) NSString * ifa_name; // 接口名

@end








#pragma mark - YMNetworkProcess
@interface YMNetworkProcess : NSObject

@property (strong, nonatomic) NSDate * time;
@property (copy, nonatomic) NSString * name;
@property (copy, nonatomic) NSString * pid;
@property (assign, nonatomic) NSInteger download;
@property (assign, nonatomic) NSInteger upload;
@property (strong, nonatomic) NSImage * icon;

@end











#pragma mark - YMNetworkTool
@interface YMNetworkTool : NSObject

FOUNDATION_EXPORT NSString * const YMNetworkDisplayNameKey;
FOUNDATION_EXPORT NSString * const YMNetworkInterfaceTypeKey;
FOUNDATION_EXPORT NSString * const YMNetworkInterfaceNameKey;
FOUNDATION_EXPORT NSString * const YMNetworkBSDKey;
FOUNDATION_EXPORT NSString * const YMNetworkMACAddressKey;

/// DNS解析
/// @param domain 域名
/// @param dns dns
/// @param dnsType 记录类型
/// @param errorReason 错误原因
/// @param output 输出
/// @param terminationStatus 0成功
+ (void)ymDNSResolution:(NSString *)domain dns:(NSString *)dns dnsType:(kDNSType)dnsType errorReason:(NSString **)errorReason output:(NSString **)output terminationStatus:(int *)terminationStatus;

/// 获取本地所有IP信息
+ (NSMutableArray <YMLocalIPInfo *> *)ymAllLocalIPInfo;

/// 获取系统中所有具有网络功能的接口
+ (NSArray <NSDictionary *> *)ymAllNetworkEquipment;

/// 获取系统中当前活跃的网络设备
+ (NSDictionary *)ymActiveInterface;

/// 获取当前活跃的网络接口的设备名(包含Ethernet：以太网 包含Wi-Fi：Wifi)
+ (NSString *)ymActiveNetworkEquipmentName;

/// 获取SSID
+ (NSString *)ymSSID;

/// 获取网络状态
+ (bool)ymNetworkStatus;

#pragma mark IP获取
/// 获取本地IP
+ (NSString *)ymLocalIP;

/// 获取公网IPv4
+ (NSString *)ymPublicIPv4;

/// 获取公网IPv6
+ (NSString *)ymPublicIPv6;

#pragma mark 流量统计
/// 获取进程流量
+ (NSArray <YMNetworkProcess *> *)ymProcessBandwidth;

@end

