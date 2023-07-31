//
//  NSBundle+YMCategory.m
//  YMCategory
//
//  Created by 海南有趣 on 2020/7/8.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import "NSBundle+YMCategory.h"
#import <UIKit/UIKit.h>

@implementation NSBundle (YMCategory)

/// 应用名称
+ (NSString *)ymDisplayName {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
}

/// BundleID
+ (NSString *)ymBundleID {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
}

/// 应用版本
+ (NSString *)ymVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

/// 应用编译版本（相当于当前应用版本的子版本）
+ (NSString *)ymBuildVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

#pragma mark 国际化(用于Framework中的国际化加载)
/// 便利构造
/// @param bundlePath 如Frameworks/xxx.framework
+ (instancetype)ymLocalizableBundleWithPath:(NSString *)bundlePath {
    NSString * systemLanguage = [self _getLanguageFromSystem];
    
    NSString * frameworkDirectory = [[NSBundle mainBundle] pathForResource:bundlePath ofType:nil];
    NSBundle * bundle = [NSBundle bundleWithPath:frameworkDirectory];
    NSString * languagePath = [bundle pathForResource:systemLanguage ofType:@"lproj"];
    if (!languagePath) {
        languagePath = [bundle pathForResource:@"en" ofType:@"lproj"];
    }
    bundle = [NSBundle bundleWithPath:languagePath];
    
    return bundle;
}

/// 获取多文本
/// @param key 多文本中的key
- (NSString *)ymLocalizableStringWithKey:(NSString *)key {
    return [self localizedStringForKey:key value:nil table:nil];
}

/// 获取系统默认的语言
+ (NSString *)_getLanguageFromSystem {
    NSString * language = [NSLocale preferredLanguages].firstObject;
    NSArray * strings = [language componentsSeparatedByString:@"-"];
    NSString * systemLanguage = @"";
    if (strings.count >= 3) {
        systemLanguage = [NSString stringWithFormat:@"%@-%@", strings[0], strings[1]];
    } else {
        systemLanguage = [strings firstObject];
    }
    return systemLanguage;
}


@end
