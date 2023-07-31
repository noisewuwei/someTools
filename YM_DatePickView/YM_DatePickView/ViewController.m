//
//  ViewController.m
//  YM_DatePickView
//
//  Created by 黄玉洲 on 2018/5/22.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "ViewController.h"
#import "YM_DatePickerView.h"
@interface ViewController () <YM_DatePickerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    
    YM_DatePickerView * pickView = [[YM_DatePickerView alloc] initDatePickerWithFrame:CGRectMake(0, 0, width, 300) mode:YM_DatePickerModeTime];
    pickView.delegate = self;
    pickView.maxDate = [NSDate dateWithTimeIntervalSinceNow:5*24*3600];
    pickView.minDate = [NSDate dateWithTimeIntervalSince1970:5*24*3600];
    [self.view addSubview:pickView];
    
    UIDatePicker * pickView1 = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 300, width, 200)];
    pickView1.datePickerMode = UIDatePickerModeDateAndTime;
    pickView1.maximumDate = [NSDate dateWithTimeIntervalSinceNow:5*24*3600];
    [self.view addSubview:pickView1];
    
    for (UIView * view in pickView1.subviews) {
        for (UIView * view1 in view.subviews) {
            if ([view1 isKindOfClass:[UILabel class]]) {
                UILabel * label = (UILabel *)view1;
                NSLog(@"label :%@",label);
            }
        }
    }
    
}


- (void)didSelecteWithYear:(NSString *)year month:(NSString *)month day:(NSString *)day
{
    NSLog(@"%@,%@,%@",year,month,day);
}

- (void)didSelecteWithHour:(NSString *)hour minute:(NSString *)minuete
{
    NSLog(@"%@,%@",hour,minuete);
}


@end
