//
//  YMSpeedTool.h
//  YMTool
//
//  Created by 海南有趣 on 2020/5/14.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMSpeedTool : NSObject

/// 配置要诊断的域名
/// @param hosts 域名数组
- (void)setupHosts:(NSArray <NSString *> *)hosts;

/// 开始诊断
- (void)startDiagnosis:(NSError **)error;

/// 结束诊断
- (void)stopDiagnosis;

/// 测速过程中的日志打印
@property (copy, nonatomic) void(^diagnosisBlock)(NSString * log);

/// 每一个域名测速成功都会回调
@property (copy, nonatomic) void(^successBlock)(NSString * host, NSInteger index, NSInteger average);

/// 每一个域名测速失败都会回调
@property (copy, nonatomic) void(^failBlock)(NSString * host, NSInteger index);

@end

NS_ASSUME_NONNULL_END
