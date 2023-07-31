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
NSDictionary转NSData
@return NSData
*/
- (NSData *)ymToData {
    return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
}

/**
NSDictionary转NSString
@return NSString
*/
- (NSString *)ymToString {
    NSString * str = [[NSString alloc] initWithData:self.ymToData
    encoding:NSUTF8StringEncoding];
    return str ?  : @"";
}

@end
