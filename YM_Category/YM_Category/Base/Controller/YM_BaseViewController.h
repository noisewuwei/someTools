//
//  YM_BaseViewController.h
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+YMHUDCategory.h"
@interface YM_BaseViewController : UIViewController

/** 导航条 */
@property (strong, nonatomic, readonly) UIImageView * navigationBar;

/** 导航条title图片 */
@property (strong, nonatomic) UIImage * navigationBarImage;

/** 导航栏标题颜色 */
@property (strong, nonatomic) UIColor * titleColor;

/** 导航栏背景色（渐变） */
@property (strong, nonatomic) NSArray <UIColor *> * gradientColors;

/** 允许屏幕旋转 */
@property (assign, nonatomic) BOOL allowAutorotate;

/** 进行重写，执行要释放的代码 */
- (void)runRelease;

#pragma mark - 手势
/**
 标题点击手势
 @param tapGesture 手势对象
 */
- (void)titleTapAction:(UITapGestureRecognizer *)tapGesture;

#pragma mark - 导航栏左右侧视图
@property (strong, nonatomic, readonly) UIView * leftView;
@property (strong, nonatomic, readonly) UIView * rightView;

/**
 导航栏左侧视图
 @param leftItem 左侧元素
 */
- (void)leftNavigationItem:(UIView *)leftItem;

/**
 导航栏左侧按钮构建方法
 @param target 事件响应对象
 @param sel    方法
 @return UIButton
 */
- (UIButton *)leftBtnWithTarget:(id)target
                            sel:(SEL)sel;

/**
 导航栏右侧视图
 @param rightItem 右侧元素
 */
- (void)rightNavigationItem:(UIView *)rightItem;

/** 让导航栏透明 */
- (void)transparentNavigation;

/** 让导航栏隐藏 */
- (void)hideNavigation;

#pragma mark - 用于重写的方法
/** 布局，仅仅用于重写 */
- (void)layoutView;

/** 左侧按钮事件 */
- (void)leftButtonAction:(UIButton *)sender;

/** 右侧按钮事件 */
- (void)rightButtonAction:(UIButton *)sender;

#pragma mark - 通知
/** 注册通知 */
- (void)registerNotification;

/* 拖拽开关(默认开启) */
@property (assign, nonatomic) BOOL  isPan;

/* 全局侧拉（默认为NO，即只有左侧100px可以发生侧拉触摸） */
@property (assign, nonatomic) BOOL  globalTouch;

#pragma mark - 界面
/** 模态出指定界面（带导航栏） */
- (void)presentViewController:(UIViewController *)vc haveNavBar:(BOOL)haveNavBar;

/** 设置工具栏索引 */
- (void)setTabbarIndex:(NSInteger)index;
- (NSInteger)tabbarIndex;

@end



