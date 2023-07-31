//
//  NSString+YMCategory.m
//  YMCategory
//
//  Created by 黄玉洲 on 2018/8/24.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "NSString+YMCategory.h"
#import <CoreText/CoreText.h>
#import "CommonCrypto/CommonDigest.h"


/** 用于域名解析 */
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

@implementation NSString (YMCategory)

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
                limitedToNumberOfLines:(NSInteger)numberOfLines {
    if (self.length == 0) {
        return 0;
    }
    
    if (!font) {
        return 0;
    }
    
    // 获取NSAttributedString
    NSDictionary * attributedDic = NSAttributedStringAttributesFromLabel(font);
    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:self attributes:attributedDic];
    
    // 计算适配高度
    CGSize size = [self sizeThatFitsAttributedString:attributedString
                                     withConstraints:CGSizeMake(width, MAXFLOAT)
                              limitedToNumberOfLines:numberOfLines];
    
    // 向上取整数并返回
    return ceil(size.height);
}

/**
 获取字符串所需要的高度
 @param width          限制宽度
 @param attribute      文本属性
 @param numberOfLines  限制行数（如果是0则不限制行数）
 @return 所需高度
 */
- (CGFloat)ymStringForHeightWithWidth:(CGFloat)width
                             attribute:(NSAttributedString *)attribute
                limitedToNumberOfLines:(NSInteger)numberOfLines {
    if (self.length == 0) {
        return 0;
    }
    
    if (!attribute) {
        return 0;
    }
    
    // 计算适配高度
    CGSize size = [self sizeThatFitsAttributedString:attribute
                                     withConstraints:CGSizeMake(width, MAXFLOAT)
                              limitedToNumberOfLines:numberOfLines];
    
    // 向上取整数并返回
    return ceil(size.height);
}

/**
 获取适应大小
 @param size 最大能显示的大小范围
 @param font 字体大小
 @return 返回适应大小
 */
- (CGSize)ym_stringForSizeWithSize:(CGSize)size
                              font:(UIFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGSize sizes = [self boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine| NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    
    return sizes;
}

#pragma mark - 获取字符串长度
/** 获取真实长度（如部分emoji的长度为2，该方法中会返回1） */
- (NSUInteger)ym_length {
    NSUInteger realLength = [self lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    return realLength;
}

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
- (NSUInteger)ymLengthWithOption:(NSStringEnumerationOptions)option {
    __block NSInteger count = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:option
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                              count++;
                          }];
    return count;
}

#pragma mark - 截取字符串
/**
 截取字符串（当截取长度只到达emoji的部分字符时，长度会增加至完整截取这个emoji）
 @param range 截取范围
 @return 截取后的字符串
 */
- (NSString *)ymSubstringWithRange:(NSRange)range {
    NSString *result = self;
    if (result.length >= range.location + range.length) {
        range = [result rangeOfComposedCharacterSequencesForRange:range];
        result = [result substringWithRange:range];
    }
    return result;
}

#pragma mark - 判断非空字符
/** 验证是否为空字符串 */
+ (BOOL)validateNull:(NSString *)str {
    if (str == nil) {
        return YES;
    }else if (str == NULL) {
        return YES;
    }else if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }else if ([str isEqualToString:@"(null)"]) {
        return YES;
    }else if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }else{
        return NO;
    }
}

/** 验证字符串非空，如果是空的会返回@""*/
+ (NSString *)nullToString:(NSString *)string {
    BOOL isNull = [NSString validateNull:string];
    if (isNull) {
        return @"";
    } else {
        return string;
    }
}

#pragma mark - 密文字符串
/**
 字符加密文
 @param range 加密范围
 @param character 替换字符
 @return 加密后的字符串
 */
- (NSString *)encryptionWithRange:(NSRange)range
                        character:(NSString *)character {
    
    if (range.location + range.length > self.length) {
        return self;
    }
    
    // 前缀字符串
    NSString * prefixStr = [self substringWithRange:NSMakeRange(0, range.location)];
    
    // 后缀字符串
    NSInteger suffixLocal = range.location + range.length;
    NSInteger suffixLength = self.length - (range.location + range.length);
    NSString * suffixStr = [self substringWithRange:NSMakeRange(suffixLocal, suffixLength)];
    
    // 密文
    NSString * cipherStr = @"";
    for (NSInteger i = 0; i < range.length; i++) {
        cipherStr = [NSString stringWithFormat:@"%@*",cipherStr];
    }
    
    // 完整的字符
    NSString * fullStr = [NSString stringWithFormat:@"%@%@%@", prefixStr, cipherStr, suffixStr];
    
    return fullStr;
}

