//
//  NSDate+YMCategory.h
//  YM_Category
//
//  Created by huangyuzhou on 2018/9/3.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, kDateUnit) {
    kDateUnit_Year    = NSCalendarUnitYear,     // 年
    kDateUnit_Month   = NSCalendarUnitMonth,    // 年
    kDateUnit_Weekday = NSCalendarUnitWeekOfYear,  // 星期
    kDateUnit_Quarter = NSCalendarUnitQuarter,  // 季度
};

@interface NSDate (YMCategory)

/**
 判断日期是否为今天
 @return Yes or No
 */
- (BOOL)isToday;

/**
 判断日期是否为昨天
 @return Yes or No
 */
- (BOOL)isYesterday;

/**
 判断日期是否为今年
 @return Yes or No
 */
- (BOOL)isThisYear;

/**
 判断日期是否为一星期内
 @return Yes or No
 */
- (BOOL)isAWeek;

/**
 将Date转换为 yyyy-MM-dd 格式
 @return 转换后的时间格式
 */
- (NSDate *)dateToYMD;

/**
 获得与当前时间的差距
 @return 时分秒
 */
- (NSDateComponents *)deltaWithNow;

/**
 比较from和self的时间差值
 @param from 要比较的时间
 @return 时间差
 */
- (NSDateComponents *)deltaFrom:(NSDate *)from;

/** 获取指定时间单位的第一天 */
- (NSDate *)dateFirstDayWithUnit:(kDateUnit)unit;

/** 获取指定时间单位的最后一天 */
- (NSDate *)dateLastDayWithUnit:(kDateUnit)unit;

/** 指定日期当日开始时间 */
- (NSDate *)dayFirstSecond;

/** 指定日期当日结束时间 */
- (NSDate *)dayLastSecond;

/** 日期格式化 */
- (NSString *)dateFormatter:(NSString *)formatter;

@end
