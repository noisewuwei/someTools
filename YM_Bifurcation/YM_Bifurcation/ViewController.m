//
//  ViewController.m
//  YM_Bifurcation
//
//  Created by huangyuzhou on 2018/8/27.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "ViewController.h"
#import "YM_PromotionView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YM_PromotionView * view = [YM_PromotionView new];
    CGFloat sumHeight = [view sumHeight];
    view.frame = CGRectMake(0, 0, Screen_Ratio(375), sumHeight);
    
    [self.view addSubview:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
