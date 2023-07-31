//
//  YMNetworkDiagnoserEnum.h
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//网络类型
typedef enum {
    NETWORK_TYPE_NONE = 0,//未连接网络
    NETWORK_TYPE_2G = 1,
    NETWORK_TYPE_3G = 2,
    NETWORK_TYPE_4G = 3,
    NETWORK_TYPE_5G = 4,  //  5G目前为猜测结果
    NETWORK_TYPE_WIFI = 5,
} NETWORK_TYPE;

@interface YMNetworkDiagnoserEnum : NSObject

@end

NS_ASSUME_NONNULL_END
