//
//  YMNetworkTool.m
//  YMTool
//
//  Created by 海南有趣 on 2020/5/11.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "YMNetworkTool.h"
#import "Reachability.h"
#import "YMToolHeader.h"

#include <sys/stat.h>
#include <unistd.h>
#include <dlfcn.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>




#include <netdb.h>
#include <sys/socket.h>
#include <dns.h>
#import <sys/sysctl.h>


#if TARGET_IPHONE_SIMULATOR
    #if __IPHONE_OS_VERSION_MAX_ALLOWED < 110000 //iOS11，用数字不用宏定义的原因是低版本XCode不支持110000的宏定义
        #include <net/route.h>
    #else
        #include "Route.h"
    #endif
#else
#include "Route.h"
#endif /*the very same from google-code*/

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a)-1) | (sizeof(long) - 1))) : sizeof(long))

@interface YMNetworkTool ()


@end

@implementation YMNetworkTool

/** ACL白名单列表 */
+ (NSArray <NSString *> *)ACLWhiteList {
    NSString * str = @"https://raw.githubusercontent.com/shadowsocks/shadowsocks-libev/master/acl/chn.acl";
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
    NSString * content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray * IPs = [[content componentsSeparatedByString:@"\n"] mutableCopy];
    [IPs removeObjectsInRange:NSMakeRange(0, 3)];
    return IPs;
}

/** 防火墙列表 */
+ (NSArray <NSString *> *)GFWList {
    // 获取内容
    NSString * str = @"https://raw.githubusercontent.com/petronny/gfwlist2pac/master/gfwlist.pac";
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
    NSString * content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // 截取域名
    NSRange range1 = [content rangeOfString:@"= ["];
    NSRange range2 = [content rangeOfString:@"];"];
    NSInteger startIndex = range1.location+range1.length;
    NSInteger endIndex = range2.location - startIndex;
    NSString * newContent =  [content substringWithRange:NSMakeRange(startIndex, endIndex)];
    for (NSString * placeStr in @[@"\t", @"]", @"[", @",", @"\"", @" "]) {
        newContent = [newContent stringByReplacingOccurrencesOfString:placeStr withString:@""];
    }
    
    // 删除空白域名
    NSMutableArray * IPs = [[newContent componentsSeparatedByString:@"\n"] mutableCopy];
    [IPs removeObject:@""];
    return IPs;
}

