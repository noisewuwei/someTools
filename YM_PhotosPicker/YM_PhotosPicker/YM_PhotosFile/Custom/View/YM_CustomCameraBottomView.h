//
//  YM_CustomCameraBottomView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoManager.h"

typedef enum : NSUInteger {
    YM_CustomCameraBottomViewModePhoto = 0,
    YM_CustomCameraBottomViewModeVideo = 1,
} YM_CustomCameraBottomViewMode;

@class YM_CustomCameraBottomView;
@protocol YM_CustomCameraBottomViewDelegate <NSObject>
@optional
- (void)playViewClick;
- (void)playViewAnimateCompletion;
- (void)playViewChangeMode:(YM_CustomCameraBottomViewMode)mode;
@end

@interface YM_CustomCameraBottomView : UIView

@property (weak, nonatomic) id<YM_CustomCameraBottomViewDelegate> delegate;
@property (assign ,nonatomic) BOOL animating;
@property (assign, nonatomic) YM_CustomCameraBottomViewMode mode;

- (instancetype)initWithFrame:(CGRect)frame
                      manager:(YM_PhotoManager *)manager
                    isOutside:(BOOL)isOutside;

- (void)changeTime:(NSInteger)time;
- (void)startRecord;
- (void)stopRecord;
- (void)beganAnimate;
- (void)leftAnimate;
- (void)rightAnimate;

@end
