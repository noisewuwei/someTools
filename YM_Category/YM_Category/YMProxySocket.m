//
//  YMProxySocket.m
//  OnionKit
//
//  Created by Christopher Ballinger on 11/19/13.
//  Copyright (c) 2013 ChatSecure. All rights reserved.
//

#import "YMProxySocket.h"

//@import CocoaLumberjack;
//#if DEBUG
//    static const int ddLogLevel = DDLogLevelVerbose;
//#else
//    static const int ddLogLevel = DDLogLevelOff;
//#endif


// Define various socket tags
#define SOCKS_OPEN             10100 // 打开sockes
#define SOCKS_CONNECT          10200 // 连接
#define SOCKS_CONNECT_REPLY_1  10300 // 连接回复
#define SOCKS_CONNECT_REPLY_2  10400 // 连接回复
#define SOCKS_AUTH_USERPASS    10500 // 验证用户信息

// Timeouts
#define TIMEOUT_CONNECT       8.00   // 连接超时时间
#define TIMEOUT_READ          5.00   // 读数据超时时间

@interface YMProxySocket()

/// 代理Socket
@property (strong, nonatomic) GCDAsyncSocket * proxySocket;

/// 代理Socket线程
@property (strong, nonatomic) dispatch_queue_t proxyQueue;

/// 目标域名
@property (copy, nonatomic, readonly) NSString * destinationHost;

/// 目标端口
@property (assign, nonatomic, readonly) uint16_t destinationPort;

@end

@implementation YMProxySocket

#pragma mark 初始化
- (id)initWithDelegate:(id)aDelegate
         delegateQueue:(dispatch_queue_t)dq
           socketQueue:(dispatch_queue_t)sq {
    if (self = [super initWithDelegate:aDelegate delegateQueue:dq socketQueue:sq]) {
        _proxyHost = nil;
        _proxyPort = 0;
        _proxyVersion = -1;
        _destinationHost = nil;
        _destinationPort = 0;
        _proxyUsername = nil;
        _proxyPassword = nil;
    }
    return self;
}

#pragma mark 配置
/// 免密认证
/// @param host 代理域名
/// @param port 代理端口
/// @param version socks版本
- (void)setProxyHost:(NSString *)host
           proxyPort:(uint16_t)port
             version:(kSocksVersion)version {
    _proxyHost = host;
    _proxyPort = port;
    _proxyVersion = version;
}

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
             version:(kSocksVersion)version {
    _proxyHost = host;
    _proxyPort = port;
    _proxyUsername = username;
    _proxyPassword = password;
    _proxyVersion = version;
}

/// 开始连接服务器
/// @param inHost 目标服务器
/// @param port 目标端口
/// @param inInterface 通过接口
/// @param timeout 超时时间
/// @param errPtr 错误信息
- (BOOL)connectToHost:(NSString *)inHost
               onPort:(uint16_t)port
         viaInterface:(NSString *)inInterface
          withTimeout:(NSTimeInterval)timeout
                error:(NSError **)errPtr {
    _destinationHost = inHost;
    _destinationPort = port;
    return [self.proxySocket connectToHost:self.proxyHost
                                    onPort:self.proxyPort
                              viaInterface:inInterface
                               withTimeout:timeout
                                     error:errPtr];
}


/// 检查是否为内部预设消息编号
- (BOOL)checkForReservedTag:(long)tag {
    if (tag == SOCKS_OPEN ||
        tag == SOCKS_CONNECT ||
        tag == SOCKS_CONNECT_REPLY_1 ||
        tag == SOCKS_CONNECT_REPLY_2 ||
        tag == SOCKS_AUTH_USERPASS) {
        return YES;
    } else {
        return NO;
    }
}

/// 写数据
/// @param data 数据
/// @param timeout 超时时长
/// @param tag 消息标识
- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket writeData:data withTimeout:timeout tag:tag];
}

/// 读数据
/// @param timeout 超时时长
/// @param buffer 数据缓冲区
/// @param offset 偏移
/// @param tag 消息标识
- (void)readDataWithTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket readDataWithTimeout:timeout buffer:buffer bufferOffset:offset tag:tag];
}

/// 读数据
/// @param timeout 超时时长
/// @param buffer 数据缓冲区
/// @param offset 偏移
/// @param length 最大长度
/// @param tag 消息标识
- (void)readDataWithTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset maxLength:(NSUInteger)length tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket readDataWithTimeout:timeout buffer:buffer bufferOffset:offset maxLength:length tag:tag];
}

