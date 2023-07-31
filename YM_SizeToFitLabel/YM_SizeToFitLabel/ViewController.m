//
//  ViewController.m
//  YM_SizeToFitLabel
//
//  Created by 黄玉洲 on 2018/6/19.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "ViewController.h"
#import "YM_SizeToFitLabel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * string = @"1234567890a1234567890b1234567890c1234567890d1234567890e1234567890f1234567890g1234567890h1234567890i1234567890j1234567890k 就像不能说的秘密啊秘密啊 1234567890l1234567890M 1234567890N";
    
    YM_SizeToFitLabel * label = [[YM_SizeToFitLabel alloc] initWithFrame:CGRectMake(0, 150, 375, 30)];
    label.text = string;
    [self.view addSubview:label];
    
    
    [label attributeWithColor:[UIColor redColor] text:label.text range:NSMakeRange(1, 3)];
    [label attributeWithColor:[UIColor redColor] text:label.text range:NSMakeRange(16, 3)];
    [label attributeWithFont:[UIFont systemFontOfSize:20] text:label.text range:NSMakeRange(5, 14)];
    [label attributeWithFont:[UIFont systemFontOfSize:30] text:label.text range:NSMakeRange(13, 3)];
    [label sizeToFitWithSize:CGSizeMake(300, 0)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
