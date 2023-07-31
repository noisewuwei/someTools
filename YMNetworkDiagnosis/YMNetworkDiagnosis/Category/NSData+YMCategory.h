//
//  NSData+YMCategory.h
//  wujiVPN
//
//  Created by 黄玉洲 on 2019/1/11.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <Foundation/Foundation.h>
void *NewBase64Decode(const char *inputBuffer, size_t length, size_t *outputLength);
char *NewBase64Encode(const void *inputBuffer, size_t length, bool separateLines, size_t *outputLength);


typedef NS_ENUM(NSInteger, kAESOperation) {
    /** 加密 */
    kAESOperation_Encrypt = 0,
    /** 解密 */
    kAESOperation_Decrypt
};
@interface NSData (YMCategory)

#pragma mark - 转化
/** NSData转十六进制 */
- (NSString *)ymDataToHexStr;

#pragma mark - Base64
/** base64转NSData */
+ (NSData *)ymDataFromBase64:(NSString *)base64;

/** NSData转base64 */
- (NSString *)ymDataToBase64;

/**
 文本数据进行DES加密
 @param data 文本NSData
 @param key 密钥
 @return 加密后的NSData
 */
+ (NSData *)ymDESEncrypt:(NSData *)data WithKey:(NSString *)key;

/**
 文本数据进行DES解密
 @param data 文本NSData
 @param key 密钥
 @return 加密后的NSData
 */
+ (NSData *)ymDESDecrypt:(NSData *)data WithKey:(NSString *)key;

#pragma mark - AES128
/**
 AES128加密、解密
 @param data    要加密、解密的内容
 @param keyData 密钥
 @param ivData  向量
 @param operation 加密：kCCEncrypt 解密：kCCDecrypt
 @return 加密后的数据
 */
+ (NSData *)ymAES128WithData:(NSData *)data
                     keyData:(NSData *)keyData
                      ivData:(NSData *)ivData
                   operation:(kAESOperation)operation;

/**
 AES128加密、解密
 @param str    要加密、解密的内容
 @param keyStr 密钥
 @param ivStr  向量
 @param operation 加密：kCCEncrypt 解密：kCCDecrypt
 @return 加密后的数据
 */
+ (NSData *)ymAES128WithStr:(NSString *)str
                     keyStr:(NSString *)keyStr
                      ivStr:(NSString *)ivStr
                  operation:(kAESOperation)operation;
@end
