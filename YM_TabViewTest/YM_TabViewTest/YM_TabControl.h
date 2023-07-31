//
//  YM_TabControl.h
//  YM_TabViewTest
//
//  Created by 黄玉洲 on 2018/6/11.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YM_TabControlDelegate;
@protocol YM_TabControlIndicatorDelegate;

/** 开奖首页列表上的滚动标签栏 */
@interface YM_TabControl : UIView

@property (weak, nonatomic) id <YM_TabControlDelegate> delegate;
@property (weak, nonatomic) id <YM_TabControlIndicatorDelegate> indicatorDelegate;

/** 允许重复点击 */
@property (assign, nonatomic) BOOL allowDuplicateTouch;

- (void)reloadData;

/** 移动到指定的位置 */
- (void)scrollToIndex:(NSInteger)index animation:(BOOL)isAnimation;

/** 当前指定下标是否处于选中状态 */
- (BOOL)isSelectedWithIndex:(NSInteger)index;

/** 当前索引 */
- (void)setCurrentIndex:(NSInteger)index;
- (NSInteger)currentIndex;

@end


#pragma mark - 代理
@protocol YM_TabControlDelegate <NSObject>

@optional
/**
 选项卡数量
 @param tabControl 选项卡控件
 @return 选项卡数量
 */
- (NSInteger)ym_tabItemCount:(YM_TabControl *)tabControl;

/**
 选项卡宽度
 @param tabControl 选项卡控件
 @param index 下标
 @return 选项卡数量
 */
- (CGFloat)ym_tabItemWidth:(YM_TabControl *)tabControl
                     index:(NSInteger)index;


/**
 点击选项卡回调
 @param tabControl 选项卡控件
 @param index 索引
 @return 是否可点击
 */
- (BOOL)ym_tabItemDidSelect:(YM_TabControl *)tabControl
                      index:(NSInteger)index;

/**
 自定义的选项视图
 @param tabControl 选项卡控件
 @param index 索引，从0开始
 @return 自定义的选项视图
 */
- (UIView *)ym_customerTabItem:(YM_TabControl *)tabControl
                     itemIndex:(NSInteger)index;

@end

/** 指示标代理 */
@protocol YM_TabControlIndicatorDelegate  <NSObject>

@optional

/**
 是否展示指示标
 @param tabControl 选项卡控件
 @return 是否展示
 */
- (BOOL)ym_showIndicatorView:(YM_TabControl *)tabControl;


/**
 指示标颜色
 @param tabControl 选项卡控件
 @param index 索引
 @return 颜色
 */
- (UIColor *)ym_indicatorViewColor:(YM_TabControl *)tabControl
                             index:(NSInteger)index;

/**
 指示标高度
 @param tabControl 选项卡控件
 @return 高度
 */
- (CGFloat)ym_indicatorViewHeight:(YM_TabControl *)tabControl;

@end


