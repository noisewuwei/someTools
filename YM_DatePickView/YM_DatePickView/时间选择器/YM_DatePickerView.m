//
//  YM_DatePickerView.m
//  YM_DatePickView
//
//  Created by 黄玉洲 on 2018/5/22.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "YM_DatePickerView.h"

static const CGFloat fontSize = 20.0f;  // 组件字体大小
static const bool isShowAllUnitOfComponent = YES;    // 是否显示所有组件的单位
@interface YM_DatePickerView () <UIPickerViewDataSource,UIPickerViewDelegate> {
    YM_DatePickerMode _mode;         // 样式
    YM_DatePickerModel * _model;     // 数据处理
    
    NSString * _hour;       // 时
    NSString * _minute;     // 分
    NSString * _year;       // 年
    NSString * _month;      // 月
    NSString * _day;        // 日
    NSString * _week;       // 星期
    
    NSString * _currenMonth;
}

@property (nonatomic, strong) UIPickerView * pickView;  // 选择器
@property (nonatomic, strong) UIView * btnView;         // 按钮视图
@property (nonatomic, strong) UIToolbar * toolBar;      // 操作框

@end

@implementation YM_DatePickerView

- (instancetype)initDatePickerWithFrame:(CGRect)frame mode:(YM_DatePickerMode)mode
{
    self = [super initWithFrame:frame];
    if (self) {
        _mode = mode;
        if (frame.size.height < TOOL_BAR_HEIGHT + 40) {
            self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, TOOL_BAR_HEIGHT + 40);
        }
        [self initData];
        [self initUI];
    }
    return self;
}

#pragma mark - 初始化
/**
 *  数据初始化
 */
- (void)initData
{
    _model = [[YM_DatePickerModel alloc] init];
    _model.mode = _mode;
    
    // 初始化默认值
    if (_mode == YM_DatePickerModeTime) {
        _hour = STRING_FROM_NSINTEGER([_model getCurrentDateWithUnit:YM_DateUnitHour]);
        _minute = STRING_FROM_NSINTEGER([_model getCurrentDateWithUnit:YM_DateUnitMinute]);
    }
    else if (_mode == YM_DatePickerModeDate){
        _year = STRING_FROM_NSINTEGER([_model getCurrentDateWithUnit:YM_DateUnitYear]);
        _month = STRING_FROM_NSINTEGER([_model getCurrentDateWithUnit:YM_DateUnitMonth]);
        
        // 更新最大日期数
        [_model updateCurrentDateMaxDayWithYear:[_year integerValue] month:[_month integerValue]];
        _day = STRING_FROM_NSINTEGER([_model getCurrentDateWithUnit:YM_DateUnitDay]);
    }
    else if (_mode == YM_DatePickerModeWeek){
        _year = STRING_FROM_NSINTEGER([_model getCurrentDateWithUnit:YM_DateUnitYear]);
        _month = STRING_FROM_NSINTEGER([_model getCurrentDateWithUnit:YM_DateUnitMonth]);
        
        // 更新相应的数据
        [_model updateCurrentDateMaxDayWithYear:[_year integerValue] month:[_month integerValue]];
        [_model updateCurrenDateWeekWithYear:[_year integerValue] month:[_month integerValue]];
        _day = STRING_FROM_NSINTEGER([_model getCurrentDateWithUnit:YM_DateUnitDay]);
    }
}

- (void)initUI
{
    [self addSubview:self.pickView];
    [self addSubview:self.toolBar];
    
    switch (_mode) {
        case YM_DatePickerModeTime:{
            [_pickView selectRow:[_hour integerValue] inComponent:HOUR_MODE_TIME animated:NO];
            [_pickView selectRow:[_minute integerValue] inComponent:MINUTE_MODE_TIME animated:NO];
            [self additionTimeUnitView];
            break;
        }
        case YM_DatePickerModeDate:{
            [_pickView selectRow:[_year integerValue] - 1  inComponent:YEAR_MODE_DATE animated:NO];
            [_pickView selectRow:[_month integerValue] - 1 inComponent:MONTH_MODE_DATE animated:NO];
            [_pickView selectRow:[_day integerValue] - 1 inComponent:DAY_MODE_DATE animated:NO];
            [self additionTimeUnitView];
            break;
        }
        case YM_DatePickerModeWeek:{
            [self additionTimeUnitView];
            break;
        }
        default:
            break;
    }
}

