//
//  NSArray+YMCategory.h
//  YMCategory
//
//  Created by 黄玉洲 on 2019/12/14.
//  Copyright © 2019 huangyuzhou. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (YMCategory)

/**
 NSArray转NSData
 @return NSData
*/
- (NSData *)ymToData;

/**
 NSArray转NSString
 @return NSString
*/
- (NSString *)ymToString;

/**
 过滤数组
 
 @param array1 要过滤的数组
 @param array2 对照数组
 @param contain 取包含或不包含的部分
 @return NSArray
 */
+ (NSArray *)ymFilterArray:(NSArray *)array1
                     array:(NSArray *)array2
                   contain:(BOOL)contain;

@end

NS_ASSUME_NONNULL_END
