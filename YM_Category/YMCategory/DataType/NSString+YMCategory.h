//
//  NSString+YMCategory.h
//  YMCategory
//
//  Created by 黄玉洲 on 2018/8/24.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, kReplaceOptions) {
    kReplaceOptionsAll,
    kReplaceOptionsFirst,
    kReplaceOptionsLast
};

@interface NSString (YMCategory)

#pragma mark - Other
#pragma mark 计算字符显示范围
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

#pragma mark 获取字符串长度
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

#pragma mark 截取字符串
/**
 截取字符串（当截取长度只到达emoji的部分字符时，长度会增加至完整截取这个emoji）
 @param range 截取范围
 @return 截取后的字符串
 */
- (NSString *)ymSubstringWithRange:(NSRange)range;

#pragma mark 插入字符串
/// 在指定位置插入字符
/// @param string 插入的字符
/// @param index  插入的位置
- (NSString *)ymInsertString:(NSString *)string atIndex:(NSInteger)index;

/// 每隔n个字符插入指定字符
/// @param string 插入的字符
/// @param interval 间隔值
- (NSString *)ymInsertString:(NSString *)string atInterval:(NSInteger)interval;

#pragma mark 替换字符串
/// 替换字符
/// @param target 要替换的字符
/// @param replacement 替换后的字符
- (NSString *)ymStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement;

/// 替换字符
/// @param target 要替换的字符
/// @param replacement 替换后的字符
/// @param options 替换位置
- (NSString *)ymStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(kReplaceOptions)options;

#pragma mark 判断非空字符
/** 验证是否为空字符串 */
+ (BOOL)ymValidateNull:(NSString *)str;

/** 验证字符串非空，如果是空的会返回@""*/
+ (NSString *)ymNullToString:(NSString *)string;

@end

#pragma mark - 字符转换
@interface NSString (Conversion)

#pragma mark Unicode
/**
 *  转为Unicode数据(不移除前两位大端十六进制)
 *  @return Unicode
 */
- (NSData *)ymToUnicode;

/**
 *  转为Unicode数据
 *  @property remove 是否移除前两位大端十六进制
 *  @return Unicode
 */
- (NSData *)ymToUnicode:(BOOL)removeBigEndian;

#pragma mark MD5
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

#pragma mark AES
/**
 AES加密(ECB_PKCS7)
 tip: 字符串需要为base64
 @param key 密钥
 @param iv  向量
 @return 加密后的字符串
 */
- (NSString *)ymAES_EncryptWithKey:(NSString *)key
                                iv:(NSString *)iv;

/**
 AES加密(ECB_PKCS7)
 tip: 字符串需要为base64
 @param key 密钥
 @param iv  向量
 @return 解密后的字符串
 */
- (NSString *)ymAES_DecryptWithKey:(NSString *)key
                                iv:(NSString *)iv;

#pragma mark 字符串转码
/** 字符串编码UTF8 */
- (NSString *)ymEmojiEncoding;

/** 字符串解码UTF8 */
- (NSString *)ymEmojiDecoding;

#pragma mark 密文字符串
/**
 字符加密文
 @param range 加密范围
 @param character 替换字符
 @return 加密后的字符串
 */
- (NSString *)ymEncryptionWithRange:(NSRange)range
                          character:(NSString *)character;


#pragma mark 简体繁体转换
/// 中文简体转繁体
- (NSString *)ymSimplifiedToTraditional;

/// 中文繁体转简体
- (NSString *)ymTraditionalToSimplified;

/// 获取首字母
- (NSString *)ymFirstLetter;

/// 整段拼音
- (NSString *)ymPinyin:(BOOL)removeBlankSpace;

@end


#pragma mark - IP相关
@interface NSString (YMParsingExtension)

#pragma mark IP获取
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
 获取CIRD
 @param fromIP IP的开始位置（192.168.0.1格式）
 @param toIP IP的结束位置（192.168.0.1格式）
 @return 返回类似"192.168.0.1/32" 格式的IP
 */
+ (NSArray <NSString *> *)ymCIDRFromIP:(NSString *)fromIP
                                  toIP:(NSString *)toIP;

/**
 从CIRD中获取IP范围
 @param CIDR 类似"192.168.0.1/32"
 @return 返回IP区间，数组中有且必定为两个IP，如[@"192.168.0.1", @"192.168.0.2"]
 */
+ (NSArray <NSString *> *)ymIPFromCIDR:(NSString *)CIDR;

#pragma mark IP转换
/** 从Data中获取IP，Data必须为IP转为十六进制后的Data */
+ (NSString *)ymIPFromData:(NSData *)data;

/** 从Data中获取Port，Data必须为Port转为十六进制后的Data */
+ (NSString *)ymPortFromData:(NSData *)data;

/** 二进制转化为IP */
+ (NSString *)ymIPFromBinary:(NSString *)binaryStr reverse:(BOOL)reverse;

/** 十进制转化为IP */
+ (NSString *)ymIPFromDecimal:(NSInteger)decimal reverse:(BOOL)reverse;

