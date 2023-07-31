//
//  NSArray+YMCategory.m
//  YMCategory
//
//  Created by 黄玉洲 on 2019/12/14.
//  Copyright © 2019 huangyuzhou. All rights reserved.
//

#import "NSArray+YMCategory.h"
#import "NSPredicate+YMCategory.h"
@implementation NSArray (YMCategory)

/**
 NSArray转NSData
 @return NSData
*/
- (NSData *)ymToData {
    return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
}

/**
 NSArray转NSString
 @return NSString
*/
- (NSString *)ymToString {
    NSString * str = [[NSString alloc] initWithData:self.ymToData
    encoding:NSUTF8StringEncoding];
    return str ?  : @"";
}

/**
 过滤数组
 
 @param array1 要过滤的数组
 @param array2 对照数组
 @param contain 取包含或不包含的部分
 @return NSArray
 */
+ (NSArray *)ymFilterArray:(NSArray *)array1
                     array:(NSArray *)array2
                   contain:(BOOL)contain {
    NSPredicate * pre = nil;
    if (contain) {
        pre = [NSPredicate predicateWithFormat:@"SELF IN %@", array2];
    } else {
        pre = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", array2];
    }
    return [array1 filteredArrayUsingPredicate:pre];
}

@end
