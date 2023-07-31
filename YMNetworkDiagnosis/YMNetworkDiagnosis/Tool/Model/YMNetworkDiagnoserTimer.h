//
//  YMNetworkDiagnoserTimer.h
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMNetworkDiagnoserTimer : NSObject

/** 返回微秒时间戳 */
+ (long)getMicroSeconds;


/** 计算一个毫秒的持续时间与参数传递的时间 */
+ (long)computeDurationSince:(long)uTime;

@end

NS_ASSUME_NONNULL_END
