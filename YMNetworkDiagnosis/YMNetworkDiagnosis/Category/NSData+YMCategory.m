//
//  NSData+YMCategory.m
//  wujiVPN
//
//  Created by 黄玉洲 on 2019/1/11.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import "NSData+YMCategory.h"
#import <CommonCrypto/CommonCryptor.h>

static unsigned char base64EncodeLookup[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
#define xx 65

static unsigned char base64DecodeLookup[256] =
{
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 62, xx, xx, xx, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xx, xx, xx, xx, xx, xx,
    xx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xx, xx, xx, xx, xx,
    xx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
};

#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4

void *NewBase64Decode(const char *inputBuffer, size_t length, size_t *outputLength) {
    if (length == -1) {
        length = strlen(inputBuffer);
    }
    
    size_t outputBufferSize = (length / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE;
    unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
    size_t i = 0;
    size_t j = 0;
    while (i < length) {
        unsigned char accumulated[BASE64_UNIT_SIZE];
        size_t accumulateIndex = 0;
        while (i < length) {
            unsigned char decode = base64DecodeLookup[inputBuffer[i++]];
            if (decode != xx) {
                accumulated[accumulateIndex] = decode;
                accumulateIndex++;
                if (accumulateIndex == BASE64_UNIT_SIZE) {
                    break;
                }
            }
        }
        
        //
        // Store the 6 bits from each of the 4 characters as 3 bytes
        //
        
        outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
        outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);
        outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
        j += accumulateIndex - 1;
    }
    
    if (outputLength) {
        *outputLength = j;
    }
    return outputBuffer;
}

char *NewBase64Encode(const void *buffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength) {
    const unsigned char *inputBuffer = (const unsigned char *)buffer;
#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2
    
    size_t outputBufferSize =
    ((length / BINARY_UNIT_SIZE) + ((length % BINARY_UNIT_SIZE) ? 1 : 0)) * BASE64_UNIT_SIZE;
    
    if (separateLines) {
        outputBufferSize += (outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
    }
    
    outputBufferSize += 1;
    char *outputBuffer = (char *)malloc(outputBufferSize);
    if (!outputBuffer) {
        return NULL;
    }
    
    size_t i = 0;
    size_t j = 0;
    const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
    size_t lineEnd = lineLength;
    
    while (true) {
        if (lineEnd > length) {
            lineEnd = length;
        }
        
        for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE) {
            
            outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
            
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                                   
                                                   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
            
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
                                                   
                                                   | ((inputBuffer[i + 2] & 0xC0) >> 6)];
            
            outputBuffer[j++] = base64EncodeLookup[inputBuffer[i + 2] & 0x3F];
            
        }
        
        if (lineEnd == length) {
            break;
        }
        
        outputBuffer[j++] = '\r';
        outputBuffer[j++] = '\n';
        lineEnd += lineLength;
    }
    
    if (i + 1 < length) {
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                               | ((inputBuffer[i + 1] & 0xF0) >> 4)];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
        outputBuffer[j++] = '=';
    }
    
    else if (i < length) {
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
        outputBuffer[j++] = '=';
        outputBuffer[j++] = '=';
    }
    outputBuffer[j] = 0;
    if (outputLength) {
        *outputLength = j;
    }
    return outputBuffer;
}

@implementation NSData (YMCategory)

#pragma mark - 转化
/** NSData转十六进制 */
- (NSString *)ymDataToHexStr {
    NSMutableString * mStr = [NSMutableString stringWithCapacity:self.length * 2];
    
    int byte = 0;
    for (NSInteger i = 0; i < self.length; i++) {
        [self getBytes:&byte range:NSMakeRange(i, 1)];
        [mStr appendFormat:@"%02x", byte];
    }
    return mStr;
}

#pragma mark - Base64
/** base64转NSData */
+ (NSData *)ymDataFromBase64:(NSString *)base64 {
    NSData *data = [base64 dataUsingEncoding:NSASCIIStringEncoding];
    size_t outputLength;
    void *outputBuffer = NewBase64Decode([data bytes], [data length], &outputLength);
    NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
    free(outputBuffer);
    return result;
}

/** NSData转base64 */
- (NSString *)ymDataToBase64 {
    size_t outputLength;
    char *outputBuffer = NewBase64Encode([self bytes], [self length], true, &outputLength);
    NSString *result = [[NSString alloc] initWithBytes:outputBuffer length:outputLength encoding:NSASCIIStringEncoding];
    free(outputBuffer);
    return result;
}


/**
 文本数据进行DES加密
 @param data 文本NSData
 @param key 密钥
 @return 加密后的NSData
 */
+ (NSData *)ymDESEncrypt:(NSData *)data WithKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}


/**
 文本数据进行DES解密
 @param data 文本NSData
 @param key 密钥
 @return 加密后的NSData
 */
+ (NSData *)ymDESDecrypt:(NSData *)data WithKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

#pragma mark - AES128
/**
 AES128加密、解密
 @param data    要加密、解密的内容
 @param keyData 密钥(16位)
 @param ivData  向量(16位)
 @param operation 加密：kCCEncrypt 解密：kCCDecrypt
 @return 加密后的数据
 */
+ (id)ymAES128WithData:(NSData *)data
               keyData:(NSData *)keyData
                ivData:(NSData *)ivData
             operation:(kAESOperation)operation {
    
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    // 进行加密
    CCCryptorStatus cryptStatus =
    CCCrypt(operation,           // kCCEncrypt：加密; kCCDecrypt：解密
            kCCAlgorithmAES128,  // 加解密标准（AES、DES）
            0x0000,              // 选项分组密码算法
            [keyData bytes],     // 密钥，加密和解密的密钥必须一致
            kCCKeySizeAES128,    // 密钥长度
            [ivData bytes],      // 可选的初始矢量
            [data bytes],        // 数据的存储单元
            data.length,         // 数据的大小
            buffer,              // 用于返回数据
            bufferSize,          // 返回数据的大小
            &numBytesEncrypted); // 加密字节
    
    if (cryptStatus == kCCSuccess) {
        NSData * aes128_Data = [NSData dataWithBytesNoCopy:buffer
                                                    length:numBytesEncrypted];
        return aes128_Data;
    } else {
        NSLog(@"Error: \(cryptStatus)");
    }
    free(buffer);
    return nil;
}

/**
 AES128加密、解密
 @param str    要加密、解密的内容
 @param keyStr 密钥(16位)
 @param ivStr  向量(16位)
 @param operation 加密：kCCEncrypt 解密：kCCDecrypt
 @return 加密后的数据
 */
+ (NSData *)ymAES128WithStr:(NSString *)str
                     keyStr:(NSString *)keyStr
                      ivStr:(NSString *)ivStr
                  operation:(kAESOperation)operation {
    
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [keyStr getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [ivStr getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          [keyStr length],
                                          ivPtr,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData * aes128_Data = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return aes128_Data;
    }
    free(buffer);
    return nil;
}

@end
