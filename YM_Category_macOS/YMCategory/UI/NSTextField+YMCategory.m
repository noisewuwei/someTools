//
//  NSTextField+YMCategory.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/29.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "NSTextField+YMCategory.h"

#import <AppKit/AppKit.h>


@implementation NSTextField (YMCategory)

/// 开始焦点模式
- (void)startFocus {
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) self = weakSelf;
        self.refusesFirstResponder = NO;
        [self becomeFirstResponder];
        [[self currentEditor] moveToEndOfLine:nil];
    });
}

/// 结束焦点模式
- (void)stopFocus {
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) self = weakSelf;
        self.refusesFirstResponder = NO;
        [self resignFirstResponder];
        [[self currentEditor] removeFromSuperview];
    });
}

#pragma mark 占位符
- (NSTextField * _Nonnull (^)(NSString * _Nonnull, NSColor * _Nonnull, NSFont * _Nonnull))ymPlaceholder {
    return ^NSTextField *(NSString * _Nonnull placeholder, NSColor * _Nonnull color, NSFont * _Nonnull font) {
        NSColor * tempColor = color ?: [NSColor blackColor];
        NSFont  * tempFont = font ?: [NSFont systemFontOfSize:14.0f];
        NSRange range = NSMakeRange(0, placeholder.length);
        
        NSMutableAttributedString * mAttribute = [[NSMutableAttributedString alloc] initWithString:placeholder];
        [mAttribute addAttribute:NSForegroundColorAttributeName value:tempColor range:range];
        [mAttribute addAttribute:NSFontAttributeName value:tempFont range:range];
        self.placeholderAttributedString = mAttribute;
        return self;
    };
}

- (NSTextField * _Nonnull (^)(NSAttributedString * _Nonnull))ymPlaceholderAttribute {
    return ^NSTextField *(NSAttributedString * _Nonnull attribute) {
        if (!attribute) {
            return self;
        }
        self.placeholderAttributedString = attribute;
        return self;
    };
}

@end
