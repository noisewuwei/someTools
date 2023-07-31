//
//  YMNetworkDiagnoserAddress.h
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMNetworkDiagnoserEnum.h"
NS_ASSUME_NONNULL_BEGIN

@interface YMNetworkDiagnoserAddress : NSObject

/** 获取当前设备ip地址 */
+ (NSString *)deviceIPAddress;

/** 获取当前设备网关地址 */
+ (NSString *)getGatewayIPAddress;

/** 通过域名获取服务器DNS地址 */
+ (NSArray *)getDNSsWithDormain:(NSString *)hostName;

/** 获取本地网络的DNS地址 */
+ (NSArray *)outPutDNSServers;

/** 获取当前网络类型 */
+ (NETWORK_TYPE)getNetworkTypeFromStatusBar;

/** 格式化IPV6地址 */
+(NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr;

@end

NS_ASSUME_NONNULL_END
