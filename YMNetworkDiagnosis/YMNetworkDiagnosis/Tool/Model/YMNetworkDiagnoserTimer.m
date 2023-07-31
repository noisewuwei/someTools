//
//  YMNetworkDiagnoserTimer.m
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import "YMNetworkDiagnoserTimer.h"
#include <sys/time.h>

@interface YMNetworkDiagnoserTimer ()


@end

@implementation YMNetworkDiagnoserTimer

/** 返回微秒时间戳 */
+ (long)getMicroSeconds{
    struct timeval time;
    gettimeofday(&time, NULL);
    return time.tv_usec;
}

/** 计算一个毫秒的持续时间与参数传递的时间 */
+ (long)computeDurationSince:(long)uTime {
    long now = [YMNetworkDiagnoserTimer getMicroSeconds];
    if (now < uTime) {
        return 1000000 - uTime + now;
    }
    return now - uTime;
}


@end
