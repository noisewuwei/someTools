//
//  NSBundle+YMCategory.h
//  YMCategory
//
//  Created by 海南有趣 on 2020/7/8.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (YMCategory)

/// 应用名称
+ (NSString *)ymDisplayName;

/// BundleID
+ (NSString *)ymBundleID;

/// 应用版本
+ (NSString *)ymVersion;

/// 应用编译版本（相当于当前应用版本的子版本）
+ (NSString *)ymBuildVersion;

#pragma mark 国际化(用于Framework中的国际化加载)
/// 便利构造
/// @param bundlePath 如Frameworks/xxx.framework
+ (instancetype)ymLocalizableBundleWithPath:(NSString *)bundlePath;

/// 获取多文本
/// @param key 多文本中的key
- (NSString *)ymLocalizableStringWithKey:(NSString *)key;

@end
