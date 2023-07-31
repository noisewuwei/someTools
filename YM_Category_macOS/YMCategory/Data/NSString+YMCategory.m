//
//  NSString+YMCategory.m
//  YMCategory
//
//  Created by 黄玉洲 on 2018/8/24.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "NSString+YMCategory.h"
#import "NSString+YMPredicate.h"
#import <CoreText/CoreText.h>
#import "CommonCrypto/CommonDigest.h"
#import "NSData+YMCategory.h"

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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation NSString (YMCategory)

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
                                 font:(NSFont *)font
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
                              font:(NSFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGSize sizes = [self boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine| NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    
    return sizes;
}

#pragma mark 获取字符串长度
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

#pragma mark 截取字符串
/// 截取字符串（当截取长度只到达emoji的部分字符时，长度会增加至完整截取这个emoji）
/// @param range 截取范围
/// @return  截取后的字符串
- (NSString *)ymSubstringWithRange:(NSRange)range {
    NSString *result = self;
    if (result.length >= range.location + range.length) {
        range = [result rangeOfComposedCharacterSequencesForRange:range];
        result = [result substringWithRange:range];
    }
    return result;
}

/// 获取上层目录
/// @return 无效路径返回nil
- (NSString *)ymUpperDirectory {
    NSString * lastPathComponent = [self lastPathComponent];
    if (lastPathComponent.length == 0) {
        return nil;
    }
    
    NSRange range = [self rangeOfString:lastPathComponent];
    if (range.length == 0) {
        return nil;
    }
    
    if (self.length < range.location) {
        return nil;
    }
    NSString * directory = [self substringWithRange:NSMakeRange(0, range.location)];
    return directory;
}

#pragma mark 插入字符串
/// 在指定位置插入字符
/// @param string 插入的字符
/// @param index  插入的位置
- (NSString *)ymInsertString:(NSString *)string atIndex:(NSInteger)index {
    NSString * string1 = [self substringToIndex:index];
    if (self.length == index) {
        return [NSString stringWithFormat:@"%@%@", string1, string];
    } else {
        NSString * string2 = [self substringFromIndex:index];
        return [NSString stringWithFormat:@"%@%@%@", string1, string, string2];
    }
}

/// 每隔n个字符插入指定字符
/// @param string 插入的字符
/// @param interval 间隔值
- (NSString *)ymInsertString:(NSString *)string atInterval:(NSInteger)interval {
    NSMutableString * mString = [NSMutableString string];
    if (self.length < interval) {
        return self;
    }
    for (NSInteger i = 0; i < self.length; i+=interval) {
        NSInteger startIndex = i;
        NSInteger endIndex = i+interval;
        if (endIndex > self.length) {
            [mString appendFormat:@"%@", [self substringFromIndex:startIndex]];
            break;
        }
        NSString * tempStr = [self substringWithRange:NSMakeRange(startIndex, interval)];
        if (endIndex == self.length) {
            [mString appendFormat:@"%@", tempStr];
        } else {
            [mString appendFormat:@"%@%@", tempStr, string];
        }
    }
    return mString;
}

#pragma mark 替换字符串
/// 替换字符
/// @param target 要替换的字符
/// @param replacement 替换后的字符
- (NSString *)ymStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement {
    return [self ymStringByReplacingOccurrencesOfString:target withString:replacement options:kReplaceOptionsAll];
}

/// 替换字符
/// @param target 要替换的字符
/// @param replacement 替换后的字符
/// @param options 替换位置
- (NSString *)ymStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(kReplaceOptions)options {
    if (options == kReplaceOptionsAll) {
        return [self stringByReplacingOccurrencesOfString:target withString:replacement];
    } else if (options == kReplaceOptionsLast) {
        NSRange range = [self rangeOfString:target options:NSBackwardsSearch];
        return [self stringByReplacingCharactersInRange:range withString:replacement];
    } else {
        NSRange range = [self rangeOfString:target];
        return [self stringByReplacingCharactersInRange:range withString:replacement];
    }
}

#pragma mark 判断非空字符
/** 验证是否为空字符串 */
+ (BOOL)ymValidateNull:(NSString *)str {
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
+ (NSString *)ymNullToString:(NSString *)string {
    BOOL isNull = [NSString ymValidateNull:string];
    if (isNull) {
        return @"";
    } else {
        return string;
    }
}


#pragma mark private 方法
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

#pragma mark private 函数
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
static inline NSDictionary * NSAttributedStringAttributesFromLabel(NSFont *font) {
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    
    [mutableAttributes setObject:font forKey:(NSString *)kCTFontAttributeName];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.minimumLineHeight = font.capHeight;
//    paragraphStyle.maximumLineHeight = font.lineHeight;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [mutableAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
    
    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

@end

#pragma mark - 字符转换
@implementation NSString (Conversion)

#pragma mark Unicode
/**
 *  转为Unicode数据(不移除前两位大端十六进制)
 *  @return Unicode
 */
- (NSData *)ymToUnicode {
    return [self ymToUnicode:NO];
}

/**
 *  转为Unicode数据
 *  @property remove 是否移除前两位大端十六进制
 *  @return Unicode
 */
- (NSData *)ymToUnicode:(BOOL)removeBigEndian {
    NSMutableData * data = [[self dataUsingEncoding:NSUnicodeStringEncoding] mutableCopy];
    [data appendData:[NSData dataWithBytes:"\x00\x00" length:2]];
    
    if (removeBigEndian && data.length > 2) {
        NSData * tempData1 = [data subdataWithRange:NSMakeRange(0, 2)];
        NSData * tempData2 = [NSData dataWithBytes:"\xff\xfe" length:2];
        if ([tempData1 isEqual:tempData2]) {
            data = [[data subdataWithRange:NSMakeRange(2, data.length - 2)] mutableCopy];
        }
    }
    
    return data;
}

#define IOSMD5_length 32
#pragma mark MD5
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

#pragma mark AES
/**
 AES加密(ECB_PKCS7)
 tip: 字符串需要为base64
 @param key 密钥
 @param iv  向量
 @return 加密后的字符串
 */
- (NSString *)ymAES_EncryptWithKey:(NSString *)key
                                iv:(NSString *)iv {
    NSData * encryptData = [NSData ymAESWithData:self
                                             key:key
                                              iv:iv
                                      AESOptions:kCCOptions_ECB_PKCS7
                                       operation:kCCOperation_Encrypt];
    return [NSData ymBase64WithData:encryptData];
}

/**
 AES加密(ECB_PKCS7)
 tip: 字符串需要为base64
 @param key 密钥
 @param iv  向量
 @return 解密后的字符串
 */
- (NSString *)ymAES_DecryptWithKey:(NSString *)key
                                iv:(NSString *)iv {
    NSData * decryptData = [NSData ymDataWithBase64:self];
    decryptData = [NSData ymAESWithData:decryptData
                                    key:key
                                     iv:iv
                             AESOptions:kCCOptions_ECB_PKCS7
                              operation:kCCOperation_Decrypt];
    return [[NSString alloc] initWithData:decryptData
                                 encoding:NSUTF8StringEncoding];
}

#pragma mark 字符串转码
/** 字符串编码UTF8 */
- (NSString *)ymEmojiEncoding {
    NSCharacterSet * characterSet = [NSCharacterSet characterSetWithCharactersInString:self];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
}

/** 字符串解码UTF8 */
- (NSString *)ymEmojiDecoding {
    return [self stringByRemovingPercentEncoding];
}

#pragma mark 密文字符串
/**
 字符加密文
 @param range 加密范围
 @param character 替换字符
 @return 加密后的字符串
 */
- (NSString *)ymEncryptionWithRange:(NSRange)range
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

#pragma mark 简体繁体转换
- (NSString *)ymChineseConvert:(BOOL)simToTra {
    // 简体
    NSString * simplifiedCode = [self simplifiedCode];
    
    // 繁体
    NSString * traditionalCode = [self traditionalCode];
    
    // 存储转换结果
    NSMutableString *resultString = [NSMutableString string];
    
    // 遍历字符串中的字符
    NSInteger length = [self length];
    for (NSInteger i = 0; i < length; i++) {
        NSString *simCharString = [self substringWithRange:NSMakeRange(i, 1)];
        NSRange charRange =
        [simToTra ? simplifiedCode : traditionalCode rangeOfString:simCharString];
        if(charRange.location != NSNotFound) {
            NSString *tradCharString =
            [simToTra ? traditionalCode : simplifiedCode  substringWithRange:charRange];
            [resultString appendString:tradCharString];
        }else{
            [resultString appendString:simCharString];
        }
    }
    return resultString;
}

/// 中文简体转繁体
- (NSString *)ymSimplifiedToTraditional {
    return [self ymChineseConvert:YES];
}

/// 中文繁体转简体
- (NSString *)ymTraditionalToSimplified {
    return [self ymChineseConvert:NO];
}

/// 获取首字母
- (NSString *)ymFirstLetter {
    NSString *pinYin = [self ymPinyin:NO];
    // 获取并返回首字母
    if (pinYin.length >= 1) {
        return [pinYin substringToIndex:1];
    } else {
        return @"";
    }
}

/// 整段拼音
- (NSString *)ymPinyin:(BOOL)removeBlankSpace {
    // 转成了可变字符串
    CFStringRef originStr = (__bridge CFStringRef)self;
    CFMutableStringRef mutStr = CFStringCreateMutableCopy(NULL, 0, originStr);
    // 先转换为带声调的拼音
    CFStringTransform(mutStr, NULL, kCFStringTransformMandarinLatin, NO);
    // 再转换为不带声调的拼音
    CFStringTransform(mutStr, NULL, kCFStringTransformStripDiacritics, NO);
    NSString* str = (__bridge NSString *)mutStr;
    if (removeBlankSpace) {
        str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    CFRelease(mutStr);
    CFRelease(originStr);
    return str;
}

- (NSString *)simplifiedCode {
    return @"锕皑蔼碍爱嗳嫒瑷暧霭谙铵鹌肮袄奥媪骜鳌坝罢钯摆败呗颁办绊钣帮绑镑谤剥饱宝报鲍鸨龅辈贝钡狈备惫鹎贲锛绷笔毕毙币闭荜哔滗铋筚跸边编贬变辩辫苄缏笾标骠飑飙镖镳鳔鳖别瘪濒滨宾摈傧缤槟殡膑镔髌鬓饼禀拨钵铂驳饽钹鹁补钸财参蚕残惭惨灿骖黪苍舱仓沧厕侧册测恻层诧锸侪钗搀掺蝉馋谗缠铲产阐颤冁谄谶蒇忏婵骣觇禅镡场尝长偿肠厂畅伥苌怅阊鲳钞车彻砗尘陈衬伧谌榇碜龀撑称惩诚骋枨柽铖铛痴迟驰耻齿炽饬鸱冲冲虫宠铳畴踌筹绸俦帱雠橱厨锄雏础储触处刍绌蹰传钏疮闯创怆锤缍纯鹑绰辍龊辞词赐鹚聪葱囱从丛苁骢枞凑辏蹿窜撺错锉鹾达哒鞑带贷骀绐担单郸掸胆惮诞弹殚赕瘅箪当挡党荡档谠砀裆捣岛祷导盗焘灯邓镫敌涤递缔籴诋谛绨觌镝颠点垫电巅钿癫钓调铫鲷谍叠鲽钉顶锭订铤丢铥东动栋冻岽鸫窦犊独读赌镀渎椟牍笃黩锻断缎簖兑队对怼镦吨顿钝炖趸夺堕铎鹅额讹恶饿谔垩阏轭锇锷鹗颚颛鳄诶儿尔饵贰迩铒鸸鲕发罚阀珐矾钒烦贩饭访纺钫鲂飞诽废费绯镄鲱纷坟奋愤粪偾丰枫锋风疯冯缝讽凤沣肤辐抚辅赋复负讣妇缚凫驸绂绋赙麸鲋鳆钆该钙盖赅杆赶秆赣尴擀绀冈刚钢纲岗戆镐睾诰缟锆搁鸽阁铬个纥镉颍给亘赓绠鲠龚宫巩贡钩沟苟构购够诟缑觏蛊顾诂毂钴锢鸪鹄鹘剐挂鸹掴关观馆惯贯诖掼鹳鳏广犷规归龟闺轨诡贵刽匦刿妫桧鲑鳜辊滚衮绲鲧锅国过埚呙帼椁蝈铪骇韩汉阚绗颉号灏颢阂鹤贺诃阖蛎横轰鸿红黉讧荭闳鲎壶护沪户浒鹕哗华画划话骅桦铧怀坏欢环还缓换唤痪焕涣奂缳锾鲩黄谎鳇挥辉毁贿秽会烩汇讳诲绘诙荟哕浍缋珲晖荤浑诨馄阍获货祸钬镬击机积饥迹讥鸡绩缉极辑级挤几蓟剂济计记际继纪讦诘荠叽哜骥玑觊齑矶羁虿跻霁鲚鲫夹荚颊贾钾价驾郏浃铗镓蛲歼监坚笺间艰缄茧检碱硷拣捡简俭减荐槛鉴践贱见键舰剑饯渐溅涧谏缣戋戬睑鹣笕鲣鞯将浆蒋桨奖讲酱绛缰胶浇骄娇搅铰矫侥脚饺缴绞轿较挢峤鹪鲛阶节洁结诫届疖颌鲒紧锦仅谨进晋烬尽劲荆茎卺荩馑缙赆觐鲸惊经颈静镜径痉竞净刭泾迳弪胫靓纠厩旧阄鸠鹫驹举据锯惧剧讵屦榉飓钜锔窭龃鹃绢锩镌隽觉决绝谲珏钧军骏皲开凯剀垲忾恺铠锴龛闶钪铐颗壳课骒缂轲钶锞颔垦恳龈铿抠库裤喾块侩郐哙脍宽狯髋矿旷况诓诳邝圹纩贶亏岿窥馈溃匮蒉愦聩篑阃锟鲲扩阔蛴蜡腊莱来赖崃徕涞濑赉睐铼癞籁蓝栏拦篮阑兰澜谰揽览懒缆烂滥岚榄斓镧褴琅阆锒捞劳涝唠崂铑铹痨乐鳓镭垒类泪诔缧篱狸离鲤礼丽厉励砾历沥隶俪郦坜苈莅蓠呖逦骊缡枥栎轹砺锂鹂疠粝跞雳鲡鳢俩联莲连镰怜涟帘敛脸链恋炼练蔹奁潋琏殓裢裣鲢粮凉两辆谅魉疗辽镣缭钌鹩猎临邻鳞凛赁蔺廪檩辚躏龄铃灵岭领绫棂蛏鲮馏刘浏骝绺镏鹨龙聋咙笼垄拢陇茏泷珑栊胧砻楼娄搂篓偻蒌喽嵝镂瘘耧蝼髅芦卢颅庐炉掳卤虏鲁赂禄录陆垆撸噜闾泸渌栌橹轳辂辘氇胪鸬鹭舻鲈峦挛孪滦乱脔娈栾鸾銮抡轮伦仑沦纶论囵萝罗逻锣箩骡骆络荦猡泺椤脶镙驴吕铝侣屡缕虑滤绿榈褛锊呒妈玛码蚂马骂吗唛嬷杩买麦卖迈脉劢瞒馒蛮满谩缦镘颡鳗猫锚铆贸麽没镁门闷们扪焖懑钔锰梦眯谜弥觅幂芈谧猕祢绵缅渑腼黾庙缈缪灭悯闽闵缗鸣铭谬谟蓦馍殁镆谋亩钼呐钠纳难挠脑恼闹铙讷馁内拟腻铌鲵撵辇鲶酿鸟茑袅聂啮镊镍陧蘖嗫颟蹑柠狞宁拧泞苎咛聍钮纽脓浓农侬哝驽钕诺傩疟欧鸥殴呕沤讴怄瓯盘蹒庞抛疱赔辔喷鹏纰罴铍骗谝骈飘缥频贫嫔苹凭评泼颇钋扑铺朴谱镤镨栖脐齐骑岂启气弃讫蕲骐绮桤碛颀颃鳍牵钎铅迁签谦钱钳潜浅谴堑佥荨悭骞缱椠钤枪呛墙蔷强抢嫱樯戗炝锖锵镪羟跄锹桥乔侨翘窍诮谯荞缲硗跷窃惬锲箧钦亲寝锓轻氢倾顷请庆揿鲭琼穷茕蛱巯赇虮鳅趋区躯驱龋诎岖阒觑鸲颧权劝诠绻辁铨却鹊确阕阙悫让饶扰绕荛娆桡热韧认纫饪轫荣绒嵘蝾缛铷颦软锐蚬闰润洒萨飒鳃赛伞毵糁丧骚扫缫涩啬铯穑杀刹纱铩鲨筛晒酾删闪陕赡缮讪姗骟钐鳝墒伤赏垧殇觞烧绍赊摄慑设厍滠畲绅审婶肾渗诜谂渖声绳胜师狮湿诗时蚀实识驶势适释饰视试谥埘莳弑轼贳铈鲥寿兽绶枢输书赎属术树竖数摅纾帅闩双谁税顺说硕烁铄丝饲厮驷缌锶鸶耸怂颂讼诵擞薮馊飕锼苏诉肃谡稣虽随绥岁谇孙损笋荪狲缩琐锁唢睃獭挞闼铊鳎台态钛鲐摊贪瘫滩坛谭谈叹昙钽锬顸汤烫傥饧铴镗涛绦讨韬铽腾誊锑题体屉缇鹈阗条粜龆鲦贴铁厅听烃铜统恸头钭秃图钍团抟颓蜕饨脱鸵驮驼椭箨鼍袜娲腽弯湾顽万纨绾网辋韦违围为潍维苇伟伪纬谓卫诿帏闱沩涠玮韪炜鲔温闻纹稳问阌瓮挝蜗涡窝卧莴龌呜钨乌诬无芜吴坞雾务误邬庑怃妩骛鹉鹜锡牺袭习铣戏细饩阋玺觋虾辖峡侠狭厦吓硖鲜纤贤衔闲显险现献县馅羡宪线苋莶藓岘猃娴鹇痫蚝籼跹厢镶乡详响项芗饷骧缃飨萧嚣销晓啸哓潇骁绡枭箫协挟携胁谐写泻谢亵撷绁缬锌衅兴陉荥凶汹锈绣馐鸺虚嘘须许叙绪续诩顼轩悬选癣绚谖铉镟学谑泶鳕勋询寻驯训讯逊埙浔鲟压鸦鸭哑亚讶垭娅桠氩阉烟盐严岩颜阎艳厌砚彦谚验厣赝俨兖谳恹闫酽魇餍鼹鸯杨扬疡阳痒养样炀瑶摇尧遥窑谣药轺鹞鳐爷页业叶靥谒邺晔烨医铱颐遗仪蚁艺亿忆义诣议谊译异绎诒呓峄饴怿驿缢轶贻钇镒镱瘗舣荫阴银饮隐铟瘾樱婴鹰应缨莹萤营荧蝇赢颖茔莺萦蓥撄嘤滢潆璎鹦瘿颏罂哟拥佣痈踊咏镛优忧邮铀犹诱莸铕鱿舆鱼渔娱与屿语狱誉预驭伛俣谀谕蓣嵛饫阈妪纡觎欤钰鹆鹬龉鸳渊辕园员圆缘远橼鸢鼋约跃钥粤悦阅钺郧匀陨运蕴酝晕韵郓芸恽愠纭韫殒氲杂灾载攒暂赞瓒趱錾赃脏驵凿枣责择则泽赜啧帻箦贼谮赠综缯轧铡闸栅诈斋债毡盏斩辗崭栈战绽谵张涨帐账胀赵诏钊蛰辙锗这谪辄鹧贞针侦诊镇阵浈缜桢轸赈祯鸩挣睁狰争帧症郑证诤峥钲铮筝织职执纸挚掷帜质滞骘栉栀轵轾贽鸷蛳絷踬踯觯钟终种肿众锺诌轴皱昼骤纣绉猪诸诛烛瞩嘱贮铸驻伫槠铢专砖转赚啭馔颞桩庄装妆壮状锥赘坠缀骓缒谆准着浊诼镯兹资渍谘缁辎赀眦锱龇鲻踪总纵偬邹诹驺鲰诅组镞钻缵躜鳟翱并卜沉丑淀迭斗范干皋硅柜后伙秸杰诀夸里凌么霉捻凄扦圣尸抬涂洼喂污锨咸蝎彝涌游吁御愿岳云灶扎札筑于志注凋讠谫郄勐凼坂垅垴埯埝苘荬荮莜莼菰藁揸吒吣咔咝咴噘噼嚯幞岙嵴彷徼犸狍馀馇馓馕愣憷懔丬溆滟溷漤潴澹甯纟绔绱珉枧桊桉槔橥轱轷赍肷胨飚煳煅熘愍淼砜磙眍钚钷铘铞锃锍锎锏锘锝锪锫锿镅镎镢镥镩镲稆鹋鹛鹱疬疴痖癯裥襁耢颥螨麴鲅鲆鲇鲞鲴鲺鲼鳊鳋鳘鳙鞒鞴齄";
}

- (NSString *)traditionalCode {
    return @"锕皚藹礙愛嗳嫒瑷暧霭谙铵鹌肮襖奧媪骜鳌壩罷钯擺敗呗頒辦絆钣幫綁鎊謗剝飽寶報鮑鸨龅輩貝鋇狽備憊鹎贲锛繃筆畢斃幣閉荜哔滗铋筚跸邊編貶變辯辮苄缏邊標骠飑飙镖镳鳔鼈別癟瀕濱賓擯傧缤槟殡膑镔髌鬓餅禀撥缽鉑駁饽钹鹁補钸財參蠶殘慚慘燦骖黪蒼艙倉滄廁側冊測測層詫锸侪钗攙摻蟬饞讒纏鏟産闡顫冁谄谶蒇忏婵骣觇禅镡場嘗長償腸廠暢伥苌怅阊鲳鈔車徹砗塵陳襯伧谌榇碜龀撐稱懲誠騁枨柽铖铛癡遲馳恥齒熾饬鸱沖沖蟲寵铳疇躊籌綢俦疇雠櫥廚鋤雛礎儲觸處刍礎蹰傳钏瘡闖創怆錘缍純鹑綽辍龊辭詞賜鹚聰蔥囪從叢從骢縱湊辏躥竄撺錯锉鹾達哒鞑帶貸骀绐擔單鄲撣膽憚誕彈殚赕瘅箪當擋黨蕩檔谠砀裆搗島禱導盜焘燈鄧镫敵滌遞締籴诋谛绨觌镝顛點墊電巅钿癫釣調铫鲷諜疊鲽釘頂錠訂铤丟铥東動棟凍凍鸫窦犢獨讀賭鍍犢椟牍笃黩鍛斷緞簖兌隊對對镦噸頓鈍炖趸奪墮铎鵝額訛惡餓谔垩阏轭锇锷鹗颚颛鳄诶兒爾餌貳迩铒鸸鲕發罰閥琺礬釩煩販飯訪紡钫鲂飛誹廢費绯镄鲱紛墳奮憤糞偾豐楓鋒風瘋馮縫諷鳳沣膚輻撫輔賦複負訃婦縛凫驸绂绋赙麸鲋鳆钆該鈣蓋赅杆趕稈贛尴擀绀岡剛鋼綱崗戆鎬睾诰缟锆擱鴿閣鉻個纥镉颍給亘赓绠鲠龔宮鞏貢鈎溝苟構購夠诟缑觏蠱顧估毂沽锢鸪鹄鹘剮挂鸹掴關觀館慣貫诖掼鹳鳏廣犷規歸龜閨軌詭貴劊軌刿妫桧鲑鳜輥滾衮绲鲧鍋國過埚呙帼椁蝈哈駭韓漢阚绗颉號灏颢閡鶴賀诃阖蛎橫轟鴻紅黉讧荭闳鲎壺護滬戶浒鹕嘩華畫劃話骅桦铧懷壞歡環還緩換喚瘓煥渙奂缳锾鲩黃謊鳇揮輝毀賄穢會燴彙諱誨繪诙荟哕會缋珲晖葷渾诨馄阍獲貨禍夥獲擊機積饑迹譏雞績緝極輯級擠幾薊劑濟計記際繼紀讦诘荠叽擠骥玑觊齑矶羁虿跻霁鲚鲫夾莢頰賈鉀價駕郏浃铗镓蛲殲監堅箋間艱緘繭檢堿鹼揀撿簡儉減薦檻鑒踐賤見鍵艦劍餞漸濺澗谏缣戋戬睑鹣笕鲣鞯將漿蔣槳獎講醬绛缰膠澆驕嬌攪鉸矯僥腳餃繳絞轎較挢峤鹪鲛階節潔結誡屆疖颌鲒緊錦僅謹進晉燼盡勁荊莖卺荩馑缙赆觐鯨驚經頸靜鏡徑痙競淨刭泾迳弪胫靓糾廄舊阄鸠鹫駒舉據鋸懼劇讵屦榉飓钜锔窭龃鵑絹锩镌隽覺決絕谲珏鈞軍駿皲開凱凱垲忾恺铠锴龛闶钪铐顆殼課骒缂轲钶锞颔墾懇龈铿摳庫褲喾塊儈郐哙脍寬狯髋礦曠況诓诳邝圹礦贶虧巋窺饋潰匮蒉愦聩篑阃锟鲲擴闊蛴蠟臘萊來賴崃徕涞濑赉睐铼癞籁藍欄攔籃闌蘭瀾讕攬覽懶纜爛濫岚榄斓镧褴琅阆锒撈勞澇唠撈铑铹痨樂鳓鐳壘類淚诔缧籬狸離鯉禮麗厲勵礫曆瀝隸俪郦坜苈位離曆逦骊缡枥栎轹砺锂鹂厲粝躍雳鲡鳢倆聯蓮連鐮憐漣簾斂臉鏈戀煉練蔹奁斂琏殓裢裣鲢糧涼兩輛諒魉療遼鐐缭钌鹩獵臨鄰鱗凜賃蔺廪檩辚躏齡鈴靈嶺領绫棂蛏鲮餾劉浏骝绺镏鹨龍聾嚨籠壟攏隴嚨壟珑栊胧砻樓婁摟簍偻蒌喽摟镂瘘耧蝼髅蘆盧顱廬爐擄鹵虜魯賂祿錄陸垆撸魯闾泸渌栌橹轳辂辘氇胪鸬鹭舻鲈巒攣孿灤亂脔娈栾鸾銮掄輪倫侖淪綸論掄蘿羅邏鑼籮騾駱絡荦猡樂椤脶镙驢呂鋁侶屢縷慮濾綠榈褛锊呒媽瑪碼螞馬罵嗎唛嬷杩買麥賣邁脈劢瞞饅蠻滿謾缦镘颡鳗貓錨鉚貿麽沒鎂門悶們扪焖懑钔錳夢眯謎彌覓冪芈谧猕祢綿緬渑腼黾廟缈缪滅憫閩闵缗鳴銘謬谟蓦馍殁镆謀畝钼呐鈉納難撓腦惱鬧铙讷餒內擬膩铌鲵攆辇鲶釀鳥鳥袅聶齧鑷鎳陧蘖聶颟蹑檸獰甯擰濘苎咛聍鈕紐膿濃農侬膿驽钕諾傩瘧歐鷗毆嘔漚讴怄歐盤蹒龐抛疱賠辔噴鵬批罴铍騙谝骈飄缥頻貧嫔蘋憑評潑頗钋撲鋪樸譜镤镨棲臍齊騎豈啓氣棄訖薪骐绮桤碛颀颃鳍牽釺鉛遷簽謙錢鉗潛淺譴塹佥荨悭骞缱椠钤槍嗆牆薔強搶牆樯戗炝锖锵镪羟跄鍬橋喬僑翹竅诮谯荞缲硗跷竊惬锲箧欽親寢浸輕氫傾頃請慶揿鲭瓊窮茕蛱巯赇虮鳅趨區軀驅齲诎區阒觑鸲顴權勸诠绻辁铨卻鵲確阕阙悫讓饒擾繞荛娆桡熱韌認紉饪轫榮絨嵘蝾缛铷颦軟銳蚬閏潤灑薩飒鰓賽傘毵糁喪騷掃缫澀啬铯穑殺刹紗铩鲨篩曬酾刪閃陝贍繕讪姗骟钐鳝墒傷賞垧殇觞燒紹賒攝懾設厍滠畲紳審嬸腎滲诜谂渖聲繩勝師獅濕詩時蝕實識駛勢適釋飾視試益埘莳弑轼贳铈鲥壽獸绶樞輸書贖屬術樹豎數摅纾帥闩雙誰稅順說碩爍铄絲飼厮驷缌锶鸶聳慫頌訟誦擻數馊飕锼蘇訴肅谡稣雖隨綏歲谇孫損筍荪狲縮瑣鎖唢睃獺撻闼铊鳎台態钛鲐攤貪癱灘壇譚談歎昙坦锬顸湯燙傥湯铴镗濤縧討韬铽騰謄銻題體屜缇鹈阗條粜龆鲦貼鐵廳聽烴銅統恸頭钭禿圖钍團專頹蛻饨脫鴕馱駝橢箨鼍襪娲腽彎灣頑萬纨绾網辋韋違圍爲濰維葦偉僞緯謂衛诿帏闱僞涠玮韪炜鲔溫聞紋穩問阌甕撾蝸渦窩臥莴龌嗚鎢烏誣無蕪吳塢霧務誤邬庑怃妩骛鹉鹜錫犧襲習銑戲細饩阋玺觋蝦轄峽俠狹廈嚇硖鮮纖賢銜閑顯險現獻縣餡羨憲線苋莶藓岘猃閑鹇痫蚝籼跹廂鑲鄉詳響項鄉饷骧缃飨蕭囂銷曉嘯曉潇骁绡枭箫協挾攜脅諧寫瀉謝亵撷泄缬鋅釁興陉荥凶洶鏽繡馐鸺虛噓須許敘緒續诩顼軒懸選癬絢谖铉镟學谑泶鳕勳詢尋馴訓訊遜埙尋鲟壓鴉鴨啞亞訝垭娅桠氩閹煙鹽嚴岩顔閻豔厭硯彥諺驗厣赝俨兖谳恹闫酽魇餍鼹鴦楊揚瘍陽癢養樣炀瑤搖堯遙窯謠藥轺鹞鳐爺頁業葉靥谒邺晔烨醫銥頤遺儀蟻藝億憶義詣議誼譯異繹诒呓峄饴怿驿缢轶贻钇镒镱瘗舣蔭陰銀飲隱铟瘾櫻嬰鷹應纓瑩螢營熒蠅贏穎茔莺萦蓥撄嘤滢潆櫻鹦瘿颏罂喲擁傭癰踴詠镛優憂郵鈾猶誘莸铕鱿輿魚漁娛與嶼語獄譽預馭伛俣谀谕蓣嵛饫阈妪于觎欤钰鹆鹬龉鴛淵轅園員圓緣遠橼鸢鼋約躍鑰粵悅閱钺鄖勻隕運蘊醞暈韻郓芸恽愠纭韫隕氲雜災載攢暫贊攢趱錾贓髒驵鑿棗責擇則澤赜啧帻箦賊谮贈綜缯軋鍘閘柵詐齋債氈盞斬輾嶄棧戰綻谵張漲帳賬脹趙诏钊蟄轍鍺這谪辄鹧貞針偵診鎮陣貞缜桢轸赈祯鸩掙睜猙爭幀症鄭證诤峥钲铮筝織職執紙摯擲幟質滯骘栉栀職轾贽鸷蛳絷踬踯觯鍾終種腫衆锺謅軸皺晝驟纣绉豬諸誅燭矚囑貯鑄駐伫槠铢專磚轉賺轉馔颞樁莊裝妝壯狀錐贅墜綴骓缒諄准著濁诼镯茲資漬谘缁辎赀眦锱龇鲻蹤總縱偬鄒诹驺鲰詛組镞鑽缵躜鳟翺並蔔沈醜澱叠鬥範幹臯矽櫃後夥稭傑訣誇裏淩麽黴撚淒扡聖屍擡塗窪喂汙鍁鹹蠍彜湧遊籲禦願嶽雲竈紮劄築于志注凋讠谫郄勐凼坂垅垴埯埝苘買荮莜莼菰藁揸吒吣咔咝咴噘霹嚯幞岙嵴彷徼瑪狍馀馇馓馕愣憷懔丬敘豔溷婪潴澹甯纟绔绱珉枧桊桉槔橥轱轷赍肷胨飚葫煅熘愍淼砜磙眍钚钷铘吊锃锍锎锏锘锝锪锫锿镅镎镢镥镩察稆鹋鹛鹱疬疴痖癯裥襁耢颥螨麴鲅鲆鲇鲞鲴鲺鲼鳊鳋鳘鳙鞒鞴齄";
}

@end


#pragma mark - IP相关
@implementation NSString (YMParsingExtension)

#pragma mark IP获取
/** 获取域名真实IP */
- (NSArray <NSString *> *)ymDomainToRealIP {
    NSString *hostname = self;
    hostname = [hostname stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    hostname = [hostname stringByReplacingOccurrencesOfString:@"https://" withString:@""];
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
                    [tempDNS addObject:strDNS];
                }
            }
        }
        CFRelease(hostRef);
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
 获取CIRD
 @param fromIP IP的开始位置（192.168.0.1格式）
 @param toIP IP的结束位置（192.168.0.1格式）
 @return 返回类似"192.168.0.1/32" 格式的IP
 */
+ (NSArray <NSString *> *)ymCIDRFromIP:(NSString *)fromIP
                                  toIP:(NSString *)toIP {
    
    if ([fromIP isEqual:toIP]) {
        return @[[NSString stringWithFormat:@"%@/32", fromIP]];
    }
    
    // 将原始IP以'.'分割成4个单独的十进制
    NSArray * fromIPs = [fromIP componentsSeparatedByString:@"."];
    NSArray * toIPs = [toIP componentsSeparatedByString:@"."];
    if ([fromIPs count] < 4 || [toIPs count] < 4) {
        return @[@"格式错误"];
    }
    
    // 转换成二进制并且补0
    NSMutableArray * mFromIPs = [NSMutableArray array];
    [fromIPs enumerateObjectsUsingBlock:^(NSString * ip, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * binaryIP = [NSString ymDec:[ip integerValue]
                                       toType:kDigitType_2];
        binaryIP = [binaryIP ymFillStrWithMaxLength:8 fillStr:@"0"];
        [mFromIPs addObject:binaryIP];
    }];
    
    // 转换成二进制并且补0
    NSMutableArray * mToIPs = [NSMutableArray array];
    [toIPs enumerateObjectsUsingBlock:^(NSString * ip, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * binaryIP = [NSString ymDec:[ip integerValue]
                                       toType:kDigitType_2];
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
    long long startDecimal = [[NSString ymBin:completeFromIp toType:kDigitType_10] integerValue];
    long long endDecimal = [[NSString ymBin:completeToIp toType:kDigitType_10] integerValue];
    
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
        ip = [NSString stringWithFormat:@"%@/%ld", ip, (long)maxsize];
        [CIDR_IPs addObject:ip];
        startDecimal += pow(2, (32 - maxsize));
    }
    return CIDR_IPs;
}

/**
 从CIRD中获取IP范围
 @param CIDR 类似"192.168.0.1/32"
 @return 返回IP区间，数组中有且必定为两个IP，如[@"192.168.0.1", @"192.168.0.2"]
 */
+ (NSArray <NSString *> *)ymIPFromCIDR:(NSString *)CIDR {
    // 如果CIDR不存在或者不是CIDR格式
    if (!(CIDR && [CIDR ymValidateCIDR])) {
        return @[@"格式错误"];
    }
    
    // 获取IP地址和范围
    NSArray * separatedStrs = [CIDR componentsSeparatedByString:@"/"];
    NSString * startIP = [separatedStrs firstObject];
    NSInteger range = [[separatedStrs lastObject] integerValue];
    
    // 获取IP区间第一个IP的十进制
    NSInteger startIP_Decimal = [NSString ymDecimalFromIP:startIP reverse:NO];
    
    // 获取IP区间最后一个IP的十进制
    // 区间范围的大小为 2^(32-CIDR) - 1
    NSInteger offset = pow(2, (32 - range));
    NSInteger endIP_Decimal = offset - 1;
    
    NSString * endIP = [NSString ymIPFromDecimal:(startIP_Decimal + endIP_Decimal)
                                         reverse:NO];
    
    if (startIP && endIP) {
        return @[startIP, endIP];
    }
    return nil;
}

#pragma mark IP转换
/** 从Data中获取IP，Data必须为IP转为十六进制后的Data */
+ (NSString *)ymIPFromData:(NSData *)data {
    NSString * hexData = [self ymHexStrFromData:data];
    NSString * ip = [self ymIPFromHex:hexData reverse:NO];
    return ip;
}

/** 从Data中获取Port，Data必须为Port转为十六进制后的Data */
+ (NSString *)ymPortFromData:(NSData *)data {
    NSString * hex = [self ymHexStrFromData:data];
    NSString * port = [self ymHex:hex toType:kDigitType_10];
    return port;
}

/** 二进制转化为IP */
+ (NSString *)ymIPFromBinary:(NSString *)binaryStr reverse:(BOOL)reverse {
    if (!binaryStr) {
        return nil;
    }
    while (binaryStr.length != 32) {
        binaryStr = [NSString stringWithFormat:@"0%@", binaryStr];
    }
    NSString * IP = @"";
    for (NSInteger i = 0; i < 32; i= (i+8)) {
        NSRange range = NSMakeRange(i, 8);
        NSString * tempBinary = [binaryStr substringWithRange:range];
        NSString * childIP = [NSString ymBin:tempBinary toType:kDigitType_10];
        if (reverse) {
            IP = IP.length == 0 ? childIP : [NSString stringWithFormat:@"%@.%@", childIP, IP];
        } else {
            IP = IP.length == 0 ? childIP : [NSString stringWithFormat:@"%@.%@", IP, childIP];
        }
    }
    return IP;
}

/** 十进制转化为IP */
+ (NSString *)ymIPFromDecimal:(NSInteger)decimal reverse:(BOOL)reverse {
    NSString * binaryStr = [NSString ymDec:decimal toType:kDigitType_2];
    NSString * ip = [self ymIPFromBinary:binaryStr reverse:reverse];
    return ip;
}

/** 十六进制转化为IP */
+ (NSString *)ymIPFromHex:(NSString *)hex reverse:(BOOL)reverse {
    NSString * decimalStr = [self ymHex:hex toType:kDigitType_10];
    NSString * ip = [self ymIPFromDecimal:[decimalStr integerValue] reverse:reverse];
    return ip;
}

/** IP转化为二进制 */
+ (NSString *)ymBinaryFromIP:(NSString *)ip reverse:(BOOL)reverse {
    if (![ip ymValidateIP]) {
        return @"";
    }
    
    NSArray * childIPs = [ip componentsSeparatedByString:@"."];
    
    NSString * bin_32 = @"";
    for (NSString * childIP in childIPs) {
        NSString * bin_8 = [NSString ymDec:[childIP integerValue] toType:kDigitType_2];
        // 补足8位
        while (bin_8.length % 8 != 0) {
            bin_8 = [NSString stringWithFormat:@"0%@", bin_8];
        }
        if (reverse) {
            // 前后倒置拼接（如192.168.0.1转换成二进制后为00000001 00000000 10101000 11000000）
            bin_32 = [NSString stringWithFormat:@"%@%@", bin_8, bin_32];
        } else {
            bin_32 = [NSString stringWithFormat:@"%@%@", bin_32, bin_8];
        }
    }
    return bin_32;
}

/** IP转化为十进制 */
+ (NSInteger)ymDecimalFromIP:(NSString *)ip reverse:(BOOL)reverse {
    if (![ip ymValidateIP]) {
        return 0;
    }

    NSString * bin_32 = [self ymBinaryFromIP:ip reverse:reverse];
    
    NSInteger decimal = [[NSString ymBin:bin_32 toType:kDigitType_10] integerValue];
    return decimal;
}

/** IP转化为十六进制 */
+ (NSString *)ymHexFromIP:(NSString *)ip reverse:(BOOL)reverse {
    NSInteger ipDecimal = [self ymDecimalFromIP:ip reverse:reverse];
    NSString * hex = [self ymDec:ipDecimal toType:kDigitType_16];
    return hex;
}

#pragma mark private
+ (NSString *)longToIp:(long long)longIP {
    NSString * binaryStr = [NSString ymDec:longIP
                                    toType:kDigitType_2];
    
    while (binaryStr.length < 32) {
        binaryStr = [NSString stringWithFormat:@"0%@", binaryStr];
    }
    while (binaryStr.length > 32) {
        binaryStr = [binaryStr substringToIndex:binaryStr.length - 1];
    }
    
    NSString * IP = @"";
    for (NSInteger i = 0; i < binaryStr.length; i++) {
        if (i % 8 == 0) {
            NSString * IP1 = [binaryStr substringWithRange:NSMakeRange(i, 8)];
            NSInteger binary = [[NSString ymBin:IP1 toType:kDigitType_10] integerValue];
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


/**
 二进制转换为指定进制
 @param binary 二进制
 @param type 进制数类型
 @return 转换后的字符
 */
+ (NSString *)ymBin:(NSString *)binary
             toType:(kDigitType)type {
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

/**
 十进制转换为指定进制
 @param decimal 十进制
 @param type 进制数类型
 @return 转换后的字符
 */
+ (NSString *)ymDec:(NSInteger)decimal toType:(kDigitType)type {
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
             toType:(kDigitType)type
             length:(NSInteger)length {
    if (type == kDigitType_10) {
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
 十六进制转为指定进制
 @param hexadecimal 十六进制
 @param type 进制数类型
 @return 转换后的字符
 */
+ (NSString *)ymHex:(NSString *)hexadecimal
             toType:(kDigitType)type {
    // 为空,直接返回.
    if (hexadecimal == nil) {
        return nil;
    }
    
    // 判断是否有十六进制外的符号
    for (NSInteger i = 0; i < hexadecimal.length; i++) {
        NSString * tempChar = [[hexadecimal substringWithRange:NSMakeRange(i, 1)] uppercaseString];
        int ascii = [tempChar characterAtIndex:0];
        if (!(ascii >= 48 && ascii <= 57) &&
            !(ascii >= 65 && ascii <= 70)) {
            return nil;
        }
    }
    
    // 转为十进制，然后再转换
    NSScanner * scanner = [NSScanner scannerWithString:hexadecimal];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    NSInteger decimal = (NSInteger)longlongValue;
    return [self ymDec:decimal toType:type];
}


@end

#pragma mark - NSString Data
@implementation NSString (YMDataExtension)

/** NSData转十六进制 */
+ (NSString *)ymHexStrFromData:(NSData *)data {
    NSMutableString * mStr = [NSMutableString stringWithCapacity:data.length * 2];
    
    int byte = 0;
    for (NSInteger i = 0; i < data.length; i++) {
        [data getBytes:&byte range:NSMakeRange(i, 1)];
        [mStr appendFormat:@"%02x", byte];
    }
    return mStr;
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
- (NSString *)ymDateStrWithFormatter:(NSString *)formatter
                     originFormatter:(NSString *)originFormatter {
    // 纯数字字符串
    if ([self ymValidatePureNumber]) {
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
- (NSDate *)ymDateWithFormatter:(NSString *)formatter {
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
- (NSInteger)ymTimeOffsetFromNow {
    // 获取当前时间
    NSDate * nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSInteger nowTimeInterval = [nowDate timeIntervalSince1970];
    return [self ymTimeOffsetFromTimeStamp:[NSString stringWithFormat:@"%ld", nowTimeInterval]];
}

/**
 获取与指定时间的时间偏移量（秒）
 @param timeStamp 指定时间
 @return 时间偏移量
 */
- (NSInteger)ymTimeOffsetFromTimeStamp:(NSString *)timeStamp {
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
- (NSString *)ymTimeFormater {
    // 判断是否为纯数字
    if (![self ymValidatePureNumber]) {
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
- (NSString *)ymTimeFormatter:(NSString *)formatter {
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:[self integerValue]];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSString * formatterDate = [dateFormatter stringFromDate:date];
    return formatterDate;
}

@end

#pragma mark - NSString 验证类目
@implementation NSString (YMPredicateCategory)

#pragma mark - 验证银行卡（https://blog.csdn.net/yqwang75457/article/details/72627542）
/** 网络验证是否为银行卡号 */
- (void)ymValidateBankCardComplete:(RequestCompleteBlock)completeBlock
                              fail:(RequestFailBlock)failBlock {
        
    // 请求路径
    NSString * str1 = @"a";
    NSString * str2 = @"p";
    NSString * str3 = @"y";
    NSString * requestURL = [NSString stringWithFormat:@"https://ccdcapi.%@li%@a%@.com/validateAndCacheCardInfo.json?_input_charset=utf-8&cardNo=%@&cardBinCheck=true", str1, str2, str3, self];
    
    // 创建url对象
    NSURL *url = [NSURL URLWithString:requestURL];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    // 创建参数字符串对象
    NSString *parmStr = [NSString stringWithFormat:@"method=album.channel.get&appKey=myKey&format=json&channel=t&pageNo=1&pageSize=10"];
    
    // 将字符串转换为NSData对象
    NSData *data = [parmStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failBlock) {
                failBlock(error);
            }
            return;
        }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (completeBlock) {
            BOOL isBankCard = [dic[@"validated"] boolValue];
            completeBlock(isBankCard);
        }
    }];
    [task resume];
}


/**
 验证是否为银行卡号
 luhn校验规则：16位银行卡号（19位通用）
 1.将未带校验位的 15（或18）位卡号从右依次编号 1 到 15（18），位于奇数位号上的数字乘以 2。
 2.将奇位乘积的个十位全部相加，再加上所有偶数位上的数字。
 3.将加法和加上校验位能被 10 整除。
 */
- (BOOL)ymValidateBankCard {
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


@end
#pragma clang diagnostic pop
#pragma mark - NSString 属性转换
@implementation NSString (YMProperty)

#pragma mark To
/**
NSString转NSDictionary
@return NSString
*/
- (NSDictionary *)ymToDictionary {
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingAllowFragments
                                             error:nil];
}

/**
NSString转NSArray
@return NSString
*/
- (NSArray *)ymToArray {
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingAllowFragments
                                             error:nil];
}

/// NSString转ASCII
- (int)ymToAscii {
    return [self characterAtIndex:0];
}

#pragma mark From
/// ASCII转NSString
/// @param ascii 传入int(65)型或者char('a')型
+ (NSString *)ymFromAscii:(int)ascii {
    return [NSString stringWithFormat:@"%c", ascii];
}


@end
