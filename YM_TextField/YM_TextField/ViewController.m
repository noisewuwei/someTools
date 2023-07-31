//
//  ViewController.m
//  YM_TextField
//
//  Created by 黄玉洲 on 2018/11/4.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "ViewController.h"
#import "YM_TextField.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YM_TextField * textField = [YM_TextField new];
    textField.frame = CGRectMake(0, 100, 200, 30);
    textField.placeholder = @"请输入";
    textField.isLimitChinese = YES;
    [self.view addSubview:textField];
}


@end
