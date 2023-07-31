//
//  YM_DatePickerModel.m
//  YM_DatePickView
//
//  Created by 黄玉洲 on 2018/5/22.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "YM_DatePickerModel.h"
#define STRING_FORMART(A,B) [NSString stringWithFormat:@"%@%@",A,B]

@interface YM_DatePickerModel () {
    NSMutableArray * _years;
    NSMutableArray * _hours;
    NSMutableArray * _days;
    NSMutableArray * _minutes;
    NSMutableArray * _seconds;
    NSMutableArray * _months;
    NSMutableArray * _weeks;
    
    NSInteger _yead;
    NSInteger _month;
}

@end

@implementation YM_DatePickerModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

#pragma mark - 初始化
- (void)initData
{
    // 年
    _years = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 2100; i++) {
        [_years addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    // 月份
    _months = [[NSMutableArray alloc] init];
    for (int i = 1; i < 13; i++) {
        if (i < 10) {
            [_months addObject:[NSString stringWithFormat:@"%d",i]];
        }else{
            [_months addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    _days = [[NSMutableArray alloc] init];
    
    
    // 星期
    _weeks = [[NSMutableArray alloc] init];
    
    // 小时
    _hours = [[NSMutableArray alloc] init];
    for (int i = 0; i < 24; i++) {
        if (i < 10) {
            [_hours addObject:[NSString stringWithFormat:@"%d",i]];
        }else{
            [_hours addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    // 分钟
    _minutes = [[NSMutableArray alloc] init];
    for (int i = 0; i < 60; i++) {
        if (i < 10) {
            [_minutes addObject:[NSString stringWithFormat:@"%d",i]];
        }else{
            [_minutes addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    // 秒
    _seconds = [[NSMutableArray alloc] init];
    for (int i = 0; i < 60; i++) {
        if (i < 10) {
            [_seconds addObject:[NSString stringWithFormat:@"%d",i]];
        }else{
            [_seconds addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
}

#pragma mark - 组件数
/**
 *  返回指定的组件数量
 *
 *  @return 数量
 */
- (NSInteger)numberOfComponentsInPicker
{
    switch (_mode) {
        case YM_DatePickerModeTime: return COMPONENT_MODE_TIME;
        case YM_DatePickerModeDate: return COMPONENT_MODE_DATE;
        case YM_DatePickerModeWeek: return COMPONENT_MODE_WEEK;
        default: return 0;
    }
}

#pragma mark - 组件内容数量
/**
 *  根据指定组件返回组件所含内容的数量
 *
 *  @param component 组件下标
 *
 *  @return 数量
 */
- (NSInteger)numberOfRowsInComponent:(NSInteger)component
{
    switch (_mode) {
        case YM_DatePickerModeTime: return [self getNumberOfModeTimeComponents:component];
        case YM_DatePickerModeDate: return [self getNumberOfModeDateComponents:component];
        case YM_DatePickerModeWeek: return [self getNumberOfModeWeekComponents:component];
        default: return 0;
    }
}

#pragma mark - 组件内容
/**
 *  获取指定组件中的指定内容
 *
 *  @param row       组件内容下标
 *  @param component 组件下标
 *
 *  @return 内容
 */
- (NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (_mode) {
        case YM_DatePickerModeTime:
            return [self getModeTimeTitleForRow:row forComponent:component];
        case YM_DatePickerModeDate:
            return [self getModeDateTitleForRow:row forComponent:component];
        case YM_DatePickerModeWeek:
            return [self getModeWeekTitleForRow:row forComponent:component];
        default: return 0;
    }
}

#pragma mark - 时分模式
/**
 *  获取时-分模式的行数
 *
 *  @param component 分组
 *
 *  @return 数量
 */
- (NSInteger)getNumberOfModeTimeComponents:(NSInteger)component
{
    switch (component) {
        case HOUR_MODE_TIME: return [_hours count];
        case MINUTE_MODE_TIME: return [_minutes count];
        default: return 0;
    }
}

/**
 *  获取时分模式内容
 *
 *  @param row       行
 *  @param component 组
 *
 *  @return 内容
 */
- (NSString *)getModeTimeTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case HOUR_MODE_TIME: return _hours[row];
        case MINUTE_MODE_TIME: return _minutes[row];
        default: return @"";
    }
}

#pragma mark - 年|月|日模式
/**
 *  获取年月日模式指定分组下的行数
 *
 *  @param componet 分组
 *
 *  @return 行数
 */
- (NSInteger)getNumberOfModeDateComponents:(NSInteger)componet
{
    switch (componet) {
        case YEAR_MODE_DATE: return [_years count];
        case MONTH_MODE_DATE: return [_months count];
        case DAY_MODE_DATE: return [_days count];
        default: return 0;
    }
}

/**
 *  获取年月日模式内容
 *
 *  @param row       行
 *  @param component 组
 *
 *  @return 内容
 */
- (NSString *)getModeDateTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case YEAR_MODE_DATE:  return _years[row];
        case MONTH_MODE_DATE: return _months[row];
        case DAY_MODE_DATE:   return _days[row];
        default:return 0;
    }
}

#pragma mark - 月|日 星期模式
/**
 *  获取月|日 星期模式指定分组下的行数
 *
 *  @param componet 分组
 *
 *  @return 行数
 */
- (NSInteger)getNumberOfModeWeekComponents:(NSInteger)componet
{
    switch (componet) {
        case MONTH_MODE_WEEK: return [_months count];
        case DAY_MODE_WEEK: return [_days count];
        default: return 0;
    }
}

/**
 *  获取月|日 星期模式内容
 *
 *  @param row       行
 *  @param component 组
 *
 *  @return 内容
 */
- (NSString *)getModeWeekTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case MONTH_MODE_WEEK: return [NSString stringWithFormat:@"%@月",_months[row]];
        case DAY_MODE_WEEK: return [NSString stringWithFormat:@"%@日 %@",_days[row],_weeks[row]];
        default: return 0;
    }
}


#pragma mark - 其他方法
/**
 *  更新当前年、月下最大日期
 *
 *  @param year  年
 *  @param month 月
 */
- (void)updateCurrentDateMaxDayWithYear:(NSInteger)year month:(NSInteger)month
{
    NSInteger maxDayNum = 0;
    // 31天的月份
    if (month == 1 || month == 3 || month == 5 ||month == 7 || month == 8 || month == 10 ||
        month == 12) {
        maxDayNum = 31;
    }
    // 30天的月份
    else if (month == 4 || month == 6 || month == 9 || month == 11){
        maxDayNum = 30;
    }else{
        // 闰年29天
        if (year % 4 == 0 && year % 100 !=0) {
            maxDayNum = 29;
        }
        // 平年28天
        else{
            maxDayNum = 28;
        }
    }
    
    [_days removeAllObjects];
    for (int i = 1; i <= maxDayNum; i++) {
        if (i < 10) {
            [_days addObject:[NSString stringWithFormat:@"%d",i]];
        }else{
            [_days addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
}

/**
 *  更新当前日期下的星期
 *
 *  @param year  年
 *  @param month 月
 */

- (void)updateCurrenDateWeekWithYear:(NSInteger)year month:(NSInteger)month
{
    // 删除本月已过的日期
    if (_mode == YM_DatePickerModeWeek) {
        NSInteger currentMonth = [self getCurrentDateWithUnit:YM_DateUnitMonth];
        if (currentMonth == month) {
            NSInteger day = [self getCurrentDateWithUnit:YM_DateUnitDay] - 1;
            [_days removeObjectsInRange:NSMakeRange(0, day)];
        }
    }
    
    // 获取相应日的星期
    [_weeks removeAllObjects];
    for (int i = 0; i < [_days count]; i++) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * dateStr = [NSString stringWithFormat:@"%ld-%ld-%@",year,month,_days[i]];
        NSDate * date = [dateFormatter dateFromString:dateStr];
        
        // 获取指定单位
        NSInteger week = [self getDateWithUnit:YM_DateUnitWeek forDate:date];
        
        NSString * weekStr = @"";
        switch (week) {
            case 1: weekStr = @"周日"; break;
            case 2: weekStr = @"周一"; break;
            case 3: weekStr = @"周二"; break;
            case 4: weekStr = @"周三"; break;
            case 5: weekStr = @"周四"; break;
            case 6: weekStr = @"周五"; break;
            case 7: weekStr = @"周六"; break;
        }
        [_weeks addObject:weekStr];
    }
    
}

/**
 *  获取当前日期的指定单位
 *
 *  @param unit 单位
 *
 *  @return 单位值
 */
- (NSInteger)getCurrentDateWithUnit:(YM_DateUnit)unit
{
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    switch (unit) {
        case YM_DateUnitYear: return [calendar component:NSCalendarUnitYear fromDate:date];
        case YM_DateUnitMonth: return [calendar component:NSCalendarUnitMonth fromDate:date];
        case YM_DateUnitDay: return [calendar component:NSCalendarUnitDay fromDate:date];
        case YM_DateUnitHour: return [calendar component:NSCalendarUnitHour fromDate:date];
        case YM_DateUnitMinute: return [calendar component:NSCalendarUnitMinute fromDate:date];
        case YM_DateUnitSecond: return [calendar component:NSCalendarUnitSecond fromDate:date];
        default: return 0;
    }
}

/**
 *  获取某时间的指定单位
 *
 *  @param unit 单位
 *  @param date 某时间
 *
 *  @return 单位值
 */
- (NSInteger)getDateWithUnit:(YM_DateUnit)unit forDate:(NSDate *)date
{
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    switch (unit) {
        case YM_DateUnitYear: return [calendar component:NSCalendarUnitYear fromDate:date];
        case YM_DateUnitMonth: return [calendar component:NSCalendarUnitMonth fromDate:date];
        case YM_DateUnitDay: return [calendar component:NSCalendarUnitDay fromDate:date];
        case YM_DateUnitHour: return [calendar component:NSCalendarUnitHour fromDate:date];
        case YM_DateUnitMinute: return [calendar component:NSCalendarUnitMinute fromDate:date];
        case YM_DateUnitSecond: return [calendar component:NSCalendarUnitSecond fromDate:date];
        case YM_DateUnitWeek: return [calendar component:NSCalendarUnitWeekday fromDate:date];
        default: return 0;
    }
}

#pragma mark - property
- (void)setMode:(YM_DatePickerMode)mode
{
    _mode = mode;
    if (_mode == YM_DatePickerModeWeek) {
        NSInteger month = [self getCurrentDateWithUnit:YM_DateUnitMonth] - 1;
        [_months removeObjectsInRange:NSMakeRange(0, month)];
    }
}


@end
