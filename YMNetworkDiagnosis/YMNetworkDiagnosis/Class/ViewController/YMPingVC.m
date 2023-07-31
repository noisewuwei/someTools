//
//  YMPingVC.m
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import "YMPingVC.h"
#import "YMLogTextView.h"
#import "YMNetworkDiagnoser.h"
@interface YMPingVC () <YMNetworkPingDelegate>

@property (strong, nonatomic) UILabel * IPLabel;
@property (strong, nonatomic) UITextField * IPTextField;

@property (strong, nonatomic) UILabel * numberLab;
@property (strong, nonatomic) UITextField * numberTextField;

@property (strong, nonatomic) UILabel * packetLossLab;

@property (strong, nonatomic) UIButton * startBtn;

@property (strong, nonatomic) YMLogTextView * logTexeView;

@end

@implementation YMPingVC

- (void)dealloc {
    
}

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    [self layoutView];
}

#pragma mark - 数据初始化
- (void)initData {

}

#pragma mark - 数据请求


#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    [self.view addSubview:self.IPLabel];
    [_IPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(kNavigationHeight + 20);
    }];
    
    [self.view addSubview:self.IPTextField];
    [_IPTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_IPLabel.mas_right).offset(10);
        make.width.mas_equalTo(kRatio(300));
        make.centerY.mas_equalTo(_IPLabel);
        make.height.mas_equalTo(30);
    }];
    
    [self.view addSubview:self.numberLab];
    [_numberLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_IPLabel.mas_bottom).offset(20);
        make.height.left.mas_equalTo(_IPLabel);
        make.width.mas_equalTo(_IPLabel);
    }];
    
    [self.view addSubview:self.numberTextField];
    [_numberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.mas_equalTo(_IPTextField);
        make.centerY.mas_equalTo(_numberLab);
        make.width.mas_equalTo(kRatio(50));
    }];
    
    [self.view addSubview:self.packetLossLab];
    [_packetLossLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_numberTextField.mas_right).offset(5);
        make.width.mas_greaterThanOrEqualTo(0);
        make.centerY.height.mas_equalTo(_numberTextField);
    }];
    
    [self.view addSubview:self.startBtn];
    [_startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.width.mas_equalTo(kRatio(50));
        make.centerY.mas_equalTo(_numberLab);
        make.height.mas_equalTo(_numberLab);
    }];
    
    [self.view addSubview:self.logTexeView];
    [_logTexeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(_packetLossLab.mas_bottom).offset(20);
        make.bottom.mas_equalTo(-kSafeAreaHeight - 20);
    }];
}

#pragma mark - 按钮事件
- (void)startBtnAction {
    _startBtn.selected = !_startBtn.selected;
    if (_startBtn.isSelected) {
        [YMNetworkDiagnoser shareTool].pingDelegate = self;
        [[YMNetworkDiagnoser shareTool] startPingWithDomain:_IPTextField.text count:[_numberTextField.text integerValue] info:^(YMNetworkDiagnoserModel * _Nonnull model) {
            
        } error:^(NSString * _Nonnull error) {
            
        }];
    } else {
        [[YMNetworkDiagnoser shareTool] stopTestPing];
    }
}

#pragma mark - <YMNetworkPingDelegate>
- (void)pingDidReportSequence:(NSUInteger)seq
                      timeout:(BOOL)isTimeout
                        delay:(NSUInteger)delay
                      average:(CGFloat)average
                   packetLoss:(double)lossRate
                         host:(NSString *)ip {
    // 未超时
    if (!isTimeout) {
        NSString * log = [NSString stringWithFormat:@"第%zd次发送 ping地址：%@, 延迟率：%zdms, 平均延迟：%.2fms", seq, ip, delay, average];
        [_logTexeView setLog:log];
    }
    // 超时
    else {
        NSString * log = [NSString stringWithFormat:@"请求超时： icmp_seq %zd \n",seq];
        [_logTexeView setLog:log];
    }
    _packetLossLab.text = [NSString stringWithFormat:@"丢包率:%.0f%%", lossRate];
}

- (void)pingDidStopPingRequest{
    _startBtn.selected = NO;
}

#pragma mark - 懒加载
- (UILabel *)IPLabel {
    if (!_IPLabel) {
        _IPLabel = [UILabel new];
        _IPLabel.text = @"域名/IP";
        _IPLabel.font = kFontRatio(14.0f);
    }
    return _IPLabel;
}

- (UITextField *)IPTextField {
    if (!_IPTextField) {
        _IPTextField = [UITextField new];
        _IPTextField.borderStyle = UITextBorderStyleRoundedRect;
        _IPTextField.font = kFontRatio(14.0f);
        _IPTextField.text = @"119.75.217.109";
    }
    return _IPTextField;
}

- (UILabel *)numberLab {
    if (!_numberLab) {
        _numberLab = [UILabel new];
        _numberLab.text = @"域名/IP";
        _numberLab.font = kFontRatio(14.0f);
    }
    return _numberLab;
}

- (UITextField *)numberTextField {
    if (!_numberTextField) {
        _numberTextField = [UITextField new];
        _numberTextField.borderStyle = UITextBorderStyleRoundedRect;
        _numberTextField.font = kFontRatio(14.0f);
        _numberTextField.text = @"10";
    }
    return _numberTextField;
}

- (UILabel *)packetLossLab {
    if (!_packetLossLab) {
        _packetLossLab = [UILabel new];
        _packetLossLab.text = @"丢包率:0%";
        _packetLossLab.font = kFontRatio(14.0f);
    }
    return _packetLossLab;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setTitle:@"开始" forState:UIControlStateNormal];
        [_startBtn setTitle:@"停止" forState:UIControlStateSelected];
        [_startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _startBtn.titleLabel.font = kFontRatio(14.0f);
        [_startBtn addTarget:self action:@selector(startBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}


- (YMLogTextView *)logTexeView {
    if (!_logTexeView) {
        _logTexeView = [YMLogTextView new];

    }
    return _logTexeView;
}

@end
