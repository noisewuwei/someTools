//
//  NSBundle+YM_PhotoPicker.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "NSBundle+YM_PhotoPicker.h"

@implementation NSBundle (YM_PhotoPicker)

+ (instancetype)ym_photopickerBundle {
    static NSBundle *hxBundle = nil;
    if (hxBundle == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HXPhotoPicker" ofType:@"bundle"];
        if (!path) {
            path = [[NSBundle mainBundle] pathForResource:@"HXPhotoPicker" ofType:@"bundle" inDirectory:@"Frameworks/HXPhotoPicker.framework/"];
        }
        hxBundle = [NSBundle bundleWithPath:path];
    }
    return hxBundle;
}
+ (NSString *)ym_localizedStringForKey:(NSString *)key
{
    return [self ym_localizedStringForKey:key value:nil];
}

+ (NSString *)ym_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        } else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans"; // 简体中文
            } else { // zh-Hant\zh-HK\zh-TW
                language = @"zh-Hant"; // 繁體中文
            }
        } else if ([language hasPrefix:@"ja"]){
            // 日文
            language = @"ja";
        }else if ([language hasPrefix:@"ko"]) {
            // 韩文
            language = @"ko";
        }else {
            language = @"en";
        }
        
        bundle = [NSBundle bundleWithPath:[[NSBundle ym_photopickerBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    NSString * localizedString = [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
    return localizedString;
}


@end