#define IOSMD5_length 32
#pragma mark - MD5
/**
 *  MD5加密, 32位 小写
 *  @return 返回加密后的字符串
 */
- (NSString *)ymToMD5ForLower32 {
    //要进行UTF8的转码
    const char* cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
}

/**
 *  MD5加密, 32位 大写
 *  @return 返回加密后的字符串
 */
- (NSString *)ymToMD5ForUpper32 {
    //要进行UTF8的转码
    const char* cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X", result[i]];
    }
    
    return ret;
}

#pragma mark - 字符串转码
/** 字符串编码UTF8 */
- (NSString *)emojiCoding {
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_9_0
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else
    NSCharacterSet * characterSet = [NSCharacterSet characterSetWithCharactersInString:self];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
#endif
}

/** 字符串解码UTF8 */
- (NSString *)emojiDecoding {
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_9_0
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else
    return [self stringByRemovingPercentEncoding];
#endif
}

#pragma mark - private 方法
/**
 根据'NSAttributedString'计算字符串所需高度
 @param attributedString 字符串属性
 @param size             控件限定大小
 @param numberOfLines    限定的行数
 @return 适配后的大小
 */
- (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attributedString
                       withConstraints:(CGSize)size
                limitedToNumberOfLines:(NSUInteger)numberOfLines
{
    if (!attributedString ||
        attributedString.length == 0) {
        return CGSizeZero;
    }
    
    /**
     https://blog.csdn.net/mangosnow/article/details/37700553
     CTFramesetter 是使用 Core Text 绘制时最重要的类。
     它管理您的字体引用和文本绘制帧。
     目前您需要了解 CTFramesetterCreateWithAttributedString 通过应用属性化文本创建 CTFramesetter。
     */
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    
    CGSize calculatedSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, attributedString, size, numberOfLines);
    
    CFRelease(framesetter);
    
    return calculatedSize;
}

#pragma mark - private 函数
/**
 计算字符串所需高度
 @param framesetter      CTFramesetterRef
 @param attributedString NSAttributedString
 @param size             限定的大小
 @param numberOfLines    限定的行数
 @return 适配后的大小
 */
static inline CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, MAXFLOAT);
    
    // 如果只限制为一行，则适配的尺寸是这一整行的宽度
    if (numberOfLines == 1) {
        constraints = CGSizeMake(MAXFLOAT, MAXFLOAT);
    }
    // 如果标签的行数大于1，则将范围限制为已设置的行数
    else if (numberOfLines > 0) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, MAXFLOAT));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        
        CFRelease(frame);
        CGPathRelease(path);
    }
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);
    
    return CGSizeMake(CGFloat_ceil(suggestedSize.width), CGFloat_ceil(suggestedSize.height));
}

/**
 获取默认情况下的'NSAttributedString'属性字典
 @param font 指定的字体样式
 @return 默认的'NSAttributedString'属性字典
 */
