//
//  YM_DatePhotoViewPresentTransition.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    YM_DatePhotoViewPresentTransitionType_Present = 0,
    YM_DatePhotoViewPresentTransitionType_Dismiss = 1,
} YM_DatePhotoViewPresentTransitionType;
@class YM_PhotoView;

@interface YM_DatePhotoViewPresentTransition : NSObject<UIViewControllerAnimatedTransitioning>

+ (instancetype)transitionWithTransitionType:(YM_DatePhotoViewPresentTransitionType)type photoView:(YM_PhotoView *)photoView;

- (instancetype)initWithTransitionType:(YM_DatePhotoViewPresentTransitionType)type photoView:(YM_PhotoView *)photoView;

@end
