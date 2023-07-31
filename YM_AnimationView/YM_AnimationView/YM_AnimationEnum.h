//
//  YM_AnimationEnum.h
//  YM_AnimationView
//
//  Created by huangyuzhou on 2018/9/12.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#ifndef YM_AnimationEnum_h
#define YM_AnimationEnum_h

/** 线头形状 */
typedef NS_ENUM(NSInteger, kLineCap) {
    kLineCap_Round,  // 圆形（默认）
    kLineCap_Butt,   // 线条性
    kLineCap_Square  // 方形
};

/** 动画形式 */
typedef NS_ENUM(NSInteger, kTimingFunction) {
    kTimingFunction_Linear,         // 线性（默认）
    kTimingFunction_EaseIn,         // 渐进
    kTimingFunction_EaseOut,        // 渐出
    kTimingFunction_EaseInEaseOut   // 渐进和渐出
};

#endif /* YM_AnimationEnum_h */
