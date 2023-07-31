//
//  NSString+YMCategory.h
//  YMCategory
//
//  Created by 黄玉洲 on 2018/8/24.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSString (YMCategory)

#pragma mark - 计算字符
/**
 获取字符串所需要的高度
 @param width          限制宽度
 @param font           字体
 @param numberOfLines  限制行数（如果是0则不限制行数）
 @return 所需高度
 */
- (CGFloat)ymStringForHeightWithWidth:(CGFloat)width
                                  font:(UIFont *)font
                limitedToNumberOfLines:(NSInteger)numberOfLines;

/**
 获取字符串所需要的高度
 @param width          限制宽度
 @param attribute      文本属性
 @param numberOfLines  限制行数（如果是0则不限制行数）
 @return 所需高度
 */
- (CGFloat)ymStringForHeightWithWidth:(CGFloat)width
                             attribute:(NSAttributedString *)attribute
                limitedToNumberOfLines:(NSInteger)numberOfLines;

/**
 获取适应大小
 @param size 最大能显示的大小范围
 @param font 字体大小
 @return 返回适应大小
 */
- (CGSize)ym_stringForSizeWithSize:(CGSize)size
                              font:(UIFont *)font;

#pragma mark - 获取字符串长度
/** 获取真实长度（如部分emoji的长度为2，该方法中会返回1） */
- (NSUInteger)ym_length;

/**
 根据枚举进行字符的遍历，获取字符、段落、单词等长度
 @param option 搜索方式
 NSStringEnumerationByLines       -- 行数
 NSStringEnumerationByParagraphs  -- 段落数
 NSStringEnumerationByComposedCharacterSequences -- 字符数
 NSStringEnumerationByWords       -- 单词数
 NSStringEnumerationBySentences   -- 句子数
 附加选项
 NSStringEnumerationReverse              -- 反向遍历
 NSStringEnumerationSubstringNotRequired -- 不必要的子字符串
 NSStringEnumerationLocalized            -- 本地化
 @return 数量
 */
- (NSUInteger)ymLengthWithOption:(NSStringEnumerationOptions)option;

#pragma mark - 截取字符串
/**
 截取字符串（当截取长度只到达emoji的部分字符时，长度会增加至完整截取这个emoji）
 @param range 截取范围
 @return 截取后的字符串
 */
- (NSString *)ymSubstringWithRange:(NSRange)range;

#pragma mark - 判断非空字符
/** 验证是否为空字符串 */
+ (BOOL)validateNull:(NSString *)str;

/** 验证字符串非空，如果是空的会返回@""*/
+ (NSString *)nullToString:(NSString *)string;

#pragma mark - 密文字符串
/**
 字符加密文
 @param range 加密范围
 @param character 替换字符
 @return 加密后的字符串
 */
- (NSString *)encryptionWithRange:(NSRange)range
                        character:(NSString *)character;

#pragma mark - MD5
/**
 *  MD5加密, 32位 小写
 *  @return 返回加密后的字符串
 */
- (NSString *)ymToMD5ForLower32;

/**
 *  MD5加密, 32位 大写
 *  @return 返回加密后的字符串
 */
- (NSString *)ymToMD5ForUpper32;

#pragma mark - UTF8
/** 字符串编码UTF8 */
- (NSString *)emojiCoding;

/** 字符串解码UTF8 */
- (NSString *)emojiDecoding;

@end

#pragma mark - NSString 解析
@interface NSString (YMParsingExtension)

/** 获取域名真实IP */
- (NSArray <NSString *> *)ymDomainToRealIP;

/**
 空缺补字符串（如1000，最大长度8位，补0 ——> 00001000）
 @param maxLength 最大长度
 @param fillStr 填补的字符串
 @return 填补后的字符串
 */
- (NSString *)ymFillStrWithMaxLength:(NSInteger)maxLength
                             fillStr:(NSString *)fillStr;

/**
 获取CIRD格式IP
 @param fromIP IP的开始位置（192.168.0.1格式）
 @param toIP IP的结束位置（192.168.0.1格式）
 @return 返回类似"192.168.0.1/32" 格式的IP
 */
+ (NSArray <NSString *> *)ymCIDRIPFromIP:(NSString *)fromIP
                                    toIP:(NSString *)toIP;

@end


#pragma mark - NSString 进制转换
@interface NSString (YMSystemConversionExtension)
/** 十进制转换为二进制 */
+ (NSString *)ymGetBinaryFromDecimal:(NSInteger)decimal;

/** 十进制转换十六进制 */
+ (NSString *)ymGetHexFromDecimal:(NSInteger)decimal;

/** 十六进制转换十进制 */
+ (NSString *)ymGetDecimalFromHex:(NSString *)hex;