/** 十六进制转化为IP */
+ (NSString *)ymIPFromHex:(NSString *)hex reverse:(BOOL)reverse;

/** IP转化为二进制 */
+ (NSString *)ymBinaryFromIP:(NSString *)ip reverse:(BOOL)reverse;

/** IP转化为十进制 */
+ (NSInteger)ymDecimalFromIP:(NSString *)ip reverse:(BOOL)reverse;

/** IP转化为十六进制 */
+ (NSString *)ymHexFromIP:(NSString *)ip reverse:(BOOL)reverse;
@end

#pragma mark - NSString 进制转换

typedef NS_ENUM(NSInteger, kDigitType) {
    /** 二进制 */
    kDigitType_2 = 1 << 1,
    /** 四进制 */
    kDigitType_4 = 1 << 2,
    /** 八进制 */
    kDigitType_8 = 1 << 3,
    /** 十进制 */
    kDigitType_10 = 10,
    /** 十六进制 */
    kDigitType_16 = 1 << 4,
    /** 三十二进制 */
    kDigitType_32 = 1 << 5,
    /** 六十四进制 */
    kDigitType_64 = 1 << 6,
};

@interface NSString (YMSystemConversionExtension)


/**
 二进制转换为指定进制
 @param binary 二进制
 @param type 进制数类型
 @return 转换后的字符
 */
+ (NSString *)ymBin:(NSString *)binary
             toType:(kDigitType)type;

/**
 十进制转换为指定进制
 @param decimal 十进制
 @param type 进制数类型
 @return 转换后的字符
 */
+ (NSString *)ymDec:(NSInteger)decimal toType:(kDigitType)type;

/**
十进制转换为指定进制
@param decimal 十进制
@param type 进制数类型
@param length 每节长度(如果不足则补0，如果超过则求得余数，补余数个数0)
@return 转换后的字符
*/
+ (NSString *)ymDec:(NSInteger)decimal
             toType:(kDigitType)type
             length:(NSInteger)length;

/**
 十六进制转为指定进制
 @param hexadecimal 十六进制
 @param type 进制数类型
 @return 转换后的字符
 */
+ (NSString *)ymHex:(NSString *)hexadecimal
             toType:(kDigitType)type;


@end

#pragma mark - NSString Data
@interface NSString (YMDataExtension)

/** NSData转十六进制 */
+ (NSString *)ymHexStrFromData:(NSData *)data;

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
- (NSString *)ymDateStrWithFormatter:(NSString *)formatter
                     originFormatter:(NSString *)originFormatter;

/**
 日期格式化
 self格式为1994-03-23 01:01:01的字符串
 @param formatter 指定规则格式化
 @return NSString
 */
- (NSDate *)ymDateWithFormatter:(NSString *)formatter;
/**
 获取与当前时间的时间偏移量（秒）
 @return 时间偏移量
 */
- (NSInteger)ymTimeOffsetFromNow;

/**
 获取与指定时间的时间偏移量（秒）
 @param timeStamp 指定时间
 @return 时间偏移量
 */
- (NSInteger)ymTimeOffsetFromTimeStamp:(NSString *)timeStamp;

/**
 将秒数转换为HH:mm:ss格式
 @return 格式化时间
 */
- (NSString *)ymTimeFormater;

/**
 时间戳转时间格式化
 @param formatter 格式化
 @return 格式化后的字符
 */
- (NSString *)ymTimeFormatter:(NSString *)formatter;

@end

#pragma mark - NSString 验证类目
typedef void (^RequestCompleteBlock)(BOOL isBank);
typedef void (^RequestFailBlock)(NSError * error);
@interface NSString (YMPredicateCategory)

#pragma mark - 验证银行卡（https://blog.csdn.net/yqwang75457/article/details/72627542）
/** 网络验证是否为银行卡号 */
- (void)ymValidateBankCardComplete:(RequestCompleteBlock)completeBlock
                              fail:(RequestFailBlock)failBlock;

/**
 验证是否为银行卡号
 luhn校验规则：16位银行卡号（19位通用）
 1.将未带校验位的 15（或18）位卡号从右依次编号 1 到 15（18），位于奇数位号上的数字乘以 2。
 2.将奇位乘积的个十位全部相加，再加上所有偶数位上的数字。
 3.将加法和加上校验位能被 10 整除。
 */
- (BOOL)ymValidateBankCard;


@end
#pragma clang diagnostic pop
#pragma mark - NSString 属性转换
@interface NSString (YMProperty)

#pragma mark To
/**
NSString转NSDictionary
@return NSString
*/
- (NSDictionary *)ymToDictionary;

/**
NSString转NSArray
@return NSString
*/
- (NSArray *)ymToArray;

/// NSString转ASCII
- (int)ymToAscii;

#pragma mark From
/// ASCII转NSString
/// @param ascii 传入int(65)型或者char('a')型
+ (NSString *)ymFromAscii:(int)ascii;

@end


