//
//  NSData+YMCategory.h
//  wujiVPN
//
//  Created by 黄玉洲 on 2019/1/11.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <Foundation/Foundation.h>
//void *NewBase64Decode(const char *inputBuffer,
//                      size_t length,
//                      size_t *outputLength);
//
//char *NewBase64Encode(const void *inputBuffer,
//                      size_t length, bool separateLines,
//                      size_t *outputLength);


/** 加密/解密 */
typedef NS_ENUM(NSInteger, kCCOperation) {
    /** 加密 */
    kCCOperation_Encrypt,
    /** 解密 */
    kCCOperation_Decrypt,
};

/** 加密模式和填充模式 */
typedef NS_ENUM(NSInteger, kCCOptions) {
    kCCOptions_ECB_PKCS7,
    kCCOptions_PKCS7,
    kCCOptions_CBC,
};

typedef NS_ENUM(NSInteger, kDataDigitType) {
    /** 二进制 */
    kDataDigitType_2 = 1 << 1,
    /** 四进制 */
    kDataDigitType_4 = 1 << 2,
    /** 八进制 */
    kDataDigitType_8 = 1 << 3,
    /** 十进制 */
    kDataDigitType_10 = 10,
    /** 十六进制 */
    kDataDigitType_16 = 1 << 4,
    /** 三十二进制 */
    kDataDigitType_32 = 1 << 5,
    /** 六十四进制 */
    kDataDigitType_64 = 1 << 6,
};

@interface NSData (YMCategory)

#pragma mark - IP
+ (BOOL)getHost:(NSString **)hostPtr
           port:(uint16_t *)portPtr
    fromAddress:(NSData *)address;

#pragma mark - 转化
/**
 NSData转换成指定进制
 @param type 指定进制
 @return 转换后的字符串
 */
- (NSString *)ymToType:(kDataDigitType)type;

///** 十六进制转压缩NSData（如有32个字符会被压缩成16个字符） */
//+ (NSData *)ymCompressionDataFromHexStr:(NSString *)inputString;

/** 十六进制转NSData(该方法会将' '和'\n'转换为'') */
+ (NSData *)ymDataFromHexStr:(NSString *)hexStr;

/**
 字符串转指定编码NSData
 @param str 字符串
 @param encoding 编码
 @return NSData
 */
+ (NSData *)ymDataFromStr:(NSString *)str
                 encoding:(NSStringEncoding)encoding;

#pragma mark Unicode
/**
 *  Unicode转为NSString数据
 *  @return NSString
 */
- (NSString *)ymUnicodeToString;

#pragma mark - Base64转换
/** base64转NSData */
+ (NSData *)ymDataWithBase64:(NSString *)base64;

/** NSData转Base64 */
+ (NSString *)ymBase64WithData:(NSData *)data;

#pragma mark - DES加解密
/**
 文本数据进行DES解密
 @param data 文本NSData
 @param key 密钥
 @return 加密后的NSData
 */
+ (id)ymDESWithData:(id)data
                key:(id)key
          operation:(kCCOperation)operation;

#pragma mark - AES加解密
/**
 AES128/192/256加密、解密
 
 @param data 要加密或解密的内容，必须为NSData 或 NSString
 @param key 密钥，必须为NSData 或 NSString
 @param iv 向量，必须为NSData 或 NSString
 @param AESOptions 加密选项
 @param operation 加密：kCCEncrypt 解密：kCCDecrypt
 @return 处理后的数据
 */
+ (id)ymAESWithData:(id)data
                key:(id)key
                 iv:(id)iv
         AESOptions:(kCCOptions)AESOptions
          operation:(kCCOperation)operation;

#pragma mark - 计算
/// 获取大小(KB)，以1000为基本单位量
- (float)ymSize;
@end
