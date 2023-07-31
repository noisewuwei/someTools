//
//  ViewController.m
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import "ViewController.h"
#import "YMViewControllerModel.h"
#import "YMHomeCell.h"
@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView * tableView;

@property (strong, nonatomic) NSMutableArray <YMViewControllerModel *> * viewControllers;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络监测";
    [self initData];
    [self layoutView];
}

- (void)initData {
    _viewControllers = [NSMutableArray array];
    
    // ping
    YMViewControllerModel * pingModel = [YMViewControllerModel new];
    pingModel.title = @"ping";
    pingModel.className = @"YMPingVC";
    [_viewControllers addObject:pingModel];
}

- (void)layoutView {
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(kNavigationHeight);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_viewControllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YMHomeCell * cell = [YMHomeCell cellWithTableView:tableView];
    cell.textLabel.text = _viewControllers[indexPath.row].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YMViewControllerModel * model = _viewControllers[indexPath.row];
    Class vcClass = NSClassFromString(model.className);
    UIViewController * vc = [[vcClass alloc] init];
    vc.title = model.title;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRatio(50);
}

@end
