//
//  YM_DateVideoEditViewController.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DateVideoEditViewController.h"
#import <Photos/Photos.h>
#import "NSBundle+YM_PhotoPicker.h"
#import "YM_PhotoTools.h"
@interface YM_DateVideoEditViewController () <YM_DateVideoEditBottomViewDelegate>

@property (strong, nonatomic) YM_DateVideoEditBottomView *bottomView;
@property (assign, nonatomic) BOOL orientationDidChange;
@property (assign, nonatomic) PHImageRequestID requestId;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayer *player;

@end

@implementation YM_DateVideoEditViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    [self stopTimer];
    [[PHImageManager defaultManager] cancelImageRequest:self.requestId];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.orientationDidChange) {
        self.orientationDidChange = NO;
        [self changeSubviewFrame];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self changeSubviewFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}
- (void)deviceOrientationChanged:(NSNotification *)notify {
    self.orientationDidChange = YES;
}
- (void)deviceOrientationWillChanged:(NSNotification *)notify {
    //    [self stopTimer];
}
- (void)changeSubviewFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat itemH;
    if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
        itemH = 40;
    }else {
        itemH = 50;
    }
    CGFloat bottomMargin = kBottomMargin;
    CGFloat width = self.view.hx_w;
    CGFloat bottomX = 0;
    CGFloat videoX = 5;
    CGFloat videoY = kTopMargin;
    CGFloat videoH;
    CGFloat bottomH = itemH + 5 + 50;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        bottomX = kBottomMargin;
        videoY = 0;
        videoX = 30;
        bottomH = itemH;
    }
    videoH = self.view.hx_h - bottomH - videoY - bottomMargin;
    self.bottomView.frame = CGRectMake(bottomX, self.view.hx_h - bottomH - bottomMargin, self.view.hx_w - bottomX * 2, bottomH + bottomMargin);
    self.playerLayer.frame = CGRectMake(videoX, videoY, width - videoX * 2, videoH);
}
- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:31.f / 255.f green:31.f / 255.f blue:31.f / 255.f alpha:1.0f];
    [self.view.layer addSublayer:self.playerLayer];
    [self.view addSubview:self.bottomView];
    
    [self getVideo];
}
- (void)getVideo {
    [self.view showLoadingHUDText:[NSBundle ym_localizedStringForKey:@"加载中"]];
    kWeakSelf
    self.requestId = [YM_PhotoTools getAVAssetWithModel:self.model startRequestIcloud:^(PHImageRequestID cloudRequestId, YM_PhotoModel *model) {
        kStrongSelf
        self.requestId = cloudRequestId;
    } progressHandler:^(YM_PhotoModel *model, double progress) {
        
    } completion:^(YM_PhotoModel *model, AVAsset *asset) {
        kStrongSelf
        [self getVideoEachFrame:asset];
    } failed:^(YM_PhotoModel *model, NSDictionary *info) {
        kStrongSelf
        [self.view handleLoading];
    }];
}
- (void)getVideoEachFrame:(AVAsset *)asset {
    kWeakSelf
    CGFloat itemHeight = 0;
    CGFloat itemWidth = 0;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
        itemHeight = 40;
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        itemHeight = 50;
    }
    itemWidth = itemHeight / 16 * 9;
    NSInteger total = (self.view.hx_w - 10) / itemWidth;
    [YM_PhotoTools getVideoEachFrameWithAsset:asset total:total size:CGSizeMake(itemWidth * 5, itemHeight * 5) complete:^(AVAsset *asset, NSArray<UIImage *> *images) {
        kStrongSelf
        [self.view handleLoading];
        self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
        self.playerLayer.player = self.player;
        [self.player play];
        self.bottomView.dataArray = [NSMutableArray arrayWithArray:images];
    }];
}
#pragma mark - < YM_DateVideoEditBottomViewDelegate >
- (void)videoEditBottomViewDidCancelClick:(YM_DateVideoEditBottomView *)bottomView {
    
    if (self.outside) {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)videoEditBottomViewDidDoneClick:(YM_DateVideoEditBottomView *)bottomView {
    
    if (self.outside) {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

#pragma mark - < 懒加载 >
- (YM_DateVideoEditBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[YM_DateVideoEditBottomView alloc] initWithManager:self.manager];
        _bottomView.delegate = self;
    }
    return _bottomView;
}
- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.backgroundColor = [UIColor colorWithRed:31.f / 255.f green:31.f / 255.f blue:31.f / 255.f alpha:1.0f].CGColor;
    }
    return _playerLayer;
}

@end
