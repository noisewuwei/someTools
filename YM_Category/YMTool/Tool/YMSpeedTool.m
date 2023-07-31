//
//  YMSpeedTool.m
//  YMTool
//
//  Created by 海南有趣 on 2020/5/14.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import "YMSpeedTool.h"
#import "YMDiagnoService.h"
#import "YMToolHeader.h"
@interface YMSpeedTool () <YMDiagnoServiceDelegate>
{
    NSMutableArray <YMDiagnoService *> * _services;
}

@end

@implementation YMSpeedTool

- (instancetype)init {
    if (self = [super init]) {
        _services = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 添加测速域名
- (void)setupHosts:(NSArray<NSString *> *)hosts {
    [_services removeAllObjects];
    for (NSInteger i = 0; i < [hosts count]; i++) {
        NSString * host = hosts[i];
        YMDiagnoService * service = [[YMDiagnoService alloc] initWithDomain:host];
        service.delegate = self;
        service.index = i;
        [_services addObject:service];
    }
}

#pragma mark - 测速操作
/// 开始诊断
- (void)startDiagnosis:(NSError **)error {
    if ([_services count] == 0) {
        NSString * domain = [NSString stringWithFormat:@"%s", __func__];
        *error = [NSError errorWithDomain:domain code:1 userInfo:@{NSLocalizedDescriptionKey: @"请先添加要诊断的域名"}];
        return;
    }
    for (YMDiagnoService * service in _services) {
        [service startDiagnosis];
    }
}

/// 停止诊断
- (void)stopDiagnosis {
    for (YMDiagnoService * service in _services) {
        [service stopDialogsis];
    }
}

#pragma mark - <YMDiagnoServiceDelegate>
- (void)ymDiagnosis:(YMDiagnoService *)diageno logInfo:(NSString *)logInfo {
    YMToolWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        YMToolStrongSelf
        if (self.diagnosisBlock) {
            self.diagnosisBlock(logInfo);
        }
    });
}

- (void)ymDiagnosis:(YMDiagnoService *)diageno success:(NSString *)allLogInfo {
    [diageno stopDialogsis];
    YMToolWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        YMToolStrongSelf
        if (self.successBlock) {
            self.successBlock(diageno.domain, diageno.index, diageno.average);
        }
    });
}

- (void)ymDiagnosis:(YMDiagnoService *)diageno fail:(NSString *)allLogInfo {
    [diageno stopDialogsis];
    YMToolWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        YMToolStrongSelf
        if (self.failBlock) {
            self.failBlock(diageno.domain, diageno.index);
        }
    });
}

@end
