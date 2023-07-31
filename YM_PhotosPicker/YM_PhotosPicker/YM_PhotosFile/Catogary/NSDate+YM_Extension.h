//
//  NSDate+YM_Extension.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (YM_Extension)

/**
 是否今天
 @return YES or NO
 */
- (BOOL)isToday;

/**
 是否昨天
 @return YES or NO
 */
- (BOOL)isYesterday;

/**
 是否今年
 @return YES or NO
 */
- (BOOL)isThisYear;

/**
 和今天是否在同一周
 @return YES or NO
 */
- (BOOL)isSameWeek;


/**
 获取当前日期格式化
 @return 日期格式化
 */
- (NSString *)getNowWeekday;

/**
 按指定格式获取当前的时间
 @param format 格式化
 @return 日期字符串
 */
- (NSString *)dateStringWithFormat:(NSString *)format;


@end
