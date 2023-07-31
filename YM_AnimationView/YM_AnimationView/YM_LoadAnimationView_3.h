//
//  YM_LoadAnimationView_3.h
//  YM_AnimationView
//
//  Created by huangyuzhou on 2018/9/12.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_AnimationEnum.h"

@interface YM_LoadAnimationView_3 : UIView

/** 进度线条的宽度，默认：2 */
@property (assign, nonatomic) CGFloat lineWidth;

/** 进度线条的线条色，默认：[UIColor redColor] */
@property (strong, nonatomic) UIColor * lineColor;

/** 动画时长，默认：1.5秒 */
@property (assign, nonatomic) CGFloat   duration;

/** 分割点效果（传入类似于'@[@1, @10]'），默认：nil */
@property (strong, nonatomic) NSArray * lineDashPattern;

/** 线头形状 */
@property (assign, nonatomic) kLineCap  lineCap;

/** 动画形式 */
@property (assign, nonatomic) kTimingFunction timingFunction;

@end