#pragma mark - setter
- (void)setDelegate:(id<YM_DatePickerViewDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark - <UIPickerViewDataSource,UIPickerViewDelegate>
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [_model numberOfComponentsInPicker];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_model numberOfRowsInComponent:component];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (_mode == YM_DatePickerModeTime) { // 时|分
        return _pickView.frame.size.width / COMPONENT_MODE_TIME - 5;
    }
    else if (_mode == YM_DatePickerModeDate){ // 年|月|日
        if (isShowAllUnitOfComponent && component == YEAR_MODE_DATE) {
            return _pickView.frame.size.width / COMPONENT_MODE_DATE + 10;
        }else{
            return _pickView.frame.size.width / COMPONENT_MODE_DATE - 5;
        }
    }
    else if (_mode == YM_DatePickerModeWeek){ // 月|日 星期
        if (component == DAY_MODE_WEEK) {
            return 100;
        }
        return _pickView.frame.size.width / COMPONENT_MODE_WEEK - 5;
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString * title = [self getPickerViewTitleForRow:row forComponent:component];
    return [self myLabelWithText:title andComponent:component];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_mode == YM_DatePickerModeTime) { // 时|分
        if (component == HOUR_MODE_TIME) {
            _hour = [_model titleForRow:row forComponent:component];
        }
        else if (component == MINUTE_MODE_TIME){
            _minute = [_model titleForRow:row forComponent:component];
        }
    }
    else if (_mode == YM_DatePickerModeDate){ // 年|月|日
        if (component == YEAR_MODE_DATE) {
            _year = [_model titleForRow:row forComponent:component];
            [_model updateCurrentDateMaxDayWithYear:[_year integerValue] month:[_month integerValue]];
            [_pickView reloadComponent:DAY_MODE_DATE];
        }
        else if (component == MONTH_MODE_DATE){
            _month = [_model titleForRow:row forComponent:component];
            [_model updateCurrentDateMaxDayWithYear:[_year integerValue] month:[_month integerValue]];
            [_pickView reloadComponent:DAY_MODE_DATE];
        }
        else if (component == DAY_MODE_DATE){
            _day = [_model titleForRow:row forComponent:component];
        }
        [self changePickViewSelecteComponet:component row:row];
    }
    else if (_mode == YM_DatePickerModeWeek){ // 月|日 星期
        if (component == MONTH_MODE_WEEK) {
            _month = [_model titleForRow:row forComponent:component];
            [_model updateCurrentDateMaxDayWithYear:[_year integerValue] month:[_month integerValue]];
            [_model updateCurrenDateWeekWithYear:[_year integerValue] month:[_month integerValue]];
            [_pickView reloadComponent:DAY_MODE_WEEK];
        }
        else if (component == DAY_MODE_WEEK)
        {
            _day = [_model titleForRow:row forComponent:component];
        }
    }
}

#pragma mark - 界面
/**
 *  刷新界面
 */
- (void)reloadAllComponents
{
    [_pickView reloadAllComponents];
}

/**
 *  如果设有最大时间或者最小时间,当选择超出这个范围，将回弹至范围内
 *
 *  @param component 组
 *  @param row       行
 */
