//
//  YMDisplayTool.h
//  YMTool
//
//  Created by 黄玉洲 on 2021/11/6.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// CGDisplay的相关引用
@interface YMDisplayTool : NSObject

/// 验证是否为主屏幕
/// @param displayID 屏幕ID
+ (BOOL)ymDisplayIsMain:(NSString *)displayID;

/// 获取显示器ID，返回nil证明获取失败;数组中第一位为主屏幕;
+ (NSArray <NSString *> *)ymDisplayList;

/// 获取指定屏幕的大小（像素值）
/// @param displayID 屏幕ID
+ (CGRect)ymDisplayBoundsWithID:(NSString *)displayID;

/// 获取指定屏幕的大小（毫米值）
/// @param displayID 屏幕ID
+ (CGSize)ymDisplaySizeWithID:(NSString *)displayID;

/// 禁用显示器
/// @param disable 是否禁用
/// @param displayID 屏幕ID
+ (NSString *)ymDisplayDisable:(BOOL)disable displayID:(NSString *)displayID;

@end

NS_ASSUME_NONNULL_END
