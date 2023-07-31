//
//  NSParagraphStyle+YMCategory.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/6/4.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSParagraphStyle (YMCategory)
/**
 Creates a new NSParagraphStyle object from the CoreText Style.
 
 @param CTStyle CoreText Paragraph Style.
 
 @return a new NSParagraphStyle
 */
+ (nullable NSParagraphStyle *)yy_styleWithCTStyle:(CTParagraphStyleRef)CTStyle;

/**
 Creates and returns a CoreText Paragraph Style. (need call CFRelease() after used)
 */
- (nullable CTParagraphStyleRef)yy_CTStyle CF_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
