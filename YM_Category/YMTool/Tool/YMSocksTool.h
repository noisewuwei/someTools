//
//  YMSocksTool.h
//  YM_Category
//
//  Created by 黄玉洲 on 2019/9/6.
//  Copyright © 2019年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <arpa/inet.h>
NS_ASSUME_NONNULL_BEGIN

@interface YMSocksTool : NSObject

/**
 从sockaddr_in中获取直接可读地址和端口
 @param hostNum 地址
 @param portNum 端口
 @param addr sockaddr_in
 */
+ (void)getHostNum:(NSInteger *)hostNum
           portNum:(NSInteger *)portNum
          fromAddr:(const struct sockaddr_in *)addr;

/**
 从sockaddr_in中获取直接可读地址和端口
 @param host 地址
 @param port 端口
 @param addr sockaddr_in
 */
+ (void)getHost:(NSString **)host
           port:(NSInteger *)port
       fromAddr:(const struct sockaddr_in *)addr;

/**  网络字节顺序转换为主机字节顺序 */
+ (uint16_t)portFromNetPort:(uint16_t)port;

/** 主机字节顺序转换为网络字节顺序 */
+ (uint16_t)portFromHexPort:(uint16_t)port;

@end

NS_ASSUME_NONNULL_END
