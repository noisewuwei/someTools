//
//  NSColor+YMCategory.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/6/2.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
#define YMColorHex(colorHex) [NSColor ymColorWithHex:colorHex]
#define YMColorHex_A(colorHex, alphaValue) [NSColor ymColorWithHex:colorHex alpha:alphaValue]
@interface NSColor (YMCategory)

/// 由十六进制获取颜色
/// @param hex 十六进制字符串
+ (NSColor *)ymColorWithHex:(NSString *)hex;

/// 由十六进制获取颜色
/// @param hex 十六进制字符串
/// @param alpha 透明度
+ (NSColor *)ymColorWithHex:(NSString *)hex
                      alpha:(CGFloat)alpha;

/// 颜色透明度
- (NSColor * (^)(CGFloat alpha))ymAlpha;

/** NSColor转换为NSImage */
- (NSImage *)toImage;

@end

NS_ASSUME_NONNULL_END
