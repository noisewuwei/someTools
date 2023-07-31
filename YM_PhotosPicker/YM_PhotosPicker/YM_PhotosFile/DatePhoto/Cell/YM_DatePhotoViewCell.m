//
//  YM_DatePhotoViewCell.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoViewCell.h"
#import <Photos/Photos.h>
#import "YM_DownloadProgressView.h"
#import "YM_CircleProgressView.h"
#import "UIImageView+YM_Extension.h"
#import "UIView+YM_Extension.h"
#import "UIButton+YM_Extension.h"
#import "YM_PhotoTools.h"

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>
#elif __has_include("UIImageView+WebCache.h")
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "UIView+WebCache.h"
#endif

@interface YM_DatePhotoViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *maskView;
@property (copy, nonatomic)  NSString *localIdentifier;
@property (assign, nonatomic) PHImageRequestID requestID;
@property (assign, nonatomic) PHImageRequestID iCloudRequestID;
@property (strong, nonatomic) UILabel *stateLb;
@property (strong, nonatomic) CAGradientLayer *bottomMaskLayer;
@property (strong, nonatomic) UIButton *selectBtn;
@property (strong, nonatomic) UIImageView *iCloudIcon;
@property (strong, nonatomic) CALayer *iCloudMaskLayer;
@property (strong, nonatomic) YM_DownloadProgressView * downloadView;
@property (strong, nonatomic) YM_CircleProgressView   * progressView;
@property (strong, nonatomic) CALayer *videoMaskLayer;

@end

