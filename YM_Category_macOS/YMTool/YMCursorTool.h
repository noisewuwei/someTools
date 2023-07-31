//
//  YMCursorTool.h
//  YMTool
//
//  Created by 黄玉洲 on 2020/12/17.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 光标发生变化的通知
static NSString * kCursorDidChangeNotifycation = @"kCursorDidChangeNotifycation";

@class NSImage;

/// 光标工具（已实现监听光标变化）
@interface YMCursorTool : NSObject

+ (instancetype)share;

#pragma mark - 监听指针变化
/// 监听周期时长，默认0.3秒;
@property (assign, nonatomic) CGFloat cycleDuration;

/// 开启监听
- (void)startListening;

/// 停止监听
- (void)stopListening;

/// 当前光标的图标
- (NSImage *)currentCursorImage;

/// 当前光标的图标数据
- (NSData *)currentCursorData;

#pragma mark - 当前指针数据
/// 获取当前指针所在位置
- (NSPoint)mousePoint;

/// 获取当前指针所在的屏幕
- (NSScreen *)mouseInScreen;

#pragma mark - 获取当前指针RGBA数据
/// 指针数据
/// @param width 指针宽度
/// @param height 指针高度
/// @param hotX 指针热点X
/// @param hotY 指针热点Y
- (NSData *)cursorDataWithWidth:(int32_t *)width height:(int32_t *)height hotX:(int32_t *)hotX hotY:(int32_t *)hotY;

@end

NS_ASSUME_NONNULL_END
