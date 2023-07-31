//
//  YM_BaseView.h
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kTouchType) {
    /// 触摸开始
    kTouchType_Began,
    /// 触摸移动
    kTouchType_Move,
    /// 触摸结束
    kTouchType_Ended,
    /// 触摸被终止
    kTouchType_Cancelled,
};

@protocol YM_BaseViewDelegate;
@interface YM_BaseView : UIView

/**
 布局，仅仅用于重写
 */
- (void)layoutView;

/// 代理
@property (weak, nonatomic) id <YM_BaseViewDelegate> delegate;

/// 透明区域手势穿透
@property (assign, nonatomic) BOOL gesturesPenetrate;

@end

@protocol YM_BaseViewDelegate <NSObject>

/// 返回触摸类型
/// @param view 当前视图
/// @param touchType 触摸类型
/// @param inRect 坐标是否在视图中
- (void)ymView:(YM_BaseView *)view touchType:(kTouchType)touchType inRect:(BOOL)inRect;

@end

NS_ASSUME_NONNULL_END
