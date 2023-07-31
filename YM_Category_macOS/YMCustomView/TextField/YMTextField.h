//
//  YMTextField.h
//  HelloWorld
//
//  Created by 海南有趣 on 2020/8/4.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "YMFormatter.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kTextFieldKey) {
    kTextFieldKey_Enter
};

@protocol YMTextFieldDelegate;
IB_DESIGNABLE
@interface YMTextField : NSView

/// 开始焦点模式
- (void)startFocus;

/// 结束焦点模式
- (void)stopFocus;

/// 安全模式
@property (assign, nonatomic) BOOL secureMode;

@property (assign, nonatomic) id <YMTextFieldDelegate> delegate;

/// 设置占位符
/// @param placeholder 内容
/// @param color 颜色（传niu，默认为纯黑色）
/// @param font  字体（传nil，默认为14.0f系统字体）
- (void)setPlaceholder:(NSString *)placeholder color:(NSColor *)color font:(NSFont *)font;
@property (strong, nonatomic) NSAttributedString * placeholderAttributedString;
@property (copy, nonatomic) IBInspectable NSString * placeholderString;

/// 占位符大小
@property (assign, nonatomic) IBInspectable CGFloat placeholderFontSize;

/// 内容
@property (copy, nonatomic) IBInspectable NSString * stringValue;

/// 内容文本样式
@property (strong, nonatomic) IBInspectable NSFont * font;

/// 内容文本颜色
@property (strong, nonatomic) IBInspectable NSColor * textColor;

/// 设置系统字体大小
@property (assign, nonatomic) IBInspectable CGFloat systemFontSize;

/// 是否可以输入
@property (assign, nonatomic) IBInspectable BOOL enabled;

/// 是否多行
@property (assign, nonatomic) IBInspectable BOOL multipleLines;

/// 边框颜色
@property (strong, nonatomic) IBInspectable NSColor * borderColor;

/// 边框宽度
@property (assign, nonatomic) IBInspectable CGFloat   borderWidth;

@property (strong, nonatomic) NSView * leftView;
@property (strong, nonatomic) NSView * rightView;

/// 设置下一个焦点视图（tap键时跳转）
/// @param nextFocusView YMTextField
- (void)nextFocusView:(YMTextField *)nextFocusView;

/// 限制输入内容
/// @param formatter NSFormatter
- (void)setTextFormatter:(NSFormatter *)formatter;
@end

@protocol YMTextFieldDelegate <NSObject>

@optional
- (BOOL)ymTextShouldBeginEditing:(YMTextField *)textField;
- (BOOL)ymTextShouldEndEditing:(YMTextField *)textField;
- (void)ymTextDidBeginEditing:(YMTextField *)textField;
- (void)ymTextDidEndEditing:(YMTextField *)textField;
- (void)ymTextDidChange:(YMTextField *)textField;
- (void)ymTextBecomeFirstResponder:(YMTextField *)textField;
- (void)ymTextResignFirstResponder:(YMTextField *)textField;
- (void)ymTextDidTouchKey:(YMTextField *)textField keyType:(kTextFieldKey)keyType;

@end

NS_ASSUME_NONNULL_END
