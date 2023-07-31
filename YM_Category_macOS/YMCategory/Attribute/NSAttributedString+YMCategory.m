//
//  NSAttributedString+YMCategory.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/6/4.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "NSAttributedString+YMCategory.h"
#import "NSParagraphStyle+YMCategory.h"
#import <AppKit/AppKit.h>




#pragma mark - NSAttributedString (Private)
@interface NSAttributedString (Private) @end
@implementation NSAttributedString (Private)
- (id)ymAttribute:(NSString *)attributeName
          atIndex:(NSUInteger)index {
    if (!attributeName) return nil;
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attribute:attributeName atIndex:index effectiveRange:NULL];
}

@end
#pragma mark - NSMutableAttributedString (Private)
@interface NSMutableAttributedString (Private) @end
@implementation NSMutableAttributedString (Private)
- (void)ym_setAttribute:(NSString *)name value:(id)value {
    NSRange range = NSMakeRange(0, self.length);
    if (!name || [NSNull isEqual:name]) return;
    if (value && ![NSNull isEqual:value]) [self addAttribute:name value:value range:range];
    else [self removeAttribute:name range:range];
}

@end





#pragma mark - NSAttributedString (Character) 字符属性
@implementation NSAttributedString (Character)

- (NSFont *)ymFont {
    NSFont *font = [self ymAttribute:NSFontAttributeName atIndex:0];
    if (font) {
        if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) {
            CTFontRef CTFont = (__bridge CTFontRef)(font);
            CFStringRef name = CTFontCopyPostScriptName(CTFont);
            CGFloat size = CTFontGetSize(CTFont);
            if (!name) {
                font = nil;
            } else {
                font = [NSFont fontWithName:(__bridge NSString *)(name) size:size];
                CFRelease(name);
            }
    }
}
    return font;
}

- (NSNumber *)ymKern {
    return [self ymAttribute:NSKernAttributeName atIndex:0];
}

- (NSColor *)ymColor {
    NSColor *color = [self ymAttribute:NSForegroundColorAttributeName atIndex:0];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self ymAttribute:(NSString *)kCTForegroundColorAttributeName atIndex:0]);
        if (ref) {
            color = [NSColor colorWithCGColor:ref];
        }
    }
    if (color && ![color isKindOfClass:[NSColor class]]) {
        if (CFGetTypeID((__bridge CFTypeRef)(color)) == CGColorGetTypeID()) {
            color = [NSColor colorWithCGColor:(__bridge CGColorRef)(color)];
        } else {
            color = nil;
        }
    }
    return color;
}

- (NSColor *)ymBackgroundColor {
    return [self ymAttribute:NSBackgroundColorAttributeName atIndex:0];
}

- (NSNumber *)ymStrokeWidth {
    return [self ymAttribute:NSStrokeWidthAttributeName atIndex:0];
}

- (NSColor *)ymStrokeColor {
    NSColor *color = [self ymAttribute:NSStrokeColorAttributeName atIndex:0];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self ymAttribute:(NSString *)kCTStrokeColorAttributeName atIndex:0]);
        color = [NSColor colorWithCGColor:ref];
    }
    return color;
}

- (NSShadow *)ymShadow {
    return [self ymAttribute:NSShadowAttributeName atIndex:0];
}

- (NSUnderlineStyle)ymStrikethroughStyle {
    NSNumber *style = [self ymAttribute:NSStrikethroughStyleAttributeName atIndex:0];
    return style.integerValue;
}

- (NSColor *)ymStrikethroughColor {
    return [self ymAttribute:NSStrikethroughColorAttributeName atIndex:0];
}

- (NSUnderlineStyle)ymUnderlineStyle {
    NSNumber * style = [self ymAttribute:NSUnderlineStyleAttributeName atIndex:0];
    return style.integerValue;
}

- (NSColor *)ymUnderlineColor {
    NSColor *color = nil;
    color = [self ymAttribute:NSUnderlineColorAttributeName atIndex:0];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self ymAttribute:(NSString *)kCTUnderlineColorAttributeName atIndex:0]);
        color = [NSColor colorWithCGColor:ref];
    }
    return color;
}

