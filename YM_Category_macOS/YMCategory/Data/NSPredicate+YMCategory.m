//
//  NSPredicate+YMCategory.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/6/3.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "NSPredicate+YMCategory.h"

#import <AppKit/AppKit.h>


@implementation NSPredicate (YMCategory)

/// 判断两个值
/// @param number1 比较值
/// @param operators 大于等于 >=，=>, 小于等于<=，=<，不等于!=、<>, 相等 =
/// @param number2 被比较值
+ (BOOL)ymCompareNum1:(NSNumber *)number1
            operators:(NSString *)operators
                 num2:(NSNumber *)number2 {
    if (![operators isEqual:@">="] &&
        ![operators isEqual:@"<="] &&
        ![operators isEqual:@"!="] &&
        ![operators isEqual:@"="] &&
        ![operators isEqual:@">"] &&
        ![operators isEqual:@"<"]) {
        [NSException raise:@"输入异常" format:@"operators 输入错误"];
    }
    NSString * formater = [NSString stringWithFormat:@"SELF %@ %@", operators, number2];
    NSPredicate * pre = [NSPredicate predicateWithFormat:formater];
    return [pre evaluateWithObject:number1];
}


/// 判断str1是否以str2开头
/// @param str1 NSString
/// @param str2 NSString
+ (BOOL)ymCheckStr1:(NSString *)str1
      beginWithStr2:(NSString *)str2 {
    NSString * formater = [NSString stringWithFormat:@"SELF BEGINSWITH '%@'", str2];
    NSPredicate * pre = [NSPredicate predicateWithFormat:formater];
    return [pre evaluateWithObject:str1];
}

/// 判断str1是否以str2结尾
/// @param str1 NSString
/// @param str2 NSString
+ (BOOL)ymCheckStr1:(NSString *)str1
        endWithStr2:(NSString *)str2 {
    NSString * formater = [NSString stringWithFormat:@"SELF ENDSWITH '%@'", str2];
    NSPredicate * pre = [NSPredicate predicateWithFormat:formater];
    return [pre evaluateWithObject:str1];
}

/// 判断str1是否包含str2
/// @param str1 NSString
/// @param str2 NSString
+ (BOOL)ymCheckStr1:(NSString *)str1
    containWithStr2:(NSString *)str2 {
    NSString * formater = [NSString stringWithFormat:@"SELF CONTAINS '%@'", str2];
    NSPredicate * pre = [NSPredicate predicateWithFormat:formater];
    return [pre evaluateWithObject:str1];
}

/// 判断str1是否包含str2
/// @param str1 NSString
/// @param str2 NSString
/// @param containsType 忽略类型
+ (BOOL)ymCheckStr1:(NSString *)str1
    containWithStr2:(NSString *)str2
       containsType:(kContainsType)containsType {
    NSString * operation = @"";
    switch (containsType) {
        case kContainsType_Not: break;
        case kContainsType_C: operation = @"[c]"; break;
        case kContainsType_D: operation = @"[d]"; break;
        case kContainsType_CD:operation = @"[cd]"; break;
            
        default:
            break;
    }
    
    NSString * formater = [NSString stringWithFormat:@"SELF CONTAINS%@ '%@'", operation, str2];
    NSPredicate * pre = [NSPredicate predicateWithFormat:formater];
    return [pre evaluateWithObject:str1];
}


/// 判断str1是否匹配str2字符串模板
/// 如'abc' 匹配 '?bc', 匹配 '*c', 但不匹配 '?c'
/// @param str1 NSString
/// @param str2 ?代表一个字符 *代表任意多个(不包括0)字符
+ (BOOL)ymCheckStr1:(NSString *)str1
       likeWithStr2:(NSString *)str2 {
    NSString * formater = [NSString stringWithFormat:@"SELF LIKE '%@'", str2];
    NSPredicate * pre = [NSPredicate predicateWithFormat:formater];
    return [pre evaluateWithObject:str1];
}

/// 判断str是否匹配正则表达式regex
/// @param str 要验证的字符串
/// @param regex 正则表达式规则，如@"^[1][3-8]\\d{9}$"
+ (BOOL)ymCheckStr:(NSString *)str
  matchesWithRegex:(NSString *)regex {
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pre evaluateWithObject:str];
}

/// 判断str1是否在strs数组中
/// @param str NSString
/// @param strs NSArray
+ (BOOL)ymCheckStr:(NSString *)str
         inWithStrs:(NSArray <NSString *> *)strs {
    if (strs.count == 0) {
        return NO;
    }
    NSString * joinStr = @"";
    for (NSString * tempStr in strs) {
        if ([joinStr isEqualToString:@""]) {
            joinStr = [NSString stringWithFormat:@"'%@'", tempStr];
        } else {
            joinStr = [NSString stringWithFormat:@"%@, '%@'", joinStr, tempStr];
        }
    }
    joinStr = [NSString stringWithFormat:@"{%@}", joinStr];
    
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"SELF IN %@", joinStr];
    return [pre evaluateWithObject:str];
}

/// 判断num是否在nums数组中
/// @param num NSNumber
/// @param nums NSArray
+ (BOOL)ymCheckNum:(NSNumber *)num
         inWithNums:(NSArray <NSNumber *> *)nums {
    if (nums.count == 0) {
        return NO;
    }
    NSString * joinStr = @"";
    for (NSNumber * tempNum in nums) {
        if ([joinStr isEqualToString:@""]) {
            joinStr = [NSString stringWithFormat:@"%@", tempNum];
        } else {
            joinStr = [NSString stringWithFormat:@"%@, %@", joinStr, tempNum];
        }
    }
    joinStr = [NSString stringWithFormat:@"SELF IN {%@}", joinStr];
    
    NSPredicate * pre = [NSPredicate predicateWithFormat:joinStr];
    return [pre evaluateWithObject:num];
}

/// 逻辑运算
/// @param obj 要检验的对象
/// @param format 逻辑规则（与：&&;或：||;非：! ）
/// format可以像下面这么传：
/// NSNumber: SELF >= 5 && SELF <=10
/// NSString: SELF.length > 4 && SELF.length > < 8
+ (BOOL)ymCheckObj:(id)obj
            format:(NSString *)format {
    NSPredicate * pre = [NSPredicate predicateWithFormat:format];
    return [pre evaluateWithObject:obj];
}


#pragma mark - NSPredicate
/// 获取指定规则的NSPredicate
/// @param format 规则
/// 1.如果是过滤模型，可用以下几种方式(name是模型属性)：
/// [NSString stringWithFormat:@"%K CONTAINS %@", @"name", @"jo"];
/// [NSString stringWithFormat:@"name CONTAINS %@", @"jo"];
/// [NSString stringWithFormat:@"SELF.name CONTAINS %@", @"jo"];
///
/// NSPredicate *predTemp3 = [NSPredicate predicateWithFormat:@"%K CONTAINS $VALUE", @"name"];
/// NSPredicate* pred3 = [predTemp3 predicateWithSubstitutionVariables:@{@"VALUE" : @"jo"}];
+ (NSPredicate *)ymPredicateForFormat:(NSString *)format {
    NSPredicate * pre = [NSPredicate predicateWithFormat:format];
    return pre;
}

@end

