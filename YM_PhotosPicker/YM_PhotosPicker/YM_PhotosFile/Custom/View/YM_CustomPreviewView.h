//
//  YM_CustomPreviewView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol YM_CustomPreviewViewDelegate <NSObject>

@optional;
- (void)tappedToFocusAtPoint:(CGPoint)point;
- (void)pinchGestureScale:(CGFloat)scale;
- (void)didLeftSwipeClick;
- (void)didRightSwipeClick;

@end

@interface YM_CustomPreviewView : UIView

@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic)   id<YM_CustomPreviewViewDelegate> delegate;

@property(nonatomic,assign) CGFloat beginGestureScale;
@property(nonatomic,assign) CGFloat effectiveScale;
@property(nonatomic,assign) CGFloat maxScale;

- (void)addSwipeGesture;

@property (nonatomic) BOOL tapToFocusEnabled;
@property (nonatomic) BOOL tapToExposeEnabled;
@property (nonatomic) BOOL pinchToZoomEnabled;

@end
