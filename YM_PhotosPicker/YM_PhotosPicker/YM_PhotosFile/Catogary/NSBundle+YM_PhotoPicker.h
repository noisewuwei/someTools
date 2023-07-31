//
//  NSBundle+YM_PhotoPicker.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (YM_PhotoPicker)

/** 初始化 */
+ (instancetype)ym_photopickerBundle;

/** 设置本地化字符 */
+ (NSString *)ym_localizedStringForKey:(NSString *)key
                                 value:(NSString *)value;

/** 设置本地化字符 */
+ (NSString *)ym_localizedStringForKey:(NSString *)key;

@end