static inline NSDictionary * NSAttributedStringAttributesFromLabel(UIFont *font) {
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    
    [mutableAttributes setObject:font forKey:(NSString *)kCTFontAttributeName];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = font.lineHeight;
    paragraphStyle.maximumLineHeight = font.lineHeight;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [mutableAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
    
    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

@end

#pragma mark - NSString 解析
@implementation NSString (YMParsingExtension)

/** 获取域名真实IP */
- (NSArray <NSString *> *)ymDomainToRealIP {
    NSString *hostname = self;
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
    NSMutableArray * tempDNS = [NSMutableArray array];
    if (hostRef){
        Boolean result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
        if (result == TRUE) {
            NSArray *addresses = (__bridge NSArray*)CFHostGetAddressing(hostRef, &result);
            for(int i = 0; i < addresses.count; i++) {
                struct sockaddr_in* remoteAddr;
                CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex((__bridge CFArrayRef)addresses, i);
                remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
                if(remoteAddr != NULL){
                    const char *strIP41 = inet_ntoa(remoteAddr->sin_addr);
                    NSString *strDNS = [NSString stringWithCString:strIP41 encoding:NSASCIIStringEncoding];
                    NSLog(@"RESOLVED %d:<%@>", i, strDNS);
                    [tempDNS addObject:strDNS];
                }
            }
        }
    }
    return tempDNS;
}

/**
 空缺补字符串（如1000，最大长度8位，补0 ——> 00001000）
 @param maxLength 最大长度
 @param fillStr 填补的字符串
 @return 填补后的字符串
 */
- (NSString *)ymFillStrWithMaxLength:(NSInteger)maxLength
                             fillStr:(NSString *)fillStr {
    NSString * numberStr = self;
    NSInteger zeroPaddingCount = maxLength - numberStr.length;
    while (zeroPaddingCount) {
        numberStr = [NSString stringWithFormat:@"%@%@", fillStr, numberStr];
        zeroPaddingCount--;
    }
    return numberStr;
}

/**
 获取CIRD格式IP
 @param fromIP IP的开始位置（192.168.0.1格式）
 @param toIP IP的结束位置（192.168.0.1格式）
 @return 返回类似"192.168.0.1/32" 格式的IP
 */
+ (NSArray <NSString *> *)ymCIDRIPFromIP:(NSString *)fromIP
                                    toIP:(NSString *)toIP {
    
    if ([fromIP isEqual:toIP]) {
        return @[[NSString stringWithFormat:@"%@/32", fromIP]];
    }
    
    // 将原始IP以'.'分割成4个单独的十进制
    NSArray * fromIPs = [fromIP componentsSeparatedByString:@"."];
    NSArray * toIPs = [toIP componentsSeparatedByString:@"."];
    if ([fromIPs count] < 4 || [toIPs count] < 4) {
        return @[];
    }
    
    // 转换成二进制并且补0
    NSMutableArray * mFromIPs = [NSMutableArray array];
    [fromIPs enumerateObjectsUsingBlock:^(NSString * ip, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * binaryIP = [NSString ymGetBinaryFromDecimal:[ip integerValue]];
        binaryIP = [binaryIP ymFillStrWithMaxLength:8 fillStr:@"0"];
        [mFromIPs addObject:binaryIP];
    }];
    
    // 转换成二进制并且补0
    NSMutableArray * mToIPs = [NSMutableArray array];
    [toIPs enumerateObjectsUsingBlock:^(NSString * ip, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * binaryIP = [NSString ymGetBinaryFromDecimal:[ip integerValue]];
        binaryIP = [binaryIP ymFillStrWithMaxLength:8 fillStr:@"0"];
        [mToIPs addObject:binaryIP];
    }];
    
    // 获取完整的32位IP
    __block NSString * completeFromIp = @"";
    [mFromIPs enumerateObjectsUsingBlock:^(NSString * ip, NSUInteger idx, BOOL * _Nonnull stop) {
        completeFromIp = [NSString stringWithFormat:@"%@%@", completeFromIp, ip];
    }];
    
    // 获取完整的32位IP
    __block NSString * completeToIp = @"";
    [mToIPs enumerateObjectsUsingBlock:^(NSString * ip, NSUInteger idx, BOOL * _Nonnull stop) {
        completeToIp = [NSString stringWithFormat:@"%@%@", completeToIp, ip];
    }];
    
    // 二进制转十进制
    long long startDecimal = [NSString ymGetDecimalFromBinary:completeFromIp];
    long long endDecimal = [NSString ymGetDecimalFromBinary:completeToIp];
    
    // 获取指定IP范围内的所有CIDR IP
    NSMutableArray * CIDR_IPs = [NSMutableArray array];
    while (endDecimal >= startDecimal) {
        
        // 获取二进制数位不同的位置
        NSInteger maxsize = 32;
        while (maxsize > 0) {
            long long mask = [[self CIDR2MASK][maxsize - 1] longLongValue];
            long long maskedBase = startDecimal & mask;
            if (maskedBase != startDecimal) {
                break;
            }
            maxsize--;
        }
        double x = log(endDecimal - startDecimal + 1) / log(2);
        
        NSInteger maxdiff = (32 - floor(x));
        if (maxsize < maxdiff) {
            maxsize = maxdiff;
        }
        NSString * ip = [NSString longToIp:startDecimal];
        ip = [NSString stringWithFormat:@"%@/%ld", ip, maxsize];
        [CIDR_IPs addObject:ip];
        startDecimal += pow(2, (32 - maxsize));
    }
    return CIDR_IPs;
}

+ (NSString *)longToIp:(long long)longIP {
    NSString * binaryStr = [NSString ymGetBinaryFromDecimal:longIP];
    NSString * IP = @"";
    for (NSInteger i = 0; i < binaryStr.length; i++) {
        if (i % 8 == 0) {
            NSString * IP1 = [binaryStr substringWithRange:NSMakeRange(i, 8)];
            NSInteger binary = [NSString ymGetDecimalFromBinary:IP1];
            NSString * binaryStr1 = [NSString stringWithFormat:@"%ld", binary];
            if (i == 0) {
                IP = [NSString stringWithFormat:@"%@", binaryStr1];
            } else {
                IP = [NSString stringWithFormat:@"%@.%@", IP, binaryStr1];
            }
            
        }
    }
    return IP;
}


+ (NSArray <NSNumber *> *)CIDR2MASK {
    return @[@(0x00000000), @(0x80000000), @(0xC0000000),
             @(0xE0000000), @(0xF0000000), @(0xF8000000),
             @(0xFC000000), @(0xFFFFFFFC), @(0xFF000000),
             @(0xFF800000), @(0xFFC00000), @(0xFFE00000),
             @(0xFFF00000), @(0xFFF80000), @(0xFFFC0000),
             @(0xFFFE0000), @(0xFFFF0000), @(0xFFFF8000),
             @(0xFFFFC000), @(0xFFFFE000), @(0xFFFFF000),
             @(0xFFFFF800), @(0xFFFFFC00), @(0xFFFFFE00),
             @(0xFFFFFF00), @(0xFFFFFF80), @(0xFFFFFFC0),
             @(0xFFFFFFE0), @(0xFFFFFFF0), @(0xFFFFFFF8),
             @(0xFFFFFFFC), @(0xFFFFFFFE), @(0xFFFFFFFF)];
}

@end

#pragma mark - NSString 进制转换
@implementation NSString (YMSystemConversionExtension)
/** 十进制转换为二进制 */
+ (NSString *)ymGetBinaryFromDecimal:(NSInteger)decimal {
    NSString *binary = @"";
    while (decimal) {
        binary = [[NSString stringWithFormat:@"%ld", decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 4 != 0) {
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
}

/** 十进制转换十六进制 */
+ (NSString *)ymGetHexFromDecimal:(NSInteger)decimal {
    NSString * hex =@"";
    NSString * letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            break;
        }
    }
    return hex;
}

/** 十六进制转换十进制  */
+ (NSString *)ymGetDecimalFromHex:(NSString *)hex {
    // 为空,直接返回.
    if (hex == nil) {
        return nil;
    }
    
    NSScanner * scanner = [NSScanner scannerWithString:hex];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    
    //将整数转换为NSNumber,存储到数组中,并返回.
    NSNumber * hexNumber = [NSNumber numberWithLongLong:longlongValue];
    
    return [NSString stringWithFormat:@"%@", hexNumber];
}


/** 二进制转换成十六进制 */
+ (NSString *)ymGetHexFromBinary:(NSString *)binary {
    
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    NSString *hex = @"";
    for (int i=0; i<binary.length; i+=4) {
        
        NSString *key = [binary substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            
            hex = [hex stringByAppendingString:value];
        }
    }
    return [NSString stringWithFormat:@"0x%@", hex];
}

/** 十六进制转换为二进制  */
+ (NSString *)ymGetBinaryFromHex:(NSString *)hex {
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}

/** 二进制转换为十进制 */
+ (NSInteger)ymGetDecimalFromBinary:(NSString *)binary {
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            decimal += pow(2, i);
        }
    }
    return decimal;
}

@end

#pragma mark - NSString Data
@implementation NSString (YMDataExtension)

/** 十六进制字符串转NSData */
- (NSData *)ymHexStrToData {
    NSString * hexStr = self;
    NSMutableData * mData = [NSMutableData data];
    while ([hexStr ymLengthWithOption:NSStringEnumerationByComposedCharacterSequences] > 0) {
        NSString * c = [hexStr substringToIndex:2];
        hexStr = [hexStr substringFromIndex:2];
        uint ch = 0;
        [[NSScanner scannerWithString:c] scanHexInt:&ch];
        uint8_t kChar = ch;
        [mData appendBytes:&kChar length:1];
    }
    return mData;
}

/**
 字符串转Data
 @param encoding 编码类型
 @return 转换后的数据
 */
- (NSData *)ymToData:(NSStringEncoding)encoding {
    return [self dataUsingEncoding:encoding];
}

@end

#pragma mark - NSString 时间类目
@implementation NSString (YMDateExtension)

/**
 日期格式化
 该方法可返回指定规则的时间字符串，self应为时间格式的字符串（如'1994-03-23...'）或者时间戳（秒为单位）
 @param formatter        指定规则格式化
 @param originFormatter  原始格式，当self不为时间戳时才需要传
 @return 格式化后的日期字符串
 */
- (NSString *)dateStrWithFormatter:(NSString *)formatter
                   originFormatter:(NSString *)originFormatter {
    // 纯数字字符串
    if ([self validatePureNumber]) {
        // 如果是毫秒则需要去掉秒后的位数，判断是否为时间戳的最小范围
        NSInteger second = [self integerValue];
        
        // 格式化时间
        NSDateFormatter * dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:formatter];
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:second];
        NSString * formaterDateStr = [dateFormater stringFromDate:date];
        return formaterDateStr;
    }
    // 非纯数字字符串
    else {
        // 格式化时间
        NSDateFormatter * dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:originFormatter];
        NSDate * date = [dateFormater dateFromString:self];
        [dateFormater setDateFormat:formatter];
        NSString * formaterDateStr = [dateFormater stringFromDate:date];
        return formaterDateStr;
    }
}

