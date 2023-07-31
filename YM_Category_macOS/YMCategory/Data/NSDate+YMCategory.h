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
- (BOOL)ymIsToday;

/**
 判断日期是否为昨天
 @return Yes or No
 */
- (BOOL)ymIsYesterday;

/**
 判断日期是否为今年
 @return Yes or No
 */
- (BOOL)ymIsThisYear;

/**
 判断日期是否为一星期内
 @return Yes or No
 */
- (BOOL)ymIsAWeek;

/**
 获取NSDate的NSDateComponents
 @return NSDateComponents
 */
- (NSDateComponents *)ymComponents;

/**
 将Date转换为 yyyy-MM-dd 格式
 @return 转换后的时间格式
 */
- (NSDate *)ymDateToYMD;

/**
 获得与当前时间的差距
 @return 日时分秒
 */
- (NSDateComponents *)ymDeltaWithNow;

/**
 比较from和self的时间差值
 @param from 要比较的时间
 @return 时间差
 */
- (NSDateComponents *)ymDeltaFrom:(NSDate *)from;

/** 获取指定时间单位的第一天 */
- (NSDate *)ymDateFirstDayWithUnit:(kDateUnit)unit;

/** 获取指定时间单位的最后一天 */
- (NSDate *)ymDateLastDayWithUnit:(kDateUnit)unit;

/** 指定日期当日开始时间 */
- (NSDate *)ymDayFirstSecond;

/** 指定日期当日结束时间 */
- (NSDate *)ymDayLastSecond;

/** 日期格式化 */
- (NSString *)ymDateFormatter:(NSString *)formatter;

/**
 获取指定单位范围内的最大指定单位值
 @param inUnit 范围单位值（例如年、月）
 @param valueUnit 要获取的指定单位制（例如年中月数、月中日数）
 @return 单位值大小
 */
- (NSInteger)ymMaxUnitInUnit:(NSCalendarUnit)inUnit
                   valueUnit:(NSCalendarUnit)valueUnit;

/**
 由NSString获取NSDate

 @param timeStr 时间字符串(按一定格式展示)
 @param formater 时间字符串的格式(如YYYY-mm-dd HH:mm:ss)
 @return NSDate
 */
+ (NSDate *)ymDateFromTimeStr:(NSString *)timeStr
                     formater:(NSString *)formater;

@end