/// 读数据
/// @param timeout 超时时长
/// @param tag 消息标识
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket readDataWithTimeout:timeout tag:tag];
}

/// 读数据
/// @param length 数据长度
/// @param timeout 超时时长
/// @param tag 消息标识
- (void)readDataToLength:(NSUInteger)length withTimeout:(NSTimeInterval)timeout tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket readDataToLength:length withTimeout:timeout tag:tag];
}

/// 读数据
/// @param length 数据长度
/// @param timeout 超时时长
/// @param buffer 数据缓冲区
/// @param offset 偏移
/// @param tag 消息标识
- (void)readDataToLength:(NSUInteger)length withTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket readDataToLength:length withTimeout:timeout buffer:buffer bufferOffset:offset tag:tag];
}

/// 读数据
/// @param data 数据
/// @param timeout 超时时长
/// @param tag 消息标识
- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket readDataToData:data withTimeout:timeout tag:tag];
}

/// 读数据
/// @param data 数据
/// @param timeout 超时时长
/// @param buffer 数据缓冲区
/// @param offset 偏移
/// @param tag 消息标识
- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket readDataToData:data withTimeout:timeout buffer:buffer bufferOffset:offset tag:tag];
}

/// 读数据
/// @param data 数据
/// @param timeout 超时时长
/// @param length 数据长度
/// @param tag 消息标识
- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout maxLength:(NSUInteger)length tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket readDataToData:data withTimeout:timeout maxLength:length tag:tag];
}

/// 读数据
/// @param data 数据
/// @param timeout 超时时长
/// @param buffer 数据缓冲区
/// @param offset 偏移
/// @param length 数据长度
/// @param tag 消息标识
- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout buffer:(NSMutableData *)buffer bufferOffset:(NSUInteger)offset maxLength:(NSUInteger)length tag:(long)tag {
    if ([self checkForReservedTag:tag]) {
        return;
    }
    [self.proxySocket readDataToData:data withTimeout:timeout buffer:buffer bufferOffset:offset maxLength:length tag:tag];
}


/// 开始
/// @param tlsSettings ssl协议内容
- (void)startTLS:(NSDictionary *)tlsSettings {
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithDictionary:tlsSettings];
    [self.proxySocket startTLS:settings];
}