#pragma mark - 获取网络信息
+ (NSString *)ymLocalIP {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    success = getifaddrs(&interfaces);

    if (success == 0) {  // 0 表示获取成功

        temp_addr = interfaces;
        while (temp_addr != NULL) {
//            YMTooLog(@"ifa_name===%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
            // Check if interface is en0 which is the wifi connection on the iPhone
            if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"])
            {
                //如果是IPV4地址，直接转化
                if (temp_addr->ifa_addr->sa_family == AF_INET){
                    // Get NSString from C String
                    address = [self ymIPV4Formatter:((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr];
                }
                
                //如果是IPV6地址
                else if (temp_addr->ifa_addr->sa_family == AF_INET6){
                    address = [self ymIPV6Formatter:((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr];
                    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) break;
                }
            }

            temp_addr = temp_addr->ifa_next;
        }
    }

    freeifaddrs(interfaces);

    //以FE80开始的地址是单播地址
    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) {
        return address;
    } else {
        return @"127.0.0.1";
    }
}

/** 公网IP */
+ (NSString *)ymPublicIP {
    NSString * requestURL = [NSString stringWithFormat:@"http://pv.sohu.com/cityjson?ie=utf-8"];
    
    NSURL *ipURL = [NSURL URLWithString:requestURL];
    
    NSError * error;
    NSMutableString *ip = [NSMutableString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
    
    NSRange range = [ip rangeOfString:@"var returnCitySN = "];
    if (range.length > 0) {
        // 删除字符串多余字符串
        [ip deleteCharactersInRange:range];
        NSString * nowIp =[ip substringToIndex:ip.length-1];
        // 将字符串转换成二进制进行Json解析
        NSData * data = [nowIp dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data          options:NSJSONReadingMutableContainers error:nil];
        return dict[@"cip"] ? dict[@"cip"] : @"";
    }
    return @"";
}

/** 获取当前网络DNS服务器地址 */
+ (NSArray *)ymDNSServers {
    res_state res = malloc(sizeof(struct __res_state));
    int result = res_ninit(res);
    
    NSMutableArray *servers = [[NSMutableArray alloc] init];
    if (result == 0) {
        union res_9_sockaddr_union *addr_union = malloc(res->nscount * sizeof(union res_9_sockaddr_union));
        res_getservers(res, addr_union, res->nscount);
        
        for (int i = 0; i < res->nscount; i++) {
            if (addr_union[i].sin.sin_family == AF_INET) {
                char ip[INET_ADDRSTRLEN];
                inet_ntop(AF_INET, &(addr_union[i].sin.sin_addr), ip, INET_ADDRSTRLEN);
                NSString *dnsIP = [NSString stringWithUTF8String:ip];
                [servers addObject:dnsIP];
//                YMTooLog(@"IPv4 DNS IP: %@", dnsIP);
            } else if (addr_union[i].sin6.sin6_family == AF_INET6) {
                char ip[INET6_ADDRSTRLEN];
                inet_ntop(AF_INET6, &(addr_union[i].sin6.sin6_addr), ip, INET6_ADDRSTRLEN);
                NSString *dnsIP = [NSString stringWithUTF8String:ip];
                [servers addObject:dnsIP];
//                YMTooLog(@"IPv6 DNS IP: %@", dnsIP);
            } else {
//                YMTooLog(@"Undefined family.");
            }
        }
    }
    res_nclose(res);
    free(res);
    
    return [NSArray arrayWithArray:servers];
}

/** 获取子网掩码 */
+ (NSString *)ymSubnetMask {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                YMTooLog(@"%@", address);
            }
            temp_addr = temp_addr->ifa_next;
        }
        
    }

    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

/** 判断是否使用了网络代理 */
+ (BOOL)ymCheckUserProxy {
    NSDictionary *proxySettings =  (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSDictionary *settings = [proxies objectAtIndex:0];
    
    YMTooLog(@"host=%@", [settings objectForKey:(NSString *)kCFProxyHostNameKey]);
    YMTooLog(@"port=%@", [settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
    YMTooLog(@"type=%@", [settings objectForKey:(NSString *)kCFProxyTypeKey]);
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]){
        //没有设置代理
        return NO;
    }else{
        //设置代理了
        return YES;
    }
}

#pragma mark - 网络信息
/** 网络类型 */
+ (kNetworkType)networkType {
    // 获取网络类型
    Reachability * reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    kNetworkType networkType = kNetworkType_Unknow;
    switch (internetStatus) {
        case NotReachable:
            networkType = kNetworkType_Unknow;
            break;
        case ReachableViaWiFi:
            networkType = kNetworkType_Wifi;
            break;
        case ReachableViaWWAN: {
            networkType = [self WWANType];
            break;
        }
        default: break;
    }
    return networkType;
}

/** 网络运营商 */
+ (NSString *)networkCarrier {
    CTTelephonyNetworkInfo * networkInfo = [CTTelephonyNetworkInfo new];
    CTCarrier * carrier = networkInfo.subscriberCellularProvider;
    return carrier.carrierName;
}

/** 蜂窝信号强度 */
+ (NSInteger)networkSignalStrength {
    return getSignalStrength();
}

#pragma mark - 网络数据处理
/** IPV4格式化 */
+ (NSString *)ymIPV4Formatter:(struct in_addr)ipv4Addr {
    NSString *address = nil;
    
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if(inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

/** IPV6格式化 */
+ (NSString *)ymIPV6Formatter:(struct in6_addr)ipv6Addr {
    NSString *address = nil;
    
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if(inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

/** 获取当前设备网关地址 */
+ (NSString *)ymGatewayIP {
    NSString *address = nil;
    
    NSString *gatewayIPV4 = [self ymGatewayIPV4];
    NSString *gatewayIPV6 = [self ymGatewayIPV6];
    
    if (gatewayIPV6 != nil) {
        address = gatewayIPV6;
    } else {
        address = gatewayIPV4;
    }
    
    return address;
}

/** 获取IPV4网关地址 */
+ (NSString *)ymGatewayIPV4 {
    NSString *address = nil;

    /* net.route.0.inet.flags.gateway */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_GATEWAY};
    
    size_t l;
    char *buf, *p;
    struct rt_msghdr *rt;
    struct sockaddr *sa;
    struct sockaddr *sa_tab[RTAX_MAX];
    int i;

    if (sysctl(mib, sizeof(mib) / sizeof(int), 0, &l, 0, 0) < 0) {
        address = @"192.168.0.1";
    }

    if (l > 0) {
        buf = malloc(l);
        if (sysctl(mib, sizeof(mib) / sizeof(int), buf, &l, 0, 0) < 0) {
            address = @"192.168.0.1";
        }

        for (p = buf; p < buf + l; p += rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for (i = 0; i < RTAX_MAX; i++) {
                if (rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }

            if (((rt->rtm_addrs & (RTA_DST | RTA_GATEWAY)) == (RTA_DST | RTA_GATEWAY)) &&
                sa_tab[RTAX_DST]->sa_family == AF_INET &&
                sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                unsigned char octet[4] = {0, 0, 0, 0};
                int i;
                for (i = 0; i < 4; i++) {
                    octet[i] = (((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr >>
                                (i * 8)) &
                               0xFF;
                }
                if (((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    in_addr_t addr =
                        ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                    address = [self ymIPV4Formatter:*((struct in_addr *)&addr)];
//                    YMTooLog(@"IPV4 address%@", address);
                    break;
                }
            }
        }
        free(buf);
    }
    
    return address;
}

/** 获取IPV4网关地址 */
+ (NSString *)ymGatewayIPV6 {
    NSString *address = nil;
    
    /* net.route.0.inet.flags.gateway */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET6, NET_RT_FLAGS, RTF_GATEWAY};
    
    size_t l;
    char *buf, *p;
    struct rt_msghdr *rt;
    struct sockaddr_in6 *sa;
    struct sockaddr_in6 *sa_tab[RTAX_MAX];
    int i;
    
    if (sysctl(mib, sizeof(mib) / sizeof(int), 0, &l, 0, 0) < 0) {
        address = @"192.168.0.1";
    }
    
    if (l > 0) {
        buf = malloc(l);
        if (sysctl(mib, sizeof(mib) / sizeof(int), buf, &l, 0, 0) < 0) {
            address = @"192.168.0.1";
        }
        
        for (p = buf; p < buf + l; p += rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr_in6 *)(rt + 1);
            for (i = 0; i < RTAX_MAX; i++) {
                if (rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr_in6 *)((char *)sa + sa->sin6_len);
                } else {
                    sa_tab[i] = NULL;
                }
            }

            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sin6_family == AF_INET6
               && sa_tab[RTAX_GATEWAY]->sin6_family == AF_INET6)
            {
                address = [self ymIPV6Formatter:((struct sockaddr_in6 *)(sa_tab[RTAX_GATEWAY]))->sin6_addr];
//                YMTooLog(@"IPV6 address%@", address);
                break;
            }
        }
        free(buf);
    }
    
    return address;
}

/** 通过hostname获取ip列表/DNS解析地址 */
+ (NSArray *)ymDNSWithHost:(NSString *)hostName{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *IPV4DNSs = [self ymIPV4DnsWithHost:hostName];
    if (IPV4DNSs && IPV4DNSs.count > 0) {
        [result addObjectsFromArray:IPV4DNSs];
    }
    
    //由于在IPV6环境下不能用IPV4的地址进行连接监测
    //所以只返回IPV6的服务器DNS地址
    NSArray *IPV6DNSs = [self ymIPV6DnsWithHost:hostName];
    if (IPV6DNSs && IPV6DNSs.count > 0) {
        [result removeAllObjects];
        [result addObjectsFromArray:IPV6DNSs];
    }
    
    return [NSArray arrayWithArray:result];
}

/**
 * 根据域名获取IPV4 DNS
 * @param hostName 域名
 */
+ (NSArray *)ymIPV4DnsWithHost:(NSString *)hostName {
    const char *hostN = [hostName UTF8String];
    struct hostent *phot;

    @try {
        phot = gethostbyname(hostN);
    } @catch (NSException *exception) {
        return nil;
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];
    int j = 0;
    while (phot && phot->h_addr_list && phot->h_addr_list[j]) {
        struct in_addr ip_addr;
        memcpy(&ip_addr, phot->h_addr_list[j], 4);
        char ip[20] = {0};
        inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));

        NSString *strIPAddress = [NSString stringWithUTF8String:ip];
        [result addObject:strIPAddress];
        j++;
    }

    return [NSArray arrayWithArray:result];
}

/**
 * 根据域名获取IPV6 DNS
 * @param hostName 域名
 */
+ (NSArray *)ymIPV6DnsWithHost:(NSString *)hostName {
    const char *hostN = [hostName UTF8String];
    struct hostent *phot;
    
    @try {
        /**
         * 只有在IPV6的网络下才会有返回值
         */
        phot = gethostbyname2(hostN, AF_INET6);
    } @catch (NSException *exception) {
        return nil;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int j = 0;
    while (phot && phot->h_addr_list && phot->h_addr_list[j]) {
        struct in6_addr ip6_addr;
        memcpy(&ip6_addr, phot->h_addr_list[j], sizeof(struct in6_addr));
        NSString *strIPAddress = [self ymIPV6Formatter:ip6_addr];
        [result addObject:strIPAddress];
        j++;
    }
    
    return [NSArray arrayWithArray:result];
}

/// 解析域名，获取域名的TXT记录
/// @param hostName 域名
+ (NSArray *)ymTXTRecordWithHost:(NSString *)hostName {
    // 声明缓冲区/返回数组
    NSMutableArray *answers = [NSMutableArray new];
    u_char answer[1024];
    ns_msg msg;
    ns_rr rr;

    // 初始化分解器
    res_init();

    // 发送查询。res_query返回答案的长度，如果查询失败，则返回-1
    int rlen = res_query([hostName cStringUsingEncoding:NSUTF8StringEncoding], ns_c_in, ns_t_txt, answer, sizeof(answer));

    if(rlen == -1) {
        return nil;
    }

    // 解析整个消息
    if(ns_initparse(answer, rlen, &msg) < 0) {
        return nil;
    }

    // 获取返回的消息数
    int rrmax = rrmax = ns_msg_count(msg, ns_s_an);

    // 迭代每个消息
    for(int i = 0; i < rrmax; i++) {
        // 解析消息的回答部分
        if(ns_parserr(&msg, ns_s_an, i, &rr))
        {
            return nil;
        }

        // 获取记录数据
        const u_char *rd = ns_rr_rdata(rr);

        // 第一个字节是数据的长度
        size_t length = rd[0];

        // 从C字符串中创建并保存一个字符串
        NSString *record = [[NSString alloc] initWithBytes:(rd + 1) length:length encoding:NSUTF8StringEncoding];
        [answers addObject:record];
    }

    return answers;
}


#pragma mark - private
int getSignalStrength()
{
    void *libHandle = dlopen("/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony", RTLD_LAZY);
    int (*CTGetSignalStrength)();
    CTGetSignalStrength = dlsym(libHandle, "CTGetSignalStrength");
    if( CTGetSignalStrength == NULL) YMTooLog(@"Could not find CTGetSignalStrength");
    int result = CTGetSignalStrength();
    dlclose(libHandle);
    return result;
}

/** 获取蜂窝数据类型 */
+ (kNetworkType)WWANType {
    // 获取手机网络类型
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = info.currentRadioAccessTechnology;
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]) {
        return kNetworkType_GPRS;
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
        return kNetworkType_Edge;
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA] ||
              [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
              [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
              [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]){
        return kNetworkType_3G;
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA]){
        return kNetworkType_HSDPA;
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]){
        return kNetworkType_HSUPA;
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]){
        return kNetworkType_2G;
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]){
        return kNetworkType_HRPD;
    }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]){
        return kNetworkType_4G;
    }
    return kNetworkType_Unknow;
}

@end
