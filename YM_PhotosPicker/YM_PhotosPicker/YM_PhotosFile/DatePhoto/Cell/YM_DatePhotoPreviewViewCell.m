//
//  YM_DatePhotoPreviewViewCell.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoPreviewViewCell.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "YM_CircleProgressView.h"
#import "UIImageView+YM_Extension.h"
#import "UIImage+YM_Extension.h"
#import "YM_PhotoTools.h"
@interface YM_DatePhotoPreviewViewCell () <UIScrollViewDelegate,PHLivePhotoViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGPoint imageCenter;
@property (strong, nonatomic) UIImage *gifImage;
@property (strong, nonatomic) UIImage *gifFirstFrame;
@property (assign, nonatomic) PHImageRequestID requestID;
@property (strong, nonatomic) PHLivePhotoView *livePhotoView;
@property (assign, nonatomic) BOOL livePhotoAnimating;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) YM_CircleProgressView *progressView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation YM_DatePhotoPreviewViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.requestID = -1;
        [self setup];
    }
    return self;
}
- (void)setup {
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.contentView.layer addSublayer:self.playerLayer];
    [self.contentView addSubview:self.videoPlayBtn];
    //    [self.scrollView addSubview:self.livePhotoView];
    [self.contentView addSubview:self.progressView];
    [self.contentView addSubview:self.loadingView];
}
- (void)resetScale {
    [self.scrollView setZoomScale:1.0 animated:NO];
}
- (void)againAddImageView {
    [self refreshImageSize];
    [self.scrollView addSubview:self.imageView];
    if (self.model.subType == YM_PhotoModelMediaSubType_Video) {
        self.videoPlayBtn.hidden = NO;
        [self.contentView.layer addSublayer:self.playerLayer];
        [self.contentView addSubview:self.videoPlayBtn];
        self.videoPlayBtn.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.videoPlayBtn.alpha = 1;
        }];
    }
}
- (void)refreshImageSize {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = self.model.imageSize.width;
    CGFloat imgHeight = self.model.imageSize.height;
    CGFloat w;
    CGFloat h;
    
    imgHeight = width / imgWidth * imgHeight;
    if (imgHeight > height) {
        w = height / self.model.imageSize.height * imgWidth;
        h = height;
        self.scrollView.maximumZoomScale = width / w + 0.5;
    }else {
        w = width;
        h = imgHeight;
        self.scrollView.maximumZoomScale = 2.5;
    }
    self.imageView.frame = CGRectMake(0, 0, w, h);
    self.imageView.center = CGPointMake(width / 2, height / 2);
    self.playerLayer.frame = self.imageView.frame;
    self.videoPlayBtn.frame = self.playerLayer.frame;
}
- (void)setModel:(YM_PhotoModel *)model {
    _model = model;
    [self cancelRequest];
    self.playerLayer.player = nil;
    self.player = nil;
    self.progressView.hidden = YES;
    [self.loadingView stopAnimating];
    self.progressView.progress = 0;
    
    [self resetScale];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = self.model.imageSize.width;
    CGFloat imgHeight = self.model.imageSize.height;
    CGFloat w;
    CGFloat h;
    
    imgHeight = width / imgWidth * imgHeight;
    if (imgHeight > height) {
        w = height / self.model.imageSize.height * imgWidth;
        h = height;
        self.scrollView.maximumZoomScale = width / w + 0.5;
    }else {
        w = width;
        h = imgHeight;
        self.scrollView.maximumZoomScale = 2.5;
    }
    self.imageView.frame = CGRectMake(0, 0, w, h);
    self.imageView.center = CGPointMake(width / 2, height / 2);
    self.playerLayer.frame = self.imageView.frame;
    self.videoPlayBtn.frame = self.playerLayer.frame;
    
    self.imageView.hidden = NO;
    kWeakSelf
    if (model.type == YM_PhotoModelMediaType_CameraPhoto || model.type == YM_PhotoModelMediaType_CameraVideo) {
        if (model.networkPhotoUrl) {
            self.progressView.hidden = model.downloadComplete;
            CGFloat progress = (CGFloat)model.receivedSize / model.expectedSize;
            self.progressView.progress = progress;
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
                            [self refreshImageSize];
                        }
                    }
                }
            }];
        }else {
            self.imageView.image = model.thumbPhoto;
            model.tempImage = nil;
        }
    }else {
        if (model.type == YM_PhotoModelMediaType_LivePhoto) {
            if (model.tempImage) {
                self.imageView.image = model.tempImage;
                model.tempImage = nil;
            }else {
                self.requestID = [YM_PhotoTools getPhotoForPHAsset:model.asset size:CGSizeMake(self.hx_w * 0.5, self.hx_h * 0.5) completion:^(UIImage *image, NSDictionary *info) {
                    self.imageView.image = image;
                }];
            }
        }else {
            if (model.previewPhoto) {
                self.imageView.image = model.previewPhoto;
                model.tempImage = nil;
            }else {
                if (model.tempImage) {
                    self.imageView.image = model.tempImage;
                    model.tempImage = nil;
                }else {
                    PHImageRequestID requestID;
                    if (imgHeight > imgWidth / 9 * 17) {
                        requestID = [YM_PhotoTools getPhotoForPHAsset:model.asset size:CGSizeMake(self.hx_w * 0.6, self.hx_h * 0.6) completion:^(UIImage *image, NSDictionary *info) {
                            self.imageView.image = image;
                        }];
                    }else {
                        requestID = [YM_PhotoTools getPhotoForPHAsset:model.asset size:CGSizeMake(model.endImageSize.width * 0.8, model.endImageSize.height * 0.8) completion:^(UIImage *image, NSDictionary *info) {
                            self.imageView.image = image;
                        }];
                    }
                    self.requestID = requestID;
                }
            }
        }
    }
    if (model.subType == YM_PhotoModelMediaSubType_Video) {
        self.playerLayer.hidden = NO;
        //        self.videoPlayBtn.hidden = NO;
        self.videoPlayBtn.hidden = YES;
    }else {
        self.playerLayer.hidden = YES;
        self.videoPlayBtn.hidden = YES;
    }
}
- (void)requestHDImage {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = self.model.imageSize.width;
    CGFloat imgHeight = self.model.imageSize.height;
    CGSize size;
    kWeakSelf
    if (imgHeight > imgWidth / 9 * 17) {
        size = CGSizeMake(width * 1.5, height * 1.5);
    }else {
        size = CGSizeMake(self.model.endImageSize.width * 2.5, self.model.endImageSize.height * 2.5);
    }
    if (self.model.type == YM_PhotoModelMediaType_LivePhoto) {
        if (_livePhotoView.livePhoto) {
            [self.livePhotoView stopPlayback];
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
            return;
        }
        if (self.model.iCloudRequestID) {
            [[PHImageManager defaultManager] cancelImageRequest:self.model.iCloudRequestID];
            self.model.iCloudRequestID = -1;
        }
        self.requestID = [YM_PhotoTools getLivePhotoForAsset:self.model.asset size:self.model.endImageSize startRequestICloud:^(PHImageRequestID iCloudRequestId) {
            kStrongSelf
            if (self.model.isICloud) {
                self.progressView.hidden = NO;
            }
            self.requestID = iCloudRequestId;
        } progressHandler:^(double progress) {
            kStrongSelf
            if (self.model.isICloud) {
                self.progressView.hidden = NO;
            }
            self.progressView.progress = progress;
        } completion:^(PHLivePhoto *livePhoto) {
            kStrongSelf
            [self downloadICloudAssetComplete];
            self.livePhotoView.frame = self.imageView.frame;
            [self.scrollView addSubview:self.livePhotoView];
            self.imageView.hidden = YES;
            self.livePhotoView.livePhoto = livePhoto;
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        } failed:^{
            kStrongSelf
            self.progressView.hidden = YES;
            if (self.model.isICloud) {
                //                [self.progressView showError];
            }
        }];
    }else if (self.model.type == YM_PhotoModelMediaType_Photo) {
        self.requestID = [YM_PhotoTools getHighQualityFormatPhoto:self.model.asset size:size startRequestIcloud:^(PHImageRequestID cloudRequestId) {
            kStrongSelf
            if (self.model.isICloud) {
                self.progressView.hidden = NO;
            }
            self.requestID = cloudRequestId;
        } progressHandler:^(double progress) {
            kStrongSelf
            if (self.model.isICloud) {
                self.progressView.hidden = NO;
            }
            self.progressView.progress = progress;
        } completion:^(UIImage *image) {
            kStrongSelf
            dispatch_async(dispatch_get_main_queue(), ^{
                [self downloadICloudAssetComplete];
                self.progressView.hidden = YES;
                self.imageView.image = image;
            });
        } failed:^(NSDictionary *info) {
            kStrongSelf
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                if (self.model.isICloud) {
                    //                    [self.progressView showError];
                }
            });
        }];
    }else if (self.model.type == YM_PhotoModelMediaType_PhotoGif) {
        if (self.gifImage) {
            self.imageView.image = self.gifImage;
        }else {
            if (self.model.asset) {
                self.requestID = [YM_PhotoTools getImageData:self.model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        kStrongSelf
                        if (self.model.isICloud) {
                            self.progressView.hidden = NO;
                        }
                        self.requestID = cloudRequestId;
                    });
                } progressHandler:^(double progress) {
                    kStrongSelf
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.model.isICloud) {
                            self.progressView.hidden = NO;
                        }
                        self.progressView.progress = progress;
                    });
                } completion:^(NSData *imageData, UIImageOrientation orientation) {
                    kStrongSelf
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                        self.model.gifImageData = imageData;
                        [self downloadICloudAssetComplete];
                        self.progressView.hidden = YES;
                        UIImage *gifImage = [UIImage animatedGIFWithData:imageData];
                        if (gifImage.images.count == 0) {
                            self.gifFirstFrame = gifImage;
                        }else {
                            self.gifFirstFrame = gifImage.images.firstObject;
                        }
                        self.model.tempImage = nil;
                        self.imageView.image = gifImage;
                        self.gifImage = gifImage;
                    });
                } failed:^(NSDictionary *info) {
                    kStrongSelf
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.progressView.hidden = YES;
                        if (self.model.isICloud) {
                            //                        [self.progressView showError];
                        }
                    });
                }];
            }else {
                self.progressView.hidden = YES;
                UIImage *gifImage = [UIImage animatedGIFWithData:self.model.gifImageData];
                if (gifImage.images.count == 0) {
                    self.gifFirstFrame = gifImage;
                }else {
                    self.gifFirstFrame = gifImage.images.firstObject;
                }
                self.model.tempImage = nil;
                self.imageView.image = gifImage;
                self.gifImage = gifImage;
            }
        }
    }
    if (self.player != nil) return;
    if (self.model.type == YM_PhotoModelMediaType_Video) {
        if (self.model.avAsset) {
            self.progressView.hidden = YES;
            [self.loadingView stopAnimating];
            self.videoPlayBtn.hidden = NO;
            self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.model.avAsset]];
            self.playerLayer.player = self.player;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        }else {
            if (self.model.asset) {
                self.requestID = [YM_PhotoTools getAVAssetWithPHAsset:self.model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                    //            if (self.model.isICloud) {
                    //                self.progressView.hidden = NO;
                    //            }
                    [self.loadingView startAnimating];
                    self.videoPlayBtn.hidden = YES;
                    self.requestID = cloudRequestId;
                } progressHandler:^(double progress) {
                    //            if (self.model.isICloud) {
                    //                self.progressView.hidden = NO;
                    //            }
                    self.progressView.progress = progress;
                } completion:^(AVAsset *asset) {
                    [self downloadICloudAssetComplete];
                    self.model.avAsset = asset;
                    self.progressView.hidden = YES;
                    [self.loadingView stopAnimating];
                    self.videoPlayBtn.hidden = NO;
                    self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
                    self.playerLayer.player = self.player;
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
                } failed:^(NSDictionary *info) {
                    [self.loadingView stopAnimating];
                    self.videoPlayBtn.hidden = NO;
                    self.progressView.hidden = YES;
                    if (self.model.isICloud) {
                        //                [self.progressView showError];
                    }
                }];
            }else {
                self.progressView.hidden = YES;
                [self.loadingView stopAnimating];
                self.videoPlayBtn.hidden = NO;
                self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:self.model.fileURL]]];
                self.playerLayer.player = self.player;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
            }
        }
    }else if (self.model.type == YM_PhotoModelMediaType_CameraVideo ) {
        self.videoPlayBtn.hidden = NO;
        self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:self.model.videoURL]];
        self.playerLayer.player = self.player;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }
}
- (void)downloadICloudAssetComplete {
    self.progressView.hidden = YES;
    [self.loadingView stopAnimating];
    if (self.model.isICloud) {
        self.model.iCloudDownloading = NO;
        self.model.isICloud = NO;
        if (self.cellDownloadICloudAssetComplete) {
            self.cellDownloadICloudAssetComplete(self);
        }
    }
}
- (void)pausePlayerAndShowNaviBar {
    //    [self.player pause];
    //    self.videoPlayBtn.selected = NO;
    [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}
- (void)cancelRequest {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
    //    self.model.avAsset = nil;
    self.videoPlayBtn.hidden = YES;
    self.progressView.hidden = YES;
    self.progressView.progress = 0;
    if (self.model.type == YM_PhotoModelMediaType_LivePhoto) {
        if (_livePhotoView.livePhoto) {
            self.livePhotoView.livePhoto = nil;
            [self.livePhotoView removeFromSuperview];
            self.imageView.hidden = NO;
            [self stopLivePhoto];
        }
    }else if (self.model.type == YM_PhotoModelMediaType_Photo) {
        
    }else if (self.model.type == YM_PhotoModelMediaType_PhotoGif) {
        if (!self.stopCancel) {
            self.imageView.image = nil;
            self.gifImage = nil;
            self.imageView.image = self.gifFirstFrame;
        }else {
            self.stopCancel = NO;
        }
    }
    if (self.model.subType == YM_PhotoModelMediaSubType_Video) {
        if (self.player != nil && !self.stopCancel) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
            [self.player pause];
            self.videoPlayBtn.selected = NO;
            [self.player seekToTime:kCMTimeZero];
            self.playerLayer.player = nil;
            self.player = nil;
        }
        self.stopCancel = NO;
    }
}
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.cellTapClick) {
        self.cellTapClick();
    }
}
- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        CGPoint touchPoint;
        if (self.model.type == YM_PhotoModelMediaType_LivePhoto) {
            touchPoint = [tap locationInView:self.livePhotoView];
        }else {
            touchPoint = [tap locationInView:self.imageView];
        }
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = width / newZoomScale;
        CGFloat ysize = height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}
