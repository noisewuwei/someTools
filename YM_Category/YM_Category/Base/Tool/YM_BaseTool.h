//
//  YM_BaseTool.h
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ymAppDelegate [UIApplication sharedApplication]
#define ymWindow [[UIApplication sharedApplication].delegate window]

/** 获取屏幕宽高 */
#define ymScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ymScreenHeight [UIScreen mainScreen].bounds.size.height

/** 判断是否为ipad */
#define ymIsiPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define ymPhoneX [YM_BaseTool isiPhoneX]

/** 导航栏容器高度（不包括状态栏） */
#define ymNavBarHeight self.navigationController.navigationBar.frame.size.height

/** 导航栏高度 */
#define ymNavigationHeight   (ymStatusBarHeight + self.navigationController.navigationBar.frame.size.height)

/** 状态栏高度 */
#define ymStatusBarHeight    [[UIApplication sharedApplication] statusBarFrame].size.height

/** 工具栏高度 */
#define ymTabBarHeight self.tabBar.bounds.size.height

/* 工具栏高度 */
#define ymTabBarHeight (ymSafeAreaHeight ? (49.0 + ymSafeAreaHeight) : 49.0)

/** 底部安全区域高度 */
#define ymSafeAreaHeight [YM_BaseTool safeAreaBottom]

#define ymFont(m) [YM_BaseTool font:m]
#define ymRatio(m) [YM_BaseTool ratioSize:m]

@interface YM_BaseTool : NSObject

#pragma mark - 机型判断
+ (BOOL)isiPhoneX;

/** 获取安全区域 */
+ (CGFloat)safeAreaBottom;

/**
 获取屏幕快照
 @param view 指定视图的屏幕快照
 @return 屏幕快照
 */
+ (UIImage *)screenShot:(UIView *)view;

#pragma mark - 字体大小
+ (UIFont *)font:(CGFloat)fontSzie;

#pragma mark - 计算比例
+ (CGFloat)ratioSize:(CGFloat)size;



@end

NS_ASSUME_NONNULL_END
