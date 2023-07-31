//
//  YM_LoadAnimationView_0.h
//  YM_AnimationView
//
//  Created by huangyuzhou on 2018/9/12.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YM_LoadAnimationView_0 : UIView

/** 进度线条的宽度，默认：2 */
@property (assign, nonatomic) CGFloat lineWidth;

/** 进度线条的背景色，默认：[UIColor grayColor] */
@property (strong, nonatomic) UIColor * lineBackColor;

/** 进度线条的线条色，默认：[UIColor redColor] */
@property (strong, nonatomic) UIColor * lineColor;

/** 视图半径，默认：self高度的一半 */
@property (assign, nonatomic) CGFloat   radius;

/** 动画时长，默认：1.5秒 */
@property (assign, nonatomic) CGFloat   duration;

/** 分割点效果（传入类似于'@[@6,@3]'），默认：nil */
@property (strong, nonatomic) NSArray * lineDashPattern;

@end
