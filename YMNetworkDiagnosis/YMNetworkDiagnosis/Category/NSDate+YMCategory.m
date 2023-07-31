//
//  NSDate+YMCategory.m
//  YM_Category
//
//  Created by huangyuzhou on 2018/9/3.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "NSDate+YMCategory.h"

@implementation NSDate (YMCategory)


/**
 判断日期是否为今天
 @return Yes or No
 */
- (BOOL)isToday {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents * nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}

/**
 判断日期是否为昨天
 @return Yes or No
 */
- (BOOL)isYesterday {
    // 获取当前日期
    NSDate * nowDate = [[NSDate date] dateToYMD];
    
    // 获取指定日期
    NSDate * selfDate = [self dateToYMD];
    
    // 获得nowDate和selfDate的差距
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * cmps = [calendar components:NSCalendarUnitDay
                                          fromDate:selfDate
                                            toDate:nowDate
                                           options:0];
    return cmps.day == 1;
}

/**
 判断日期是否为今年
 @return Yes or No
 */
- (BOOL)isThisYear {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents * nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents * selfCmps = [calendar components:unit fromDate:self];
    
    return nowCmps.year == selfCmps.year;
}

/**
 判断日期是否为一星期内
 @return Yes or No
 */
- (BOOL)isAWeek {
    // 获取当前日期
    NSDate * nowDate = [[NSDate date] dateToYMD];
    
    // 获取指定日期
    NSDate * selfDate = [self dateToYMD];
    
    // 获得nowDate和selfDate的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay
                                         fromDate:selfDate
                                           toDate:nowDate
                                          options:0];
    return cmps.day <= 6;
}


/**
 将Date转换为 yyyy-MM-dd 格式
 @return 转换后的时间格式
 */
- (NSDate *)dateToYMD {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

/**
 获得与当前时间的差距
 @return 日时分秒
 */
- (NSDateComponents *)deltaWithNow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:unit fromDate:[NSDate date] toDate:self options:0];
}

/**
 比较from和self的时间差值
 @param from 要比较的时间
 @return 时间差
 */
- (NSDateComponents *)deltaFrom:(NSDate *)from {
    // 日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 比较时间
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    return [calendar components:unit fromDate:from toDate:self options:0];
}

/** 获取指定时间单位的第一天 */
- (NSDate *)dateFirstDayWithUnit:(kDateUnit)unit {
    // 指定日期
    NSDate * specifiedDate = self;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:(NSCalendarUnit)unit
                startDate:&specifiedDate
                 interval:nil
                  forDate:specifiedDate];
    
    NSDateComponents * firstDayComponents =
    [calendar components:NSCalendarUnitEra |
                         NSCalendarUnitYear |
                         NSCalendarUnitMonth |
                         NSCalendarUnitDay|
                         NSCalendarUnitWeekday |
                         NSCalendarUnitQuarter
                fromDate:specifiedDate];
    
    NSDate * firstDayDate = [calendar dateFromComponents:firstDayComponents];
    return firstDayDate;
}

/** 获取指定时间单位的最后一天 */
- (NSDate *)dateLastDayWithUnit:(kDateUnit)unit {
    // 获取第一天
    NSDate * firstDayDate = [self dateFirstDayWithUnit:unit];
    
    // 获取年/月/日数
    NSInteger maxDay = 0;
    if (unit == kDateUnit_Weekday) {
        maxDay = 7;
    } else {
        maxDay = [firstDayDate maxUnitInUnit:(NSCalendarUnit)unit
                                   valueUnit:NSCalendarUnitDay];
    }

    // 获取指定日期的最后一天（例如该星期的最后一天）
    NSDate * lastDayDate = [firstDayDate dateByAddingTimeInterval:(maxDay - 1) * 24 * 3600];
    return lastDayDate;
}

/** 指定日期当日开始时间 */
- (NSDate *)dayFirstSecond {
    // 指定日期
    NSDate * specifiedDate = self;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay
                startDate:&specifiedDate
                 interval:nil
                  forDate:specifiedDate];
    
    NSDateComponents * monthFirstDayComponents =
    [calendar components:NSCalendarUnitEra |
                         NSCalendarUnitYear |
                         NSCalendarUnitMonth |
                         NSCalendarUnitDay|
                         NSCalendarUnitWeekday |
                         NSCalendarUnitQuarter
                fromDate:specifiedDate];
    
    NSDate * dayFirstSecond = [calendar dateFromComponents:monthFirstDayComponents];
    return dayFirstSecond;
}

/** 指定日期当日结束时间 */
- (NSDate *)dayLastSecond {
    NSDate * dayFirstSecond = [self dayFirstSecond];
    NSDate * dayLastSecond = [NSDate dateWithTimeInterval:24 * 3600 - 1 sinceDate:dayFirstSecond];
    return dayLastSecond;
}

/** 日期格式化 */
- (NSString *)dateFormatter:(NSString *)formatter {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSString * dateStr = [dateFormatter stringFromDate:self];
    return dateStr;
}

/**
 获取指定单位范围内的最大指定单位值
 @param inUnit 范围单位值（例如年、月）
 @param valueUnit 要获取的指定单位制（例如年中月数、月中日数）
 @return 单位值大小
 */
- (NSInteger)maxUnitInUnit:(NSCalendarUnit)inUnit
                 valueUnit:(NSCalendarUnit)valueUnit {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:valueUnit
                                   inUnit:inUnit
                                  forDate:self];
    return range.length;
}

@end
