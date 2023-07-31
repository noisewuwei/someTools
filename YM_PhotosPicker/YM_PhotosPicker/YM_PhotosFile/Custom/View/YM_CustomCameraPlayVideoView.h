//
//  YM_CustomCameraPlayVideoView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface YM_CustomCameraPlayVideoView : UIView

@property (strong, nonatomic) NSURL *videoURL;

@property (strong, nonatomic) AVPlayerLayer *playerLayer;

- (void)stopPlay;

@end
