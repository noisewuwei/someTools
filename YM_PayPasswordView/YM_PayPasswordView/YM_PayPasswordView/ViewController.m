//
//  ViewController.m
//  YM_PayPasswordView
//
//  Created by huangyuzhou on 2018/10/31.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "ViewController.h"
#import "YM_PayPasswordAlertView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    showBtn.frame = CGRectMake(0, 0, 100, 40);
    [showBtn setTitle:@"show" forState:UIControlStateNormal];
    [showBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showBtn setBackgroundColor:[UIColor blackColor]];
    [showBtn addTarget:self action:@selector(showAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showBtn];
    showBtn.center = self.view.center;
    
}

- (void)showAction:(id)sender {
    
    YM_PayPasswordAlertView *pwdAlert = [[YM_PayPasswordAlertView alloc] init];
    pwdAlert.title = @"请输入支付密码";
    pwdAlert.length = 8;
    pwdAlert.completeAction = ^(NSString *pwd){
        NSLog(@"==pwd:%@", pwd);
    };
    [pwdAlert show];
    
}

@end
