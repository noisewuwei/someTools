//
//  YMDiagnoService.m
//  YMTool
//
//  Created by 海南有趣 on 2020/5/11.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import "YMDiagnoService.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "YMNetworkTool.h"
#import "YMNetConnect.h"

@interface YMDiagnoService () <YMNetConnectDelegate> {
    kNetworkType   _curNetType;
    NSString     * _localIp;
    NSString     * _gatewayIp;
    NSArray      * _dnsServers;
    NSArray      * _hostAddress;
    
    BOOL _isRunning;
    YMNetConnect *_netConnect;
}


@end

@implementation YMDiagnoService


/// 初始化网络诊断服务
/// @param domain 要诊断的地址
- (instancetype)initWithDomain:(NSString *)domain {
    self = [super init];
    if (self) {
        _domain = domain;
        _isRunning = NO;
    }

    return self;
}

#pragma mark - public method
/// 开始诊断网络
- (void)startDiagnosis {
    if (_domain.length == 0)
        NSAssert(NO, @"请输入诊断地址");

    _isRunning = YES;
    [self recordLocalNetEnvironment];

    // 未联网不进行任何检测
    if (_curNetType == 0) {
        _isRunning = NO;
        [self recordStepInfo:@"\n当前主机未联网，请检查网络！" runType:1];
        [self recordStepInfo:@"\n网络诊断结束\n" runType:1];
        [self recordStepInfo:@"" runType:3];
        [self stopDialogsis];
        return;
    }

    // 开始TCP连接测试
    if (_isRunning) {
        // connect诊断，同步过程, 如果TCP无法连接，检查本地网络环境
        [self recordStepInfo:@"开始TCP连接测试..." runType:1];
        if ([_hostAddress count] > 0) {
            _netConnect = [[YMNetConnect alloc] init];
            _netConnect.delegate = self;
            for (int i = 0; i < [_hostAddress count]; i++) {
                [_netConnect runWithHostAddress:[_hostAddress objectAtIndex:i] port:80];
            }
        } else {
            [self recordStepInfo:@"DNS解析失败，主机地址不可达" runType:1];
            [self recordStepInfo:@"" runType:3];
            [self stopDialogsis];
        }
    }
}

/// 停止诊断网络
- (void)stopDialogsis {
    if (_isRunning) {
        if (_netConnect != nil) {
            [_netConnect stopConnect];
            _netConnect = nil;
        }
        _isRunning = NO;
    }
}

#pragma mark - private method
/// 获取本地网络环境信息
- (void)recordLocalNetEnvironment {
    
    // 获取网络类型
    _curNetType = [YMNetworkTool networkType];

    // 本地ip信息
    _localIp = [YMNetworkTool ymGatewayIPV4];

    // 网关IP
    _gatewayIp = _curNetType != kNetworkType_Wifi ? @"" : [YMNetworkTool ymGatewayIP];

    // dns
    _dnsServers = [NSArray arrayWithArray:[YMNetworkTool ymDNSServers]];

    // host地址IP列表
    _hostAddress = [NSArray arrayWithArray:[YMNetworkTool ymDNSWithHost:_domain]];
}

#pragma mark - <YMNetConnectDelegate>
- (void)ymConnectAverage:(long)avarage {
//    NSLog(@"%@ 平均延迟 %ldms", _domain, avarage);
    _average = avarage;
}

- (void)ymConnectLog:(NSString *)socketLog {
    [self recordStepInfo:socketLog runType:1];
}

- (void)ymConnectDidEnd:(BOOL)success {
    [self recordStepInfo:@"" runType:success ? 2 : 3];
    [self recordStepInfo:@"诊断完成" runType:1];
}

#pragma mark - common method
/// 如果调用者实现了stepInfo接口，输出信息
/// @param stepInfo 要保存的内容

/// 如果调用者实现了stepInfo接口，输出信息
/// @param stepInfo 输出内容
/// @param type 1:输出信息 2:完成 3:失败
- (void)recordStepInfo:(NSString *)stepInfo runType:(NSInteger)type {
    if ([stepInfo isEqual:@""] || stepInfo == nil) {
        stepInfo = @"";
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (type == 3 &&[self.delegate respondsToSelector:@selector(ymDiagnosis:fail:)]) {
            [self.delegate ymDiagnosis:self fail:@""];
        } else if (type == 2 && [self.delegate respondsToSelector:@selector(ymDiagnosis:success:)]) {
            [self.delegate ymDiagnosis:self success:@""];
        } else if (type == 1 && [self.delegate respondsToSelector:@selector(ymDiagnosis:logInfo:)]) {
            [self.delegate ymDiagnosis:self logInfo:stepInfo];
        }
    });
}

@end
