//
//  YM_CustomCameraViewController.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_CustomCameraViewController.h"
#import "YM_CustomCameraController.h"
#import "YM_CustomPreviewView.h"
#import "YM_CustomCameraBottomView.h"
#import "YM_CustomCameraPlayVideoView.h"
#import "YM_PhotoTools.h"
#import "UIImage+YM_Extension.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YM_CustomCameraViewController ()
<YM_CustomPreviewViewDelegate,
 YM_CustomCameraBottomViewDelegate,
 YM_CustomCameraControllerDelegate,
 CLLocationManagerDelegate>

@property (strong, nonatomic) YM_CustomCameraController *cameraController;
@property (strong, nonatomic) YM_CustomPreviewView *previewView;
@property (strong, nonatomic) CAGradientLayer *topMaskLayer;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *changeCameraBtn;
@property (strong, nonatomic) UIButton *flashBtn;
@property (strong, nonatomic) YM_CustomCameraBottomView *bottomView;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger time;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) YM_CustomCameraPlayVideoView *playVideoView;
@property (strong, nonatomic) UIButton *doneBtn;
@property (assign, nonatomic) BOOL addAudioInputComplete;
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation YM_CustomCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self.locationManager startUpdatingLocation];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn];
    if (self.manager.configuration.videoMaximumDuration > self.manager.configuration.videoMaxDuration) {
        self.manager.configuration.videoMaximumDuration = self.manager.configuration.videoMaxDuration;
    }else if (self.manager.configuration.videoMaximumDuration < 3.f) {
        self.manager.configuration.videoMaximumDuration = 4.f;
    }
    
    [self.view addSubview:self.previewView];
    self.cameraController = [[YM_CustomCameraController alloc] init];
    self.cameraController.delegate = self;
    if ([self.cameraController setupSession:nil]) {
        [self.previewView setSession:self.cameraController.captureSession];
        self.previewView.delegate = self;
        if (self.manager.type == YM_PhotoManagerType_Photo) {
            [self.cameraController initImageOutput];
        }else if (self.manager.type == YM_PhotoManagerType_Video) {
            [self.view insertSubview:self.playVideoView belowSubview:self.bottomView];
            [self.cameraController addAudioInput];
            self.addAudioInputComplete = YES;
            [self.cameraController initMovieOutput];
        }else {
            if (!self.manager.configuration.selectTogether && self.isOutside) {
                if (self.manager.afterSelectedPhotoArray.count > 0) {
                    [self.cameraController initImageOutput];
                }else if (self.manager.afterSelectedVideoArray.count > 0) {
                    [self.view insertSubview:self.playVideoView belowSubview:self.bottomView];
                    [self.cameraController addAudioInput];
                    self.addAudioInputComplete = YES;
                    [self.cameraController initMovieOutput];
                }else {
                    [self.view insertSubview:self.playVideoView belowSubview:self.bottomView];
                    [self.cameraController initImageOutput];
                    [self.previewView addSwipeGesture];
                }
            }else {
                [self.view insertSubview:self.playVideoView belowSubview:self.bottomView];
                [self.cameraController initImageOutput];
                [self.previewView addSwipeGesture];
            }
        }
        [self.cameraController startSession];
    }
    self.previewView.tapToFocusEnabled = self.cameraController.cameraSupportsTapToFocus;
    self.previewView.tapToExposeEnabled = self.cameraController.cameraSupportsTapToExpose;
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.topView];
    
    UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc] initWithCustomView:self.changeCameraBtn];
    UIBarButtonItem *rightBtn2 = [[UIBarButtonItem alloc] initWithCustomView:self.flashBtn];
    if ([self.cameraController canSwitchCameras] && [self.cameraController cameraHasFlash]) {
        self.navigationItem.rightBarButtonItems = @[rightBtn1,rightBtn2];
    }else {
        if ([self.cameraController cameraHasTorch] || [self.cameraController cameraHasFlash]) {
            self.navigationItem.rightBarButtonItems = @[rightBtn2];
        }
    }
    [self changeSubviewFrame];
    self.previewView.maxScale = [self.cameraController maxZoomFactor];
    if ([self.cameraController cameraSupportsZoom]) {
        self.previewView.effectiveScale = 1.0f;
        self.previewView.beginGestureScale = 1.0f;
        [self.cameraController rampZoomToValue:1.0f];
        [self.cameraController cancelZoom];
    }
    [self setupFlashAndTorchBtn];
    self.previewView.tapToExposeEnabled = self.cameraController.cameraSupportsTapToExpose;
    self.previewView.tapToFocusEnabled = self.cameraController.cameraSupportsTapToFocus;
    
    if (self.manager.configuration.navigationBar) {
        self.manager.configuration.navigationBar(self.navigationController.navigationBar);
    }
}
- (void)requestAccessForAudio {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if (!self.addAudioInputComplete) {
                    [self.cameraController addAudioInput];
                    self.addAudioInputComplete = YES;
                }
            }else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle ym_localizedStringForKey:@"无法使用麦克风"] message:[NSBundle ym_localizedStringForKey:@"请在设置-隐私-相机中允许访问麦克风"] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"取消"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"麦克风添加失败,录制视频会没有声音哦!"]];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"设置"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}
