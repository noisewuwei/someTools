//
//  YMMouseBaseTool.h
//  YM_Category_macOS
//
//  Created by 黄玉洲 on 2021/12/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "YMMouseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMMouseBaseTool : NSObject

/// 鼠标滚轮滚动的距离（-10~10），默认-10/10px
@property (assign, nonatomic) CGFloat mouseScrollEdge;

/// 鼠标滚动时，是否使用kCGScrollEventUnitLine模式
@property (assign, nonatomic) BOOL useUnitLine;

@property (assign, nonatomic) CGScrollEventUnit scrollEventUnit;

/// 设置当前屏幕ID
@property (assign, nonatomic) CGDirectDisplayID displayID;

/// 当前鼠标所在的屏幕（以设置displayID后为准）
@property (strong, nonatomic) NSScreen * currentScreen;

/// 鼠标注入时带的事件类型，新API才能使用（默认0x77）
@property (assign, nonatomic) NSInteger mouseSubtype;

/// 打开日志打印
@property (assign, nonatomic) bool logEnable;

/// 鼠标滚轮事件
/// @param distance 负向上、右，正向下、左
/// @param horizontal 是否为水平滚动
- (void)postMouseScrollEvent:(int32_t)distance horizontal:(BOOL)horizontal deltax:(int32_t)deltax deltay:(int32_t)deltay;

- (void)postMouseScrollEvent:(int32_t)distance horizontal:(BOOL)horizontal;

@end

NS_ASSUME_NONNULL_END
