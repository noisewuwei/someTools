//
//  YMNetworkSimplePing.h
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

@import Foundation;
#include <AssertMacros.h>           // for __Check_Compile_Time


/** 控制SimplePing实例使用的IP地址版本。 */
typedef NS_ENUM(NSInteger, SimplePingAddressStyle) {
    /** 使用找到的第一个IPv4或IPv6地址; 默认 */
    SimplePingAddressStyleAny,
    /** 使用找到的第一个IPv4地址 */
    SimplePingAddressStyleICMPv4,
    /** 使用找到的第一个IPv6地址 */
    SimplePingAddressStyleICMPv6
};

NS_ASSUME_NONNULL_BEGIN

@protocol SimplePingDelegate;
@interface YMNetworkSimplePing : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 初始化对象以ping指定的主机。
 @param hostName 要ping的主机的DNS名称; 字符串形式的IPv4或IPv6地址在这里工作。
 @return 初始化对象。
  */
- (instancetype)initWithHostName:(NSString *)hostName NS_DESIGNATED_INITIALIZER;

/** 传递给' -initWithHostName: '的值的副本。 */
@property (nonatomic, copy, readonly) NSString * hostName;

/**
 此对象的委托。
 委托回调是在运行循环的默认运行循环模式下进行的调用`-start`的线程。
 */
@property (nonatomic, weak, readwrite, nullable) id<SimplePingDelegate> delegate;

/**
 控制对象使用的IP地址版本。
 您应该在启动对象之前设置此值。
 */
@property (nonatomic, assign, readwrite) SimplePingAddressStyle addressStyle;

/**
 地址被ping。
 NSData的内容是某种形式的（struct sockaddr）。该对象停止时值为nil，直到开始时保持为零
 `-simplePing：didStartWithAddress：`被调用。
 */
@property (nonatomic, copy, readonly, nullable) NSData * hostAddress;

/**
 `hostAddress`的地址族，如果没有，则为'AF_UNSPEC`。
 */
@property (nonatomic, assign, readonly) sa_family_t hostAddressFamily;

/**
 此对象ping的标识符。
 当您创建此对象的实例时，它会生成一个随机标识符它用于识别自己的ping。
 */
@property (nonatomic, assign, readonly) uint16_t identifier;

/**
 此对象要使用的下一个序列号。
 此值从零开始，每次发送ping时都会递增（安全必要时回到零）。
 序列号包含在ping中，允许您匹配请求和响应，从而计算ping时间和等等。
 */
@property (nonatomic, assign, readonly) uint16_t nextSequenceNumber;

/**
 启动对象。
 在调用之前，您应该设置委托和任何ping参数。
  
 如果事情进展顺利，你很快就会得到`-simplePing：didStartWithAddress：`delegate回调，
 此时你可以开始发送ping（通过`-sendPingWithData：`）和
 将开始接收ICMP数据包（ping响应，通过`-simplePing：didReceivePingResponsePacket：sequenceNumber：`delegate callback，或者未经请求的ICMP数据包，通过`-simplePing：didReceiveUnexpectedPacket：`delegate打回来）。
  
 如果对象无法启动，通常是因为`hostName`没有解析，你会得到
 `-simplePing：didFailWithError：`委托回调。
 
 启动已启动的对象是不正确的
 */
- (void)start;

/**
 发送包含指定数据的ping数据包。
 发送实际的ping。
 
 调用此方法时必须启动该对象，并且在启动对象时必须启动该对象
 在调用之前等待`-simplePing：didStartWithAddress：`委托回调。
 @param data 在ICMP标头之后包含在ping数据包中的一些数据，如果是，则为nil希望数据包包含标准的56字节有效负载（产生标准的64字节ping）。
 */
- (void)sendPingWithData:(nullable NSData *)data;

/**
 停止对象。
 你应该在完成ping操作后调用它。
 在已停止的对象上调用它是安全的。
  */
- (void)stop;

@end


@protocol SimplePingDelegate <NSObject>

@optional

/**
 SimplePing委托回调，在对象启动后调用。
 这是在你启动对象后立即调用它来告诉你的
 对象已成功启动。 收到此回调后，您可以调用 `-sendPingWithData：`发送ping。
 
 如果对象没有启动，则调用`-simplePing：didFailWithError：`。
 @param pinger 发出回调的对象。
 @param address 正在被ping的地址; 当时这个代表回调生成，它将具有与`hostAddress`属性相同的值。
  */
- (void)simplePing:(YMNetworkSimplePing *)pinger didStartWithAddress:(NSData *)address;

/**
 SimplePing委托回调，如果对象无法启动则调用。
 这是在你启动对象后立即调用它来告诉你的
 对象无法启动。 最可能的失败原因是一个问题
 解析`hostName`。
 
 当调用此回调时，对象已停止（您不需要自己调用`-stop`）。
 @param pinger 发出回调的对象。
 @param error描述失败。
 */
