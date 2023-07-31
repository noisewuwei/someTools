//
//  ViewController.m
//  YM_SliderView
//
//  Created by 黄玉洲 on 2018/6/20.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "ViewController.h"
#import "YM_SliderView.h"
@interface ViewController ()

@property (nonatomic, strong) YM_SliderView * slider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _slider = [[YM_SliderView alloc] initWithFrame:CGRectMake(100, 100, 100, 5)];
    _slider.maximumValue = 100;
    [self.view addSubview:_slider];
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:1 animations:^{
        _slider.value = 50;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
