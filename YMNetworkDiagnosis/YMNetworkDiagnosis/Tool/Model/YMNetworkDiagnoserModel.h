//
//  YMNetworkDiagnoserModel.h
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMNetworkDiagnoserModel : NSObject


/** 经历的时间 */
@property (assign, nonatomic) float durationTime;

/** 消息序号 */
@property (copy, nonatomic) NSString *sequence;

/** 消息标示 */
@property (copy, nonatomic) NSString *identifier;

/** 携带的信息 */
@property (copy, nonatomic) NSString *infoStr;

/** 存储数组 */
@property (nonatomic,strong) NSArray *infoArray;

@end

NS_ASSUME_NONNULL_END