- (void)simplePing:(YMNetworkSimplePing *)pinger didFailWithError:(NSError *)error;

/**
 SimplePing委托回调，在对象成功发送ping数据包时调用。
 每次调用`-sendPingWithData：`都会产生一个
 `-simplePing：didSendPacket：sequenceNumber：`委托回调 或
 `-simplePing：didFailToSendPacket：sequenceNumber：error：`委托回调
 （除非你在获得回调之前停止对象）。 目前已提供这些回调
  
 同步来自`-sendPingWithData：`，但这种同步行为不是考虑API。
 
 @param pinger 发出回调的对象。
 @param packet 发送的数据包; 这包括ICMP头（`ICMPHeader`）和 传递给`-sendPingWithData：`的数据，但不包含任何IP级头。
 @param sequenceNumber该数据包的ICMP序列号。
 */
- (void)simplePing:(YMNetworkSimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber;

/**
 一个SimplePing委托回调，在对象无法发送ping数据包时调用。
 每次调用`-sendPingWithData：`都会产生一个
 `-simplePing：didSendPacket：sequenceNumber：`委托回调或
 `-simplePing：didFailToSendPacket：sequenceNumber：error：`委托回调
 （除非你在获得回调之前停止对象）。 目前已提供这些回调
 同步来自`-sendPingWithData：`，但这种同步行为不是考虑API。
 @param pinger 发出回调的对象。
 @param packet 未发送的数据包; 参见`-simplePing：didSendPacket：sequenceNumber：`了解详情。
 @param sequenceNumber 该数据包的ICMP序列号。
 @param error 描述失败。
 */
- (void)simplePing:(YMNetworkSimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error;


/**
 SimplePing委托回调，在对象收到ping响应时调用。
 如果对象收到与ping请求匹配的ping响应发送，它通过此回调通知代表。
 匹配主要基于ICMP标识符，尽管也使用其他标准。
 
 @param pinger 发出回调的对象。
 @param packet 收到的数据包; 这包括ICMP头（`ICMPHeader`）和任何数据在ICMP消息中跟随，但不包括任何IP级头。
 @param sequenceNumber 该数据包的ICMP序列号。
  */
- (void)simplePing:(YMNetworkSimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber;

/**
 SimplePing委托回调，在对象收到不匹配的ICMP消息时调用。
 如果对象收到的ICMP消息与ping请求不匹配发送，它通过此回调通知代表。
 ICMP处理的本质 BSD内核使这成为一个常见事件，因为当ICMP消息到达时，它就是发送到所有ICMP插座。

 重要提示：此回调在使用IPv6时尤为常见，因为IPv6使用ICMP
 用于重要的网络管理功能。例如，IPv6路由器定期
 通过邻居发现协议（NDP）发送路由器通告（RA）数据包
 在ICMP之上实现。
  
 有关匹配的更多信息，请参阅与之相关的讨论
 `-simplePing：didReceivePingResponsePacket：sequenceNumber：`。
 @param pinger 发出回调的对象。
 @param packet 收到的数据包;这包括ICMP头（`ICMPHeader`）和任何数据在ICMP消息中跟随，但不包括任何IP级头。
 */
- (void)simplePing:(YMNetworkSimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet;

@end

#pragma mark * ICMP On-The-Wire Format

/**
 描述ICMP ping的线上标头格式。
 这定义了线路上ping数据包的头结构。 IPv4和IPv6使用相同的基本结构。
  
 这是在标头中声明的，因为SimplePing的客户端可能想要使用它解析收到的ping数据包。
  */
struct ICMPHeader {
    uint8_t     type;
    uint8_t     code;
    uint16_t    checksum;
    uint16_t    identifier;
    uint16_t    sequenceNumber;
    // data...
};
typedef struct ICMPHeader ICMPHeader;

__Check_Compile_Time(sizeof(ICMPHeader) == 8);
__Check_Compile_Time(offsetof(ICMPHeader, type) == 0);
__Check_Compile_Time(offsetof(ICMPHeader, code) == 1);
__Check_Compile_Time(offsetof(ICMPHeader, checksum) == 2);
__Check_Compile_Time(offsetof(ICMPHeader, identifier) == 4);
__Check_Compile_Time(offsetof(ICMPHeader, sequenceNumber) == 6);

enum {
    /** ping请求的ICMP`type`; 在这种情况下，`code`始终为0。 */
    ICMPv4TypeEchoRequest = 8,
    /** 用于ping响应的ICMP`type`; 在这种情况下，`code`始终为0 */
    ICMPv4TypeEchoReply   = 0
};

enum {
    /** ping请求的ICMP`type`; 在这种情况下，`code`始终为0 */
    ICMPv6TypeEchoRequest = 128,
    /** 用于ping响应的ICMP`type`; 在这种情况下，`code`始终为0 */
    ICMPv6TypeEchoReply   = 129   
};

NS_ASSUME_NONNULL_END