- (NSNumber *)ymLigature {
    return [self ymAttribute:NSLigatureAttributeName atIndex:0];
}

- (NSString *)ymTextEffect {
    return [self ymAttribute:NSTextEffectAttributeName atIndex:0];
}

- (NSNumber *)ymObliqueness {
    return [self ymAttribute:NSObliquenessAttributeName atIndex:0];
}

- (NSNumber *)ymExpansion {
    return [self ymAttribute:NSExpansionAttributeName atIndex:0];
}

- (NSNumber *)ymBaselineOffset {
    return [self ymAttribute:NSBaselineOffsetAttributeName atIndex:0];
}

- (BOOL)ymVerticalGlyphForm {
    NSNumber *num = [self ymAttribute:NSVerticalGlyphFormAttributeName atIndex:0];
    return num.boolValue;
}

- (NSString *)ymLanguage {
    return [self ymAttribute:(id)kCTLanguageAttributeName atIndex:0];
}

- (NSArray<NSNumber *> *)ymWritingDirection {
    return [self ymAttribute:(id)kCTWritingDirectionAttributeName atIndex:0];
}

- (NSParagraphStyle *)ymParagraphStyle {
    NSParagraphStyle *style = [self ymAttribute:NSParagraphStyleAttributeName
                                        atIndex:0];
    if (style) {
        if (CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) { \
            style = [NSParagraphStyle yy_styleWithCTStyle:(__bridge CTParagraphStyleRef)(style)];
        }
    }
    return style;
}

@end

#pragma mark - NSAttributedString (Character) 字符属性
@implementation NSMutableAttributedString (Character)

- (void)setYmFont:(NSFont *)ymFont {
    [self ym_setAttribute:NSFontAttributeName value:ymFont];
}

- (void)setYmKern:(NSNumber *)ymKern {
    [self ym_setAttribute:NSKernAttributeName value:ymKern];
}

- (void)setYmColor:(NSColor *)ymColor {
    [self ym_setAttribute:(id)kCTForegroundColorAttributeName value:(id)ymColor.CGColor ];
    [self ym_setAttribute:NSForegroundColorAttributeName value:ymColor];
}

- (void)setYmBackgroundColor:(NSColor *)ymBackgroundColor {
    [self ym_setAttribute:NSBackgroundColorAttributeName value:ymBackgroundColor];
}

- (void)setYmStrokeWidth:(NSNumber *)ymStrokeWidth {
    [self ym_setAttribute:NSStrokeWidthAttributeName value:ymStrokeWidth];
}

- (void)setYmStrokeColor:(NSColor *)ymStrokeColor {
    [self ym_setAttribute:(id)kCTStrokeColorAttributeName value:(id)ymStrokeColor.CGColor];
    [self ym_setAttribute:NSStrokeColorAttributeName value:ymStrokeColor];
}

- (void)setYmShadow:(NSShadow *)ymShadow {
    [self ym_setAttribute:NSShadowAttributeName value:ymShadow];
}

- (void)setYmStrikethroughStyle:(NSUnderlineStyle)ymStrikethroughStyle {
    NSNumber *style = ymStrikethroughStyle == 0 ? nil : @(ymStrikethroughStyle);
    [self ym_setAttribute:NSStrikethroughStyleAttributeName value:style];
}

- (void)setYmStrikethroughColor:(NSColor *)ymStrikethroughColor {
    [self ym_setAttribute:NSStrikethroughColorAttributeName value:ymStrikethroughColor];
}

- (void)setYmUnderlineStyle:(NSUnderlineStyle)ymUnderlineStyle {
    NSNumber *style = ymUnderlineStyle == 0 ? nil : @(ymUnderlineStyle);
    [self ym_setAttribute:NSUnderlineStyleAttributeName value:style];
}

- (void)setYmUnderlineColor:(NSColor *)ymUnderlineColor {
    [self ym_setAttribute:(id)kCTUnderlineColorAttributeName value:(id)ymUnderlineColor.CGColor];
    [self ym_setAttribute:NSUnderlineColorAttributeName value:ymUnderlineColor];
}