- (void)changePickViewSelecteComponet:(NSInteger)component row:(NSInteger)row
{
    // 获取选中时间的年月日和距离当前系统时间的秒差
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateStr = [NSString stringWithFormat:@"%@-%@-%@",_year,_month,_day];
    NSDate * selectedDate = [dateFormatter dateFromString:dateStr];
    NSTimeInterval intetval = [selectedDate timeIntervalSinceNow];
    
    // 最大时间
    if (_maxDate) {
        // 获取最大时间的年月日和距离当前系统时间的秒差
        NSTimeInterval maxInteval = [_maxDate timeIntervalSinceNow];
        
        // 判断选中时间是否大于最大时间
        // 如果大于则弹跳至最大时间
        if (intetval > maxInteval) {
            NSInteger maxYear = [_model getDateWithUnit:YM_DateUnitYear forDate:_minDate] - 1;
            NSInteger maxMonth = [_model getDateWithUnit:YM_DateUnitMonth forDate:_minDate] - 1;
            NSInteger maxDay = [_model getDateWithUnit:YM_DateUnitDay forDate:_minDate] - 1;
            [_pickView selectRow:maxYear inComponent:YEAR_MODE_DATE animated:YES];
            [_pickView selectRow:maxMonth inComponent:MONTH_MODE_DATE animated:YES];
            [_pickView selectRow:maxDay inComponent:DAY_MODE_DATE animated:YES];
            _year = [_model titleForRow:maxYear forComponent:YEAR_MODE_DATE];
            _month = [_model titleForRow:maxMonth forComponent:MONTH_MODE_DATE];
            _day = [_model titleForRow:maxDay forComponent:DAY_MODE_DATE];
        }
    }
    
    // 最小时间
    if (_minDate) {
        // 获取最小时间的年月日和距离当前系统时间的秒差
        NSTimeInterval minInteval = [_minDate timeIntervalSinceNow];
        
        // 判断选中时间是否小于最小时间
        // 如果小于则弹跳至最小时间
        if (intetval < minInteval) {
            NSInteger minYear =  [_model getDateWithUnit:YM_DateUnitYear forDate:_minDate] - 1;
            NSInteger minMonth = [_model getDateWithUnit:YM_DateUnitMonth forDate:_minDate] - 1;
            NSInteger minDay = [_model getDateWithUnit:YM_DateUnitDay forDate:_minDate] - 1;
            [_pickView selectRow:minYear inComponent:YEAR_MODE_DATE animated:YES];
            [_pickView selectRow:minMonth inComponent:MONTH_MODE_DATE animated:YES];
            [_pickView selectRow:minDay inComponent:DAY_MODE_DATE animated:YES];
            _year = [_model titleForRow:minYear forComponent:YEAR_MODE_DATE];
            _month = [_model titleForRow:minMonth forComponent:MONTH_MODE_DATE];
            _day = [_model titleForRow:minDay forComponent:DAY_MODE_DATE];
        }
    }
}

/**
 *  获取pickerView组件title
 *
 *  @param row       行
 *  @param component 组件
 *
 *  @return 拼接后的title
 */
- (NSString *)getPickerViewTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * dateUnit = @"";
    NSString * dateStr = [_model titleForRow:row forComponent:component];
    if (_mode == YM_DatePickerModeTime && isShowAllUnitOfComponent) {
        switch (component) {
            case HOUR_MODE_TIME: dateUnit = @"时"; break;
            case MINUTE_MODE_TIME: dateUnit = @"分"; break;
            default: break;
        }
    }
    else if (_mode == YM_DatePickerModeDate && isShowAllUnitOfComponent) { // 年|月|日
        switch (component) {
            case YEAR_MODE_DATE: dateUnit = @"年"; break;
            case MONTH_MODE_DATE: dateUnit = @"月"; break;
            case DAY_MODE_DATE: dateUnit = @"日"; break;
            default: break;
        }
    }
    else if (_mode == YM_DatePickerModeWeek){
        
    }
    return STRING_FORMAT(dateStr, dateUnit);
}

/**
 *  添加固定的时间单位
 */
