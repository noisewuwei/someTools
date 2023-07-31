//
//  YM_CustomCameraBottomView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_CustomCameraBottomView.h"
#import "NSBundle+YM_PhotoPicker.h"
#import "UIFont+YM_Extension.h"
#import "YM_FullScreenCameraPlayView.h"

@interface YM_CustomCameraBottomView ()

@property (strong, nonatomic) CAGradientLayer *maskLayer;
@property (strong, nonatomic) YM_FullScreenCameraPlayView *playView;
@property (strong, nonatomic) YM_PhotoManager *manager;
@property (strong, nonatomic) UILabel *titleLb;
@property (strong, nonatomic) UILabel *timeLb;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UIButton *photoBtn;
@property (strong, nonatomic) UIButton *videoBtn;
@property (assign, nonatomic) BOOL isOutside;

@end

@implementation YM_CustomCameraBottomView

- (instancetype)initWithFrame:(CGRect)frame
                      manager:(YM_PhotoManager *)manager
                    isOutside:(BOOL)isOutside{
    self = [super initWithFrame:frame];
    if (self) {
        self.isOutside = isOutside;
        self.manager = manager;
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self.layer addSublayer:self.maskLayer];
    [self addSubview:self.playView];
    [self addSubview:self.titleLb];
    [self addSubview:self.timeLb];
    [self addSubview:self.photoBtn];
    [self addSubview:self.videoBtn];
    self.photoBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 0);
    self.videoBtn.hx_x = CGRectGetMaxX(self.photoBtn.frame) + 10;
    self.titleLb.alpha = 0;
    if (self.manager.type == YM_PhotoManagerType_All) {
        if (!self.manager.configuration.selectTogether && self.isOutside) {
            if (self.manager.afterSelectedPhotoArray.count > 0) {
                self.mode = YM_CustomCameraBottomViewModePhoto;
                self.titleLb.text = [NSBundle ym_localizedStringForKey:@"点击拍照"];
                self.titleLb.alpha = 1;
                self.photoBtn.hidden = YES;
                self.videoBtn.hidden = YES;
            }else if (self.manager.afterSelectedVideoArray.count > 0) {
                self.mode = YM_CustomCameraBottomViewModeVideo;
                self.titleLb.text = [NSBundle ym_localizedStringForKey:@"点击录制"];
                self.titleLb.alpha = 1;
                self.photoBtn.hidden = YES;
                self.videoBtn.hidden = YES;
            }else {
                self.mode = YM_CustomCameraBottomViewModePhoto;
                self.titleLb.text = [NSBundle ym_localizedStringForKey:@"点击拍照"];
                self.photoBtn.hidden = NO;
                self.videoBtn.hidden = NO;
                self.photoBtn.enabled = NO;
                self.videoBtn.enabled = YES;
            }
        }else {
            self.mode = YM_CustomCameraBottomViewModePhoto;
            self.titleLb.text = [NSBundle ym_localizedStringForKey:@"点击拍照"];
            self.photoBtn.hidden = NO;
            self.videoBtn.hidden = NO;
            self.photoBtn.enabled = NO;
            self.videoBtn.enabled = YES;
        }
    }else if (self.manager.type == YM_PhotoManagerType_Photo) {
        self.mode = YM_CustomCameraBottomViewModePhoto;
        self.titleLb.text = [NSBundle ym_localizedStringForKey:@"点击拍照"];
        self.titleLb.alpha = 1;
        self.photoBtn.hidden = YES;
        self.videoBtn.hidden = YES;
    }else {
        self.mode = YM_CustomCameraBottomViewModeVideo;
        self.titleLb.text = [NSBundle ym_localizedStringForKey:@"点击录制"];
        self.titleLb.alpha = 1;
        self.photoBtn.hidden = YES;
        self.videoBtn.hidden = YES;
    }
}
- (void)takePictures {
    if ([self.delegate respondsToSelector:@selector(playViewClick)]) {
        [self.delegate playViewClick];
    }
}
- (void)changeTime:(NSInteger)time {
    if (time < 3) {
        self.timeLb.text = [NSBundle ym_localizedStringForKey:@"3秒内的视频无效哦~"];
    }else {
        self.timeLb.text = [NSString stringWithFormat:@"%lds",time];
    }
    self.playView.progress = (CGFloat)time / self.manager.configuration.videoMaximumDuration;
}
- (void)beganAnimate {
    self.userInteractionEnabled = NO;
    self.titleLb.alpha = 0;
    self.photoBtn.hidden = YES;
    self.videoBtn.hidden = YES;
    self.animating = YES;
    self.tap.enabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.playView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        self.animating = NO;
        if ([self.delegate respondsToSelector:@selector(playViewAnimateCompletion)]) {
            [self.delegate playViewAnimateCompletion];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tap.enabled = YES;
            self.userInteractionEnabled = YES;
        });
    }];
}
- (void)startRecord {
    self.timeLb.hidden = NO;
    self.timeLb.text = [NSBundle ym_localizedStringForKey:@"3秒内的视频无效哦~"];
}
- (void)stopRecord {
    if (self.manager.type == YM_PhotoManagerType_All && self.isOutside) {
        if (!self.manager.configuration.selectTogether) {
            if (self.manager.afterSelectedPhotoArray.count > 0) {
                self.titleLb.alpha = 1;
            }else if (self.manager.afterSelectedVideoArray.count > 0) {
                self.titleLb.alpha = 1;
            }else {
                self.photoBtn.hidden = NO;
                self.videoBtn.hidden = NO;
            }
        }else {
            self.photoBtn.hidden = NO;
            self.videoBtn.hidden = NO;
        }
    }else {
        if (self.manager.type == YM_PhotoManagerType_All) {
            self.photoBtn.hidden = NO;
            self.videoBtn.hidden = NO;
        }else {
            self.titleLb.alpha = 1;
        }
    }
    self.timeLb.hidden = YES;
    [self.playView clean];
    self.playView.transform = CGAffineTransformIdentity;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.maskLayer.frame = CGRectMake(0, -40, self.hx_w, self.hx_h + 40);
    self.playView.center = CGPointMake(self.hx_w / 2, self.hx_h / 2 + 10);
    self.timeLb.frame = CGRectMake(12, self.playView.hx_y - 26, self.hx_w - 24, 15);
    self.titleLb.frame = CGRectMake(12, self.playView.hx_y - 20 - 30, self.hx_w - 24, 15);
    if (self.manager.type == YM_PhotoManagerType_Video || self.manager.type == YM_PhotoManagerType_Photo) {
        self.titleLb.hx_y = self.playView.hx_y - 30;
    }else if (self.manager.type == YM_PhotoManagerType_All) {
        if (!self.manager.configuration.selectTogether && self.isOutside) {
            if (self.manager.afterSelectedPhotoArray.count > 0) {
                self.titleLb.hx_y = self.playView.hx_y - 30;
            }else if (self.manager.afterSelectedVideoArray.count > 0) {
                self.titleLb.hx_y = self.playView.hx_y - 30;
            }
        }
    }
    self.photoBtn.hx_y = self.playView.hx_y - 30;
    self.videoBtn.hx_y = self.photoBtn.hx_y;
}
- (void)leftAnimate {
    if (self.videoBtn.center.x == self.hx_w / 2) {
        return;
    }
    self.mode = YM_CustomCameraBottomViewModeVideo;
    self.titleLb.text = [NSBundle ym_localizedStringForKey:@"点击录制"];
    self.titleLb.alpha = 0;
    self.videoBtn.enabled = NO;
    self.photoBtn.enabled = YES;
    if ([self.delegate respondsToSelector:@selector(playViewChangeMode:)]) {
        [self.delegate playViewChangeMode:self.mode];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.videoBtn.center = CGPointMake(self.hx_w / 2, 0);
        self.videoBtn.hx_y = self.playView.hx_y - 30;
        self.photoBtn.hx_x -= 15 + 40;
        self.titleLb.alpha = 1;
    } completion:^(BOOL finished) {
        [self hideTitleLb];
    }];
}
- (void)rightAnimate {
    if (self.photoBtn.center.x == self.hx_w / 2) {
        return;
    }
    self.mode = YM_CustomCameraBottomViewModePhoto;
    self.titleLb.text = [NSBundle ym_localizedStringForKey:@"点击拍照"];
    self.titleLb.alpha = 0;
    self.photoBtn.enabled = NO;
    self.videoBtn.enabled = YES;
    if ([self.delegate respondsToSelector:@selector(playViewChangeMode:)]) {
        [self.delegate playViewChangeMode:self.mode];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.photoBtn.center = CGPointMake(self.hx_w / 2, 0);
        self.photoBtn.hx_y = self.playView.hx_y - 30;
        self.videoBtn.hx_x += 15 + 40;
        self.titleLb.alpha = 1;
    } completion:^(BOOL finished) {
        [self hideTitleLb];
    }];
}
- (void)hideTitleLb {
    [UIView animateWithDuration:1.0f animations:^{
        self.titleLb.alpha = 0;
    }];
}
- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.textColor = [UIColor whiteColor];
        _titleLb.font = [UIFont ym_pingFangFontOfSize:14];
    }
    return _titleLb;
}
- (UILabel *)timeLb {
    if (!_timeLb) {
        _timeLb = [[UILabel alloc] init];
        _timeLb.textAlignment = NSTextAlignmentCenter;
        _timeLb.textColor = [UIColor whiteColor];
        _timeLb.font = [UIFont ym_pingFangFontOfSize:14];
        _timeLb.hidden = YES;
    }
    return _timeLb;
}
- (CAGradientLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAGradientLayer layer];
        _maskLayer.colors = @[
                              (id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor,
                              (id)[[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor
                              ];
        _maskLayer.startPoint = CGPointMake(0, 0);
        _maskLayer.endPoint = CGPointMake(0, 1);
        _maskLayer.locations = @[@(0),@(1.f)];
        _maskLayer.borderWidth  = 0.0;
    }
    return _maskLayer;
}
- (YM_FullScreenCameraPlayView *)playView {
    if (!_playView) {
        _playView = [[YM_FullScreenCameraPlayView alloc] initWithFrame:CGRectMake(0, 0, 70, 70) color:self.manager.configuration.themeColor];
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePictures)];
        [_playView addGestureRecognizer:self.tap];
    }
    return _playView;
}
- (UIButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoBtn setTitle:[NSBundle ym_localizedStringForKey:@"照片"] forState:UIControlStateNormal];
        [_photoBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
        [_photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        _photoBtn.titleLabel.font = [UIFont ym_pingFangFontOfSize:14];
        _photoBtn.hx_size = CGSizeMake(40, 20);
        [_photoBtn addTarget:self action:@selector(rightAnimate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}
- (UIButton *)videoBtn {
    if (!_videoBtn) {
        _videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoBtn setTitle:[NSBundle ym_localizedStringForKey:@"视频"] forState:UIControlStateNormal];
        [_videoBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
        [_videoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        _videoBtn.titleLabel.font = [UIFont ym_pingFangFontOfSize:14];
        _videoBtn.hx_size = CGSizeMake(40, 20);
        [_videoBtn addTarget:self action:@selector(leftAnimate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoBtn;
}
@end

