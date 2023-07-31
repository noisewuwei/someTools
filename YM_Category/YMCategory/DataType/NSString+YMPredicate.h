//
//  NSString+YMPredicate.h
//  YMCategory
//
//  Created by 黄玉洲 on 2020/3/10.
//  Copyright © 2020年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (YMPredicate)

#pragma mark - 便利验证
/** 验证是否为纯数字 */
- (BOOL)ymValidatePureNumber;

/** 验证是否包含数字 */
- (BOOL)ymValidateHaveNumber;

/** 验证是否为整型 */
- (BOOL)ymValidatePureInt;

/** 验证是否为浮点型 */
- (BOOL)ymValidatePureFloat;

/** 验证是否有小数部分（几xxx.yyy，yyy部分是否大于0） */
- (BOOL)ymValidateDecimal;

/** 验证是否为特殊符号 */
- (BOOL)ymValidateHaveSpecialSymbols;

/** 验证是否为纯字母 */
- (BOOL)ymValidatePureWord;

/** 验证是否为纯Emoji */
- (BOOL)ymValidatePureEmoji;

/** 验证是否包含Emoji */
- (BOOL)ymValidateHaveEmoji;

/**
 验证是否包含或全为汉字
 @param isPure 是否全为汉字
 @return 是否符合验证
 */
- (BOOL)ymValidateChinese:(BOOL)isPure;

/**
 验证是否包含或全为韩文
 @param isPure 是否全为韩文
 @return 是否符合验证
 */
- (BOOL)ymValidateKorean:(BOOL)isPure;

/**
 验证字符串是否包含日文或者全是日文
 @param isPure 包含或者全是日文
 @return 是否符合条件
 */
- (BOOL)ymValidateJapan:(BOOL)isPure;

/** 是否为手机号码 */
- (BOOL)ymValidatePhone;

/** 是否为18位身份证 */
- (BOOL)ymValidateIdentity;

/** 验证邮箱 */
- (BOOL)ymValidateEmail;

/** 验证整数金额 */
- (BOOL)ymValidateMoneyInt;

/** 验证小数金额 */
- (BOOL)ymValidateMoneyDouble;

/** 判断CIDRIP：如192.168.0.1:32 */
- (BOOL)ymValidateCIDR;

/** 验证IP */
- (BOOL)ymValidateIP;

/**
 验证IP是否在某个范围内
 tip: startIP十进制必须小于endIP十进制
 @param startIP 开始IP
 @param endIP   结束IP
 @return 是否在IP范围内
 */
- (BOOL)ymValidateIPInStartIP:(NSString *)startIP endIP:(NSString *)endIP;

#pragma mark - 文字Unicode
/// 中文
+ (NSString *)chineseUnicode;

/// 韩文
+ (NSString *)koreanUnicode;

/// 日文
+ (NSString *)japanUnicode;

@end

NS_ASSUME_NONNULL_END
