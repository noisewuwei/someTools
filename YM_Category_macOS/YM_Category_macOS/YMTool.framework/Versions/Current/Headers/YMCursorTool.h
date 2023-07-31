//
//  YMCursorTool.h
//  YMTool
//
//  Created by 蒋天宝 on 2020/12/17.
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

@end

NS_ASSUME_NONNULL_END
