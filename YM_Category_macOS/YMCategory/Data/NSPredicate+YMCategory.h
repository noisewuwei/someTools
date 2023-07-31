//
//  NSPredicate+YMCategory.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/6/3.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 包含的类型 */
typedef NS_ENUM(NSInteger, kContainsType) {
    /** 不进行忽略 */
    kContainsType_Not,
    /** 忽略大小写 */
    kContainsType_C,
    /** 忽略重音符 */
    kContainsType_D,
    /** 忽略大小写和重音符 */
    kContainsType_CD
};

@interface NSPredicate (YMCategory)

/// 判断两个值
/// @param number1 比较值
/// @param operators 大于等于 >=，=>, 小于等于<=，=<，不等于!=、<>, 相等 =
/// @param number2 被比较值
+ (BOOL)ymCompareNum1:(NSNumber *)number1
            operators:(NSString *)operators
                 num2:(NSNumber *)number2;

/// 判断str1是否以str2开头
/// @param str1 NSString
/// @param str2 NSString
+ (BOOL)ymCheckStr1:(NSString *)str1
      beginWithStr2:(NSString *)str2;

/// 判断str1是否以str2结尾
/// @param str1 NSString
/// @param str2 NSString
+ (BOOL)ymCheckStr1:(NSString *)str1
        endWithStr2:(NSString *)str2;

/// 判断str1是否包含str2
/// @param str1 NSString
/// @param str2 NSString
+ (BOOL)ymCheckStr1:(NSString *)str1
    containWithStr2:(NSString *)str2;

/// 判断str1是否包含str2
/// @param str1 NSString
/// @param str2 NSString
/// @param containsType 忽略类型
+ (BOOL)ymCheckStr1:(NSString *)str1
    containWithStr2:(NSString *)str2
       containsType:(kContainsType)containsType;

/// 判断str1是否匹配str2字符串模板(如'abc' 匹配 '?bc')
/// @param str1 NSString
/// @param str2 ?代表一个字符 *代表任意多个(不包括0)字符
+ (BOOL)ymCheckStr1:(NSString *)str1
       likeWithStr2:(NSString *)str2;

/// 判断str是否匹配正则表达式regex
/// @param str 要验证的字符串
/// @param regex 正则表达式规则，如@"^[1][3-8]\\d{9}$"
+ (BOOL)ymCheckStr:(NSString *)str
  matchesWithRegex:(NSString *)regex;

/// 判断str1是否在strs数组中
/// @param str NSString
/// @param strs NSArray
+ (BOOL)ymCheckStr:(NSString *)str
         inWithStrs:(NSArray <NSString *> *)strs;

/// 判断num是否在nums数组中
/// @param num NSNumber
/// @param nums NSArray
+ (BOOL)ymCheckNum:(NSNumber *)num
        inWithNums:(NSArray <NSNumber *> *)nums;

/// 逻辑运算
/// @param num NSNumber
/// @param format 逻辑规则（与：&&;或：||;非：! ）
/// format可以像下面这么传：
/// SELF >= 5 && SELF <=10
+ (BOOL)ymCheckNum:(NSNumber *)num
            format:(NSString *)format;

/// 逻辑运算
/// @param obj 要检验的对象
/// @param format 逻辑规则（与：&&;或：||;非：! ）
/// format可以像下面这么传：
/// NSNumber: SELF >= 5 && SELF <=10
/// NSString: SELF.length > 4 && SELF.length > < 8
+ (BOOL)ymCheckObj:(id)obj
            format:(NSString *)format;

#pragma mark - NSPredicate
/// 获取指定规则的NSPredicate
/// @param format 规则，结尾必须传入nil
+ (NSPredicate *)ymPredicateForFormat:(NSString *)format;

@end


NS_ASSUME_NONNULL_END