#pragma mark - < PHLivePhotoViewDelegate >
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    self.livePhotoAnimating = YES;
}
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    [self stopLivePhoto];
}
- (void)stopLivePhoto {
    self.livePhotoAnimating = NO;
    [self.livePhotoView stopPlayback];
}
#pragma mark - < UIScrollViewDelegate >
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.model.subType == YM_PhotoModelMediaSubType_Video) {
        return nil;
    }
    if (self.model.type == YM_PhotoModelMediaType_Photo) {
        return self.livePhotoView;
    }else {
        return self.imageView;
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    if (self.model.type == YM_PhotoModelMediaType_LivePhoto) {
        self.livePhotoView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    }else {
        self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    }
}
- (void)didPlayBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self.player play];
    }else {
        [self.player pause];
    }
    if (self.cellDidPlayVideoBtn) {
        self.cellDidPlayVideoBtn(button.selected);
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    //    self.playerLayer.frame = self.bounds;
    //    self.videoPlayBtn.frame = self.bounds;
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.hx_w, self.hx_h);
    self.progressView.center = CGPointMake(self.hx_w / 2, self.hx_h / 2);
    self.loadingView.center = self.progressView.center;
}
#pragma mark - < 懒加载 >
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bouncesZoom = YES;
        _scrollView.minimumZoomScale = 1;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [_scrollView addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [_scrollView addGestureRecognizer:tap2];
    }
    return _scrollView;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}
- (PHLivePhotoView *)livePhotoView {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] init];
        _livePhotoView.clipsToBounds = YES;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
        _livePhotoView.delegate = self;
    }
    return _livePhotoView;
}
- (UIButton *)videoPlayBtn {
    if (!_videoPlayBtn) {
        _videoPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoPlayBtn setImage:[YM_PhotoTools ym_imageNamed:@"multimedia_videocard_play@2x.png"] forState:UIControlStateNormal];
        [_videoPlayBtn setImage:[[UIImage alloc] init] forState:UIControlStateSelected];
        [_videoPlayBtn addTarget:self action:@selector(didPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _videoPlayBtn.hidden = YES;
    }
    return _videoPlayBtn;
}
- (YM_CircleProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[YM_CircleProgressView alloc] init];
        _progressView.hidden = YES;
    }
    return _progressView;
}
- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_loadingView stopAnimating];
    }
    return _loadingView;
}
- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.hidden = YES;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}
- (void)dealloc {
    [self cancelRequest];
}

@end
