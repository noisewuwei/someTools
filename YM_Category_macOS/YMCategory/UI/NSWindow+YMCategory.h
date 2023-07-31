//
//  NSWindow+YMCategory.h
//  ToDesk
//
//  Created by 黄玉洲 on 2021/8/27.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSWindow (YMCategory)

/// 通过坐标获取NSWindow（限当前应用程序，无法获取其他应用程序的窗口）
/// @param point 坐标
+ (NSWindow *)ymWindowFromPoint:(CGPoint)point;

/// 是否处于全屏状态
- (bool)isFullScreen;

/// 是否处于最大化
- (bool)isMaximize;

/// 全屏切换
/// @param fullScreen 是否切换到全屏
- (void)toggleFullScreenWithState:(bool)fullScreen;

@end

NS_ASSUME_NONNULL_END
