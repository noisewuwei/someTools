//
//  YMProxySocket.h
//  OnionKit
//
//  Created by Christopher Ballinger on 11/19/13.
//  Copyright (c) 2013 ChatSecure. All rights reserved.
//

//@import CocoaAsyncSocket;
#import "GCDAsyncSocket.h"

typedef NS_ENUM(int16_t, kSocksVersion) {
    kSocksVersion4 = 0,    // Not implemented
    kSocksVersion4a,       // Not implemented
    kSocksVersion5         // WIP
};

typedef NS_ENUM(int16_t, GCDAsyncProxySocketError) {
	GCDAsyncProxySocketNoError = 0,           // Never used
    GCDAsyncProxySocketAuthenticationError
};

@interface YMProxySocket : GCDAsyncSocket <GCDAsyncSocketDelegate>


@property (nonatomic, strong, readonly) NSString * proxyHost;
@property (nonatomic, readonly) uint16_t proxyPort;
@property (nonatomic, readonly) kSocksVersion proxyVersion;

@property (nonatomic, strong, readonly) NSString * proxyUsername;
@property (nonatomic, strong, readonly) NSString * proxyPassword;



@property (assign, nonatomic) BOOL s5Connected;

#pragma mark 配置
/// 免密认证
/// @param host 代理域名
/// @param port 代理端口
/// @param version socks版本
- (void)setProxyHost:(NSString *)host
           proxyPort:(uint16_t)port
             version:(kSocksVersion)version;

/// /// 用户认证
/// @param host 代理域名
/// @param port 代理端口
/// @param username 用户名
/// @param password 密码
/// @param version socks版本
- (void)setProxyHost:(NSString *)host
           proxyPort:(uint16_t)port
            userName:(NSString *)username
            password:(NSString *)password
             version:(kSocksVersion)version;

@end
