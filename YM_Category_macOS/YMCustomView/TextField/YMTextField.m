//
//  YMTextField.m
//  HelloWorld
//
//  Created by 海南有趣 on 2020/8/4.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "YMTextField.h"
#import "YMCustomTextField.h"
#import "YMSecureTextField.h"
#import "YMFormatter.h"
@interface YMTextField () <YMCustomTextFieldDelegate, YMSecureTextFieldDelegate>

@property (strong, nonatomic) YMCustomTextField * textField;
@property (strong, nonatomic) YMSecureTextField * secureTextField;
@property (assign, nonatomic) YMTextField * nextFocusView;
@end

@implementation YMTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self layoutView];
    }
    return self;
}

- (void)layout {
    [super layout];
    CGFloat height = self.bounds.size.height;
    CGFloat startX = 0;
    CGFloat rightWidth = 0;
    if (_leftView) {
        [self addSubview:_leftView];
        CGFloat width = _leftView.bounds.size.width;
        _leftView.frame = CGRectMake(0, 0, width, height);
        startX = width;
    }
    if (_rightView) {
        [self addSubview:_rightView];
        CGFloat width = _rightView.bounds.size.width;
        _rightView.frame = CGRectMake(self.bounds.size.width - width, 0, width, height);
        rightWidth = width;
    }
    
    CGFloat textFieldHeight = _textField.font.pointSize + 4;
    if (self.font) {
        textFieldHeight = self.font.pointSize + 4;
    } else if (self.systemFontSize > 0) {
        textFieldHeight = _systemFontSize + 4;
    }
    _textField.frame = CGRectMake(startX, (height - textFieldHeight) / 2, self.bounds.size.width - startX - rightWidth, textFieldHeight);
    _secureTextField.frame = _textField.frame;
    
    
    if (_systemFontSize > 0) {
        _textField.font = [NSFont systemFontOfSize:_systemFontSize];
        _secureTextField.font = _textField.font;
    }
    if (_placeholderFontSize > 0) {
        if (self.placeholderAttributedString) {
            NSMutableAttributedString * mAttribute = [self.placeholderAttributedString mutableCopy];
            [mAttribute addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:_placeholderFontSize] range:NSMakeRange(0, mAttribute.length)];
            self.placeholderAttributedString = mAttribute;
        } else {
            self.font = [NSFont systemFontOfSize:_placeholderFontSize];
        }
    }
    
    _textField.hidden = _secureMode;
    _secureTextField.hidden = !_secureMode;
    
    if (self.borderColor) {
        self.layer.borderColor = self.borderColor.CGColor;
        self.layer.borderWidth = self.borderWidth;
    }
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    [self addSubview:self.textField];
    [self addSubview:self.secureTextField];
}

#pragma mark public
/// 开始焦点模式
- (void)startFocus {
    if (self.textField.hidden) {
        [self _startFocus:_secureTextField];
    } else {
        [self _startFocus:_textField];
    }
}

/// 结束焦点模式
- (void)stopFocus {
    if (self.textField.hidden) {
        [self _stopFocus:_secureTextField];
    } else {
        [self _stopFocus:_textField];
    }
}

#pragma mark setter
- (void)setPlaceholder:(NSString *)placeholder color:(NSColor *)color font:(NSFont *)font {
    NSColor * tempColor = color ?: [NSColor blackColor];
    NSFont  * tempFont = font ?: [NSFont systemFontOfSize:14.0f];
    NSRange range = NSMakeRange(0, placeholder.length);
    
    NSMutableAttributedString * mAttribute = [[NSMutableAttributedString alloc] initWithString:placeholder];
    [mAttribute addAttribute:NSForegroundColorAttributeName value:tempColor range:range];
    [mAttribute addAttribute:NSFontAttributeName value:tempFont range:range];
    self.placeholderAttributedString = mAttribute;
}

- (void)setPlaceholderString:(NSString *)placeholderString {
    _placeholderString = placeholderString;
    _textField.placeholderString = placeholderString;
    _secureTextField.placeholderString = placeholderString;
}

- (void)setPlaceholderAttributedString:(NSAttributedString *)placeholderAttributedString {
    _placeholderAttributedString = placeholderAttributedString;
    _textField.placeholderAttributedString = placeholderAttributedString;
    _secureTextField.placeholderAttributedString = placeholderAttributedString;
    _placeholderFontSize = 0;
}

- (void)setStringValue:(NSString *)stringValue {
    _textField.stringValue = stringValue ?: @"";
    _secureTextField.stringValue = stringValue ?: @"";
}

- (void)setFont:(NSFont *)font {
    _font = font;
    _textField.font = font;
    _secureTextField.font = font;
    _systemFontSize = 0;
}

- (void)setTextColor:(NSColor *)textColor {
    _textColor = textColor;
    _textField.textColor = textColor;
    _secureTextField.textColor = textColor;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    _textField.enabled = enabled;
    _secureTextField.enabled = enabled;
}

- (void)setMultipleLines:(BOOL)multipleLines {
    _multipleLines = multipleLines;
    if (multipleLines) {
        _textField.wraps = YES;
        _textField.scrollable = NO;
        _secureTextField.wraps = YES;
        _secureTextField.scrollable = NO;
    } else {
        _textField.wraps = NO;
        _textField.scrollable = YES;
        _secureTextField.wraps = NO;
        _secureTextField.scrollable = YES;
    }
}

- (void)setSecureMode:(BOOL)secureMode {
    _secureMode = secureMode;
    _textField.hidden = secureMode;
    _secureTextField.hidden = !secureMode;
}


- (void)setTextFormatter:(NSFormatter *)formatter {
    if (formatter) {
        [_textField setFormatter:formatter];
        [_secureTextField setFormatter:formatter];
    }
}

