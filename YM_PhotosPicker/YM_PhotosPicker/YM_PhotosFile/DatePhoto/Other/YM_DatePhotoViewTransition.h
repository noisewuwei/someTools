//
//  YM_DatePhotoViewTransition.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    YM_DatePhotoViewTransitionType_Push = 0,
    YM_DatePhotoViewTransitionType_Pop = 1,
} YM_DatePhotoViewTransitionType;

@interface YM_DatePhotoViewTransition : NSObject<UIViewControllerAnimatedTransitioning>

+ (instancetype)transitionWithType:(YM_DatePhotoViewTransitionType)type;

- (instancetype)initWithTransitionType:(YM_DatePhotoViewTransitionType)type;

@end
