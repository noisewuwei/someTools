//
//  YMDiagnoService.h
//  YMTool
//
//  Created by 海南有趣 on 2020/5/11.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YMDiagnoServiceDelegate;

/// 网络诊断服务
@interface YMDiagnoService : NSObject

// 向调用者输出诊断信息接口
@property (nonatomic, weak, readwrite) id<YMDiagnoServiceDelegate> delegate;

// 接口域名
@property (copy, nonatomic, readonly) NSString * domain;

/// 平均延迟
@property (assign, nonatomic, readonly) long average;

@property (assign, nonatomic) NSInteger   index;

/// 初始化网络诊断服务
/// @param domain 要诊断的地址
- (instancetype)initWithDomain:(NSString *)domain;

/// 开始诊断网络
- (void)startDiagnosis;

/// 停止诊断网络
- (void)stopDialogsis;
@end



/// 监控网络诊断的过程信息
@protocol YMDiagnoServiceDelegate <NSObject>

/// 诊断开始
/// @param diageno self
- (void)ymDiagnosisStart:(YMDiagnoService *)diageno;

/// 诊断过程中，返回当前日志
/// @param diageno self
/// @param logInfo 当前调用日志
- (void)ymDiagnosis:(YMDiagnoService *)diageno
            logInfo:(NSString *)logInfo;

/// 诊断完成
/// @param diageno self
/// @param allLogInfo 全部日志
- (void)ymDiagnosis:(YMDiagnoService *)diageno
            success:(NSString *)allLogInfo;

/// 诊断失败
/// @param diageno self
/// @param allLogInfo 全部日志
- (void)ymDiagnosis:(YMDiagnoService *)diageno
               fail:(NSString *)allLogInfo;


@end
