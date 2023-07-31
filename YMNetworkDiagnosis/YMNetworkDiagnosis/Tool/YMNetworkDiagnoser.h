//
//  YMNetworkDiagnoser.h
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMNetworkDiagnoserModel.h"
#import "YMNetworkDiagnoserEnum.h"
NS_ASSUME_NONNULL_BEGIN

@protocol YMNetworkPingDelegate;
@interface YMNetworkDiagnoser : NSObject

+ (instancetype)shareTool;

#pragma mark - ping
/** ping代理 */
@property (weak, nonatomic) id <YMNetworkPingDelegate> pingDelegate;

/**
 开始ping
 @param domain    域名/IP
 @param count     测试次数
 @param infoBlock ping数据
 @param errorBlock 错误信息
 */
- (void)startPingWithDomain:(NSString *)domain
                      count:(NSInteger)count
                       info:(void(^)(YMNetworkDiagnoserModel *model))infoBlock
                      error:(void(^)(NSString *error))errorBlock;

- (void)stopTestPing;

@end


#pragma mark - YMNetworkPingDelegate
@protocol YMNetworkPingDelegate <NSObject>


/**
 ping结果
 @param seq 发送的数据包
 @param isTimeout 是否超时
 @param delay 延迟率 ms
 @param lossRate 丢包率 %
 @param ip ping的ip
 */
- (void)pingDidReportSequence:(NSUInteger)seq
                      timeout:(BOOL)isTimeout
                        delay:(NSUInteger)delay
                      average:(CGFloat)average
                   packetLoss:(double)lossRate
                         host:(NSString *)ip;

- (void)pingDidStopPingRequest;
@end


NS_ASSUME_NONNULL_END
