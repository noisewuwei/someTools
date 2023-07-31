//
//  YMNetworkPingHelper.h
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol YMNetworkPingHelperDelegate <NSObject>

@required
/**
 * 报告RTT和丢包率
 * 实现此委托方法可执行更多操作
 */
- (void)didReportSequence:(NSUInteger)seq
                  timeout:(BOOL)isTimeout
                    delay:(NSUInteger)delay
               packetLoss:(double)lossRate
                     host:(NSString *)ip;

/** 停止ping请求 */
- (void)didStopPingRequest;

@end

/**
* 封装关于苹果的SimplePing, IPv4和IPv6都支持。
* RTT和平均丢包率
*/
@interface YMNetworkPingHelper : NSObject

@property (nonatomic, weak) id<YMNetworkPingHelperDelegate> delegate;

/** ping次数 */
@property (nonatomic,assign) NSInteger pingCount;

/** 网络延迟 单位：ms */
@property (nonatomic, readonly) NSUInteger delay;

/** 丢包率 单位：百分比 */
@property (nonatomic, readonly) double packetLoss;

/** IP地址或域名。 */
@property (nonatomic, copy) NSString *host;


+ (instancetype)sharedInstance;

/**
 * 开始进行ping
 * 每2秒发送一个ping包
 */
- (void)startPing;

/**
 * 停止进行ping
 */
- (void)stopPing;

@end

