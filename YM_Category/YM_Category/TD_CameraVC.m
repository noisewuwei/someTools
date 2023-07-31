//
//  TD_CameraVC.m
//  ToDesk-iOS
//
//  Created by 黄玉洲 on 2021/5/25.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "TD_CameraVC.h"
#import <Masonry/Masonry.h>
#import <YMCategory/YMCategory.h>
@interface TD_CameraVC ()

@property (strong, nonatomic) UIImageView * cameraImageView;

@property (strong, nonatomic) UIView * bottomContainView;
@property (strong, nonatomic) UIButton * switchMicrophoneBtn;
@property (strong, nonatomic) UIButton * closeBtn;
@property (strong, nonatomic) UIButton * switchCameraBtn;

@end

@implementation TD_CameraVC

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
    self.view.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self initData];
    [self layoutView];
}

#pragma mark 数据初始化
- (void)initData {

}

#pragma mark 数据请求


#pragma mark 界面
/** 布局 */
- (void)layoutView {
    [self transparentNavigation];
    
    [self.view addSubview:self.cameraImageView];
    [_cameraImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self.view.mas_height).multipliedBy(0.8);
    }];
    
    [self.view addSubview:self.bottomContainView];
    [_bottomContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_cameraImageView.mas_bottom);
        make.left.right.mas_equalTo(_cameraImageView);
        make.height.mas_equalTo(self.view.mas_height).multipliedBy(0.2);
    }];
    
    
    
    [_bottomContainView addSubview:self.switchMicrophoneBtn];
    [_switchMicrophoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(_bottomContainView);
        make.width.mas_equalTo(_bottomContainView.mas_width).multipliedBy(0.33);
        make.height.mas_equalTo(120);
    }];
    
    [_bottomContainView addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_bottomContainView);
        make.centerY.mas_equalTo(_bottomContainView);
        make.width.mas_equalTo(_bottomContainView.mas_width).multipliedBy(0.33);
        make.height.mas_equalTo(_switchMicrophoneBtn);
    }];
    
    [_bottomContainView addSubview:self.switchCameraBtn];
    [_switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(_bottomContainView);
        make.width.mas_equalTo(_bottomContainView.mas_width).multipliedBy(0.33);
        make.height.mas_equalTo(_switchMicrophoneBtn);
    }];
}

#pragma mark 按钮事件
- (void)buttonAction:(UIButton *)sender {
    
}

#pragma mark 懒加载
- (UIImageView *)cameraImageView {
    if (!_cameraImageView) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        _cameraImageView = imageView;
    }
    return _cameraImageView;
}

- (UIView *)bottomContainView {
    if (!_bottomContainView) {
        UIView * view = [UIView new];
        view.backgroundColor = [UIColor blackColor];
        _bottomContainView = view;
    }
    return _bottomContainView;
}

- (UIButton *)switchMicrophoneBtn {
    if (!_switchMicrophoneBtn) {
        UIButton * button = [self buttonWithTitle:@"打开麦克风" imageName:@"camera_microphone_off"];
        button.tag = 1000;
        _switchMicrophoneBtn = button;
    }
    return _switchMicrophoneBtn;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        UIButton * button = [self buttonWithTitle:@"挂断" imageName:@"camera_close"];
        button.tag = 1000+1;
        _closeBtn = button;
    }
    return _closeBtn;
}

- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        UIButton * button = [self buttonWithTitle:@"切换摄像头" imageName:@"camera_switch"];
        button.tag = 1000+2;
        _switchCameraBtn = button;
    }
    return _switchCameraBtn;
}

- (UIButton *)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button
    .ymTitle(title, UIControlStateNormal)
    .ymTitleFont([UIFont systemFontOfSize:13.0f])
    .ymImage([UIImage imageNamed:imageName], UIControlStateNormal)
    .ymImage([UIImage imageNamed:imageName].ymAlpha(0.5), UIControlStateHighlighted)
    .ymPosition(YM_ImagePosition_Top, 10)
    .ymAction(self, @selector(buttonAction:), UIControlEventTouchUpInside);
    return button;
}

@end
