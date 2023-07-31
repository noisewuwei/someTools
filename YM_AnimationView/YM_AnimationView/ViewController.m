//
//  ViewController.m
//  YM_AnimationView
//
//  Created by huangyuzhou on 2018/9/12.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "ViewController.h"
#import "YM_LoadAnimationView_0.h"
#import "YM_LoadAnimationView_1.h"
#import "YM_LoadAnimationView_2.h"
#import "YM_LoadAnimationView_3.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YM_LoadAnimationView_0 * loadAnimationView = [YM_LoadAnimationView_0 new];
    loadAnimationView.frame = CGRectMake(10, 100, 50, 50);
    loadAnimationView.lineBackColor = [UIColor clearColor];
    [self.view addSubview:loadAnimationView];
    
    YM_LoadAnimationView_1 * loadAnimationView1 = [YM_LoadAnimationView_1 new];
    loadAnimationView1.frame = CGRectMake(70, 100, 50, 50);
    loadAnimationView1.lineWidth = 3;
    loadAnimationView1.lineColor = [UIColor redColor];
    loadAnimationView1.timingFunction = kTimingFunction_EaseOut;
    [self.view addSubview:loadAnimationView1];
    
    YM_LoadAnimationView_2 * loadAnimationView2 = [YM_LoadAnimationView_2 new];
    loadAnimationView2.frame = CGRectMake(120, 50, 100, 100);
//    loadAnimationView2.lineWidth = 3;
//    loadAnimationView2.lineColor = [UIColor redColor];
//    loadAnimationView2.timingFunction = kTimingFunction_EaseOut;
    [self.view addSubview:loadAnimationView2];
    [loadAnimationView2 startAnimation:2];
    
    YM_LoadAnimationView_3 * loadAnimationView3 = [YM_LoadAnimationView_3 new];
    loadAnimationView3.frame = CGRectMake(230, 50, 100, 100);
    loadAnimationView3.lineWidth = 10;
    loadAnimationView3.lineColor = [UIColor redColor];
    loadAnimationView3.timingFunction = kTimingFunction_EaseIn;
    loadAnimationView3.lineCap = kLineCap_Butt;
    loadAnimationView3.duration = 2;
    [self.view addSubview:loadAnimationView3];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