/// 断开连接
- (void)disconnect {
    [self.proxySocket disconnect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark SOCKS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/// 发送SOCKS5打开/握手/身份验证数据，并开始读取响应。
/// 我们试图获得匿名访问(没有身份验证)
- (void)socksOpen {
	//      +-----+-----------+---------+
	// NAME | VER | NMETHODS  | METHODS |
	//      +-----+-----------+---------+
	// SIZE |  1  |    1      | 1 - 255 |
	//      +-----+-----------+---------+
	//
	// Note: 大小以字节为单位
	//
	// Version    = 5 (for SOCKS5)
	// NumMethods = 1
	// Method     = 0 (无认证，匿名访问)
    
	NSUInteger byteBufferLength = 3;
	uint8_t *byteBuffer = malloc(byteBufferLength * sizeof(uint8_t));
	
	uint8_t version = 5; // 版本
	byteBuffer[0] = version;
	
	uint8_t numMethods = 1; // 第三个字段的长度
	byteBuffer[1] = numMethods;
	
	uint8_t method = 0; // 无身份验证
    if (self.proxyUsername.length || self.proxyPassword.length) {
        method = 2; // username/password
    }
	byteBuffer[2] = method;
	
	NSData *data = [NSData dataWithBytesNoCopy:byteBuffer length:byteBufferLength freeWhenDone:YES];
    
	[self.proxySocket writeData:data withTimeout:-1 tag:SOCKS_OPEN];
	
	//      +-----+--------+
	// NAME | VER | METHOD |
	//      +-----+--------+
	// SIZE |  1  |   1    |
	//      +-----+--------+
	//
	// Note: 大小以字节为单位
	//
	// Version = 5 (for SOCKS5)
	// Method  = 0 (No authentication, anonymous access)
	[self.proxySocket readDataToLength:2 withTimeout:TIMEOUT_READ tag:SOCKS_OPEN];
}

/*
 对于用户名/密码身份验证
 
 field 1: 版本, 1 byte (must be 0x01)
 field 2: 用户名长度, 1 byte
 field 3: 用户名
 field 4: 密码长度, 1 byte
 field 5: 密码

 */
- (void)socksUserPassAuth {
    NSData *usernameData = [self.proxyUsername dataUsingEncoding:NSUTF8StringEncoding];
    NSData *passwordData = [self.proxyPassword dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t usernameLength = (uint8_t)usernameData.length;
    uint8_t passwordLength = (uint8_t)passwordData.length;
    NSMutableData *authData = [NSMutableData dataWithCapacity:1+1+usernameLength+1+passwordLength];
    uint8_t version[1] = {0x01};
    [authData appendBytes:version length:1];
    [authData appendBytes:&usernameLength length:1];
    [authData appendBytes:usernameData.bytes length:usernameLength];
    [authData appendBytes:&passwordLength length:1];
    [authData appendBytes:passwordData.bytes length:passwordLength];
    [self.proxySocket writeData:authData withTimeout:-1 tag:SOCKS_AUTH_USERPASS];
    [self.proxySocket readDataToLength:2 withTimeout:-1 tag:SOCKS_AUTH_USERPASS];
}

/**
 * 发送SOCKS5连接数据(根据XEP-65)，并开始读取响应。
 **/
- (void)socksConnect
{
	//      +-----+-----+-----+------+------+------+
	// NAME | VER | CMD | RSV | ATYP | ADDR | PORT |
	//      +-----+-----+-----+------+------+------+
	// SIZE |  1  |  1  |  1  |  1   | var  |  2   |
	//      +-----+-----+-----+------+------+------+
	//
	// Note: Size is in bytes
	//
	// Version      = 5 (for SOCKS5)
	// Command      = 1 (for Connect)
	// Reserved     = 0
	// Address Type = 3 (1=IPv4, 3=DomainName 4=IPv6)
	// Address      = P:D (P=LengthOfDomain D=DomainWithoutNullTermination)
	// Port         = 0
    
    NSUInteger hostLength = [self.destinationHost length];
    NSData *hostData = [self.destinationHost dataUsingEncoding:NSUTF8StringEncoding];
	NSUInteger byteBufferLength = (uint)(4 + 1 + hostLength + 2);
	uint8_t *byteBuffer = malloc(byteBufferLength * sizeof(uint8_t));
    NSUInteger offset = 0;
	
    // VER
	uint8_t version = 0x05;
    byteBuffer[0] = version;
    offset++;
	
    /* CMD
     o  CONNECT X'01'
     o  BIND X'02'
     o  UDP ASSOCIATE X'03'
    */
	uint8_t command = 0x01;
    byteBuffer[offset] = command;
    offset++;
	
	byteBuffer[offset] = 0x00; // Reserved, must be 0
	offset++;
    /* ATYP
     o  IP V4 address: X'01'
     o  DOMAINNAME: X'03'
     o  IP V6 address: X'04'
    */
	uint8_t addressType = 0x03;
    byteBuffer[offset] = addressType;
    offset++;
    /* ADDR
     o  X'01' - the address is a version-4 IP address, with a length of 4 octets
     o  X'03' - the address field contains a fully-qualified domain name.  The first
     octet of the address field contains the number of octets of name that
     follow, there is no terminating NUL octet.
     o  X'04' - the address is a version-6 IP address, with a length of 16 octets.
     */
    byteBuffer[offset] = hostLength;
    offset++;
	memcpy(byteBuffer+offset, [hostData bytes], hostLength);
	offset+=hostLength;
	uint16_t port = htons(self.destinationPort);
    NSUInteger portLength = 2;
	memcpy(byteBuffer+offset, &port, portLength);
    offset+=portLength;

	NSData *data = [NSData dataWithBytesNoCopy:byteBuffer length:byteBufferLength freeWhenDone:YES];
//	DDLogVerbose(@"TURNSocket: SOCKS_CONNECT: %@", data);
	
	[self.proxySocket writeData:data withTimeout:-1 tag:SOCKS_CONNECT];
	
	//      +-----+-----+-----+------+------+------+
	// NAME | VER | REP | RSV | ATYP | ADDR | PORT |
	//      +-----+-----+-----+------+------+------+
	// SIZE |  1  |  1  |  1  |  1   | var  |  2   |
	//      +-----+-----+-----+------+------+------+
	//
	// Note: Size is in bytes
	//
	// Version      = 5 (for SOCKS5)
	// Reply        = 0 (0=Succeeded, X=ErrorCode)
	// Reserved     = 0
	// Address Type = 3 (1=IPv4, 3=DomainName 4=IPv6)
	// Address      = P:D (P=LengthOfDomain D=DomainWithoutNullTermination)
	// Port         = 0
	//
	// It is expected that the SOCKS server will return the same address given in the connect request.
	// But according to XEP-65 this is only marked as a SHOULD and not a MUST.
	// So just in case, we'll read up to the address length now, and then read in the address+port next.
	
	[self.proxySocket readDataToLength:5 withTimeout:TIMEOUT_READ tag:SOCKS_CONNECT_REPLY_1];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark AsyncSocket Delegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    _s5Connected = YES;
    NSLog(@"S5代理地址：%@:%d", host, port);
	
    // 启动SOCKS协议
	[self socksOpen];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"read partial data with tag %ld of length %d", tag, (int)partialLength);
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReadPartialDataOfLength:tag:)]) {
        dispatch_async(self.delegateQueue, ^{
            @autoreleasepool {
                [self.delegate socket:self didReadPartialDataOfLength:partialLength tag:tag];
            }
        });
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	if (tag == SOCKS_OPEN) {
        NSAssert(data.length == 2, @"SOCKS_OPEN reply length must be 2!");
		// See socksOpen method for socks reply format
		uint8_t *bytes = (uint8_t*)[data bytes];
		uint8_t version = bytes[0];
		uint8_t method = bytes[1];
		
//		DDLogVerbose(@"TURNSocket: SOCKS_OPEN: ver(%o) mtd(%o)", version, method);
		
		if(version == 5)
		{
            if (method == 0) { // No Auth
                [self socksConnect];
            } else if (method == 2) { // Username / password
                [self socksUserPassAuth];
            } else {
                // unsupported auth method
                [self disconnect];
            }
		}
		else
		{
			// Wrong version
			[self disconnect];
		}
	}
	else if (tag == SOCKS_CONNECT_REPLY_1)
	{
		// See socksConnect method for socks reply format
		NSAssert(data.length == 5, @"SOCKS_CONNECT_REPLY_1 length must be 5!");
//		DDLogVerbose(@"TURNSocket: SOCKS_CONNECT_REPLY_1: %@", data);
		uint8_t *bytes = (uint8_t*)[data bytes];
        
		uint8_t ver = bytes[0];
		uint8_t rep = bytes[1];
		
//		DDLogVerbose(@"TURNSocket: SOCKS_CONNECT_REPLY_1: ver(%o) rep(%o)", ver, rep);
		
		if(ver == 5 && rep == 0)
		{
			// We read in 5 bytes which we expect to be:
			// 0: ver  = 5
			// 1: rep  = 0
			// 2: rsv  = 0
			// 3: atyp = 3
			// 4: size = size of addr field
			//
			// However, some servers don't follow the protocol, and send a atyp value of 0.
			
			uint8_t addressType = bytes[3];
            uint8_t portLength = 2;
			
            if (addressType == 1) { // IPv4
                // only need to read 3 address bytes instead of 4 + portlength because we read an extra byte already
                [self.proxySocket readDataToLength:(3+portLength) withTimeout:TIMEOUT_READ tag:SOCKS_CONNECT_REPLY_2];
            }
			else if (addressType == 3) // Domain name
			{
				uint8_t addrLength = bytes[4];
				
//				DDLogVerbose(@"TURNSocket: addrLength: %o", addrLength);
//				DDLogVerbose(@"TURNSocket: portLength: %o", portLength);
				
				[self.proxySocket readDataToLength:(addrLength+portLength)
								  withTimeout:TIMEOUT_READ
										  tag:SOCKS_CONNECT_REPLY_2];
			} else if (addressType == 4) { // IPv6
                [self.proxySocket readDataToLength:(16+portLength) withTimeout:TIMEOUT_READ tag:SOCKS_CONNECT_REPLY_2];
            } else if (addressType == 0) {
				// The size field was actually the first byte of the port field
				// We just have to read in that last byte
				[self.proxySocket readDataToLength:1 withTimeout:TIMEOUT_READ tag:SOCKS_CONNECT_REPLY_2];
			} else {
//				DDLogVerbose(@"TURNSocket: Unknown atyp field in connect reply");
				[self disconnect];
			}
		}
		else
		{
            NSString *failureReason = nil;
            switch (rep) {
                case 1:
                    failureReason = @"general SOCKS server failure";
                    break;
                case 2:
                    failureReason = @"connection not allowed by ruleset";
                    break;
                case 3:
                    failureReason = @"Network unreachable";
                    break;
                case 4:
                    failureReason = @"Host unreachable";
                    break;
                case 5:
                    failureReason = @"Connection refused";
                    break;
                case 6:
                    failureReason = @"TTL expired";
                    break;
                case 7:
                    failureReason = @"Command not supported";
                    break;
                case 8:
                    failureReason = @"Address type not supported";
                    break;
                default: // X'09' to X'FF' unassigned
                    failureReason = @"unknown socks  error";
                    break;
            }
//            DDLogVerbose(@"SOCKS failed, disconnecting: %@", failureReason);
			// Some kind of error occurred.
            
			[self disconnect];
		}
	}
	else if (tag == SOCKS_CONNECT_REPLY_2)
	{
		// See socksConnect method for socks reply format
		
//		DDLogVerbose(@"TURNSocket: SOCKS_CONNECT_REPLY_2: %@", data);
		
        if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
            dispatch_async(self.delegateQueue, ^{
                @autoreleasepool {
                    [self.delegate socket:self didConnectToHost:self.destinationHost port:self.destinationPort];
                }
            });
        }
	}
    else if (tag == SOCKS_AUTH_USERPASS) {
        /*
         Server response for username/password authentication:
         
         field 1: version, 1 byte
         field 2: status code, 1 byte.
         0x00 = success
         any other value = failure, connection must be closed
         */
//        DDLogVerbose(@"TURNSocket: SOCKS_AUTH_USERPASS: %@", data);
        if (data.length == 2) {
            uint8_t *bytes = (uint8_t*)[data bytes];
            uint8_t status = bytes[1];
            if (status == 0x00) {
                [self socksConnect];
            } else {
//                DDLogVerbose(@"TURNSocket: Invalid SOCKS username/password auth");
                [self disconnect];
                return;
            }
        } else {
//            DDLogVerbose(@"TURNSocket: Invalid SOCKS username/password response length");
            [self disconnect];
            return;
        }
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReadData:withTag:)]) {
            dispatch_async(self.delegateQueue, ^{
                @autoreleasepool {
                    [self.delegate socket:self didReadData:data withTag:tag];
                }
            });
        }
    }
}


