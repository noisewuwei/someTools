//
//  ViewController.m
//  YM_DrawDigitalAndRound
//
//  Created by 黄玉洲 on 2018/5/22.
//

#import "ViewController.h"
#import "YM_DrawDigitalRoundView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YM_DrawDigitalRoundView * view = [[YM_DrawDigitalRoundView alloc] initWithFrame:CGRectMake(100, 100, 50, 50) number:10];
    view.isFill = YES;
    view.textColor = [UIColor whiteColor];
    view.textFont = [UIFont systemFontOfSize:30.0f];
    [view redraw];
    [self.view addSubview:view];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
