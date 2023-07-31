//
//  NSString+YMPredicate.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/6/3.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "NSString+YMPredicate.h"
#import "NSPredicate+YMCategory.h"
#import <AppKit/AppKit.h>


@implementation NSString (YMPredicate)

#pragma mark - 便利验证
/** 验证是否为纯数字 */
- (BOOL)ymValidatePureNumber {
    NSString * regex = @"^[0-9]{1,}$";
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/** 验证是否包含数字 */
- (BOOL)ymValidateHaveNumber {
    NSString * regex = @"^(\\D*[0-9]{1,}\\D*){1,}$";
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/** 验证是否为整型 */
- (BOOL)ymValidatePureInt {
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

/** 验证是否为浮点型 */
- (BOOL)ymValidatePureFloat {
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

/** 验证是否有小数部分（几xxx.yyy，yyy部分是否大于0） */
- (BOOL)ymValidateDecimal {
    CGFloat floatValue = [self floatValue];
    NSInteger intValue = [self integerValue];
    return (intValue - floatValue) < 0;
}

/** 验证是否为特殊符号 */
- (BOOL)ymValidateHaveSpecialSymbols {
    NSString * regex = @"`~!@#$%^&*()_-+=<>?:\"{}|,./;'\\[\\]·~！@#￥%……&*（）——-+={}|《》？：“”【】、；‘’，。、";
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/** 验证是否为纯字母 */
- (BOOL)ymValidatePureWord {
    NSString * regex = @"^[a-zA-Z]{1,}$";
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/** 验证是否为纯Emoji */
- (BOOL)ymValidatePureEmoji {
    NSString * regex = @"^([\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]){1,}$";
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}


/** 验证是否包含Emoji */
- (BOOL)ymValidateHaveEmoji {
    NSString * regex = @"^(\\w{0,}([\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]){1,}\\w{0,}){1,}$";
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/**
 验证是否包含或全为汉字
 @param isPure 是否全为汉字
 @return 是否符合验证
 */
- (BOOL)ymValidateChinese:(BOOL)isPure {
    NSString * unicode = [[self class] chineseUnicode];
    NSString * regex = @"";
    if (isPure) {
        regex = [NSString stringWithFormat:@"(^[%@]{1,}$)", unicode];
    } else {
        regex = [NSString stringWithFormat:@"^((.*)[%@]{1,}(.*))$", unicode];
    }
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/**
 验证是否包含或全为韩文
 @param isPure 是否全为韩文
 @return 是否符合验证
 */
- (BOOL)ymValidateKorean:(BOOL)isPure {
    NSString * unicode = [[self class] koreanUnicode];
    NSString * regex = @"";
    if (isPure) {
        regex = [NSString stringWithFormat:@"(^[%@]{1,}$)", unicode];
    } else {
        regex = [NSString stringWithFormat:@"^((.*)[%@]{1,}(.*))$", unicode];
    }
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/**
 验证字符串是否包含日文或者全是日文
 @param isPure 包含或者全是日文
 @return 是否符合条件
 */
- (BOOL)ymValidateJapan:(BOOL)isPure {
    NSString * unicode = [[self class] japanUnicode];
    NSString * regex = @"";
    if (isPure) {
        regex = [NSString stringWithFormat:@"(^[%@]{1,}$)", unicode];
    } else {
        regex = [NSString stringWithFormat:@"^((.*)[%@]{1,}(.*))$", unicode];
    }
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/** 是否为手机号码 */
- (BOOL)ymValidatePhone {
    // 替换掉空格
    NSString * telNumber = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 手机号为11位
    if (telNumber.length != 11) {
        return NO;
    }
    // 验证手机格式
    else {
        /**
         移动号段正则表达式
         134(0-8)、135、136、137、138、139、147、150、
         151、152、157、158、159、178、182、183、184、
         187、188、198
         */
        NSString * CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8])|(198))\\d{8}|(1705)\\d{7}$";
        BOOL isMatch1 = [NSPredicate ymCheckStr:self matchesWithRegex:CM_NUM];
        
        /**
         联通号段正则表达式
         130、131、132、145、152、155、156、166、175、176、185、186
         */
        NSString * CU_NUM = @"^((13[0-2])|(145)|(152)|(15[5-6])|(166)|(17[5,6])|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        BOOL isMatch2 = [NSPredicate ymCheckStr:self matchesWithRegex:CU_NUM];
        
        /**
         电信号段正则表达式
         133、149、153、171、173、177、180、181、189、191、199
         */
        NSString *CT_NUM = @"^((133)|(149)|(153)|(17[1,3,7])|(18[0,1,9])|(19[1,9]))\\d{8}$";
        BOOL isMatch3 = [NSPredicate ymCheckStr:self matchesWithRegex:CT_NUM];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else {
            return NO;
        }
    }
}

///** 是否为18位身份证 */
//- (BOOL)ymValidateIdentity {
//    // 身份证正则表达式(18位)
//    NSString * regex = @"^[1-9]\\d{5}(19\\d{2}|[2-9]\\d{3})((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])(\\d{4}|\\d{3}X)$";
//    NSString * identity = [self uppercaseString];
//    if (![NSPredicate ymCheckStr:identity matchesWithRegex:regex]) {
//        return NO;
//    }
//
//    // 最后一位身份证的号码
//    NSString * stard = @"10X98765432";
//
//    // 1-17系数
//    NSArray * first = @[@7, @9, @10, @5, @8, @4, @2, @1, @6, @3, @7, @9, @10, @5, @8, @4, @2];
//
//    NSString * yearStr = [self substringWithRange:NSMakeRange(6, 4)];
//    NSString * monthStr = [self substringWithRange:NSMakeRange(10, 2)];
//    NSString * dayStr = [self substringWithRange:NSMakeRange(12, 2)];
//    NSString * birthdayStr = [self substringWithRange:NSMakeRange(6, 8)];
//    NSString * dateStr = [NSString stringWithFormat:@"%@/%@/%@",yearStr, monthStr, dayStr];
//    NSString * newDateStr = [dateStr ymDateStrWithFormatter:@"yyyyMMdd" originFormatter:@"yyyy/MM/dd"];
//
//    // 校验日期是否合法
//    if (![birthdayStr isEqual:newDateStr]) {
//        return NO;
//    }
//
//    NSInteger sum = 0;
//    for (NSInteger i = 0; i < self.length - 1; i++) {
//        sum += [[self substringWithRange:NSMakeRange(i, 1)] integerValue] *
//        [first[i] integerValue];
//    }
//
//    NSInteger result = sum % 11;
//
//    // 计算出来的最后一位身份证号码
//    NSString * last = [stard substringWithRange:NSMakeRange(result, 1)];
//    if ([[[self substringWithRange:NSMakeRange(self.length - 1, 1)] uppercaseString] isEqual:last]) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

/** 验证邮箱 */
- (BOOL)ymValidateEmail {
    NSString * regex = @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$";
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/** 验证整数金额 */
- (BOOL)ymValidateMoneyInt {
    NSString * regex = @"^[1-9]{1}[0-9]*$";
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/** 验证小数金额 */
- (BOOL)ymValidateMoneyDouble {
    NSString * regex = @"^(([0-9]*\\.\\d{0,2})|([0-9]{1}))$";
    return [NSPredicate ymCheckStr:self matchesWithRegex:regex];
}

/** 判断CIDRIP：如192.168.0.1/32 */
- (BOOL)ymValidateCIDR {
    // 将IP和区间分离，判断是否都存在
    NSArray * array = [self componentsSeparatedByString:@"/"];
    if ([array count] == 2) {
        NSString * IP = [array firstObject];
        if (![IP ymValidateIP]) {
            return NO;
        }
    } else {
        return NO;
    }
    
    // 判断/后的数字是否在32位以内，如果是则为CRDRIP
    if ([[array lastObject] integerValue] <= 32) {
        return YES;
    }
    return NO;
}

/** 验证IP */
- (BOOL)ymValidateIP {
    NSArray * array = [self componentsSeparatedByString:@"."];
    if ([array count] != 4) {
        return NO;
    }
    
    for (NSString * number in array) {
        if ([number integerValue] > 255) {
            return NO;
        } else if (![number ymValidatePureNumber]) {
            return NO;
        }
    }
    
    return YES;
}

///**
// 验证IP是否在某个范围内
// tip: startIP十进制必须小于endIP十进制
// @param startIP 开始IP
// @param endIP   结束IP
// @return 是否在IP范围内
// */
//- (BOOL)ymValidateIPInStartIP:(NSString *)startIP endIP:(NSString *)endIP {
//    // 验证是否为IP格式
//    if (![self ymValidateIP] || ![startIP ymValidateIP] || ![endIP ymValidateIP]) {
//        return NO;
//    }
//
//    NSInteger selfIPDec = [NSString ymDecimalFromIP:self reverse:NO];
//    NSInteger startIPDec = [NSString ymDecimalFromIP:startIP reverse:NO];
//    NSInteger endIPDec = [NSString ymDecimalFromIP:endIP reverse:NO];
//    if (startIPDec < selfIPDec && selfIPDec < endIPDec) {
//        return YES;
//    }
//    return NO;
//}

#pragma mark - 文字Unicode
+ (NSString *)chineseUnicode {
    NSArray * chineseUnicodes = @[@"\\u4E00-\\u9FA5",
                                  @"\\u9FA6-\\u9FEF",
                                  @"\\u3400-\\u4DB5",
                                  //                                  @"\\u20000-\\u2A6D6",
                                  //                                  @"\\u2A700-\\u2B734",
                                  //                                  @"\\u2B740-\\u2B81D",
                                  //                                  @"\\u2B820-\\u2CEA1",
                                  //                                  @"\\u2CEB0-\\u2EBE0",
                                  @"\\u2F00-\\u2FD5",
                                  @"\\u2E80-\\u2EF3",
                                  @"\\uF900-\\uFAD9",
                                  @"\\u2F80-\\u2FA1",
                                  @"\\uE815-\\uE86F",
                                  @"\\uE400-\\uE5E8",
                                  @"\\uE600-\\uE6CF",
                                  @"\\u31C0-\\u31E3",
                                  @"\\u2FF0-\\u2FFB",
                                  @"\\u3105-\\u312F",
                                  @"\\u31A0-\\u31BA",
                                  @"\\u3007"
                                  ];
    NSString * chineseUnicode = @"";
    for (NSString * unicode in chineseUnicodes) {
        chineseUnicode = [NSString stringWithFormat:@"%@%@", chineseUnicode, unicode];
    }
    return chineseUnicode;
}

+ (NSString *)koreanUnicode {
    NSArray * koreanUnicodes = @[@"\uAC00-\uD7AF",
                                 @"\u1100-\u11FF",
                                 @"\u3130-\u318F",
                                 @"\uA490-\uA4CF"];
    NSString * koreanUnicode = @"";
    for (NSString * unicode in koreanUnicodes) {
        koreanUnicode = [NSString stringWithFormat:@"%@%@", koreanUnicode, unicode];
    }
    return koreanUnicode;
}

+ (NSString *)japanUnicode {
    NSArray * japanUnicodes = @[@"\u3040-\u309F",
                                @"\u30A0-\u30FF",
                                @"\u4E00-\u9FBF"];
    
    NSString * japanUnicode = @"";
    for (NSString * unicode in japanUnicodes) {
        japanUnicode = [NSString stringWithFormat:@"%@%@", japanUnicode, unicode];
    }
    return japanUnicode;
}

@end