@implementation YM_DatePhotoViewCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.maskView];
    [self.contentView addSubview:self.downloadView];
    [self.contentView addSubview:self.progressView];
}
- (void)bottomViewPrepareAnimation {
    self.maskView.alpha = 0;
}
- (void)bottomViewStartAnimation {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.maskView.alpha = 1;
    } completion:nil];
}
- (void)setSingleSelected:(BOOL)singleSelected {
    _singleSelected = singleSelected;
    if (singleSelected) {
        [self.selectBtn removeFromSuperview];
    }
}
- (void)setModel:(YM_PhotoModel *)model {
    _model = model;
    self.progressView.hidden = YES;
    self.progressView.progress = 0;
    kWeakSelf
    if (model.type == YM_PhotoModelMediaType_Camera || model.type == YM_PhotoModelMediaType_CameraPhoto || model.type == YM_PhotoModelMediaType_CameraVideo) {
        kStrongSelf
        if (model.networkPhotoUrl) {
            self.progressView.hidden = model.downloadComplete;
            CGFloat progress = (CGFloat)model.receivedSize / model.expectedSize;
            self.progressView.progress = progress;
            [self.imageView hx_setImageWithModel:model progress:^(CGFloat progress, YM_PhotoModel *model) {
                if (self.model == model) {
                    self.progressView.progress = progress;
                }
            } completed:^(UIImage *image, NSError *error, YM_PhotoModel *model) {
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
            self.imageView.image = model.thumbPhoto;
        }
    }else {
        self.imageView.image = nil;
        PHImageRequestID requestID = [YM_PhotoTools getImageWithModel:model completion:^(UIImage *image, YM_PhotoModel *model) {
            if (self.model == model) {
                self.imageView.image = image;
            }
        }];
        self.requestID = requestID;
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
    self.selectMaskLayer.hidden = !model.selected;
    self.selectBtn.selected = model.selected;
    [self.selectBtn setTitle:model.selectIndexStr forState:UIControlStateSelected];
    self.selectBtn.backgroundColor = model.selected ? self.selectBgColor :nil;
    
    //    if (model.isICloud) {
    //        self.selectBtn.userInteractionEnabled = NO;
    //    }else {
    //        self.selectBtn.userInteractionEnabled = YES;
    //    }
    
    self.iCloudIcon.hidden = !model.isICloud;
    self.iCloudMaskLayer.hidden = !model.isICloud;
    
    // 当前是否需要隐藏选择按钮
    if (model.needHideSelectBtn) {
        self.selectBtn.hidden = YES;
        self.selectBtn.userInteractionEnabled = NO;
    }else {
        self.selectBtn.hidden = model.isICloud;
        self.selectBtn.userInteractionEnabled = !model.isICloud;
    }
    
    if (model.isICloud) {
        self.videoMaskLayer.hidden = YES;
        self.userInteractionEnabled = YES;
    }else {
        // 当前是否需要隐藏选择按钮
        if (model.needHideSelectBtn) {
            // 当前视频是否不可选
            self.videoMaskLayer.hidden = !model.videoUnableSelect;
            self.userInteractionEnabled = !model.videoUnableSelect;
        }else {
            self.videoMaskLayer.hidden = YES;
            self.userInteractionEnabled = YES;
        }
    }
    
    //    self.iCloudIcon.hidden = !model.isICloud;
    //    self.selectBtn.hidden = model.isICloud;
    //    self.iCloudMaskLayer.hidden = !model.isICloud;
    
    if (model.iCloudDownloading) {
        if (model.isICloud) {
            self.downloadView.progress = model.iCloudProgress;
            [self startRequestICloudAsset];
        }else {
            model.iCloudDownloading = NO;
            self.downloadView.hidden = YES;
        }
    }else {
        self.downloadView.hidden = YES;
    }
}
- (void)setSelectBgColor:(UIColor *)selectBgColor {
    _selectBgColor = selectBgColor;
    if ([selectBgColor isEqual:[UIColor whiteColor]] && !self.selectedTitleColor) {
        [self.selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    }
}
- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    [self.selectBtn setTitleColor:selectedTitleColor forState:UIControlStateSelected];
}
- (void)startRequestICloudAsset {
    self.downloadView.hidden = NO;
    [self.downloadView startAnima];
    self.iCloudIcon.hidden = YES;
    self.iCloudMaskLayer.hidden = YES;
    kWeakSelf
    if (self.model.type == YM_PhotoModelMediaType_Video) {
        self.iCloudRequestID = [YM_PhotoTools getAVAssetWithModel:self.model startRequestIcloud:^(PHImageRequestID cloudRequestId, YM_PhotoModel *model) {
            kStrongSelf
            if (self.model == model) {
                self.downloadView.hidden = NO;
                self.iCloudRequestID = cloudRequestId;
            }
        } progressHandler:^(YM_PhotoModel *model, double progress) {
            kStrongSelf
            if (self.model == model) {
                self.downloadView.hidden = NO;
                self.downloadView.progress = progress;
            }
        } completion:^(YM_PhotoModel *model, AVAsset *asset) {
            kStrongSelf
            if (self.model == model) {
                self.downloadView.progress = 1;
                if ([self.delegate respondsToSelector:@selector(datePhotoViewCellRequestICloudAssetComplete:)]) {
                    [self.delegate datePhotoViewCellRequestICloudAssetComplete:weakSelf];
                }
            }
        } failed:^(YM_PhotoModel *model, NSDictionary *info) {
            kStrongSelf
            if (self.model == model) {
                [self downloadError:info];
            }
        }];
    }else if (self.model.type == YM_PhotoModelMediaType_LivePhoto){
        self.iCloudRequestID = [YM_PhotoTools getLivePhotoWithModel:self.model size:CGSizeMake(self.model.previewViewSize.width * 1.5, self.model.previewViewSize.height * 1.5) startRequestICloud:^(YM_PhotoModel *model, PHImageRequestID iCloudRequestId) {
            kStrongSelf
            if (self.model == model) {
                self.downloadView.hidden = NO;
                self.iCloudRequestID = iCloudRequestId;
            }
        } progressHandler:^(YM_PhotoModel *model, double progress) {
            kStrongSelf
            if (self.model == model) {
                self.downloadView.hidden = NO;
                self.downloadView.progress = progress;
            }
        } completion:^(YM_PhotoModel *model, PHLivePhoto *livePhoto) {
            kStrongSelf
            if (self.model == model) {
                self.downloadView.progress = 1;
                if ([self.delegate respondsToSelector:@selector(datePhotoViewCellRequestICloudAssetComplete:)]) {
                    [self.delegate datePhotoViewCellRequestICloudAssetComplete:weakSelf];
                }
            }
        } failed:^(YM_PhotoModel *model, NSDictionary *info) {
            kStrongSelf
            if (self.model == model) {
                [self downloadError:info];
            }
        }];
    }else {
        self.iCloudRequestID = [YM_PhotoTools getImageDataWithModel:self.model startRequestIcloud:^(PHImageRequestID cloudRequestId, YM_PhotoModel *model) {
            kStrongSelf
            if (self.model == model) {
                self.downloadView.hidden = NO;
                self.iCloudRequestID = cloudRequestId;
            }
        } progressHandler:^(YM_PhotoModel *model, double progress) {
            kStrongSelf
            if (self.model == model) {
                self.downloadView.hidden = NO;
                self.downloadView.progress = progress;
            }
        } completion:^(YM_PhotoModel *model, NSData *imageData, UIImageOrientation orientation) {
            kStrongSelf
            if (self.model == model) {
                self.downloadView.progress = 1;
                if ([self.delegate respondsToSelector:@selector(datePhotoViewCellRequestICloudAssetComplete:)]) {
                    [self.delegate datePhotoViewCellRequestICloudAssetComplete:weakSelf];
                }
            }
        } failed:^(YM_PhotoModel *model, NSDictionary *info) {
            kStrongSelf
            if (self.model == model) {
                [self downloadError:info];
            }
        }];
    }
}
- (void)downloadError:(NSDictionary *)info {
    if (![[info objectForKey:PHImageCancelledKey] boolValue]) {
        [[self viewController].view showImageHUDText:[NSBundle ym_localizedStringForKey:@"下载失败，请重试！"]];
    }
    self.downloadView.hidden = YES;
    [self.downloadView resetState];
    self.iCloudIcon.hidden = !self.model.isICloud;
    self.iCloudMaskLayer.hidden = !self.model.isICloud;
}
- (void)cancelRequest {
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
    [self.imageView sd_cancelCurrentImageLoad];
#endif
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
    if (self.iCloudRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.iCloudRequestID];
        self.iCloudRequestID = -1;
    }
}
- (void)didSelectClick:(UIButton *)button {
    if (self.model.type == YM_PhotoModelMediaType_Camera) {
        return;
    }
    if (self.model.isICloud) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(datePhotoViewCell:didSelectBtn:)]) {
        [self.delegate datePhotoViewCell:self didSelectBtn:button];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.maskView.frame = self.bounds;
    self.stateLb.frame = CGRectMake(0, self.hx_h - 18, self.hx_w - 4, 18);
    self.bottomMaskLayer.frame = CGRectMake(0, self.hx_h - 25, self.hx_w, 25);
    self.selectBtn.frame = CGRectMake(self.hx_w - 27, 2, 25, 25);
    self.selectMaskLayer.frame = self.bounds;
    self.iCloudMaskLayer.frame = self.bounds;
    self.iCloudIcon.hx_x = self.hx_w - 3 - self.iCloudIcon.hx_w;
    self.iCloudIcon.hx_y = 3;
    self.downloadView.frame = self.bounds;
    self.progressView.center = CGPointMake(self.hx_w / 2, self.hx_h / 2);
    self.videoMaskLayer.frame = self.bounds;
}
- (void)dealloc {
    self.model.dateCellIsVisible = NO;
}
#pragma mark - < 懒加载 >
- (YM_DownloadProgressView *)downloadView {
    if (!_downloadView) {
        _downloadView = [[YM_DownloadProgressView alloc] initWithFrame:self.bounds];
    }
    return _downloadView;
}
- (YM_CircleProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[YM_CircleProgressView alloc] init];
        _progressView.hidden = YES;
    }
    return _progressView;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        [_maskView.layer addSublayer:self.bottomMaskLayer];
        [_maskView.layer addSublayer:self.selectMaskLayer];
        [_maskView.layer addSublayer:self.iCloudMaskLayer];
        [_maskView.layer addSublayer:self.videoMaskLayer];
        [_maskView addSubview:self.iCloudIcon];
        [_maskView addSubview:self.stateLb];
        [_maskView addSubview:self.selectBtn];
    }
    return _maskView;
}
- (UIImageView *)iCloudIcon {
    if (!_iCloudIcon) {
        _iCloudIcon = [[UIImageView alloc] initWithImage:[YM_PhotoTools ym_imageNamed:@"icon_yunxiazai@2x.png"]];
        _iCloudIcon.hx_size = _iCloudIcon.image.size;
    }
    return _iCloudIcon;
}
- (CALayer *)selectMaskLayer {
    if (!_selectMaskLayer) {
        _selectMaskLayer = [CALayer layer];
        _selectMaskLayer.hidden = YES;
        _selectMaskLayer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
    }
    return _selectMaskLayer;
}
- (CALayer *)iCloudMaskLayer {
    if (!_iCloudMaskLayer) {
        _iCloudMaskLayer = [CALayer layer];
        _iCloudMaskLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    }
    return _iCloudMaskLayer;
}
- (CALayer *)videoMaskLayer {
    if (!_videoMaskLayer) {
        _videoMaskLayer = [CALayer layer];
        _videoMaskLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    }
    return _videoMaskLayer;
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
- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setBackgroundImage:[YM_PhotoTools ym_imageNamed:@"compose_guide_check_box_default@2x.png"] forState:UIControlStateNormal];
        [_selectBtn setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected];
        [_selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _selectBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _selectBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_selectBtn addTarget:self action:@selector(didSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        [_selectBtn setEnlargeEdgeWithTop:0 right:0 bottom:20 left:20];
        _selectBtn.layer.cornerRadius = 25 / 2;
    }
    return _selectBtn;
}

@end