- (void)setYmLigature:(NSNumber *)ymLigature {
    [self ym_setAttribute:NSLigatureAttributeName value:ymLigature];
}

- (void)setYmTextEffect:(NSString *)ymTextEffect {
    [self ym_setAttribute:NSTextEffectAttributeName value:ymTextEffect];
}

- (void)setYmObliqueness:(NSNumber *)ymObliqueness {
    [self ym_setAttribute:NSObliquenessAttributeName value:ymObliqueness];
}

- (void)setYmExpansion:(NSNumber *)ymExpansion {
    [self ym_setAttribute:NSExpansionAttributeName value:ymExpansion];
}

- (void)setYmBaselineOffset:(NSNumber *)ymBaselineOffset {
    [self ym_setAttribute:NSBaselineOffsetAttributeName value:ymBaselineOffset];
}

- (void)setYmVerticalGlyphForm:(BOOL)ymVerticalGlyphForm {
    NSNumber *v = ymVerticalGlyphForm ? @(YES) : nil;
    [self ym_setAttribute:NSVerticalGlyphFormAttributeName value:v];
}

- (void)setYmLanguage:(NSString *)ymLanguage {
    [self ym_setAttribute:(id)kCTLanguageAttributeName value:ymLanguage];
}

- (void)setYmWritingDirection:(NSArray<NSNumber *> *)ymWritingDirection {
    [self ym_setAttribute:(id)kCTWritingDirectionAttributeName value:ymWritingDirection];
}


- (void)setYmParagraphStyle:(NSParagraphStyle *)ymParagraphStyle {
    [self ym_setAttribute:NSParagraphStyleAttributeName value:ymParagraphStyle];
}


@end




















#pragma mark - NSAttributedString (Paragraph) 段落
@implementation NSAttributedString (Paragraph)

#define ParagraphAttribute(_attr_) \
NSParagraphStyle *style = self.ymParagraphStyle; \
if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
return style. _attr_;
- (CGFloat)ymLineSpacing {
    ParagraphAttribute(lineSpacing);
}

- (CGFloat)ymParagraphSpacing {
    ParagraphAttribute(paragraphSpacing);
}

- (NSTextAlignment)ymAlignment {
    ParagraphAttribute(alignment);
}

- (CGFloat)ymHeadIndent {
    ParagraphAttribute(headIndent);
}

- (CGFloat)ymTailIndent {
    ParagraphAttribute(tailIndent);
}

- (CGFloat)ymFirstLineHeadIndent {
    ParagraphAttribute(firstLineHeadIndent);
}

- (CGFloat)ymMinimumLineHeight {
    ParagraphAttribute(minimumLineHeight);
}

- (CGFloat)ymMaximumLineHeight {
    ParagraphAttribute(maximumLineHeight);
}

- (NSLineBreakMode)ymLineBreakMode {
    ParagraphAttribute(lineBreakMode);
}

- (NSWritingDirection)ymBaseWritingDirection {
    ParagraphAttribute(baseWritingDirection);
}

- (CGFloat)ymLineHeightMultiple {
    ParagraphAttribute(lineHeightMultiple);
}

- (CGFloat)ymParagraphSpacingBefore {
    ParagraphAttribute(paragraphSpacingBefore);
}

- (float)ymHyphenationFactor {
    ParagraphAttribute(hyphenationFactor);
}

- (CGFloat)ymDefaultTabInterval {
    ParagraphAttribute(defaultTabInterval);
}

- (NSArray<NSTextTab *> *)ymTabStops {
    ParagraphAttribute(tabStops);
}

@end

#pragma mark - NSMutableAttributedString (Paragraph) 段落
@implementation NSMutableAttributedString (Paragraph)

