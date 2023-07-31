//
//  YM_DatePickerView.h
//  YM_DatePickView
//
//  Created by 黄玉洲 on 2018/5/22.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_DatePickerModel.h"

@protocol YM_DatePickerViewDelegate <NSObject>

@optional

/**
 *  获取选择的时间
 *  @param hour    时
 *  @param minuete 分
 */
- (void)didSelecteWithHour:(NSString *)hour minute:(NSString *)minuete;

/**
 *  获取选择的日期
 *  @param year  年
 *  @param month 月
 *  @param day   日
 */
- (void)didSelecteWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day;

/**
 *  "关闭"按钮事件
 *  @param sender 关闭按钮
 */
- (void)closeItemAction:(UIButton *)sender;

@end

@interface YM_DatePickerView : UIView


/** 初始化 */
- (instancetype)initDatePickerWithFrame:(CGRect)frame mode:(YM_DatePickerMode)mode;

/** 时间区间 */
@property (nonatomic, strong) NSDate * maxDate; // 最大日期
@property (nonatomic, strong) NSDate * minDate; // 最小日期

@property (nonatomic, assign) id <YM_DatePickerViewDelegate> delegate;

// 加载所有组件
- (void)reloadAllComponents;

@end
