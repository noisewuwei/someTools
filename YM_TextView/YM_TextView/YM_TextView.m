//
//  YM_TextView.m
//  YM_TextView
//
//  Created by 黄玉洲 on 2018/8/1.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_TextView.h"

@interface YM_TextView () <UITextViewDelegate, UIScrollViewDelegate>
{
    __weak id<YM_TextViewDelegate> _kDelegate;
}
@end

@implementation YM_TextView

- (void)dealloc {
    [self removeNotify];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initDefaultConfig];
        // 注册通知
        [self registerNotify];
        [super setDelegate:self];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

#pragma mark - initData
/** 初始化默认配置 */
- (void)initDefaultConfig {
    // 设置默认字体
    self.font = [UIFont systemFontOfSize:15];
    
    // 初始化占位符默认属性
    _placeholder = @"";
    _placeholderColor = [UIColor grayColor];
    _placeholderFont = [UIFont systemFontOfSize:12];
}

/** 每次调用drawRect:方法，都会将以前画的东西清除掉 */
- (void)drawRect:(CGRect)rect {
    // 如果有文字，就直接返回，不需要画占位文字
    if (self.hasText) return;
    
    // 属性
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    [attrs setObject:_placeholderFont forKey:NSFontAttributeName];
    [attrs setObject:_placeholderColor forKey:NSForegroundColorAttributeName];
    
    // 画文字
    rect.origin.x = 5;
    rect.origin.y = 8;
    rect.size.width -= 2 * rect.origin.x;
    [_placeholder drawInRect:rect withAttributes:attrs];
}

#pragma mark - 通知
/** 注册通知 */
- (void)registerNotify {
    // 使用通知监听文字改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
}

/** 内容发生改变时 */
- (void)textDidChange:(NSNotification *)note
{
    // 会重新调用drawRect:方法
    [self setNeedsDisplay];
}

/** 删除通知 */
- (void)removeNotify {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_kDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_kDelegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark - <UITextViewDelegate>
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([_kDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [_kDelegate textViewShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([_kDelegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [_kDelegate textViewShouldEndEditing:self];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([_kDelegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [_kDelegate textViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.selectedRange = NSMakeRange(0, 0);
    if ([_kDelegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [_kDelegate textViewDidEndEditing:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 判断是否有限制最大长度
    if (_maxLength > 0) {
        // 删除键
        if ([text isEqual:@""]) {
            return YES;
        }
        // 超过最大限制字符长度
        NSUInteger inputLength = [text lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
        NSUInteger textLength = [textView.text lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
        if ((inputLength + textLength) > _maxLength) {
            return NO;
        }
    }
    
    if ([_kDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [_kDelegate textView:self
             shouldChangeTextInRange:range
                     replacementText:text];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([_kDelegate respondsToSelector:@selector(textViewDidChange:)]) {
        [_kDelegate textViewDidChange:self];
    }
    if (textView.text.length == 0) {
        textView.contentSize = textView.bounds.size;
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if ([_kDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [_kDelegate textViewDidChangeSelection:self];
    }
}

#pragma mark - setter
- (void)setPlaceholder:(NSString *)placeholder {
    if (placeholder) {
        _placeholder = placeholder;
        [self setNeedsDisplay];
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    if (placeholderColor) {
        _placeholderColor = placeholderColor;
        [self setNeedsDisplay];
    }
}

//- (void)setAttributedText:(NSAttributedString *)attributedText {
//    [super setAttributedText:attributedText];
//    [self setNeedsDisplay];
//}

- (id)delegate {
    NSString       *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array        = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    NSLog(@"\n%@",[NSThread callStackSymbols]);
    NSLog(@"Stack = %@", [array objectAtIndex:0]);
    NSLog(@"Framework = %@", [array objectAtIndex:1]);
    NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    NSLog(@"Line caller = %@", [array objectAtIndex:5]);
    Class class = NSClassFromString([array objectAtIndex:3]);
    if ([class isEqual:[UIScrollView class]] ||
        [class isEqual:[UITextView class]] ) {
        return [super delegate];
    } else {
        return _kDelegate;
    }
}

- (void)setDelegate:(id<YM_TextViewDelegate>)delegate {
    id delegateObject = delegate;
    _kDelegate = delegateObject;
}

@end
