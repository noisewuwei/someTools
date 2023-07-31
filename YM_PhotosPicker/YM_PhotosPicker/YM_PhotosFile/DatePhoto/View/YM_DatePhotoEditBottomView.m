//
//  YM_DatePhotoEditBottomView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoEditBottomView.h"
#import "YM_PhotoTools.h"
#import "NSBundle+YM_PhotoPicker.h"
#import "YM_EditRatio.h"

@interface YM_DatePhotoEditBottomView ()

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *restoreBtn;
@property (strong, nonatomic) UIButton *rotateBtn;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *clipBtn;
@property (strong, nonatomic) YM_PhotoManager *manager;
@property (strong, nonatomic) UIButton *selectRatioBtn;

@end

@implementation YM_DatePhotoEditBottomView

- (instancetype)initWithManager:(YM_PhotoManager *)manager {
    self = [super init];
    if (self) {
        self.manager = manager;
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    if (!self.manager.configuration.movableCropBox) {
        [self addSubview:self.topView];
    }else {
        if (CGPointEqualToPoint(self.manager.configuration.movableCropBoxCustomRatio, CGPointZero)) {
            [self addSubview:self.topView];
        }
    }
    [self addSubview:self.bottomView];
}
- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.restoreBtn.enabled = enabled;
    if (!self.manager.configuration.singleSelected) {
        self.clipBtn.enabled = enabled;
    }
}
- (void)didRestoreBtnClick {
    if ([self.delegate respondsToSelector:@selector(bottomViewDidRestoreClick)]) {
        [self.delegate bottomViewDidRestoreClick];
    }
}
- (void)didCancelBtnClick {
    if ([self.delegate respondsToSelector:@selector(bottomViewDidCancelClick)]) {
        [self.delegate bottomViewDidCancelClick];
    }
}
- (void)didRotateBtnClick {
    if ([self.delegate respondsToSelector:@selector(bottomViewDidRotateClick)]) {
        [self.delegate bottomViewDidRotateClick];
    }
}
- (void)didClipBtnClick {
    if ([self.delegate respondsToSelector:@selector(bottomViewDidClipClick)]) {
        [self.delegate bottomViewDidClipClick];
    }
}
- (void)didSelectRatioBtnClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"原始值"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupRatioWithValue1:0 value2:0];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"正方形"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupRatioWithValue1:1 value2:1];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"2:3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupRatioWithValue1:2 value2:3];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"3:4" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupRatioWithValue1:3 value2:4];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"9:16" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupRatioWithValue1:9 value2:16];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"取消"] style:UIAlertActionStyleCancel handler:nil]];
    
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}
- (void)setupRatioWithValue1:(CGFloat)value1 value2:(CGFloat)value2 {
    YM_EditRatio *ratio = [[YM_EditRatio alloc] initWithValue1:value1 value2:value2];
    ratio.isLandscape = NO;
    
    if ([self.delegate respondsToSelector:@selector(bottomViewDidSelectRatioClick:)]) {
        [self.delegate bottomViewDidSelectRatioClick:ratio];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.topView.frame = CGRectMake(0, 0, self.hx_w, 60);
    self.bottomView.frame = CGRectMake(0, 60, self.hx_w, 40);
    self.restoreBtn.hx_x = self.hx_w / 2 - 20 - self.restoreBtn.hx_w;
    self.restoreBtn.center = CGPointMake(self.restoreBtn.center.x, 30);
    
    self.rotateBtn.hx_x = self.hx_w / 2 + 20;
    self.rotateBtn.center = CGPointMake(self.rotateBtn.center.x, 30);
    
    self.cancelBtn.frame = CGRectMake(20, 0, [YM_PhotoTools getTextWidth:self.cancelBtn.currentTitle height:40 fontSize:15] + 20, 40);
    self.clipBtn.hx_size = CGSizeMake(50, 40);
    self.clipBtn.hx_x = self.hx_w - 20 - self.clipBtn.hx_w;
    
    self.selectRatioBtn.center = CGPointMake(self.hx_w / 2, 20);
}
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        [_topView addSubview:self.restoreBtn];
        [_topView addSubview:self.rotateBtn];
    }
    return _topView;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [_bottomView addSubview:self.cancelBtn];
        [_bottomView addSubview:self.clipBtn];
        if (!self.manager.configuration.movableCropBox) {
            [_bottomView addSubview:self.selectRatioBtn];
        }else {
            if (CGPointEqualToPoint(self.manager.configuration.movableCropBoxCustomRatio, CGPointZero)) {
                [_bottomView addSubview:self.selectRatioBtn];
            }
        }
    }
    return _bottomView;
}
- (UIButton *)selectRatioBtn {
    if (!_selectRatioBtn) {
        _selectRatioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectRatioBtn setImage:[YM_PhotoTools ym_imageNamed:@"icon_xiangce_xuanbili@2x.png"] forState:UIControlStateNormal];
        _selectRatioBtn.hx_size = CGSizeMake(50, 40);
        [_selectRatioBtn addTarget:self action:@selector(didSelectRatioBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectRatioBtn;
}
- (UIButton *)restoreBtn {
    if (!_restoreBtn) {
        _restoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_restoreBtn setImage:[YM_PhotoTools ym_imageNamed:@"paizhao_bianji_huanyuan@2x.png"] forState:UIControlStateNormal];
        [_restoreBtn setTitle:[NSBundle ym_localizedStringForKey:@"还原"] forState:UIControlStateNormal];
        [_restoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_restoreBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        _restoreBtn.enabled = NO;
        _restoreBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _restoreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_restoreBtn addTarget:self action:@selector(didRestoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _restoreBtn.hx_size = CGSizeMake(100, 60);
    }
    return _restoreBtn;
}
- (UIButton *)rotateBtn {
    if (!_rotateBtn) {
        _rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rotateBtn setImage:[YM_PhotoTools ym_imageNamed:@"paizhao_bianji_xuanzhuan@2x.png"] forState:UIControlStateNormal];
        [_rotateBtn setTitle:[NSBundle ym_localizedStringForKey:@"旋转"] forState:UIControlStateNormal];
        [_rotateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _rotateBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _rotateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_rotateBtn addTarget:self action:@selector(didRotateBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _rotateBtn.hx_size = CGSizeMake(100, 60);
    }
    return _rotateBtn;
}
- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:[NSBundle ym_localizedStringForKey:@"取消"] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cancelBtn addTarget:self action:@selector(didCancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
- (UIButton *)clipBtn {
    if (!_clipBtn) {
        _clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (self.manager.configuration.singleSelected) {
            [_clipBtn setTitle:[NSBundle ym_localizedStringForKey:@"选择"] forState:UIControlStateNormal];
        }else {
            [_clipBtn setTitle:[NSBundle ym_localizedStringForKey:@"裁剪"] forState:UIControlStateNormal];
            if (!self.manager.configuration.movableCropBox) {
                _clipBtn.enabled = NO;
            }else {
                if (CGPointEqualToPoint(self.manager.configuration.movableCropBoxCustomRatio, CGPointZero)) {
                    _clipBtn.enabled = NO;
                }
            }
        }
        UIColor *color = self.manager.configuration.themeColor;
        if ([color isEqual:[UIColor blackColor]]) {
            color = [UIColor whiteColor];
        }
        [_clipBtn setTitleColor:color forState:UIControlStateNormal];
        [_clipBtn setTitleColor:[color colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        _clipBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _clipBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_clipBtn addTarget:self action:@selector(didClipBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clipBtn;
}

@end
