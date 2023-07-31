//
//  NSTextField+YMCategory.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/29.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTextField (YMCategory)

/// 开始焦点模式
- (void)startFocus;

/// 结束焦点模式
- (void)stopFocus;

/// 设置占位符
/// @param placeholder 内容
/// @param color 颜色（传niu，默认为纯黑色）
/// @param font  字体（传nil，默认为14.0f系统字体）
@property (copy, nonatomic, readonly) NSTextField * (^ymPlaceholder)(NSString * placeholder, NSColor * color, NSFont * font);

@property (copy, nonatomic, readonly) NSTextField * (^ymPlaceholderAttribute)(NSAttributedString *);

@end

NS_ASSUME_NONNULL_END
