//
//  UIButton+YMCategory.h
//  YM_Category
//
//  Created by huangyuzhou on 2018/9/4.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YM_ImagePosition) {
    /** 图片在左，文字在右，默认 */
    YM_ImagePosition_Left = 0,
    /** 图片在右，文字在左 */
    YM_ImagePosition_Right = 1,
    /** 图片在上，文字在下 */
    YM_ImagePosition_Top = 2,
    /** 图片在下，文字在上 */
    YM_ImagePosition_Bottom = 3,
};

/** 对齐方式 */
typedef NS_ENUM(NSInteger, YM_BtnAlignment) {
    /** 垂直 */
    YM_BtnAlignment_VCenter = 0,
    YM_BtnAlignment_VTop = 1,
    YM_BtnAlignment_VBottom = 2,
    YM_BtnAlignment_VFill = 3,
    // 水平
    YM_BtnAlignment_HCenter = 4,
    YM_BtnAlignment_HLeft = 5,
    YM_BtnAlignment_HRight = 6,
    YM_BtnAlignment_HFill = 7,
    YM_BtnAlignment_HLeading = 8,
    YM_BtnAlignment_HTrailing = 9,
};

@interface UIButton (YMCategory)

/// 便利构造
/// 注意：一定要先设置UIControlStateNormal再设置UIControlStateHighlighted
/// @param buttonType 按钮类型
/// @param isSetup 是否设置默认高亮标题颜色
/// @param alpha 透明度
+ (instancetype)buttonWithType:(UIButtonType)buttonType
              isSetupHighlight:(BOOL)isSetup
                         alpha:(CGFloat)alpha;

/// 便利构造
+ (instancetype)buttonWithTitle:(NSString *)title
                          image:(UIImage *)image
                      backImage:(UIImage *)backImage
                 highlightAlpha:(CGFloat)alpha;

// 利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
// 注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
#pragma mark - 按钮图文风格
/** 图文风格 */
@property (copy, nonatomic, readonly) UIButton * (^ymPosition)(YM_ImagePosition position, CGFloat space);

#pragma mark - 按钮图片
@property (copy, nonatomic, readonly) UIButton * (^ymImage)(UIImage *, UIControlState);
@property (copy, nonatomic, readonly) UIButton * (^ymImageName)(NSString *, UIControlState);

#pragma mark - 按钮背景
@property (copy, nonatomic, readonly) UIButton * (^ymBackImage)(UIImage *, UIControlState);
@property (copy, nonatomic, readonly) UIButton * (^ymBackImageName)(NSString *, UIControlState);

#pragma mark - 事件
@property (copy, nonatomic, readonly) UIButton * (^ymAction)(id target, SEL action, UIControlEvents event);

#pragma mark - 标题
/** 标题 */
@property (copy, nonatomic, readonly) UIButton * (^ymTitle)(NSString *, UIControlState);
/** 标题颜色 */
@property (copy, nonatomic, readonly) UIButton * (^ymTitleColor)(UIColor *, UIControlState);
/** 标题字体 */
@property (copy, nonatomic, readonly) UIButton * (^ymTitleFont)(UIFont *);
/** 标题富文本 */
@property (copy, nonatomic, readonly) UIButton * (^ymTitleAttribute)(NSAttributedString *, UIControlState);
/** 标题对齐 */
@property (copy, nonatomic, readonly) UIButton * (^ymAlignment)(YM_BtnAlignment);

#pragma mark - 图片加载动画
/** 开始加载动画 */
- (void)ymStartLoadAnimationWithImage:(UIImage *)image
                             duration:(CGFloat)duration
                           buttonSize:(CGSize)buttonSize;

/** 停止加载动画 */
- (void)ymStopLoadAnimation;

/** 更新图片和文本位置 */
- (void)updateImageTextPosition;

#pragma mark - 动态属性
/** 扩大点击范围 */
@property (copy, nonatomic, readonly) UIButton * (^ymExpandTouch)(BOOL);

@end

#pragma mark - 按钮点击时间间隔
@interface UIControl (YMClickInterval)

/// 点击事件响应的时间间隔，不设置即没有时间间隔
@property (nonatomic, assign) NSTimeInterval ymClickInterval;

/// 交换点击事件（需调用才能起效）
+ (void)ymExchangeClickMethod;

@end