- (void)setupFlashAndTorchBtn {
    self.previewView.pinchToZoomEnabled = [self.cameraController cameraSupportsZoom];
    BOOL hidden = NO;
    if (self.bottomView.mode == YM_CustomCameraBottomViewModePhoto) {
        hidden = !self.cameraController.cameraHasFlash;
    }else {
        hidden = !self.cameraController.cameraHasTorch;
    }
    self.flashBtn.hidden = hidden;
    
    if (self.bottomView.mode == YM_CustomCameraBottomViewModePhoto) {
        if (self.cameraController.flashMode == AVCaptureFlashModeOff) {
            self.flashBtn.selected = NO;
        }else {
            self.flashBtn.selected = YES;
        }
    }else {
        if (self.cameraController.torchMode == AVCaptureTorchModeOff) {
            self.flashBtn.selected = NO;
        }else {
            self.flashBtn.selected = YES;
        }
    }
}
- (void)changeSubviewFrame {
    self.topView.frame = CGRectMake(0, 0, self.view.hx_w, kNavigationBarHeight);
    self.topMaskLayer.frame = self.topView.bounds;
    self.bottomView.frame = CGRectMake(0, self.view.hx_h - 120, self.view.hx_w, 120);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    AVCaptureConnection *previewLayerConnection = [(AVCaptureVideoPreviewLayer *)self.previewView.layer connection];
    if ([previewLayerConnection isVideoOrientationSupported])
        [previewLayerConnection setVideoOrientation:(AVCaptureVideoOrientation)[[UIApplication sharedApplication] statusBarOrientation]];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.cameraController stopMontionUpdate];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cameraController startMontionUpdate];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopTimer];
    [self.cameraController stopSession];
}
- (void)dealloc {
    [self.locationManager stopUpdatingLocation];
    if (showLog) NSSLog(@"dealloc");
}
- (void)cancelClick:(UIButton *)button {
    if (button.selected) {
        [self.cameraController startSession];
        [self.imageView removeFromSuperview];
        [self.doneBtn removeFromSuperview];
        [self.playVideoView stopPlay];
        self.playVideoView.hidden = YES;
        self.playVideoView.playerLayer.hidden = YES;
        self.flashBtn.hidden = NO;
        self.changeCameraBtn.hidden = NO;
        self.cancelBtn.selected = NO;
        self.bottomView.hidden = NO;
        self.previewView.tapToFocusEnabled = YES;
        self.previewView.pinchToZoomEnabled = [self.cameraController cameraSupportsZoom];
    }else {
        [self stopTimer];
        [self.cameraController stopMontionUpdate];
        [self.cameraController stopSession];
        if ([self.delegate respondsToSelector:@selector(customCameraViewControllerDidCancel:)]) {
            [self.delegate customCameraViewControllerDidCancel:self];
        }
        if (self.cancelBlock) {
            self.cancelBlock(self);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)didDoneBtnClick {
    YM_PhotoModel *model = [[YM_PhotoModel alloc] init];
    model.location = self.location;
    if (!self.videoURL) {
        model.type = YM_PhotoModelMediaType_CameraPhoto;
        model.subType = YM_PhotoModelMediaSubType_Photo;
        if (self.imageView.image.imageOrientation != UIImageOrientationUp) {
            self.imageView.image = [self.imageView.image normalizedImage];
        }
        model.thumbPhoto = self.imageView.image;
        model.imageSize = self.imageView.image.size;
        model.previewPhoto = self.imageView.image;
        //        model.cameraIdentifier = [self videoOutFutFileName];
    }else {
        if (self.time < 3) {
            [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"录制时间少于3秒"]];
            return;
        }
        [self.playVideoView stopPlay];
        model.type = YM_PhotoModelMediaType_CameraVideo;
        model.subType = YM_PhotoModelMediaSubType_Video;
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:self.videoURL] ;
        player.shouldAutoplay = NO;
        UIImage  *image = [player thumbnailImageAtTime:0.1 timeOption:MPMovieTimeOptionNearestKeyFrame];
        NSString *videoTime = [YM_PhotoTools getNewTimeFromDurationSecond:self.time];
        model.videoDuration = self.time;
        model.videoURL = self.videoURL;
        model.videoTime = videoTime;
        model.thumbPhoto = image;
        model.imageSize = image.size;
        model.previewPhoto = image;
        //        model.cameraIdentifier = [self videoOutFutFileName];
    }
    [self stopTimer];
    [self.cameraController stopMontionUpdate];
    [self.cameraController stopSession];
    if (self.manager.configuration.saveSystemAblum) {
        if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
            [YM_PhotoTools savePhotoToCustomAlbumWithName:self.manager.configuration.customAlbumName photo:model.thumbPhoto];
        }else {
            [YM_PhotoTools saveVideoToCustomAlbumWithName:self.manager.configuration.customAlbumName videoURL:model.videoURL];
        }
    }
    if ([self.delegate respondsToSelector:@selector(customCameraViewController:didDone:)]) {
        [self.delegate customCameraViewController:self didDone:model];
    }
    if (self.doneBlock) {
        self.doneBlock(model, self);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didchangeCameraClick {
    if ([self.cameraController switchCameras]) {
        self.previewView.maxScale = [self.cameraController maxZoomFactor];
        if ([self.cameraController cameraSupportsZoom]) {
            self.previewView.effectiveScale = 1.0f;
            self.previewView.beginGestureScale = 1.0f;
            [self.cameraController rampZoomToValue:1.0f];
            [self.cameraController cancelZoom];
        }
        [self setupFlashAndTorchBtn];
        self.previewView.tapToExposeEnabled = self.cameraController.cameraSupportsTapToExpose;
        self.previewView.tapToFocusEnabled = self.cameraController.cameraSupportsTapToFocus;
        [self.cameraController resetFocusAndExposureModes];
    }
}
- (void)didFlashClick:(UIButton *)button {
    if (self.bottomView.mode == YM_CustomCameraBottomViewModePhoto) {
        if (button.selected) {
            self.cameraController.flashMode = 0;
        }else {
            self.cameraController.flashMode = 1;
        }
    }else {
        if (button.selected) {
            self.cameraController.torchMode = 0;
        }else {
            self.cameraController.torchMode = 1;
        }
    }
    button.selected = !button.selected;
}
- (void)takePicturesComplete:(UIImage *)image {
    self.imageView.image = image;
    [self.view insertSubview:self.imageView belowSubview:self.bottomView];
    [self.view addSubview:self.doneBtn];
    [self.cameraController stopSession];
    self.cancelBtn.hidden = NO;
}
- (void)takePicturesFailed {
    self.cancelBtn.hidden = NO;
    self.flashBtn.hidden = NO;
    self.changeCameraBtn.hidden = NO;
    self.cancelBtn.selected = NO;
    self.bottomView.hidden = NO;
    self.previewView.tapToFocusEnabled = YES;
    self.previewView.pinchToZoomEnabled = [self.cameraController cameraSupportsZoom];
    [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"拍摄失败"]];
}
- (void)startTimer {
    self.time = 0;
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(updateTimeDisplay)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimeDisplay {
    CMTime duration = self.cameraController.recordedDuration;
    NSUInteger time = (NSUInteger)CMTimeGetSeconds(duration);
    self.time = time;
    [self.bottomView changeTime:time];
    if (time == self.manager.configuration.videoMaximumDuration) {
        [self.cameraController stopRecording];
        [self stopTimer];
    }
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}
- (void)videoStartRecording {
    [self.bottomView startRecord];
}
- (void)videoNeedHideViews {
    self.cancelBtn.hidden = YES;
    self.cancelBtn.selected = YES;
    self.flashBtn.hidden = YES;
    self.changeCameraBtn.hidden = YES;
}
- (void)videoFinishRecording:(NSURL *)videoURL {
    [self.bottomView stopRecord];
    if (self.time < 3) {
        self.bottomView.hidden = NO;
        self.cancelBtn.selected = NO;
        self.flashBtn.hidden = NO;
        self.changeCameraBtn.hidden = NO;
        [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"3秒内的视频无效哦~"]];
    }else {
        [self.cameraController stopSession];
        self.previewView.tapToFocusEnabled = NO;
        self.previewView.pinchToZoomEnabled = NO;
        self.bottomView.hidden = YES;
        self.videoURL = [videoURL copy];
        self.playVideoView.hidden = NO;
        self.playVideoView.playerLayer.hidden = NO;
        self.playVideoView.videoURL = self.videoURL;
        [self.view addSubview:self.doneBtn];
    }
    self.cancelBtn.hidden = NO;
    //    NSSLog(@"%@",videoURL);
}
- (void)mediaCaptureFailedWithError:(NSError *)error {
    self.time = 0;
    [self stopTimer];
    [self.bottomView stopRecord];
    [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"录制视频失败!"]];
    self.bottomView.hidden = NO;
    self.cancelBtn.selected = NO;
    self.flashBtn.hidden = NO;
    self.changeCameraBtn.hidden = NO;
    self.cancelBtn.hidden = NO;
}
- (void)playViewClick {
    if (self.bottomView.mode == YM_CustomCameraBottomViewModePhoto) {
        [self.cameraController captureStillImage];
        self.previewView.tapToFocusEnabled = NO;
        self.previewView.pinchToZoomEnabled = NO;
        [self needHideViews];
    }else {
        if ([self.cameraController isRecording]) {
            [self.cameraController stopRecording];
            [self stopTimer];
            return;
        }else {
            if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] != AVAuthorizationStatusAuthorized) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle ym_localizedStringForKey:@"无法使用麦克风"] message:[NSBundle ym_localizedStringForKey:@"请在设置-隐私-相机中允许访问麦克风"] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"继续录制"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"麦克风添加失败,录制视频会没有声音哦!"]];
                    [self.bottomView beganAnimate];
                    [self videoNeedHideViews];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"设置"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }else {
                [self.bottomView beganAnimate];
                [self videoNeedHideViews];
            }
        }
    }
}
- (void)needHideViews {
    self.cancelBtn.selected = YES;
    self.flashBtn.hidden = YES;
    self.changeCameraBtn.hidden = YES;
    self.bottomView.hidden = YES;
    self.cancelBtn.hidden = YES;
}
- (void)playViewChangeMode:(YM_CustomCameraBottomViewMode)mode {
    if (mode == YM_CustomCameraBottomViewModePhoto) {
        [self.cameraController addImageOutput];
    }else {
        [self requestAccessForAudio];
        [self.cameraController addMovieOutput];
    }
    [self setupFlashAndTorchBtn];
}
- (void)playViewAnimateCompletion {
    if (!self.bottomView.animating) {
        dispatch_async(dispatch_queue_create("com.hxdatephotopicker.kamera", NULL), ^{
            [self.cameraController startRecording];
            [self startTimer];
        });
    }
}
- (void)didLeftSwipeClick {
    [self.bottomView leftAnimate];
}
- (void)didRightSwipeClick {
    [self.bottomView rightAnimate];
}
- (void)tappedToFocusAtPoint:(CGPoint)point {
    [self.cameraController focusAtPoint:point];
    [self.cameraController exposeAtPoint:point];
}
- (void)pinchGestureScale:(CGFloat)scale {
    [self.cameraController setZoomValue:scale];
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

- (YM_CustomPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[YM_CustomPreviewView alloc] initWithFrame:self.view.bounds];
        _previewView.delegate = self;
    }
    return _previewView;
}
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        [_topView.layer addSublayer:self.topMaskLayer];
    }
    return _topView;
}
- (CAGradientLayer *)topMaskLayer {
    if (!_topMaskLayer) {
        _topMaskLayer = [CAGradientLayer layer];
        _topMaskLayer.colors = @[
                                 (id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor,
                                 (id)[[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor
                                 ];
        _topMaskLayer.startPoint = CGPointMake(0, 1);
        _topMaskLayer.endPoint = CGPointMake(0, 0);
        _topMaskLayer.locations = @[@(0.15f),@(0.9f)];
        _topMaskLayer.borderWidth  = 0.0;
    }
    return _topMaskLayer;
}
- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:[NSBundle ym_localizedStringForKey:@"重拍"] forState:UIControlStateSelected];
        [_cancelBtn setTitle:@"" forState:UIControlStateNormal];
        [_cancelBtn setImage:[YM_PhotoTools ym_imageNamed:@"faceu_cancel@3x.png"] forState:UIControlStateNormal];
        [_cancelBtn setImage:[[UIImage alloc] init] forState:UIControlStateSelected];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _cancelBtn.hx_size = CGSizeMake(50, 50);
    }
    return _cancelBtn;
}
- (UIButton *)changeCameraBtn {
    if (!_changeCameraBtn) {
        _changeCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeCameraBtn setImage:[YM_PhotoTools ym_imageNamed:@"faceu_camera@3x.png"] forState:UIControlStateNormal];
        [_changeCameraBtn addTarget:self action:@selector(didchangeCameraClick) forControlEvents:UIControlEventTouchUpInside];
        _changeCameraBtn.hx_size = _changeCameraBtn.currentImage.size;
    }
    return _changeCameraBtn;
}
- (UIButton *)flashBtn {
    if (!_flashBtn) {
        _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashBtn setImage:[YM_PhotoTools ym_imageNamed:@"camera_flashlight@2x的副本11.png"] forState:UIControlStateNormal];
        [_flashBtn setImage:[YM_PhotoTools ym_imageNamed:@"flash_pic_nopreview@2x.png"] forState:UIControlStateSelected];
        _flashBtn.hx_size = _flashBtn.currentImage.size;
        [_flashBtn addTarget:self action:@selector(didFlashClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashBtn;
}
- (YM_CustomCameraBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[YM_CustomCameraBottomView alloc] initWithFrame:CGRectZero manager:self.manager isOutside:self.isOutside];
        _bottomView.delegate = self;
    }
    return _bottomView;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}