- (void)additionTimeUnitView
{
    if (isShowAllUnitOfComponent) {
        return;
    }
    
    CGFloat width = _pickView.frame.size.width;
    if (_mode == YM_DatePickerModeTime) {
        width = width / COMPONENT_MODE_TIME;
        NSArray * positionXs = @[@(HOUR_MODE_TIME + 1),@(MINUTE_MODE_TIME + 1)];
        NSArray * titles = @[@"时",@"分"];
        
        for (int i = 0; i < [positionXs count]; i++) {
            NSInteger x = [positionXs[i] integerValue] * width;
            
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(x, CGRectGetHeight(_pickView.frame) / 2.0 - 10, 30, 20)];
            label.font = [UIFont systemFontOfSize:fontSize];
            label.text = titles[i];
            [_pickView addSubview:label];
        }
    }
    else if (_mode == YM_DatePickerModeDate){
        width = width / COMPONENT_MODE_DATE;
        NSArray * positionXs = @[@(YEAR_MODE_DATE + 1),@(MONTH_MODE_DATE + 1),@(DAY_MODE_DATE + 1)];
        NSArray * titles = @[@"年",@"月",@"日"];
        
        for (int i = 0; i < [positionXs count]; i++) {
            NSInteger x = [positionXs[i] integerValue] * width;
            
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(x, CGRectGetHeight(_pickView.frame) / 2.0 - 10, 30, 20)];
            label.font = [UIFont systemFontOfSize:fontSize];
            label.text = titles[i];
            [_pickView addSubview:label];
        }
    }
}

#pragma mark - 操作栏
/**
 *  “关闭”按钮
 *
 *  @param sender 按钮对象
 */
- (void)leftItemAction:(UIButton *)sender
{
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(closeItemAction:)]) {
        [self.delegate closeItemAction:sender];
    }
}

/**
 *  “完成”按钮
 *
 *  @param sender 按钮对象
 */
- (void)rightItemAction:(UIButton *)sender
{
    if (_mode == YM_DatePickerModeTime) {    // 时|分
        if ([self.delegate respondsToSelector:@selector(didSelecteWithHour:minute:)]) {
            [self.delegate didSelecteWithHour:_hour minute:_minute];
        }
    }else if (_mode == YM_DatePickerModeDate){   // 年|月|日
        if ([self.delegate respondsToSelector:@selector(didSelecteWithYear:month:day:)]) {
            [self.delegate didSelecteWithYear:_year month:_month day:_day];
        }
    }
}



#pragma mark - property
- (UIPickerView *)pickView
{
    if (!_pickView) {
        _pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, TOOL_BAR_HEIGHT, SELF_WIDTH, SELF_HEIGHT - TOOL_BAR_HEIGHT)];
        _pickView.dataSource = self;
        _pickView.delegate = self;
        _pickView.backgroundColor = [UIColor whiteColor];
    }
    return _pickView;
}

- (UIToolbar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SELF_WIDTH, TOOL_BAR_HEIGHT)];
        _toolBar.barTintColor = TOOLBAR_COLOR;
        
        // 左按钮
        UIBarButtonItem * leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(leftItemAction:)];
        leftBtn.tintColor = ITEM_TINTCOLOR;
        
        // 空白
        UIBarButtonItem * spaceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        // 右按钮
        UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction:)];
        rightBtn.tintColor = ITEM_TINTCOLOR;
        
        _toolBar.items = @[leftBtn,spaceBtn,rightBtn];
        
        // 顶部边界线
        UIView * topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SELF_WIDTH, 0.5)];
        topLine.backgroundColor = [UIColor grayColor];
        [_toolBar addSubview:topLine];
        
    }
    return _toolBar;
}

#pragma mark - 便利构造
- (UILabel *)myLabelWithText:(NSString *)text andComponent:(NSInteger)component
{
    UILabel * pickerLabel = [[UILabel alloc] init];
    pickerLabel.font = [UIFont systemFontOfSize:fontSize];
    pickerLabel.textAlignment = NSTextAlignmentRight;
    pickerLabel.text = text;
    return pickerLabel;
    
}


@end
