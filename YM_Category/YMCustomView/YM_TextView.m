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

}

@end

@implementation YM_TextView
@dynamic delegate;
- (void)dealloc {
    [self removeNotify];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initDefaultConfig];
        // 注册通知
        [self registerNotify];
        self.delegate = self;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

#pragma mark initData
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

#pragma mark 重写
- (void)deleteBackward {
    if (self.text.length > 0) {
        [super deleteBackward];
    }
    if ([self.ymDelegate respondsToSelector:@selector(ymTextViewDidDelete:)]) {
        [self.ymDelegate ymTextViewDidDelete:self];
    }
}

#pragma mark 通知
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

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.ymDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.ymDelegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark <UITextViewDelegate>
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextViewShouldBeginEditing:)]) {
        return [self.ymDelegate ymTextViewShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextViewShouldEndEditing:)]) {
        return [self.ymDelegate ymTextViewShouldEndEditing:self];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextViewDidBeginEditing:)]) {
        [self.ymDelegate ymTextViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.selectedRange = NSMakeRange(0, 0);
    if ([self.ymDelegate respondsToSelector:@selector(ymTextViewDidEndEditing:)]) {
        [self.ymDelegate ymTextViewDidEndEditing:self];
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
    
    // 回车键
    if ([text isEqual:@"\n"] && [self.self.ymDelegate respondsToSelector:@selector(ymTextViewShouldReturn:)]) {
        if (![self.self.ymDelegate ymTextViewShouldReturn:self]) {
            return NO;
        }
    }
    
    if ([self.ymDelegate respondsToSelector:@selector(ymTextView:shouldChangeTextInRange:replacementText:)]) {
        return [self.ymDelegate ymTextView:self
             shouldChangeTextInRange:range
                     replacementText:text];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextViewDidChange:)]) {
        [self.ymDelegate ymTextViewDidChange:self];
    }
    if (textView.text.length == 0) {
        textView.contentSize = textView.bounds.size;
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextViewDidChangeSelection:)]) {
        [self.ymDelegate ymTextViewDidChangeSelection:self];
    }
}


#pragma mark setter
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

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    [super setDelegate:self];
}

//- (void)setAttributedText:(NSAttributedString *)attributedText {
//    [super setAttributedText:attributedText];
//    [self setNeedsDisplay];
//}

#pragma mark - 懒加载


@end