- (YM_CustomCameraPlayVideoView *)playVideoView {
    if (!_playVideoView) {
        _playVideoView = [[YM_CustomCameraPlayVideoView alloc] initWithFrame:self.view.bounds];
        _playVideoView.hidden = YES;
        _playVideoView.playerLayer.hidden = YES;
    }
    return _playVideoView;
}
- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setTitle:[NSBundle ym_localizedStringForKey:@"完成"] forState:UIControlStateNormal];
        [_doneBtn setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
        [_doneBtn.titleLabel setShadowOffset:CGSizeMake(1, 2)];
        _doneBtn.frame = CGRectMake(self.view.hx_w - 20 - 70, self.view.hx_h - 120 + 70, 70, 35);
        [_doneBtn addTarget:self action:@selector(didDoneBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        [_locationManager requestWhenInUseAuthorization];
    }
    return _locationManager;
}
#pragma mark - < CLLocationManagerDelegate >
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.location = locations.lastObject;
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorLocationUnknown) {
        if (showLog) NSSLog(@"定位失败，无法检索位置");
    }
    else if(error.code == kCLErrorNetwork) {
        if (showLog) NSSLog(@"定位失败，网络问题");
    }
    else if(error.code == kCLErrorDenied) {
        if (showLog) NSSLog(@"定位失败，定位权限的问题");
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
}
@end
