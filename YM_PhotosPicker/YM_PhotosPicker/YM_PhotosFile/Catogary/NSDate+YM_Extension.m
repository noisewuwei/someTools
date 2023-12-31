//
//  NSDate+YM_Extension.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "NSDate+YM_Extension.h"

@implementation NSDate (YM_Extension)

/**
 是否今天
 @return YES or NO
 */
- (BOOL)isToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return
    (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}

/**
 是否昨天
 @return YES or NO
 */
- (BOOL)isYesterday {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyyMMdd";
    
    // 生成只有年月日的字符串对象
    NSString *selfString = [fmt stringFromDate:self];
    NSString *nowString = [fmt stringFromDate:[NSDate date]];
    
    // 生成只有年月日的日期对象
    NSDate *selfDate = [fmt dateFromString:selfString];
    NSDate *nowDate = [fmt dateFromString:nowString];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps = [calendar components:unit fromDate:selfDate toDate:nowDate options:0];
    return cmps.year == 0
    && cmps.month == 0
    && cmps.day == 1;
}

/**
 是否今年
 @return YES or NO
 */
- (BOOL)isThisYear {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return nowCmps.year == selfCmps.year;
}

/**
 和今天是否在同一周
 @return YES or NO
 */
- (BOOL)isSameWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear ;
    
    //1.获得当前时间的 年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //2.获得self
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}

/**
 获取当前日期格式化
 @return 日期格式化
 */
- (NSString *)getNowWeekday {
    NSDateFormatter *dateday = [[NSDateFormatter alloc] init];
    NSString *language = [NSLocale preferredLanguages].firstObject;
    
    if ([language hasPrefix:@"en"]) {
        // 英文
        [dateday setDateFormat:@"MMM dd"];
        [dateday setDateFormat:@"EEE"];
    } else if ([language hasPrefix:@"zh"]) {
        // 中文
        [dateday setDateFormat:@"MM月dd日"];
        [dateday setDateFormat:@"EEEE"];
    }else if ([language hasPrefix:@"ko"]) {
        // 韩语
        [dateday setDateFormat:@"MM월dd일"];
        [dateday setDateFormat:@"EEEE"];
    }else if ([language hasPrefix:@"ja"]) {
        // 日语
        [dateday setDateFormat:@"MM月dd日"];
        [dateday setDateFormat:@"EEEE"];
    } else {
        // 英文
        [dateday setDateFormat:@"MMM dd"];
        [dateday setDateFormat:@"EEE"];
    }
    return [dateday stringFromDate:self];
}

/**
 按指定格式获取当前的时间
 @param format 格式化
 @return 日期字符串
 */
- (NSString *)dateStringWithFormat:(NSString *)format {
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = format;
    return[formater stringFromDate:self];
}


@end
