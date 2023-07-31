//
//  TDEncryptorFactory.m
//  ToDesk-iOS
//
//  Created by 黄玉洲 on 2021/5/26.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "TDEncryptorFactory.h"
#import "EncryptorFactory.h"
#import "Encryptor.h"
@interface TDEncryptorFactory ()
{
    BOOL _allowLog;
}
@property (copy, nonatomic) NSString * encryptionModeStr;
@property (assign, nonatomic) TDEncryption encryptionMode;

@property (nonatomic) IEncryptor * encrypt;
@property (nonatomic) Encryptor * newEcenrypt;

@end

@implementation TDEncryptorFactory

- (void)dealloc {
    if (_allowLog) {
        NSLog(@"%@ 释放", self);
    }
    [self releaseEncryptAndDecrypt];
}

- (instancetype)init {
    if (self = [super init]) {
        _encrypt = NULL;
    }
    return self;
}

/// 初始化
/// @param secretKey 秘钥
- (instancetype)initWithSecretkey:(NSString *)secretKey encryptionMode:(TDEncryption)encryptionMode {
    if (self = [super init]) {
        if (!secretKey) {
            return nil;
        }
        
        self.encryptionMode = encryptionMode;
        switch (encryptionMode) {
            case TDEncryptionChacha20:  self.encryptionModeStr = @"chacha20-ietf-poly1305"; break;
            case TDEncryptionXChacha20: self.encryptionModeStr = @"xchacha20-ietf-poly1305"; break;
            default: self.encryptionModeStr = @"xchacha20-ietf-poly1305"; break;
        }
        
        // 加密模式
        char smodestr[self.encryptionModeStr.length];
        memset(smodestr, 0, self.encryptionModeStr.length);
        sprintf(smodestr, "%s", [self.encryptionModeStr UTF8String]);
        
        // 秘钥
        char secretKeystr[secretKey.length];
        memset(secretKeystr, 0, secretKey.length);
        sprintf(secretKeystr, "%s", [secretKey UTF8String]);
        if (!_encrypt) {
            _encrypt = EncryptorFactory::GetEncryptor(smodestr, secretKeystr);
        }
//        if (!_newEcenrypt) {
//            _newEcenrypt = new Encryptor((const unsigned char* )secretKeystr, secretKey.length);
//        }
    
    }
    return self;
}

/// 释放
- (void)releaseEncryptAndDecrypt {
    if (_encrypt != NULL) {
        delete _encrypt;
        _encrypt = NULL;
    }
    if (_newEcenrypt != NULL) {
        delete _newEcenrypt;
        _newEcenrypt = NULL;
    }
}

/// 判断是否有效
- (BOOL)effective {
    if (_encrypt) {
        return YES;
    }
    return NO;
}

/// 进行解密
- (NSData *)decryptWithEncryptData:(NSData *)sourceData {
    if (sourceData.length == 0) {
        return nil;
    }
    
    NSMutableData * mData = [sourceData mutableCopy];
    
    const void * dataBytes = [mData bytes];
    NSUInteger   dataLength =  [mData length];
    if (!dataBytes || dataLength == 0) {
        return nil;
    }
    
    char* outgoing_buffer_encode = (char*)malloc(sizeof(char)*mData.length+512);
    memset(outgoing_buffer_encode, 0, mData.length+512);
    NSData * destData = nil;
    if (_encrypt) {
        int outlenght = 0;
        _encrypt->DecryptUDP((char *)dataBytes, (int)dataLength, outgoing_buffer_encode, outlenght);
        destData = [NSData dataWithBytes:outgoing_buffer_encode length:outlenght];
    } else if (_newEcenrypt) {
        size_t outlenght = 0;
        _newEcenrypt->Decrypt((const unsigned char *)dataBytes, (size_t)dataLength, (unsigned char *)outgoing_buffer_encode, &outlenght, (int)self.encryptionMode);
        destData = [NSData dataWithBytes:outgoing_buffer_encode length:outlenght];
    }
    
    if (outgoing_buffer_encode != NULL) {
        free(outgoing_buffer_encode);
        outgoing_buffer_encode = NULL;
    }
    return destData;
    
}

/// 进行加密
- (NSData *)encryptWithDecryptData:(NSData *)sourceData {
    if (sourceData.length == 0) {
        return nil;
    }
    
    NSMutableData * mData = [sourceData mutableCopy];
    
    const void * dataBytes = [mData bytes];
    NSUInteger   dataLength =  [mData length];
    if (!dataBytes || dataLength == 0) {
        return nil;
    }
    
    char* outgoing_buffer_encode = (char*)malloc(sizeof(char)*mData.length+512);
    memset(outgoing_buffer_encode, 0, mData.length+512);
    NSData * destData = nil;
    if (_encrypt) {
        int outlenght = 0;
        _encrypt->EncryptUDP((char *)[mData bytes], (int)[mData length], outgoing_buffer_encode, outlenght);
        destData = [NSData dataWithBytes:outgoing_buffer_encode length:outlenght];
    } else if (_newEcenrypt) {
        size_t outlenght = 0;
        _newEcenrypt->Encrypt((const unsigned char *)dataBytes, (size_t)dataLength, (unsigned char *)outgoing_buffer_encode, &outlenght, (int)self.encryptionMode);
        destData = [NSData dataWithBytes:outgoing_buffer_encode length:outlenght];
    }
    
    if (outgoing_buffer_encode != NULL) {
        free(outgoing_buffer_encode);
        outgoing_buffer_encode = NULL;
    }
    return destData;
}

- (void)allowLog {
    _allowLog = YES;
}

@end
