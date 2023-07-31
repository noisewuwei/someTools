//
//  YM_PhotoSubViewCell.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PhotoSubViewCell.h"
#import "YM_PhotoModel.h"
#import "YM_CircleProgressView.h"
#import "YM_PhotoTools.h"
#import "UIImageView+YM_Extension.h"

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#elif __has_include("UIImageView+WebCache.h")
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"
#endif

@interface YM_PhotoSubViewCell () <UIAlertViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) YM_CircleProgressView *progressView;
@property (assign, nonatomic) int32_t requestID;
@property (strong, nonatomic) UILabel *stateLb;
@property (strong, nonatomic) CAGradientLayer *bottomMaskLayer;

@end

@implementation YM_PhotoSubViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
#pragma mark - < 懒加载 >
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_imageView.layer addSublayer:self.bottomMaskLayer];
    }
    return _imageView;
}
- (UILabel *)stateLb {
    if (!_stateLb) {
        _stateLb = [[UILabel alloc] init];
        _stateLb.textColor = [UIColor whiteColor];
        _stateLb.textAlignment = NSTextAlignmentRight;
        _stateLb.font = [UIFont systemFontOfSize:12];
    }
    return _stateLb;
}
- (CAGradientLayer *)bottomMaskLayer {
    if (!_bottomMaskLayer) {
        _bottomMaskLayer = [CAGradientLayer layer];
        _bottomMaskLayer.colors = @[
                                    (id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor,
                                    (id)[[UIColor blackColor] colorWithAlphaComponent:0.35].CGColor
                                    ];
        _bottomMaskLayer.startPoint = CGPointMake(0, 0);
        _bottomMaskLayer.endPoint = CGPointMake(0, 1);
        _bottomMaskLayer.locations = @[@(0.15f),@(0.9f)];
        _bottomMaskLayer.borderWidth  = 0.0;
    }
    return _bottomMaskLayer;
}
- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[YM_PhotoTools ym_imageNamed:@"compose_delete@2x.png"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(didDeleteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}
- (YM_CircleProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[YM_CircleProgressView alloc] init];
        _progressView.hidden = YES;
    }
    return _progressView;
}
- (void)setup {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.stateLb];
    [self.contentView addSubview:self.deleteBtn];
    [self.contentView addSubview:self.progressView];
}

- (void)didDeleteClick {
    if (self.model.networkPhotoUrl) {
        if (self.showDeleteNetworkPhotoAlert) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSBundle ym_localizedStringForKey:@"提示"] message:[NSBundle ym_localizedStringForKey:@"是否删除此照片"] delegate:self cancelButtonTitle:[NSBundle ym_localizedStringForKey:@"取消"] otherButtonTitles:[NSBundle ym_localizedStringForKey:@"确定"], nil];
            [alert show];
            return;
        }
    }
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
    [self.imageView sd_cancelCurrentImageLoad];
#endif
    if ([self.delegate respondsToSelector:@selector(cellDidDeleteClcik:)]) {
        [self.delegate cellDidDeleteClcik:self];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([self.delegate respondsToSelector:@selector(cellDidDeleteClcik:)]) {
            [self.delegate cellDidDeleteClcik:self];
        }
    }
}

- (void)againDownload {
    self.model.downloadError = NO;
    self.model.downloadComplete = NO;
    kWeakSelf
    [self.imageView hx_setImageWithModel:self.model progress:^(CGFloat progress, YM_PhotoModel *model) {
        kStrongSelf
        if (self.model == model) {
            self.progressView.progress = progress;
        }
    } completed:^(UIImage *image, NSError *error, YM_PhotoModel *model) {
        kStrongSelf
        if (self.model == model) {
            if (error != nil) {
                self.model.downloadError = YES;
                self.model.downloadComplete = YES;
                [self.progressView showError];
            }else {
                if (image) {
                    self.progressView.progress = 1;
                    self.progressView.hidden = YES;
                    self.imageView.image = image;
                    self.userInteractionEnabled = YES;
                }
            }
        }
    }];
}
- (void)setHideDeleteButton:(BOOL)hideDeleteButton {
    _hideDeleteButton = hideDeleteButton;
    if (self.model.type != YM_PhotoModelMediaType_Camera) {
        self.deleteBtn.hidden = hideDeleteButton;
    }
}
- (void)setModel:(YM_PhotoModel *)model {
    _model = model;
    self.progressView.hidden = YES;
    self.progressView.progress = 0;
    self.imageView.image = nil;
    if (model.type == YM_PhotoModelMediaType_Camera) {
        self.deleteBtn.hidden = YES;
        self.imageView.image = model.thumbPhoto;
    }else {
        self.deleteBtn.hidden = NO;
        if (model.networkPhotoUrl) {
            //        if ([[model.networkPhotoUrl substringFromIndex:model.networkPhotoUrl.length - 3] isEqualToString:@"gif"]) {
            //            self.gifIcon.hidden = NO;
            //        }
            kWeakSelf
            self.progressView.hidden = model.downloadComplete;
            [self.imageView hx_setImageWithModel:model progress:^(CGFloat progress, YM_PhotoModel *model) {
                kStrongSelf
                if (self.model == model) {
                    self.progressView.progress = progress;
                }
            } completed:^(UIImage *image, NSError *error, YM_PhotoModel *model) {
                kStrongSelf
                if (self.model == model) {
                    if (error != nil) {
                        [self.progressView showError];
                    }else {
                        if (image) {
                            self.progressView.progress = 1;
                            self.progressView.hidden = YES;
                            self.imageView.image = image;
                        }
                    }
                }
            }];
        }else {
            if (model.previewPhoto) {
                self.imageView.image = model.previewPhoto;
            }else {
                self.imageView.image = model.thumbPhoto;
            }
        }
    }
    if (model.type == YM_PhotoModelMediaType_PhotoGif) {
        self.stateLb.text = @"GIF";
        self.stateLb.hidden = NO;
        self.bottomMaskLayer.hidden = NO;
    }else if (model.type == YM_PhotoModelMediaType_LivePhoto) {
        self.stateLb.text = @"Live";
        self.stateLb.hidden = NO;
        self.bottomMaskLayer.hidden = NO;
    }else {
        if (model.subType == YM_PhotoModelMediaSubType_Video) {
            self.stateLb.text = model.videoTime;
            self.stateLb.hidden = NO;
            self.bottomMaskLayer.hidden = NO;
        }else {
            self.stateLb.hidden = YES;
            self.bottomMaskLayer.hidden = YES;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    
    self.stateLb.frame = CGRectMake(0, self.hx_h - 18, self.hx_w - 4, 18);
    self.bottomMaskLayer.frame = CGRectMake(0, self.hx_h - 25, self.hx_w, 25);
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat deleteBtnW = self.deleteBtn.currentImage.size.width;
    CGFloat deleteBtnH = self.deleteBtn.currentImage.size.height;
    self.deleteBtn.frame = CGRectMake(width - deleteBtnW, 0, deleteBtnW, deleteBtnH);
    
    self.progressView.center = CGPointMake(width / 2, height / 2);
}

@end
