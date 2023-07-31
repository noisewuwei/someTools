//
//  TDEncryptorFactory.h
//  ToDesk-iOS
//
//  Created by 黄玉洲 on 2021/5/26.
//  Copyright © 2021 海南有趣. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* 如果报错，可能需要在Other Linker Flags中加入-lc++ */

/// chacha20加密方式兼顾安全和效率，适合在没有AES指令集的CPU上使用，效率比AES高。
typedef NS_ENUM(NSInteger, TDEncryption) {
    /// chacha20-ietf-poly1305，，支持 AEAD 认证加密，同时完成加密和完整性校验。
    TDEncryptionChacha20 = 1,
    /// xchacha20-ietf-poly1305，拥有更大的随机数以防碰撞攻击，支持 AEAD 认证加密，同时完成加密和完整性校验。
    TDEncryptionXChacha20,
};

@interface TDEncryptorFactory : NSObject

/// 初始化
/// @param secretKey 秘钥
- (instancetype)initWithSecretkey:(NSString *)secretKey encryptionMode:(TDEncryption)encryptionMode;

/// 判断是否有效
- (BOOL)effective;

/// 进行解密
- (NSData *)decryptWithEncryptData:(NSData *)sourceData;

/// 进行加密
- (NSData *)encryptWithDecryptData:(NSData *)sourceData;

- (void)allowLog;

@end

NS_ASSUME_NONNULL_END