#pragma mark GCDAsyncSocketDelegate methods
- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didWriteDataWithTag:)]) {
        dispatch_async(self.delegateQueue, ^{
            @autoreleasepool {
                [self.delegate socket:self didWriteDataWithTag:tag];
            }
        });
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"proxySocket disconnected from proxy %@:%d / destination %@:%d", self.proxyHost, self.proxyPort, self.destinationHost, self.self.destinationPort);
    _s5Connected = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidDisconnect:withError:)]) {
        dispatch_async(self.delegateQueue, ^{
            @autoreleasepool {
                [self.delegate socketDidDisconnect:self withError:err];
            }
        });
    }
}

- (void) socketDidSecure:(GCDAsyncSocket *)sock {
//    DDLogVerbose(@"didSecure proxy %@:%d / destination %@:%d", self.proxyHost, self.proxyPort, self.destinationHost, self.self.destinationPort);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidSecure:)]) {
        dispatch_async(self.delegateQueue, ^{
            @autoreleasepool {
                [self.delegate socketDidSecure:self];
            }
        });
    }
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidCloseReadStream:)]) {
        dispatch_async(self.delegateQueue, ^{
            @autoreleasepool {
                [self.delegate socketDidCloseReadStream:self];
            }
        });
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didWritePartialDataOfLength:tag:)]) {
        dispatch_async(self.delegateQueue, ^{
            @autoreleasepool {
                [self.delegate socket:self didWritePartialDataOfLength:partialLength tag:tag];
            }
        });
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReceiveTrust:completionHandler:)]) {
        dispatch_async(self.delegateQueue, ^{
            @autoreleasepool {
                [self.delegate socket:self didReceiveTrust:trust completionHandler:completionHandler];
            }
        });
    }
}

#pragma mark 懒加载
- (GCDAsyncSocket *)proxySocket {
    if (!_proxySocket) {
        _proxySocket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                  delegateQueue:self.proxyQueue
                                                    socketQueue:NULL];
    }
    return _proxySocket;
}

- (dispatch_queue_t)proxyQueue {
    if (!_proxyQueue) {
        _proxyQueue = dispatch_queue_create("GCDAsyncProxySocket delegate queue", 0);
    }
    return _proxyQueue;
}
@end
