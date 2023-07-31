//
//  ViewController.m
//  YM_TabViewTest
//
//  Created by 黄玉洲 on 2018/6/11.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "ViewController.h"
#import "YM_TabControl.h"
@interface ViewController () <YM_TabControlDelegate, YM_TabControlIndicatorDelegate>
{
    NSArray * _titles;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _titles = @[@"1",@"2",@"3",@"4",@"5",@"6",@"8",@"9",@"10"];
    
    YM_TabControl * tabControl = [YM_TabControl new];
    tabControl.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 30);
    tabControl.delegate = self;
    tabControl.indicatorDelegate = self;
    [self.view addSubview:tabControl];
}

#pragma mark - <YM_TabControlDelegate>
- (NSInteger)ym_tabItemCount:(YM_TabControl *)tabControl {
    return [_titles count];
}

- (UIView *)ym_customerTabItem:(YM_TabControl *)tabControl itemIndex:(NSInteger)index {
    UILabel * label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _titles[index];
    return label;
}

- (BOOL)ym_tabItemDidSelect:(YM_TabControl *)tabControl index:(NSInteger)index {
    return YES;
}

#pragma mark - <YM_TabControlIndicatorDelegate>
- (BOOL)ym_showIndicatorView:(YM_TabControl *)tabControl {
    return YES;
}

- (UIColor *)ym_indicatorViewColor:(YM_TabControl *)tabControl index:(NSInteger)index {
    switch (index) {
        case 0: return [UIColor purpleColor];
        case 1: return [UIColor yellowColor];
        case 2: return [UIColor redColor];
        case 3: return [UIColor blueColor];
        case 4: return [UIColor cyanColor];
        default: return [UIColor orangeColor];
    }
}

@end
