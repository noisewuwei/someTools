//
//  YMNetworkDiagnoser.m
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#pragma mark - NSString (Diagonoser)
#import <arpa/inet.h>
@interface NSString (Diagonoser)

@end

@implementation NSString (Diagonoser)

/** 验证IP格式 */
- (BOOL)isIPaddress {
    in_addr_t addt =  inet_addr([self UTF8String]);
    in_addr_t addt255 = inet_addr("255.255.255.255");
    if (addt == addt255) {
        return NO;
    }else{
        return YES;
    }
}

@end

#pragma mark - YMNetworkDiagnoser
#import "YMNetworkDiagnoser.h"
#import "YMNetworkPingHelper.h"
#import "YMNetworkDiagnoserModel.h"
#import "YMNetworkDiagnoserTimer.h"
#import "YMNetworkDiagnoserAddress.h"

typedef void(^kInfoBlock)(YMNetworkDiagnoserModel * statues);

@interface YMNetworkDiagnoser () <YMNetworkPingHelperDelegate> {
    YMNetworkDiagnoserModel  * _baseNetInfo;
    dispatch_queue_t _requestQueue;
    dispatch_queue_t _serialQueue;
    YMNetworkPingHelper * _netPinger;
    
    // Ping平均值计算
    CGFloat _pingSum;
    NSInteger _pingCount;
    CGFloat _pingAverage;
}

@property (nonatomic,copy) kInfoBlock infoBlock;

@end

@implementation YMNetworkDiagnoser

+ (instancetype)shareTool {
    static YMNetworkDiagnoser *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[YMNetworkDiagnoser alloc] init];
    });
    return tool;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _baseNetInfo = [YMNetworkDiagnoserModel new];
        _netPinger = [YMNetworkPingHelper sharedInstance];
        _netPinger.delegate = self;
        _requestQueue = dispatch_queue_create("LYTNetDiagnoserQueue", DISPATCH_QUEUE_CONCURRENT);
        _serialQueue = dispatch_queue_create("LYTNetDiagnoserQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - ping
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
                      error:(void(^)(NSString *error))errorBlock {
    _pingSum = 0;
    _pingCount = 0;
    _pingAverage = 0;
    // IP格式
    if ([domain isIPaddress]) {
        [_netPinger setHost:domain];
        _netPinger.pingCount = count;
        [_netPinger startPing];
    }
    // 域名
    else {
        [self getDNSFromDomain:domain respose:^(YMNetworkDiagnoserModel *info) {
            dispatch_async(_serialQueue, ^{
                if(info.infoArray.count){
                    self.infoBlock =  [infoBlock copy];
                    [_netPinger setHost:info.infoArray[0]];
                    _netPinger.delegate = self;
                    _netPinger.pingCount = count;
                    [_netPinger startPing];
                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        errorBlock(@"域名解析失败!!! 请检查域名和网络\n");
                    });
                }
            });
        }];
    }
}

- (void)stopTestPing {
    [_netPinger stopPing];
}

#pragma mark - Ping <YMNetworkPingHelper>
- (void)didReportSequence:(NSUInteger)seq
                  timeout:(BOOL)isTimeout
                    delay:(NSUInteger)delay
               packetLoss:(double)lossRate
                     host:(NSString *)ip{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.pingDelegate respondsToSelector:@selector(pingDidReportSequence:timeout:delay:average:packetLoss:host:)]) {
            _pingSum += delay;
            _pingCount++;
            _pingAverage = _pingSum * 1.0 / _pingCount;
            [self.pingDelegate pingDidReportSequence:seq timeout:isTimeout delay:delay average:_pingAverage packetLoss:lossRate host:ip];
        }
    });
}
- (void)didStopPingRequest{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.pingDelegate respondsToSelector:@selector(pingDidStopPingRequest)]) {
            [self.pingDelegate pingDidStopPingRequest];
        }
    });
    
}

#pragma mark - DNS
- (void)getDNSFromDomain:(NSString *)domainName
                 respose:(void(^)(YMNetworkDiagnoserModel * info))resposeblock{
    dispatch_async(_serialQueue, ^{
        // host地址IP列表
        YMNetworkDiagnoserModel *info = [YMNetworkDiagnoserModel new];
        long time_start = [YMNetworkDiagnoserTimer getMicroSeconds];
        info.infoArray = [NSArray arrayWithArray:[YMNetworkDiagnoserAddress getDNSsWithDormain:domainName]];
        long time_duration = [YMNetworkDiagnoserTimer computeDurationSince:time_start] / 1000;
        info.durationTime = time_duration;
        info.infoStr = [NSString stringWithFormat:@"DNS解析结果: %@ (%ldms)",[info.infoArray componentsJoinedByString:@", "],time_duration];
        dispatch_async(dispatch_get_main_queue(), ^{
            resposeblock(info);
        });
    });
}

@end