- (void)nextFocusView:(YMTextField *)nextFocusView {
    _nextFocusView = nextFocusView;
}

#pragma mark getter
- (NSString *)stringValue {
    NSString * string = @"";
    if (_secureMode) {
        string = [NSString stringWithFormat:@"%@",  _secureTextField.stringValue ?: @""];
    } else {
        string = [NSString stringWithFormat:@"%@",  _textField.stringValue ?: @""];
    }
    return string;
}

#pragma mark <YMCustomTextFieldDelegate>
- (BOOL)ymTextShouldBeginEditing:(NSText *)textObject {
    if ([self.delegate respondsToSelector:@selector(ymTextShouldBeginEditing:)]) {
        return [self.delegate ymTextShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)ymTextShouldEndEditing:(NSText *)textObject {
    if ([self.delegate respondsToSelector:@selector(ymTextShouldEndEditing:)]) {
        return [self.delegate ymTextShouldEndEditing:self];
    }
    return YES;
}

- (void)ymTextDidBeginEditing:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(ymTextDidBeginEditing:)]) {
        [self.delegate ymTextDidBeginEditing:self];
    }
}

- (void)ymTextDidEndEditing:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(ymTextDidEndEditing:)]) {
        [self.delegate ymTextDidEndEditing:self];
    }

}

- (void)ymTextDidChange:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(ymTextDidChange:)]) {
        [self.delegate ymTextDidChange:self];
    }
}

- (void)ymTextBecomeFirstResponder:(YMCustomTextField *)textField {
    if ([self.delegate respondsToSelector:@selector(ymTextBecomeFirstResponder:)]) {
        [self.delegate ymTextBecomeFirstResponder:self];
    }
}

- (void)ymTextResignFirstResponder:(YMCustomTextField *)textField {
    if ([self.delegate respondsToSelector:@selector(ymTextResignFirstResponder:)]) {
        [self.delegate ymTextResignFirstResponder:self];
    }
}

- (void)ymTextDidTouchKey:(YMCustomTextField *)textField keyType:(kCustomTextFieldKey)keyType {
    if ([self.delegate respondsToSelector:@selector(ymTextDidTouchKey:keyType:)]) {
        [self.delegate ymTextDidTouchKey:self keyType:(kTextFieldKey)keyType];
    }
}

- (void)ymTextDidClickTap:(YMCustomTextField *)textField {
    if (![_nextFocusView isKindOfClass:[YMTextField class]]) {
        return;
    }
    [_nextFocusView startFocus];
}

#pragma mark private
- (void)_startFocus:(NSTextField *)textField {
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) self = weakSelf;
        textField.refusesFirstResponder = NO;
        [textField becomeFirstResponder];
        [[textField currentEditor] moveToEndOfLine:nil];
    });
}

/// 结束焦点模式
- (void)_stopFocus:(NSTextField *)textField {
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) self = weakSelf;
        textField.refusesFirstResponder = NO;
        [textField resignFirstResponder];
        [[textField currentEditor] removeFromSuperview];
    });
}

#pragma mark <YMSecureTextFieldDelegate>
- (BOOL)ymSecureTextShouldBeginEditing:(NSText *)textObject {
    if ([self.delegate respondsToSelector:@selector(ymTextShouldBeginEditing:)]) {
        return [self.delegate ymTextShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)ymSecureTextShouldEndEditing:(NSText *)textObject {
    if ([self.delegate respondsToSelector:@selector(ymTextShouldEndEditing:)]) {
        return [self.delegate ymTextShouldEndEditing:self];
    }
    return YES;
}

- (void)ymSecureTextDidBeginEditing:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(ymTextDidBeginEditing:)]) {
        [self.delegate ymTextDidBeginEditing:self];
    }
}

- (void)ymSecureTextDidEndEditing:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(ymTextDidEndEditing:)]) {
        [self.delegate ymTextDidEndEditing:self];
    }

}

- (void)ymSecureTextDidChange:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(ymTextDidChange:)]) {
        [self.delegate ymTextDidChange:self];
    }
}

- (void)ymSecureTextBecomeFirstResponder:(YMCustomTextField *)textField {
    if ([self.delegate respondsToSelector:@selector(ymTextBecomeFirstResponder:)]) {
        [self.delegate ymTextBecomeFirstResponder:self];
    }
}

- (void)ymSecureTextResignFirstResponder:(YMCustomTextField *)textField {
    if ([self.delegate respondsToSelector:@selector(ymTextResignFirstResponder:)]) {
        [self.delegate ymTextResignFirstResponder:self];
    }
}

- (void)ymSecureTextDidTouchKey:(YMCustomTextField *)textField keyType:(kSecureTextFieldKey)keyType {
    if ([self.delegate respondsToSelector:@selector(ymTextDidTouchKey:keyType:)]) {
        [self.delegate ymTextDidTouchKey:self keyType:(kTextFieldKey)keyType];
    }
}

- (void)ymSecureTextDidClickTap:(YMCustomTextField *)textField {
    if (![_nextFocusView isKindOfClass:[YMTextField class]]) {
        return;
    }
    [_nextFocusView startFocus];
}

#pragma mark 懒加载
- (YMCustomTextField *)textField {
    if (!_textField) {
        YMCustomTextField * textField = [YMCustomTextField new];
        textField.ymDelegate = self;
        _textField = textField;
    }
    return _textField;
}

- (YMSecureTextField *)secureTextField {
    if (!_secureTextField) {
        YMSecureTextField * textField = [YMSecureTextField new];
        textField.ymDelegate = self;
        _secureTextField.hidden = YES;
        _secureTextField = textField;
    }
    return _secureTextField;
}

@end
