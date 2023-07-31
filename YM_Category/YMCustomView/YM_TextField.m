//
//  YM_TextField.m
//  ToDesk-iOS
//
//  Created by 海南有趣 on 2020/7/16.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "YM_TextField.h"

@interface YM_TextField () <UITextFieldDelegate>

@property (copy, nonatomic) NSString * oldString;
@property (copy, nonatomic) NSString * replacementString;

@end

@implementation YM_TextField
@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self
                 action:@selector(textFieldDidChange:)
       forControlEvents:UIControlEventEditingChanged];
        self.delegate = self;
        [self layoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {

}

#pragma mark 重写
/// 点击了删除按钮
- (void)deleteBackward {
    if (self.text.length > 0) {
        [super deleteBackward];
    }
    
    if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldDidDelete:)]) {
        [self.ymDelegate ymTextFieldDidDelete:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidDeleteNotification object:self];
}

#pragma mark <UITextFieldDelegate>
/// 是否允许开始编辑
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldShouldBeginEditing:)]) {
        return [self.ymDelegate ymTextFieldShouldBeginEditing:self];
    }
    return YES;
}

/// 开始编辑
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldDidBeginEditing:)]) {
        [self.ymDelegate ymTextFieldDidBeginEditing:self];
    }
}

/// 是否允许结束编辑
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldShouldEndEditing:)]) {
        return [self.ymDelegate ymTextFieldShouldEndEditing:self];
    }
    return YES;
}

/// 结束编辑
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldDidEndEditing:)]) {
        [self.ymDelegate ymTextFieldDidEndEditing:self];
    }
}

/// 结束编辑并返回原因
- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason API_AVAILABLE(ios(10.0)) {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldDidEndEditing:reason:)]) {
        [self.ymDelegate ymTextFieldDidEndEditing:self reason:reason];
    }
}

/// 输入框即将发生改变
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqual:@""]) {
        return YES;
    }
    
    // 系统拼音
    BOOL specialWord = NO;
    if ([string isEqual:@"➋"] || [string isEqual:@"➌"] || [string isEqual:@"➍"] ||
        [string isEqual:@"➎"] || [string isEqual:@"➏"] || [string isEqual:@"➐"] ||
        [string isEqual:@"➑"] || [string isEqual:@"➒"] || [string isEqual:@"☻"]) {
        specialWord = YES;
    }
    
    if (!specialWord && [self.ymDelegate respondsToSelector:@selector(ymTextField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.ymDelegate ymTextField:self shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

/// 输入框选择发生变化
- (void)textFieldDidChangeSelection:(UITextField *)textField {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldDidChangeSelection:)]) {
        [self.ymDelegate ymTextFieldDidChangeSelection:self];
    }
}

/// 点击了清除按钮
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldShouldClear:)]) {
        return [self.ymDelegate ymTextFieldShouldClear:self];
    }
    return YES;
}

/// 点击了return键
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldShouldReturn:)]) {
        return [self.ymDelegate ymTextFieldShouldReturn:self];
    }
    return YES;
}

/// 输入框内容发生变化
- (void)textFieldDidChange:(UITextField *)textField {
   if (textField.markedTextRange == nil) {
       BOOL del = NO;
       if (_oldString.length == 0) {
           _oldString = textField.text;
           _replacementString = textField.text;
       } else {
           // 发生了删除
           if (textField.text.length < _oldString.length) {
               _replacementString = @"";
               _oldString = textField.text;
           }
           // 发生字符替换
           else if (_oldString.length == textField.text.length) {
               _replacementString = @"";
               _oldString = textField.text;
               del = YES;
           }
           // 正常的字符输入
           else {
               _replacementString = [textField.text substringWithRange:NSMakeRange(_oldString.length, textField.text.length - _oldString.length)];
               _oldString = textField.text;
           }
       }
       
       if ([self.ymDelegate respondsToSelector:@selector(ymTextFieldDidChange:replacementString:del:)]) {
           [self.ymDelegate ymTextFieldDidChange:self replacementString:_replacementString del:del];
       }
   }
}


#pragma mark setter
- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    [super setDelegate:self];
}

@end