/**
 日期格式化
 self格式为1994-03-23 01:01:01的字符串
 @param formatter 指定规则格式化
 @return NSString
 */
- (NSDate *)dateWithFormatter:(NSString *)formatter {
    // 格式化时间
    NSDateFormatter * dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:formatter];
    NSDate * date = [dateFormater dateFromString:self];
    return date;
}

/**
 获取与当前时间的时间偏移量（秒）
 @return 时间偏移量
 */
- (NSInteger)timeOffsetFromNow {
    // 获取当前时间
    NSDate * nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSInteger nowTimeInterval = [nowDate timeIntervalSince1970];
    return [self timeOffsetFromTimeStamp:[NSString stringWithFormat:@"%ld", nowTimeInterval]];
}

/**
 获取与指定时间的时间偏移量（秒）
 @param timeStamp 指定时间
 @return 时间偏移量
 */
- (NSInteger)timeOffsetFromTimeStamp:(NSString *)timeStamp {
    // 计算间隔时间
    NSTimeInterval offsetTime = [timeStamp integerValue] - [self integerValue];
    
    // 取绝对值
    offsetTime = (NSTimeInterval)abs((int)offsetTime);
    return offsetTime;
}

/**
 将秒数转换为HH:mm:ss格式
 @return 格式化时间
 */
