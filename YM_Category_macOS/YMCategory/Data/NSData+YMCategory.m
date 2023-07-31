//
//  NSData+YMCategory.m
//  wujiVPN
//
//  Created by 黄玉洲 on 2019/1/11.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import "NSData+YMCategory.h"
#import "NSString+YMCategory.h"
#import <CommonCrypto/CommonCryptor.h>

/** IP相关 */
#import <sys/socket.h>
#import <netdb.h>
#import <arpa/inet.h>

#pragma mark - 枚举
/** 加密方式 */
typedef NS_ENUM(NSInteger, kCCAlgorithm) {
    /** AES 对应kCCBlockSizeAES128 = 16 */
    kCCAlgorithm_AES128 = kCCAlgorithmAES128,
    /** AES同上 */
    kCCAlgorithm_AES = kCCAlgorithmAES,
    /** DES 对应kCCBlockSizeDES = 8 */
    kCCAlgorithm_DES = kCCAlgorithmDES,
    /** 三重DES 对应kCCBlockSize3DES = 8 */
    kCCAlgorithm_3DES = kCCAlgorithm3DES,
    /** CAST 对应kCCBlockSizeCAST = 8 */
    kCCAlgorithm_CAST = kCCAlgorithmCAST,
    /** RC4 流加密 */
    kCCAlgorithm_RC4 = kCCAlgorithmRC4,
    /** RC2 */
    kCCAlgorithm_RC2 = kCCAlgorithmRC2,
    /** Blowfish分组密码 对应kCCBlockSizeBlowfish = 8 */
    kCCAlgorithm_Blowfish = kCCAlgorithmBlowfish,
};

/** 填充模式 */
typedef NS_ENUM(NSInteger, kCCOptionPadding) {
    /** PKCS7填充模式 */
    kCCOptionPadding_PKCS7 = kCCOptionPKCS7Padding,
};

/** 加密模式 */
typedef NS_ENUM(NSInteger, kCCOptionModel) {
    /** CBC加密模式 */
    kCCOptionModel_CBC = 0x0000,
    /** ECB加密模式 */
    kCCOptionModel_ECB = kCCOptionECBMode,
};

/** 块大小 */
typedef NS_ENUM(NSInteger, kCCBlockSize) {
    /** AES */
    kCCBlockSize_AES128 = kCCBlockSizeAES128,
    /** DES */
    kCCBlockSize_DES = kCCBlockSizeDES,
    /** 3DES */
    kCCBlockSize_3DES = kCCBlockSize3DES,
    /** CAST */
    kCCBlockSize_CAST = kCCBlockSizeCAST,
    /** RC2 */
    kCCBlockSize_RC2 = kCCBlockSizeRC2,
    /** Blowfish */
    kCCBlockSize_Blowfish = kCCBlockSizeBlowfish,
};

/** 密钥长度 */
typedef NS_ENUM(NSInteger, kCCKeySize) {
    kCCKeySize_AES128 = kCCKeySizeAES128,
    kCCKeySize_AES192 = kCCKeySizeAES192,
    kCCKeySize_AES256 = kCCKeySizeAES256,
    kCCKeySize_DES = kCCKeySizeDES,
    kCCKeySize_3DES = kCCKeySize3DES,
    kCCKeySize_MinCAST = kCCKeySizeMinCAST,
    kCCKeySize_MaxCAST = kCCKeySizeMaxCAST,
    kCCKeySize_MinRC4 = kCCKeySizeMinRC4,
    kCCKeySize_MaxRC4 = kCCKeySizeMaxRC4,
    kCCKeySize_MinRC2 = kCCKeySizeMinRC2,
    kCCKeySize_MaxRC2 = kCCKeySizeMaxRC2,
    kCCKeySize_MinBlowfish = kCCKeySizeMinBlowfish,
    kCCKeySize_MaxBlowfish = kCCKeySizeMaxBlowfish,
};


#pragma mark - 加密函数
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


@implementation NSData (YMCategory)

