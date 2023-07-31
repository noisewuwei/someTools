//
//  YMSocksTool.m
//  YM_Category
//
//  Created by 黄玉洲 on 2019/9/6.
//  Copyright © 2019年 huangyuzhou. All rights reserved.
//

#import "YMSocksTool.h"

typedef struct ip_addr_packed ip_addr_p_t;

typedef NS_ENUM(NSInteger, kNumberType) {
    /** 二进制 */
    kNumberType_2 = 1 << 1,
    /** 四进制 */
    kNumberType_4 = 1 << 2,
    /** 八进制 */
    kNumberType_8 = 1 << 3,
    /** 十进制 */
    kNumberType_10 = 10,
    /** 十六进制 */
    kNumberType_16 = 1 << 4,
    /** 三十二进制 */
    kNumberType_32 = 1 << 5,
    /** 六十四进制 */
    kNumberType_64 = 1 << 6,
};

@interface YMSocksTool ()


@end

@implementation YMSocksTool

/**
 从sockaddr_in中获取直接可读地址和端口
 @param hostNum 地址
 @param portNum 端口
 @param addr sockaddr_in
 */
+ (void)getHostNum:(NSInteger *)hostNum
           portNum:(NSInteger *)portNum
          fromAddr:(const struct sockaddr_in *)addr {
    if (hostNum) {
        *hostNum = addr->sin_addr.s_addr;
    }
    if (portNum) {
        *portNum = addr->sin_port;
    }
}

/**
 从sockaddr_in中获取直接可读地址和端口
 @param host 地址
 @param port 端口
 @param addr sockaddr_in
 */
+ (void)getHost:(NSString **)host
           port:(NSInteger *)port
       fromAddr:(const struct sockaddr_in *)addr {
    if (host) {
        *host = [self ymIPFromDecimal:addr->sin_addr.s_addr reverse:YES];
    }
    if (port) {
        *port = (NSInteger)(ntohs(addr->sin_port));
    }
}

/**  网络字节顺序转换为主机字节顺序 */
+ (uint16_t)portFromNetPort:(uint16_t)port {
    return ntohs(port);
}

/** 主机字节顺序转换为网络字节顺序 */
+ (uint16_t)portFromHexPort:(uint16_t)port {
    return htons(port);
}

#pragma mark - private
+ (NSString *)ymIPFromDecimal:(NSInteger)decimal reverse:(BOOL)reverse {
    NSString * binaryStr = [self ymDec:decimal toType:kNumberType_2];
    if (!binaryStr) {
        return nil;
    }
    while (binaryStr.length != 32) {
        binaryStr = [NSString stringWithFormat:@"0%@", binaryStr];
    }
    NSString * IP = @"";
    for (NSInteger i = 0; i < 32; i= (i+8)) {
        NSRange range = NSMakeRange(i, 8);
        NSString * binary = [binaryStr substringWithRange:range];
        NSString * childIP = [self ymBin:binary toType:kNumberType_10];
        if (reverse) {
            IP = IP.length == 0 ? childIP : [NSString stringWithFormat:@"%@.%@", childIP, IP];
        } else {
            IP = IP.length == 0 ? childIP : [NSString stringWithFormat:@"%@.%@", IP, childIP];
        }
    }
    return IP;
}

/**
 十进制转换为指定进制
 @param decimal 十进制
 @param type 进制数类型
 @return 转换后的字符
 */
+ (NSString *)ymDec:(NSInteger)decimal toType:(kNumberType)type {
    return [self ymDec:decimal toType:type length:0];
}

/**
十进制转换为指定进制
@param decimal 十进制
@param type 进制数类型
@param length 每节长度(如果不足则补0，如果超过则求得余数，补余数个数0)
@return 转换后的字符
*/
+ (NSString *)ymDec:(NSInteger)decimal
             toType:(kNumberType)type
             length:(NSInteger)length {
    if (type == kNumberType_10) {
        return [NSString stringWithFormat:@"%ld", decimal];
    }
    
    NSString * tempStr = @"";
    // 进制转换
    while (decimal > -1) {
        // 获取每一位的进制值
        NSInteger remainder = decimal % type;
        
        // 获取进制符号（大于9的用A、B、C...代替）
        NSString * code = @"";
        if (remainder < 10) {
            code = [NSString stringWithFormat:@"%ld", remainder];
        } else {
            code = [NSString stringWithFormat:@"%c", (int)(remainder - 10) + 65];
        }
        
        // 拼接进制符号
        tempStr = [code stringByAppendingString:tempStr];
        if (decimal / type < 1) {
            break;
        }
        decimal = decimal / type;
        if (decimal == 0) {
            decimal = -1;
        }
    }
    // 不足指定长度的倍数补0
    while (tempStr.length % (length > 2 ? length : 2) != 0) {
        tempStr = [NSString stringWithFormat:@"0%@", tempStr];
    }
    
    return tempStr;
}

/**
 二进制转换为指定进制
 @param binary 二进制
 @param type 进制数类型
 @return 转换后的字符
 */
+ (NSString *)ymBin:(NSString *)binary
             toType:(kNumberType)type {
    // 次幂
    NSInteger power = binary.length - 1;
    power = power >= 0 ? power : 0;
    
    // 转为10进制
    NSInteger sum = 0;
    for (NSInteger i = 0; i < binary.length; i++) {
        NSString * number = [binary substringWithRange:NSMakeRange(i, 1)];
        int ascii = [number characterAtIndex:0];
        if (ascii != 48 && ascii != 49) {
            return nil;
        }
        sum += [number integerValue] * pow(2, power);
        power--;
    }
    
    return [NSString stringWithFormat:@"%ld", sum];
}

@end
