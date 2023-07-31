//
//  ViewController.m
//  YM_SearchView
//
//  Created by 黄玉洲 on 2018/5/22.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "ViewController.h"
#import "YM_SearchBar.h"
#import "YM_SearchBarView.h"
@interface ViewController ()<YM_SearchBarDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YM_SearchBar * searchBar = [[YM_SearchBar alloc] initWithFrame:CGRectMake(0, 100, 200, 30)];
    searchBar.placeHolder = @"请输入内容";
    searchBar.delegate = self;
    searchBar.isChangeLocation = YES;
    [self.view addSubview:searchBar];
    self.view.backgroundColor = [UIColor blackColor];
    
    YM_SearchBarView * searchBar1 = [YM_SearchBarView new];
    searchBar1.frame = CGRectMake(0, 200, self.view.bounds.size.width, 30);
    searchBar1.iconName = @"search";
    searchBar1.placeHolder = @"搜索";
    searchBar1.placeHolderColor = [UIColor cyanColor];
    searchBar1.placeHolderFont = [UIFont systemFontOfSize:14.0f];
    searchBar1.inputViewBackColor = [UIColor grayColor];
    
    searchBar1.cancelBtnFont = [UIFont systemFontOfSize:14.0f];
    searchBar1.cancelBtnColor = [UIColor greenColor];
    searchBar1.cancelBtnTitle = @"取消";
    searchBar1.cancelBtnWidth = 60;
    
    searchBar1.contentFont = [UIFont systemFontOfSize:14.0f];
    searchBar1.contentColor = [UIColor whiteColor];
    
    searchBar1.contentDidChangeBlock = ^(NSString * _Nonnull content) {
        NSLog(@"%@", content);
    };
    [self.view addSubview:searchBar1];
}

- (void)didSearchWithKeyword:(NSString *)keyword
{
    NSLog(@"%@",keyword);
}


@end