#define ParagraphStyleSet(_attr_) \
[self enumerateAttribute:NSParagraphStyleAttributeName \
                 inRange:range \
                 options:kNilOptions \
              usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) { \
                  NSMutableParagraphStyle *style = nil; \
                  if (value) { \
                      if (CFGetTypeID((__bridge CFTypeRef)(value)) == CTParagraphStyleGetTypeID()) { \
                          value = [NSParagraphStyle yy_styleWithCTStyle:(__bridge CTParagraphStyleRef)(value)]; \
                      } \
                      if (value. _attr_ == _attr_) return; \
                      if ([value isKindOfClass:[NSMutableParagraphStyle class]]) { \
                          style = (id)value; \
                      } else { \
                          style = value.mutableCopy; \
                      } \
                  } else { \
                      if ([NSParagraphStyle defaultParagraphStyle]. _attr_ == _attr_) return; \
                      style = [NSParagraphStyle defaultParagraphStyle].mutableCopy; \
                  } \
                  style. _attr_ = _attr_; \
                  [self setYmParagraphStyle:style]; \
              }];
- (void)setYmAlignment:(NSTextAlignment)ymAlignment {
    NSRange range = NSMakeRange(0, self.length);
    NSTextAlignment alignment = ymAlignment;
    ParagraphStyleSet(alignment);
}

- (void)setYmParagraphSpacing:(CGFloat)ymParagraphSpacing {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat paragraphSpacing = ymParagraphSpacing;
    ParagraphStyleSet(paragraphSpacing);
}

- (void)setYmLineSpacing:(CGFloat)ymLineSpacing {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat lineSpacing = ymLineSpacing;
    ParagraphStyleSet(lineSpacing);
}

- (void)setYmHeadIndent:(CGFloat)ymHeadIndent {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat headIndent = ymHeadIndent;
    ParagraphStyleSet(headIndent);
}

- (void)setYmTailIndent:(CGFloat)ymTailIndent {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat tailIndent = ymTailIndent;
    ParagraphStyleSet(tailIndent);
}

- (void)setYmFirstLineHeadIndent:(CGFloat)ymFirstLineHeadIndent {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat firstLineHeadIndent = ymFirstLineHeadIndent;
    ParagraphStyleSet(firstLineHeadIndent);
}

- (void)setYmMinimumLineHeight:(CGFloat)ymMinimumLineHeight {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat minimumLineHeight = ymMinimumLineHeight;
    ParagraphStyleSet(minimumLineHeight);
}

- (void)setYmMaximumLineHeight:(CGFloat)ymMaximumLineHeight {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat maximumLineHeight = ymMaximumLineHeight;
    ParagraphStyleSet(maximumLineHeight);
}

- (void)setYmLineBreakMode:(NSLineBreakMode)ymLineBreakMode {
    NSRange range = NSMakeRange(0, self.length);
    NSLineBreakMode lineBreakMode = ymLineBreakMode;
    ParagraphStyleSet(lineBreakMode);
}

- (void)setYmBaseWritingDirection:(NSWritingDirection)ymBaseWritingDirection {
    NSRange range = NSMakeRange(0, self.length);
    NSWritingDirection baseWritingDirection = ymBaseWritingDirection;
    ParagraphStyleSet(baseWritingDirection);
}

- (void)setYmLineHeightMultiple:(CGFloat)ymLineHeightMultiple {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat lineHeightMultiple = ymLineHeightMultiple;
    ParagraphStyleSet(lineHeightMultiple);
}

- (void)setYmParagraphSpacingBefore:(CGFloat)ymParagraphSpacingBefore {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat paragraphSpacingBefore = ymParagraphSpacingBefore;
    ParagraphStyleSet(paragraphSpacingBefore);
}

- (void)setYmHyphenationFactor:(float)ymHyphenationFactor {
    NSRange range = NSMakeRange(0, self.length);
    float hyphenationFactor = ymHyphenationFactor;
    ParagraphStyleSet(hyphenationFactor);
}

- (void)setYmDefaultTabInterval:(CGFloat)ymDefaultTabInterval {
    NSRange range = NSMakeRange(0, self.length);
    CGFloat defaultTabInterval = ymDefaultTabInterval;
    ParagraphStyleSet(defaultTabInterval);
}

- (void)setYmTabStops:(NSArray<NSTextTab *> *)ymTabStops {
    NSRange range = NSMakeRange(0, self.length);
    NSArray<NSTextTab *> * tabStops = ymTabStops;
    ParagraphStyleSet(tabStops);
}

@end
