//
//  YMFormatter.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/20.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "YMFormatter.h"

@interface YMFormatter ()

@end

@implementation YMFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString * _Nullable __autoreleasing *)newString errorDescription:(NSString * _Nullable __autoreleasing *)error {
    // 删除键
    if ([partialString isEqual:@""]) {
        return YES;
    }
    
    // 自定义
    if (_customRegex) {
        BOOL result = [self _ymCheckStr:partialString matchesWithRegex:_customRegex];
        return result;
    }
    // 默认模式
    else if (_type == kNumberFormatterType_Normal) {
        return YES;
    }
    // 纯数字
    else if (_type == kNumberFormatterType_Number) {
        if (![self _ymValidatePureInt:partialString]) {
            return NO;
        }
    }
    // 手机号
    else if (_type == kNumberFormatterType_Phone) {
        if (![self _ymValidatePureInt:partialString]) {
            return NO;
        } else if (partialString.length > 11) {
            return NO;
        }
    }
    return YES;
}

#pragma mark private
/// 判断str是否匹配正则表达式regex
/// @param str 要验证的字符串
/// @param regex 正则表达式规则，如@"^[1][3-8]\\d{9}$"
- (BOOL)_ymCheckStr:(NSString *)str matchesWithRegex:(NSString *)regex {
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pre evaluateWithObject:str];
}


/** 验证是否为整型 */
- (BOOL)_ymValidatePureInt:(NSString *)string {
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

@end
