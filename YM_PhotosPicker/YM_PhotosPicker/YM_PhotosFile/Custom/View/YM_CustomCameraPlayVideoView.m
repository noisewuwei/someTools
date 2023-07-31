//
//  YM_CustomCameraPlayVideoView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_CustomCameraPlayVideoView.h"

@interface YM_CustomCameraPlayVideoView ()

@end

@implementation YM_CustomCameraPlayVideoView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    self.playerLayer = [[AVPlayerLayer alloc] init];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:self.playerLayer];
}
- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    [player play];
    self.playerLayer.player = player;
}
- (void)stopPlay {
    [self.playerLayer.player pause];
}

@end
