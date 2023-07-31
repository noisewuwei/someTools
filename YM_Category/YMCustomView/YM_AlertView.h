//
//  YM_AlertView.h
//  YM_AlertView
//
//  Created by 黄玉洲 on 2018/6/20.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_AlertViewItem.h"
@class AppDelegate;

#pragma mark - 协议
@protocol YM_AlertViewDelegate <NSObject>

@optional

// 点击后响应
- (void)myAlertView:(UIView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

#pragma mark - 枚举
typedef NS_ENUM(NSInteger, AnimationType) {
    AnimationTypeNormal = 0,            // 无动画
    AnimationTypeMagnifying = 1,        // 在中心从缩小状态变成正常大小
    AnimationTypeNarrow = 2,            // 在中心从放大状态变成正常大小
};

#pragma mark - 提示窗
@interface YM_AlertView : UIView


@property (nonatomic, strong) UIWindow * myWindow;
@property (nonatomic, strong) NSString * title;                     // 标题
@property (nonatomic, strong) NSString * message;                   // 内容
@property (nonatomic,readonly) NSInteger numberOfButtons;           // 获取按钮个数

@property (nonatomic, assign) CGFloat animationDuration;            // 动画时长
@property (nonatomic, assign) AnimationType animationType;          // 动画效果

@property (nonatomic, weak) id <YM_AlertViewDelegate> delegate;    // 代理

/// 初始化方法
/// @param title 标题
/// @param message 内容
/// @param cancelButtonItem 取消按钮
/// @param otherButtonItems 其他按钮
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
             cancelButtonItem:(YM_AlertViewItem *)cancelButtonItem
             otherButtonItems:(NSArray <YM_AlertViewItem *> *)otherButtonItems;

// 获取指定索引按钮的标题
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

// 显示视图
- (void)show;

@end