- (NSString *)timeFormater {
    // 判断是否为纯数字
    if (![self validatePureNumber]) {
        return @"时间戳必须为纯数字";
    }
    
    NSInteger second = [self integerValue];
    if (second > 0) {
        // 时
        NSInteger hour = second / 3600;
        NSString * hourStr = hour > 0 ? [NSString stringWithFormat:@"%ld", hour] : [NSString stringWithFormat:@"0%ld", hour];
        
        // 分
        NSInteger minute = second / 60 % 60;
        NSString * minuteStr = minute > 0 ? [NSString stringWithFormat:@"%ld", minute] : [NSString stringWithFormat:@"0%ld", minute];
        
        // 秒
        second = second % 60;
        NSString * secondStr = second > 0 ? [NSString stringWithFormat:@"%ld", second] : [NSString stringWithFormat:@"0%ld", second];
        
        if(hour == 0){
            return [NSString stringWithFormat:@"%@分%@秒",minuteStr,secondStr];
        }
        return [NSString stringWithFormat:@"%@小时%@分%@秒",hourStr,minuteStr,secondStr];
    }else{
        return @"";
    }
}

/**
 时间戳转时间格式化
 @param formatter 格式化
 @return 格式化后的字符
 */
- (NSString *)timeFormatter:(NSString *)formatter {
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:[self integerValue]];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSString * formatterDate = [dateFormatter stringFromDate:date];
    return formatterDate;
}

@end

#pragma mark - NSString 验证类目
RequestCompleteBlock _completeBlock;
RequestFailBlock _failBlock;
NSDictionary * _requestDic;
@implementation NSString (YMPredicateCategory)

#pragma mark - 便利验证
/** 验证是否为纯数字 */
- (BOOL)validatePureNumber {
    NSString * timeRegex = @"^[0-9]{1,}$";
    return [self validateWithRegex:timeRegex];
}

/** 验证是否包含数字 */
- (BOOL)validateHaveNumber {
    NSString * timeRegex = @"^(\\D*[0-9]{1,}\\D*){1,}$";
    return [self validateWithRegex:timeRegex];
}

