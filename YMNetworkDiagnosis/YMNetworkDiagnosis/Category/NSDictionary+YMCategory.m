//
//  NSDictionary+YMCategory.m
//  youqu
//
//  Created by 黄玉洲 on 2019/5/7.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import "NSDictionary+YMCategory.h"

@implementation NSDictionary (YMCategory)

/**
 转换为字符串
 @return ymConverToJson
 */
- (NSString*)ymConverToJson {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
    NSLog(@"%s error = %@", __FUNCTION__, jsonData);
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
