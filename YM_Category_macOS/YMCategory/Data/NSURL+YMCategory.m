//
//  NSURL+YMCategory.m
//  YMCategory
//
//  Created by 黄玉洲 on 2022/1/21.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import "NSURL+YMCategory.h"

@implementation NSURL (YMCategory)

/// 根据文件路径初始化NSURL
/// @param filePath 路径如果不含"file://"，会自动拼接；该路径可包含空格
+ (NSURL *)ymURLWithFilePath:(NSString *)filePath {
    if (![filePath isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    if (![filePath containsString:@"file://"]) {
        filePath = [NSString stringWithFormat:@"file://%@", filePath];
    }
    
    filePath = [filePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:filePath];
    return url;
}

@end