/** 验证是否为整型 */
- (BOOL)validatePureInt {
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

/** 验证是否为浮点型 */
- (BOOL)validatePureFloat {
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

/** 验证是否为特殊符号 */
- (BOOL)validateHaveSpecialSymbols {
    NSString * regex = @"`~!@#$%^&*()_-+=<>?:\"{}|,./;'\\[\\]·~！@#￥%……&*（）——-+={}|《》？：“”【】、；‘’，。、";
    return [regex containsString:self];
}

/** 验证是否为纯字母 */
- (BOOL)validatePureWord {
    NSString * regex = @"^[a-zA-Z]{1,}$";
    return [self validateWithRegex:regex];
}

/** 验证是否为纯Emoji */
- (BOOL)validatePureEmoji {
    NSString * emojiRegex = @"^([\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]){1,}$";
    return [self validateWithRegex:emojiRegex];
}


/** 验证是否包含Emoji */
- (BOOL)validateHaveEmoji {
    NSString * emojiRegex = @"^(\\w{0,}([\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]){1,}\\w{0,}){1,}$";
    return [self validateWithRegex:emojiRegex];
}

/**
 验证是否包含或全为汉字
 @param isPure 是否全为汉字
 @return 是否符合验证
 */
- (BOOL)validateChinese:(BOOL)isPure {
    NSString * unicode = [[self class] chineseUnicode];
    NSString * chineseRegex = @"";
    if (isPure) {
        chineseRegex = [NSString stringWithFormat:@"(^[%@]{1,}$)", unicode];
    } else {
        chineseRegex = [NSString stringWithFormat:@"^((.*)[%@]{1,}(.*))$", unicode];
    }
    return [self validateWithRegex:chineseRegex];
}

/**
 验证是否包含或全为韩文
 @param isPure 是否全为韩文
 @return 是否符合验证
 */
- (BOOL)validateKorean:(BOOL)isPure {
    NSString * unicode = [[self class] koreanUnicode];
    NSString * koreanRegex = @"";
    if (isPure) {
        koreanRegex = [NSString stringWithFormat:@"(^[%@]{1,}$)", unicode];
    } else {
        koreanRegex = [NSString stringWithFormat:@"^((.*)[%@]{1,}(.*))$", unicode];
    }
    return [self validateWithRegex:koreanRegex];
}

/**
 验证字符串是否包含日文或者全是日文
 @param isPure 包含或者全是日文
 @return 是否符合条件
 */
- (BOOL)validateJapan:(BOOL)isPure {
    NSString * unicode = [[self class] japanUnicode];
    NSString * japanRegex = @"";
    if (isPure) {
        japanRegex = [NSString stringWithFormat:@"(^[%@]{1,}$)", unicode];
    } else {
        japanRegex = [NSString stringWithFormat:@"^((.*)[%@]{1,}(.*))$", unicode];
    }
    return [self validateWithRegex:japanRegex];
}

/** 是否为手机号码 */
- (BOOL)validatePhone {
    // 替换掉空格
    NSString * telNumber = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 手机号为11位
    if (telNumber.length != 11) {
        return NO;
    }
    // 验证手机格式
    else {
        /**
         移动号段正则表达式
         134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        BOOL isMatch1 = [self validateWithRegex:CM_NUM];
        
        /**
         联通号段正则表达式
         130,131,132,145,152,155,156,176,185,186
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(152)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        BOOL isMatch2 = [self validateWithRegex:CU_NUM];
        
        /**
         电信号段正则表达式
         133,1349,153,180,189,181(增加)
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        BOOL isMatch3 = [self validateWithRegex:CT_NUM];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else {
            return NO;
        }
    }
}

/** 是否为18位身份证 */
- (BOOL)validateIdentity {
    // 身份证正则表达式(18位)
    NSString * identityRegex = @"^[1-9]\\d{5}(19\\d{2}|[2-9]\\d{3})((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])(\\d{4}|\\d{3}X)$";
    NSString * identity = [self uppercaseString];
    if (![identity validateWithRegex:identityRegex]) {
        return NO;
    }
    
    // 最后一位身份证的号码
    NSString * stard = @"10X98765432";
    
    // 1-17系数
    NSArray * first = @[@7, @9, @10, @5, @8, @4, @2, @1, @6, @3, @7, @9, @10, @5, @8, @4, @2];
    
    NSString * yearStr = [self substringWithRange:NSMakeRange(6, 4)];
    NSString * monthStr = [self substringWithRange:NSMakeRange(10, 2)];
    NSString * dayStr = [self substringWithRange:NSMakeRange(12, 2)];
    NSString * birthdayStr = [self substringWithRange:NSMakeRange(6, 8)];
    NSString * dateStr = [NSString stringWithFormat:@"%@/%@/%@",yearStr, monthStr, dayStr];
    NSString * newDateStr = [dateStr dateStrWithFormatter:@"yyyyMMdd" originFormatter:@"yyyy/MM/dd"];
    
    // 校验日期是否合法
    if (![birthdayStr isEqual:newDateStr]) {
        return NO;
    }
    
    NSInteger sum = 0;
    for (NSInteger i = 0; i < self.length - 1; i++) {
        sum += [[self substringWithRange:NSMakeRange(i, 1)] integerValue] *
        [first[i] integerValue];
    }
    
    NSInteger result = sum % 11;
    
    // 计算出来的最后一位身份证号码
    NSString * last = [stard substringWithRange:NSMakeRange(result, 1)];
    if ([[[self substringWithRange:NSMakeRange(self.length - 1, 1)] uppercaseString] isEqual:last]) {
        return YES;
    } else {
        return NO;
    }
}

/** 验证邮箱 */
- (BOOL)validateEmail {
    NSString * emailRegex = @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$";
    return [self validateWithRegex:emailRegex];
}

/** 验证整数金额 */
- (BOOL)validateMoneyInt {
    NSString * emailRegex = @"^[1-9]{1}[0-9]*$";
    return [self validateWithRegex:emailRegex];
}

/** 验证小数金额 */
- (BOOL)validateMoneyDouble {
    NSString * emailRegex = @"^(([0-9]*\\.\\d{0,2})|([0-9]{1}))$";
    return [self validateWithRegex:emailRegex];
}

#pragma mark - 验证银行卡（https://blog.csdn.net/yqwang75457/article/details/72627542）
/** 通过Alipay验证是否为银行卡号 */
- (void)validateBankCardComplete:(RequestCompleteBlock)complete
                            fail:(RequestFailBlock)fail {
    
    _completeBlock = complete;
    _failBlock = fail;
    
    // 请求路径
    NSString * requestURL = [NSString stringWithFormat:@"https://ccdcapi.alipay.com/validateAndCacheCardInfo.json?_input_charset=utf-8&cardNo=%@&cardBinCheck=true", self];
    
    // 创建url对象
    NSURL *url = [NSURL URLWithString:requestURL];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    // 创建参数字符串对象
    NSString *parmStr = [NSString stringWithFormat:@"method=album.channel.get&appKey=myKey&format=json&channel=t&pageNo=1&pageSize=10"];
    
    // 将字符串转换为NSData对象
    NSData *data = [parmStr dataUsingEncoding:NSUTF8StringEncoding]; [request setHTTPBody:data]; [request setHTTPMethod:@"POST"];
    
    // 创建异步连接（形式二）
    [NSURLConnection connectionWithRequest:request delegate:self];
}


/**
 验证是否为银行卡号
 luhn校验规则：16位银行卡号（19位通用）
 1.将未带校验位的 15（或18）位卡号从右依次编号 1 到 15（18），位于奇数位号上的数字乘以 2。
 2.将奇位乘积的个十位全部相加，再加上所有偶数位上的数字。
 3.将加法和加上校验位能被 10 整除。
 */
- (BOOL)validateBankCard {
    // 取出最后一位（与luhn进行比较）
    NSString * lastNumber = [self ymSubstringWithRange:NSMakeRange(self.length - 1, 1)];
    
    // 前15或18位
    NSString * first15Number = [self ymSubstringWithRange:NSMakeRange(0, self.length - 1)];
    
    NSMutableArray * newArray = [NSMutableArray array];
    for (NSInteger i = first15Number.length - 1; i > -1; i--) {
        [newArray addObject:[first15Number ymSubstringWithRange:NSMakeRange(i, 1)]];
    }
    
    // 奇数位*2的积 <9
    NSMutableArray * arrJiShu = [NSMutableArray array];
    
    // 奇数位*2的积 >9
    NSMutableArray * arrJiShu2 = [NSMutableArray array];
    
    // 偶数位数组
    NSMutableArray * arrOuShu = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [newArray count]; i++) {
        // 奇数位
        if ((i+1) % 2 == 1) {
            NSInteger number = [newArray[i] integerValue] * 2;
            if (number < 9) {
                [arrJiShu addObject:[NSString stringWithFormat:@"%ld", number]];
            } else {
                [arrJiShu2 addObject:[NSString stringWithFormat:@"%ld", number]];
            }
        }
        // 偶数位
        else {
            [arrOuShu addObject:newArray[i]];
        }
    }
    
    // 奇数位*2 >9 的分割之后的数组个位数
    NSMutableArray * jishu_child1 = [NSMutableArray array];
    // 奇数位*2 >9 的分割之后的数组十位数
    NSMutableArray * jishu_child2 = [NSMutableArray array];
    for (NSInteger i = 0; i < [arrJiShu2 count]; i++) {
        NSInteger number_1 = [arrJiShu2[i] integerValue] % 10;
        NSInteger number_2 = [arrJiShu2[i] integerValue] / 10;
        [jishu_child1 addObject:[NSString stringWithFormat:@"%ld", number_1]];
        [jishu_child2 addObject:[NSString stringWithFormat:@"%ld", number_2]];
    }
    
    // 奇数位*2 < 9 的数组之和
    NSInteger sumJiShu = 0;
    // 偶数位数组之和
    NSInteger sumOuShu=0;
    // 奇数位*2 > 9 的分割之后的数组个位数之和
    NSInteger sumJiShuChild1=0;
    // 奇数位*2 > 9 的分割之后的数组十位数之和
    NSInteger sumJiShuChild2=0;
    NSInteger sumTotal=0;
    for (NSInteger i = 0; i < [arrJiShu count]; i++) {
        sumJiShu += [arrJiShu[i] integerValue];
    }
    
    for (NSInteger i = 0; i < [arrOuShu count]; i++) {
        sumOuShu += [arrOuShu[i] integerValue];
    }
    
    for (NSInteger i = 0; i < [jishu_child1 count]; i++) {
        sumJiShuChild1 += [jishu_child1[i] integerValue];
        sumJiShuChild2 += [jishu_child2[i] integerValue];
    }
    
    // 计算总和
    sumTotal = sumJiShu +sumOuShu + sumJiShuChild1 + sumJiShuChild2;
    
    // 计算luhn值
    NSInteger k= sumTotal % 10 == 0 ? 10 : sumTotal % 10;
    NSInteger luhn= 10 - k;
    
    if ([lastNumber integerValue] == luhn){
        //        NSLog(@"luhn验证通过");
        return YES;
    } else {
        //        NSLog(@"银行卡号必须符合luhn校验");
        return NO;
    }
}

#pragma mark - <NSURLConnectionDelegate>
// 服务器接收到请求时
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

// 当收到服务器返回的数据时触发, 返回的可能是资源片段
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    _requestDic = dic;
}

// 当服务器返回所有数据时触发, 数据返回完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_completeBlock) {
        BOOL isBankCard = [_requestDic[@"validated"] boolValue];
        _completeBlock(isBankCard);
    }
}

