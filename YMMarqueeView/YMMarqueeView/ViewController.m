//
//  ViewController.m
//  YMMarqueeView
//
//  Created by 黄玉洲 on 2019/7/31.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import "ViewController.h"
#import "YMMarqueeView.h"
@interface ViewController ()

@property (strong, nonatomic) YMMarqueeView * marqueeView1;

@property (strong, nonatomic) YMMarqueeView * marqueeView2;

@property (strong, nonatomic) YMMarqueeView * marqueeView3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * string1 =  @"君不见，黄河之水天上来，奔流到海不复回。";
    NSString * string2 = @"君不见，黄河之水天上来，奔流到海不复回。\n君不见，高堂明镜悲白发，朝如青丝暮成雪。\n人生得意须尽欢，莫使金樽空对月。";
    
    BOOL isVertical = YES;
    NSString * content = isVertical ? string2 : string1;
    
    UILabel * label1 = [UILabel new];
    label1.text = content;
    label1.font = [UIFont systemFontOfSize:20.0f];
    label1.textColor = [UIColor redColor];
    
    _marqueeView1 = [YMMarqueeView new];
    _marqueeView1.contentView = label1;
    _marqueeView1.backgroundColor = [UIColor lightGrayColor];
    _marqueeView1.contentMargin = 10;
    _marqueeView1.direction = isVertical ? kMarqueeDirection_Top : kMarqueeDirection_Left;
    [self.view addSubview:_marqueeView1];
    
    UILabel * label2 = [UILabel new];
    label2.text = content;
    label2.font = [UIFont systemFontOfSize:20.0f];
    label2.textColor = [UIColor redColor];
    
    _marqueeView2 = [YMMarqueeView new];
    _marqueeView2.contentView = label2;
    _marqueeView2.backgroundColor = [UIColor lightGrayColor];
    _marqueeView2.contentMargin = 10;
    _marqueeView2.direction = isVertical ? kMarqueeDirection_Bottom : kMarqueeDirection_Right;
    [self.view addSubview:_marqueeView2];
    
    UILabel * label3 = [UILabel new];
    label3.text = content;
    label3.font = [UIFont systemFontOfSize:20.0f];
    label3.textColor = [UIColor redColor];
    
    _marqueeView3 = [YMMarqueeView new];
    _marqueeView3.contentView = label3;
    _marqueeView3.backgroundColor = [UIColor lightGrayColor];
    _marqueeView3.contentMargin = 10;
    _marqueeView3.direction = isVertical ? kMarqueeDirection_VerticalReset : kMarqueeDirection_HorizontalReset;
    [self.view addSubview:_marqueeView3];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _marqueeView1.frame = CGRectMake(50, 200, 300, 60);
    
    _marqueeView2.frame = CGRectMake(50, 300, 300, 60);
    
    _marqueeView3.frame = CGRectMake(50, 400, 300, 60);
    
}


@end