+ (void *)NewBase64Decode:(const char *)inputBuffer
                   length:(size_t)length
             outputLength:(size_t *)outputLength {
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

+ (char *)NewBase64Encode:(const void *)buffer
                 length:(size_t)length
          separateLines:(BOOL)separateLines
           outputLength:(size_t *)outputLength {
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

#pragma mark - IP
+ (BOOL)getHost:(NSString **)hostPtr
           port:(uint16_t *)portPtr
    fromAddress:(NSData *)address {
    return [self getHost:hostPtr port:portPtr family:NULL fromAddress:address];
}

+ (BOOL)getHost:(NSString **)hostPtr
           port:(uint16_t *)portPtr
         family:(int *)afPtr
    fromAddress:(NSData *)address {
    if ([address length] >= sizeof(struct sockaddr))
    {
        const struct sockaddr *addrX = (const struct sockaddr *)[address bytes];
        
        if (addrX->sa_family == AF_INET)
        {
            if ([address length] >= sizeof(struct sockaddr_in))
            {
                const struct sockaddr_in *addr4 = (const struct sockaddr_in *)addrX;
                
                if (hostPtr) *hostPtr = [self hostFromSockaddr4:addr4];
                if (portPtr) *portPtr = [self portFromSockaddr4:addr4];
                if (afPtr)   *afPtr   = AF_INET;
                
                return YES;
            }
        }
        else if (addrX->sa_family == AF_INET6)
        {
            if ([address length] >= sizeof(struct sockaddr_in6))
            {
                const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6 *)addrX;
                
                if (hostPtr) *hostPtr = [self hostFromSockaddr6:addr6];
                if (portPtr) *portPtr = [self portFromSockaddr6:addr6];
                if (afPtr)   *afPtr   = AF_INET6;
                
                return YES;
            }
        }
    }
    
    if (hostPtr) *hostPtr = nil;
    if (portPtr) *portPtr = 0;
    if (afPtr)   *afPtr   = AF_UNSPEC;
    
    return NO;
}

+ (NSString *)hostFromSockaddr4:(const struct sockaddr_in *)pSockaddr4 {
    char addrBuf[INET_ADDRSTRLEN];
    
    if (inet_ntop(AF_INET, &pSockaddr4->sin_addr, addrBuf, (socklen_t)sizeof(addrBuf)) == NULL)
    {
        addrBuf[0] = '\0';
    }
    
    return [NSString stringWithCString:addrBuf encoding:NSASCIIStringEncoding];
}

+ (NSString *)hostFromSockaddr6:(const struct sockaddr_in6 *)pSockaddr6 {
    char addrBuf[INET6_ADDRSTRLEN];
    
    if (inet_ntop(AF_INET6, &pSockaddr6->sin6_addr, addrBuf, (socklen_t)sizeof(addrBuf)) == NULL)
    {
        addrBuf[0] = '\0';
    }
    
    return [NSString stringWithCString:addrBuf encoding:NSASCIIStringEncoding];
}

+ (uint16_t)portFromSockaddr4:(const struct sockaddr_in *)pSockaddr4 {
    return ntohs(pSockaddr4->sin_port);
}

+ (uint16_t)portFromSockaddr6:(const struct sockaddr_in6 *)pSockaddr6 {
    return ntohs(pSockaddr6->sin6_port);
}

#pragma mark - 转化
/**
 NSData转换成指定进制
 @param type 指定进制
 @return 转换后的字符串
 */
- (NSString *)ymToType:(kDataDigitType)type {
    // 先将NSData转十六进制，再通过16进制转其他进制
    NSMutableString * mStr = [NSMutableString stringWithCapacity:self.length * 2];
    int byte = 0;
    for (NSInteger i = 0; i < self.length; i++) {
        // 获取Data中每一位的ASCII码并拼接
        [self getBytes:&byte range:NSMakeRange(i, 1)];
        // 02x表示不足两位在高位补0
        [mStr appendFormat:@"%02x", byte];
    }
    if (type == kDataDigitType_16) {
        return mStr;
    } else {
        return [NSString ymHex:mStr toType:(kDigitType)type];
    }
}

///** 十六进制转压缩NSData（如有32个字符会被压缩成16个字符） */
//+ (NSData *)ymCompressionDataFromHexStr:(NSString *)inputString {
//    NSUInteger inLength = [inputString length];
//
//    unichar *inCharacters = alloca(sizeof(unichar) * inLength);
//    [inputString getCharacters:inCharacters range:NSMakeRange(0, inLength)];
//
//    UInt8 *outBytes = malloc(sizeof(UInt8) * ((inLength / 2) + 1));
//
//    NSInteger i, o = 0;
//    UInt8 outByte = 0;
//    for (i = 0; i < inLength; i++) {
//        UInt8 c = inCharacters[i];
//        SInt8 value = -1;
//
//        if (c >= '0' && c <= '9') {
//            value = (c - '0');
//        } else if (c >= 'A' && c <= 'F') {
//            value = 10 + (c - 'A');
//        } else if (c >= 'a' && c <= 'f') {
//            value = 10 + (c - 'a');
//        }
//
//        if (value >= 0) {
//            if (i % 2 == 1) {
//                outBytes[o++] = (outByte << 4) | value;
//                outByte = 0;
//            } else if (i == (inLength - 1)) {
//                outBytes[o++] = value << 4;
//            } else {
//                outByte = value;
//            }
//
//        } else {
//            if (o != 0) break;
//        }
//    }
//
//    return [[NSData alloc] initWithBytesNoCopy:outBytes length:o freeWhenDone:YES];
//}

/** 十六进制转NSData(该方法会将' '和'\n'转换为'') */
+ (NSData *)ymDataFromHexStr:(NSString *)hexStr {
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString * str = hexStr;
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

/**
 字符串转指定编码NSData
 @param str 字符串
 @param encoding 编码
 @return NSData
 */
+ (NSData *)ymDataFromStr:(NSString *)str
                 encoding:(NSStringEncoding)encoding {
    return [str dataUsingEncoding:encoding];
}

#pragma mark Unicode
/**
 *  Unicode转为NSString数据
 *  @return NSString
 */
- (NSString *)ymUnicodeToString {
    NSMutableData * mData = [NSMutableData new];
    NSData * data = [NSData dataWithBytes:"\x00\x00" length:2];
    for (int i = 0; i < self.length-2; i+=2) {
        NSData * tempData = nil;
        if (self.length >= i+2) {
            tempData = [self subdataWithRange:NSMakeRange(i, 2)];
        }
        if (tempData && ![tempData isEqualToData:data]) {
            [mData appendData:tempData];
        }
    }
    
    const unichar *bytes = (const unichar *)[mData bytes];
    int length = mData.length / 2.0;
    NSString * string = [NSString stringWithCharacters:bytes length:length];
    return string;
}


#pragma mark - Base64转换
/** base64转NSData */
+ (NSData *)ymDataWithBase64:(NSString *)base64 {
    NSData *data = [base64 dataUsingEncoding:NSASCIIStringEncoding];
    size_t outputLength;
    void *outputBuffer = [self NewBase64Decode:[data bytes]
                                        length:[data length]
                                  outputLength:&outputLength];
    NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
    free(outputBuffer);
    return result;
}

/** NSData转Base64 */
+ (NSString *)ymBase64WithData:(NSData *)data {
    size_t outputLength = 0;
    char *outputBuffer = [self NewBase64Encode:[data bytes]
                                        length:[data length]
                                 separateLines:true
                                  outputLength:&outputLength];
    NSString *result = [[NSString alloc] initWithBytes:outputBuffer length:outputLength encoding:NSASCIIStringEncoding];
    free(outputBuffer);
    return result;
}

#pragma mark - DES加解密
/**
 文本数据进行DES解密
 @param data 文本NSData
 @param key 密钥
 @return 加密后的NSData
 */
+ (id)ymDESWithData:(id)data
                key:(id)key
          operation:(kCCOperation)operation {
    // 根据data的类型进行内容处理
    NSData * tempData = nil;
    if ([data isKindOfClass:[NSString class]]) {
        tempData = [data dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([data isKindOfClass:[NSData class]]) {
        tempData = data;
    } else {
        return nil;
    }
    
    // 处理key
    NSData * keyData = nil;
    if ([key isKindOfClass:[NSString class]]) {
        keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([key isKindOfClass:[NSData class]]) {
        keyData = key;
    } else {
        return nil;
    }
    
    // 进行加密
    CCOperation op = operation;
    CCAlgorithm alg = kCCAlgorithm_DES;
    CCOptions options = kCCOptionPadding_PKCS7 | kCCOptionModel_ECB;
    const void *key1 = [keyData bytes];
    size_t keyLength = kCCBlockSize_DES;
    const void *iv1 = NULL;
    const void *dataIn = [tempData bytes];
    size_t dataInLength = tempData.length;
    size_t bufferSize = [tempData length] + kCCBlockSize_DES;
    void *buffer = malloc(bufferSize);
    size_t numBytes = 0;
    CCCryptorStatus cryptStatus =
    CCCrypt(op,             // kCCEncrypt：加密; kCCDecrypt：解密
            alg,            // 加解密标准（AES、DES）
            options,        // 选项分组密码算法
            key1,           // 密钥，加密和解密的密钥必须一致
            keyLength,      // 密钥长度
            iv1,            // 可选的初始矢量
            dataIn,         // 数据的存储单元
            dataInLength,   // 数据的大小
            buffer,         // 用于返回数据
            bufferSize,     // 返回数据的大小
            &numBytes);     // 加密字节
    
    if (cryptStatus == kCCSuccess) {
        NSData * aes128_Data = [NSData dataWithBytesNoCopy:buffer
                                                    length:numBytes];
        return aes128_Data;
    } else {
        NSLog(@"ymDESWithData Error: \(cryptStatus)");
    }
    free(buffer);
    return nil;
    return nil;
}

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
          operation:(kCCOperation)operation {
    
    // 根据data的类型进行内容处理
    NSData * tempData = nil;
    if ([data isKindOfClass:[NSString class]]) {
        tempData = [data dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([data isKindOfClass:[NSData class]]) {
        tempData = data;
    } else {
        return nil;
    }
    
    // 处理key
    NSData * keyData = nil;
    if ([key isKindOfClass:[NSString class]]) {
        keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([key isKindOfClass:[NSData class]]) {
        keyData = key;
    } else {
        return nil;
    }
    
    // 处理ivKey
    NSData * ivData = nil;
    if ([iv isKindOfClass:[NSString class]]) {
        ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([iv isKindOfClass:[NSData class]]) {
        ivData = iv;
    } else {
        if (AESOptions == kCCOptions_CBC) {
            return @"缺少向量值";
        }
    }
    
    // 进行加密
    CCOperation op = operation;
    CCAlgorithm alg = kCCAlgorithm_AES;
    CCOptions options = 0;
    if (AESOptions == kCCOptions_ECB_PKCS7) {
        options = kCCOptionPKCS7Padding|kCCOptionECBMode;
    } else if (AESOptions == kCCOptions_PKCS7) {
        options = kCCOptionPadding_PKCS7;
    } else if (AESOptions == kCCOptions_CBC) {
        options = 0x00;
    }
    const void *key1 = [keyData bytes];
    size_t keyLength = keyData.length;
    const void *iv1 = [ivData bytes];
    const void *dataIn = [tempData bytes];
    size_t dataInLength = tempData.length;
    size_t bufferSize = [tempData length] + kCCBlockSize_AES128;
    void *buffer = malloc(bufferSize);
    size_t numBytes = 0;
    CCCryptorStatus cryptStatus =
    CCCrypt(op,             // kCCEncrypt：加密; kCCDecrypt：解密
            alg,            // 加解密标准（AES、DES）
            options,        // 选项分组密码算法
            key1,           // 密钥，加密和解密的密钥必须一致
            keyLength,      // 密钥长度
            iv1,            // 可选的初始矢量
            dataIn,         // 数据的存储单元
            dataInLength,   // 数据的大小
            buffer,         // 用于返回数据
            bufferSize,     // 返回数据的大小
            &numBytes);     // 加密字节
    
    if (cryptStatus == kCCSuccess) {
        NSData * aes128_Data = [NSData dataWithBytesNoCopy:buffer
                                                    length:numBytes];
        return aes128_Data;
    } else {
        NSLog(@"Error: \(cryptStatus)");
    }
    free(buffer);
    return nil;
}

#pragma mark - 计算
/// 获取大小(KB)，以1000为基本单位量
- (float)ymSize {
    return self.length / 1000.0;
}

@end