// 请求数据失败时触发
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    if (_failBlock) {
        _failBlock(error);
    }
}



#pragma mark - 自定义验证
/**
 根据指定格式进行验证
 @param regex 验证格式
 @return 验证结果
 */
- (BOOL)validateWithRegex:(NSString *)regex {
    if (!regex) {
        regex = @"";
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL allow = [predicate evaluateWithObject:self];
    return allow;
}

#pragma mark - private 方法
+ (NSString *)chineseUnicode {
    NSArray * chineseUnicodes = @[@"\\u4E00-\\u9FA5",
                                  @"\\u9FA6-\\u9FEF",
                                  @"\\u3400-\\u4DB5",
                                  //                                  @"\\u20000-\\u2A6D6",
                                  //                                  @"\\u2A700-\\u2B734",
                                  //                                  @"\\u2B740-\\u2B81D",
                                  //                                  @"\\u2B820-\\u2CEA1",
                                  //                                  @"\\u2CEB0-\\u2EBE0",
                                  @"\\u2F00-\\u2FD5",
                                  @"\\u2E80-\\u2EF3",
                                  @"\\uF900-\\uFAD9",
                                  @"\\u2F80-\\u2FA1",
                                  @"\\uE815-\\uE86F",
                                  @"\\uE400-\\uE5E8",
                                  @"\\uE600-\\uE6CF",
                                  @"\\u31C0-\\u31E3",
                                  @"\\u2FF0-\\u2FFB",
                                  @"\\u3105-\\u312F",
                                  @"\\u31A0-\\u31BA",
                                  @"\\u3007"
                                  ];
    NSString * chineseUnicode = @"";
    for (NSString * unicode in chineseUnicodes) {
        chineseUnicode = [NSString stringWithFormat:@"%@%@", chineseUnicode, unicode];
    }
    return chineseUnicode;
}

+ (NSString *)koreanUnicode {
    NSArray * koreanUnicodes = @[@"\uAC00-\uD7AF",
                                 @"\u1100-\u11FF",
                                 @"\u3130-\u318F",
                                 @"\uA490-\uA4CF"];
    NSString * koreanUnicode = @"";
    for (NSString * unicode in koreanUnicodes) {
        koreanUnicode = [NSString stringWithFormat:@"%@%@", koreanUnicode, unicode];
    }
    return koreanUnicode;
}

+ (NSString *)japanUnicode {
    NSArray * japanUnicodes = @[@"\u3040-\u309F",
                                @"\u30A0-\u30FF",
                                @"\u4E00-\u9FBF"];
    
    NSString * japanUnicode = @"";
    for (NSString * unicode in japanUnicodes) {
        japanUnicode = [NSString stringWithFormat:@"%@%@", japanUnicode, unicode];
    }
    return japanUnicode;
}

@end
