//
//  YM_Photo3DTouchViewController.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_Photo3DTouchViewController.h"
#import <PhotosUI/PhotosUI.h>
#import "UIImage+YM_Extension.h"
#import "YM_CircleProgressView.h"

@interface YM_Photo3DTouchViewController ()

@property (strong, nonatomic) PHLivePhotoView *livePhotoView;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) YM_CircleProgressView *progressView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;
@property (assign, nonatomic) PHImageRequestID requestId;

@end

@implementation YM_Photo3DTouchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.hx_size = self.model.previewViewSize;
    self.imageView.image = self.image;
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.loadingView];
    self.progressView.center = CGPointMake(self.imageView.hx_size.width / 2, self.imageView.hx_size.height / 2);
    self.loadingView.center = self.progressView.center;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    switch (self.model.type) {
        case YM_PhotoModelMediaType_Video:
            [self loadVideo];
            break;
        case YM_PhotoModelMediaType_CameraVideo:
            [self loadVideo];
            break;
        case YM_PhotoModelMediaType_PhotoGif:
            [self loadGifPhoto];
            break;
        case YM_PhotoModelMediaType_LivePhoto:
            [self loadLivePhoto];
            break;
        default:
            [self loadPhoto];
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[PHImageManager defaultManager] cancelImageRequest:self.requestId];
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    self.playerLayer.player = nil;
    self.player = nil;
    [self.playerLayer removeFromSuperlayer];
    if (_livePhotoView) {
        [self.livePhotoView stopPlayback];
        [self.livePhotoView removeFromSuperview];
        self.livePhotoView.livePhoto = nil;
        self.livePhotoView = nil;
    }
    [self.progressView removeFromSuperview];
    [self.loadingView stopAnimating];
    [self.view addSubview:self.imageView];
    if (self.player) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }
}

- (void)loadPhoto {
    if (self.model.type == YM_PhotoModelMediaType_CameraPhoto) {
        self.imageView.image = self.model.thumbPhoto;
        return;
    }
    kWeakSelf
    if (self.model.asset) {
        self.requestId = [YM_PhotoTools getHighQualityFormatPhoto:self.model.asset size:CGSizeMake(self.model.previewViewSize.width * 1.5, self.model.previewViewSize.height * 1.5) startRequestIcloud:^(PHImageRequestID cloudRequestId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                kStrongSelf
                self.requestId = cloudRequestId;
                if (self.model.isICloud) {
                    self.progressView.hidden = NO;
                }
            });
        } progressHandler:^(double progress) {
            kStrongSelf
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.model.isICloud) {
                    self.progressView.hidden = NO;
                }
                self.progressView.progress = progress;
            });
        } completion:^(UIImage *image) {
            kStrongSelf
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                self.imageView.image = image;
            });
        } failed:^(NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //            [self.progressView showError];
            });
        }];
    }else {
        self.imageView.image = self.model.thumbPhoto;
    }
    //    requestId = [YM_PhotoTools fetchPhotoWithAsset:self.model.asset photoSize:CGSizeMake(self.model.previewViewSize.width * 1.5, self.model.previewViewSize.height * 1.5) completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
    //        self.imageView.image = photo;
    //    }];
}

- (void)loadGifPhoto {
    if (self.model.asset) {
        kWeakSelf
        self.requestId = [YM_PhotoTools getImageData:self.model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
            kStrongSelf
            dispatch_async(dispatch_get_main_queue(), ^{
                self.requestId = cloudRequestId;
                if (self.model.isICloud) {
                    self.progressView.hidden = NO;
                }
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
            dispatch_async(dispatch_get_main_queue(), ^{
                kStrongSelf
                self.progressView.hidden = YES;
                UIImage *gifImage = [UIImage animatedGIFWithData:imageData];
                if (gifImage.images.count > 0) {
                    self.imageView.image = nil;
                    self.imageView.image = gifImage;
                }
            });
        } failed:^(NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //            [self.progressView showError];
            });
        }];
    }else {
        UIImage *gifImage = [UIImage animatedGIFWithData:self.model.gifImageData];
        self.imageView.image = gifImage;
    }
    //    requestId = [YM_PhotoTools FetchPhotoDataForPHAsset:self.model.asset completion:^(NSData *imageData, NSDictionary *info) {
    //        if (imageData) {
    //            UIImage *gifImage = [UIImage animatedGIFWithData:imageData];
    //            if (gifImage.images.count > 0) {
    //                self.imageView.image = nil;
    //                self.imageView.image = gifImage;
    //            }
    //        }
    //    }];
}