/** 二进制转换成十六进制 */
+ (NSString *)ymGetHexFromBinary:(NSString *)binary;

/** 十六进制转换为二进制 */
+ (NSString *)ymGetBinaryFromHex:(NSString *)hex;

/** 二进制转换为十进制 */
+ (NSInteger)ymGetDecimalFromBinary:(NSString *)binary;

@end

#pragma mark - NSString Data
@interface NSString (YMDataExtension)

/** 十六进制字符串转NSData */
- (NSData *)ymHexStrToData;

/**
 字符串转NSData
 @param encoding 编码类型
 @return 转换后的数据
 */
- (NSData *)ymToData:(NSStringEncoding)encoding;

@end

#pragma mark - NSString 时间类目
@interface NSString (YMDateExtension)
/**
 日期格式化
 该方法可返回指定规则的时间字符串，self应为时间格式的字符串（如'1994-03-23...'）或者时间戳（秒为单位）
 @param formatter        指定规则格式化
 @param originFormatter  原始格式，当self不为时间戳时才需要传
 @return 格式化后的日期字符串
 */
- (NSString *)dateStrWithFormatter:(NSString *)formatter
                   originFormatter:(NSString *)originFormatter;


/**
 日期格式化
 self格式为1994-03-23 01:01:01的字符串
 @param formatter 指定规则格式化
 @return NSString
 */
- (NSDate *)dateWithFormatter:(NSString *)formatter;

/**
 获取与当前时间的时间偏移量（秒）
 @return 时间偏移量
 */
- (NSInteger)timeOffsetFromNow;

/**
 获取与指定时间的时间偏移量（秒）
 @param timeStamp 指定时间
 @return 时间偏移量
 */
- (NSInteger)timeOffsetFromTimeStamp:(NSString *)timeStamp;

/**
 将秒数转换为HH:mm:ss格式
 @return 格式化时间
 */
- (NSString *)timeFormater;

/**
 时间戳转时间格式化
 @param formatter 格式化
 @return 格式化后的字符
 */
- (NSString *)timeFormatter:(NSString *)formatter;

@end

#pragma mark - NSString 验证类目
typedef void (^RequestCompleteBlock)(BOOL isBankBlock);
typedef void (^RequestFailBlock)(NSError * error);
@interface NSString (YMPredicateCategory) 
#pragma mark - 便利验证
/** 验证是否为纯数字 */
- (BOOL)validatePureNumber;

/** 验证是否包含数字 */
- (BOOL)validateHaveNumber;

/** 验证是否为整型 */
- (BOOL)validatePureInt;

/** 验证是否为浮点型 */
- (BOOL)validatePureFloat;

/** 验证是否为特殊符号 */
- (BOOL)validateHaveSpecialSymbols;

/** 验证是否为纯字母 */
- (BOOL)validatePureWord;

/** 验证是否为纯Emoji */
- (BOOL)validatePureEmoji;

/** 验证是否包含Emoji */
- (BOOL)validateHaveEmoji;

/**
 验证是否包含或全为汉字
 @param isPure 是否全为汉字
 @return 是否符合验证
 */
- (BOOL)validateChinese:(BOOL)isPure;

/**
 验证是否包含或全为韩文
 @param isPure 是否全为韩文
 @return 是否符合验证
 */
- (BOOL)validateKorean:(BOOL)isPure;

/**
 验证字符串是否包含日文或者全是日文
 @param isPure 包含或者全是日文
 @return 是否符合条件
 */
- (BOOL)validateJapan:(BOOL)isPure;

/** 是否为手机号码 */
- (BOOL)validatePhone;

/** 是否为18位身份证 */
- (BOOL)validateIdentity;

/** 验证邮箱 */
- (BOOL)validateEmail;

/** 验证整数金额 */
- (BOOL)validateMoneyInt;

/** 验证小数金额 */
- (BOOL)validateMoneyDouble;

#pragma mark - 验证银行卡
/** 通过Alipay验证是否为银行卡号 */
- (void)validateBankCardComplete:(RequestCompleteBlock)complete
                            fail:(RequestFailBlock)fail;

/**
 验证是否为银行卡号
 luhn校验规则：16位银行卡号（19位通用）
 1.将未带校验位的 15（或18）位卡号从右依次编号 1 到 15（18），位于奇数位号上的数字乘以 2。
 2.将奇位乘积的个十位全部相加，再加上所有偶数位上的数字。
 3.将加法和加上校验位能被 10 整除。
 */
- (BOOL)validateBankCard;

#pragma mark - 自定义验证
/**
 根据指定格式进行验证
 @param regex 验证格式
 @return 验证结果
 */
- (BOOL)validateWithRegex:(NSString *)regex;

@end


