//
//  YMNetworkTool.h
//  YMTool
//
//  Created by 海南有趣 on 2020/5/11.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 网络状态 */
typedef NS_ENUM(NSInteger, kNetworkType) {
    kNetworkType_Unknow,
    kNetworkType_Wifi,
    /** GPRS */
    kNetworkType_GPRS,
    /** 2G */
    kNetworkType_2G,
    /** 3G */
    kNetworkType_3G,
    /** 4G */
    kNetworkType_4G,
    /** 2.75G EDGE */
    kNetworkType_Edge,
    /** 3.5G HSDPA */
    kNetworkType_HSDPA,
    /** 3.5G HSUPA */
    kNetworkType_HSUPA,
    /** HRPD */
    kNetworkType_HRPD
};

@interface YMNetworkTool : NSObject

/** ACL白名单列表 */
+ (NSArray <NSString *> *)ACLWhiteList;

/** 防火墙列表 */
+ (NSArray <NSString *> *)GFWList;

#pragma mark - 获取本机IP
/** 本机IP */
+ (NSString *)ymLocalIP;

/** 公网IP */
+ (NSString *)ymPublicIP;

/** DNS服务器 */
+ (NSArray *)ymDNSServers;

/** 获取子网掩码 */
+ (NSString *)ymSubnetMask;

/** 判断是否使用了网络代理 */
+ (BOOL)ymCheckUserProxy;

#pragma mark - 网络信息
/** 网络类型 */
+ (kNetworkType)networkType;

/** 网路运营商 */
+ (NSString *)networkCarrier;

/** 蜂窝信号强度 */
+ (NSInteger)networkSignalStrength;

#pragma mark - 网络数据处理
/** IPV4格式化 */
+ (NSString *)ymIPV4Formatter:(struct in_addr)ipv4Addr;

/** IPV6格式化 */
+ (NSString *)ymIPV6Formatter:(struct in6_addr)ipv6Addr;

/** 获取当前设备网关地址 */
+ (NSString *)ymGatewayIP;

/** 获取IPV4网关地址 */
+ (NSString *)ymGatewayIPV4;

/** 获取IPV4网关地址 */
+ (NSString *)ymGatewayIPV6;

/** 通过hostname获取ip列表/DNS解析地址 */
+ (NSArray *)ymDNSWithHost:(NSString *)hostName;

/**
 * 根据域名获取IPV4 DNS
 * @param hostName 域名
 */
+ (NSArray *)ymIPV4DnsWithHost:(NSString *)hostName;

/**
 * 根据域名获取IPV6 DNS
 * @param hostName 域名
 */
+ (NSArray *)ymIPV6DnsWithHost:(NSString *)hostName;

/// 解析域名，获取域名的TXT记录
/// @param hostName 域名
+ (NSArray *)ymTXTRecordWithHost:(NSString *)hostName;

@end

NS_ASSUME_NONNULL_END