- (void)loadLivePhoto {
    self.livePhotoView = [[PHLivePhotoView alloc] initWithFrame:CGRectMake(0, 0, self.model.previewViewSize.width, self.model.previewViewSize.height)];
    self.livePhotoView.clipsToBounds = YES;
    self.livePhotoView.hidden = YES;
    self.livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.livePhotoView];
    kWeakSelf
    self.requestId = [YM_PhotoTools getLivePhotoForAsset:self.model.asset size:CGSizeMake(self.model.previewViewSize.width * 1.5, self.model.previewViewSize.height * 1.5) startRequestICloud:^(PHImageRequestID iCloudRequestId) {
        kStrongSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            self.requestId = iCloudRequestId;
            if (self.model.isICloud) {
                self.progressView.hidden = NO;
            }
        });
    } progressHandler:^(double progress) {
        kStrongSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.model.isICloud) {
                self.progressView.hidden = NO;
            }
            self.progressView.progress = progress;
        });
    } completion:^(PHLivePhoto *livePhoto) {
        kStrongSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.hidden = YES;
            self.livePhotoView.hidden = NO;
            self.livePhotoView.livePhoto = livePhoto;
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
            [self.imageView removeFromSuperview];
        });
    } failed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [self.progressView showError];
        });
    }];
    //    requestId = [YM_PhotoTools FetchLivePhotoForPHAsset:self.model.asset Size:CGSizeMake(self.model.previewViewSize.width * 1.5, self.model.previewViewSize.height * 1.5) Completion:^(PHLivePhoto *livePhoto, NSDictionary *info) {
    //        self.livePhotoView.livePhoto = livePhoto;
    //        [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
    //        [self.imageView removeFromSuperview];
    //    }];
}

- (void)loadVideo {
    if (self.model.type == YM_PhotoModelMediaType_CameraVideo) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.model.videoURL];
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        [self playVideo];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }else {
        if (self.model.asset) {
            kWeakSelf
            self.requestId = [YM_PhotoTools getAVAssetWithPHAsset:self.model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                kStrongSelf
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.requestId = cloudRequestId;
                    //                if (self.model.isICloud) {
                    //                    self.progressView.hidden = NO;
                    //                }
                    [self.loadingView startAnimating];
                });
            } progressHandler:^(double progress) {
                kStrongSelf
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.model.isICloud) {
                        self.progressView.hidden = NO;
                    }
                    self.progressView.progress = progress;
                });
            } completion:^(AVAsset *asset) {
                kStrongSelf
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progressView.hidden = YES;
                    self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
                    [self playVideo];
                    [self.loadingView stopAnimating];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
                });
            } failed:^(NSDictionary *info) {
                kStrongSelf
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                [self.progressView showError];
                    [self.loadingView stopAnimating];
                });
            }];
        }else {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.model.fileURL];
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            [self playVideo];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        }
        //        requestId = [[PHImageManager defaultManager] requestAVAssetForVideo:self.model.asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        //            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        //            if (downloadFinined && asset) {
        //                __strong typeof(weakSelf) self = self;
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
        //                    [self playVideo];
        //                });
        //            }
        //        }];
        //        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        //        options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
        //        options.networkAccessAllowed = NO;
        //
        //        requestId = [[PHImageManager defaultManager] requestPlayerItemForVideo:self.model.asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        //            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        //            if (downloadFinined && playerItem) {
        //                __strong typeof(weakSelf) self = self;
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    self.player = [AVPlayer playerWithPlayerItem:playerItem];
        //                    [self playVideo];
        //                });
        //            }
        //        }];
    }
}
- (void)pausePlayerAndShowNaviBar {
    [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}
- (void)playVideo {
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, self.model.previewViewSize.width, self.model.previewViewSize.height);
    [self.view.layer insertSublayer:self.playerLayer atIndex:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
        [self.imageView removeFromSuperview];
    });
}

- (void)dealloc {
    if (showLog) NSSLog(@"%@",self);
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.hx_x = 0;
        _imageView.hx_y = 0;
    }
    return _imageView;
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
    }
    return _loadingView;
}
//- (PHLivePhotoView *)livePhotoView {
//    if (!_livePhotoView) {
//        _livePhotoView = [[PHLivePhotoView alloc] init];
//        _livePhotoView.clipsToBounds = YES;
//        _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
//    }
//    return _livePhotoView;
//}

@end
