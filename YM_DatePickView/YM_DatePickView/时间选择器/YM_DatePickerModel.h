//
//  YM_DatePickerModel.h
//  YM_DatePickView
//
//  Created by 黄玉洲 on 2018/5/22.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  YMDatePickerModeTime模式的组件数量和组件位置
 */
#define COMPONENT_MODE_TIME 6.0f
#define HOUR_MODE_TIME 2
#define MINUTE_MODE_TIME 3

/**
 *  YMDatePickerModeDate模式的组件数量和组件位置
 */
#define COMPONENT_MODE_DATE 5.0f
#define YEAR_MODE_DATE 1
#define MONTH_MODE_DATE 2
#define DAY_MODE_DATE 3

/**
 *  YMDatePickerModeWeek模式的组件数量和组件位置
 */
#define COMPONENT_MODE_WEEK 5.0f
#define MONTH_MODE_WEEK 1
#define DAY_MODE_WEEK 2

/**
 *  视图宽高
 */
#define SELF_WIDTH self.frame.size.width
#define SELF_HEIGHT self.frame.size.height
#define TOOL_BAR_HEIGHT 40.0f

/**
 *  相应颜色
 */
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define TOOLBAR_COLOR COLOR(248,234,193, 1.0)
#define ITEM_TINTCOLOR COLOR(253, 143, 0, 1.0)

/**
 *  字符串拼接
 */
#define STRING_FORMAT(A,B) [NSString stringWithFormat:@"%@%@",A,B]
#define STRING_FROM_NSINTEGER(A) [NSString stringWithFormat:@"%ld",A]

/**
 选择器类型
 - YM_DatePickerModeTime: 时|分
 - YM_DatePickerModeDate: 年|月|日
 - YM_DatePickerModeWeek: 月|日 星期
 */
typedef NS_ENUM(NSInteger, YM_DatePickerMode){
    YM_DatePickerModeTime = 0,
    YM_DatePickerModeDate,
    YM_DatePickerModeWeek,
};

/**
 时间单位
 */
typedef enum {
    YM_DateUnitYear,
    YM_DateUnitMonth,
    YM_DateUnitDay,
    YM_DateUnitHour,
    YM_DateUnitMinute,
    YM_DateUnitSecond,
    YM_DateUnitWeek
}YM_DateUnit;


@interface YM_DatePickerModel : NSObject


@property (nonatomic, assign) YM_DatePickerMode mode;
/**
 *  返回指定的组件数量
 *
 *  @return 数量
 */
- (NSInteger)numberOfComponentsInPicker;

/**
 *  根据指定组件返回组件所含内容的数量
 *
 *  @param component 组件下标
 *
 *  @return 数量
 */
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;

/**
 *  获取指定组件中的指定内容
 *
 *  @param row       组件内容下标
 *  @param component 组件下标
 *
 *  @return 内容
 */
- (NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component;

/**
 *  更新当前年、月下最大日期
 *
 *  @param year  年
 *  @param month 月
 */
- (void)updateCurrentDateMaxDayWithYear:(NSInteger)year month:(NSInteger)month;

/**
 *  更新星期
 *
 *  @param year  年
 *  @param month 月
 */
- (void)updateCurrenDateWeekWithYear:(NSInteger)year month:(NSInteger)month;


/**
 *  获取当前日期时间
 *
 *  @param unit 获取时间的
 */

/**
 *  获取当前日期的指定单位
 *
 *  @param unit 单位
 *
 *  @return 单位值
 */
- (NSInteger)getCurrentDateWithUnit:(YM_DateUnit)unit;

/**
 *  获取某时间的指定单位
 *
 *  @param unit 单位
 *  @param date 某时间
 *
 *  @return 单位值
 */
- (NSInteger)getDateWithUnit:(YM_DateUnit)unit forDate:(NSDate *)date;


@end
