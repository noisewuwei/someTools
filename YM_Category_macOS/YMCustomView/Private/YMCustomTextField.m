//
//  YMCustomTextField.m
//  HelloWorld
//
//  Created by 海南有趣 on 2020/8/4.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "YMCustomTextField.h"
#import <Carbon/Carbon.h>
@interface YMCustomTextField () <NSTextFieldDelegate>

@end

@implementation YMCustomTextField

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self initProperty];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initProperty];
    }
    return self;
}

- (void)layout {
    [super layout];
}

/// 初始化属性
- (void)initProperty {
    self.cell.editable = YES;
    self.cell.stringValue = @"";
    self.cell.wraps = NO;
    self.cell.scrollable = YES;
    self.bordered = NO;
    self.refusesFirstResponder = YES;
    self.focusRingType = NSFocusRingTypeNone;
    self.delegate = self;
    self.drawsBackground = NO;
}

#pragma mark setter
- (void)setWraps:(BOOL)wraps {
    _wraps = wraps;
    self.cell.wraps = wraps;
}

- (void)setScrollable:(BOOL)scrollable {
    _scrollable = scrollable;
    self.cell.scrollable = scrollable;
}

- (void)setStringValue:(NSString *)stringValue {
    [super setStringValue:stringValue];
    self.cell.stringValue = stringValue;
}

- (void)setEditable:(BOOL)editable {
    [super setEditable:editable];
    self.cell.editable = editable;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.cell.enabled = enabled;
}

#pragma mark 重写
- (BOOL)textShouldBeginEditing:(NSText *)textObject {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextShouldBeginEditing:)]) {
        return [self.ymDelegate ymTextShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)textShouldEndEditing:(NSText *)textObject {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextShouldEndEditing:)]) {
        return [self.ymDelegate ymTextShouldEndEditing:self];
    }
    return YES;
}

- (void)textDidBeginEditing:(NSNotification *)notification {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextDidBeginEditing:)]) {
        [self.ymDelegate ymTextDidBeginEditing:self];
    }
}

- (void)textDidEndEditing:(NSNotification *)notification {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextDidEndEditing:)]) {
        [self.ymDelegate ymTextDidEndEditing:self];
    }
    if ([self.ymDelegate respondsToSelector:@selector(ymTextResignFirstResponder:)]) {
        [self.ymDelegate ymTextResignFirstResponder:self];
    }
    [super textDidEndEditing:notification];
}

- (void)textDidChange:(NSNotification *)notification {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextDidChange:)]) {
        [self.ymDelegate ymTextDidChange:self];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if ([NSStringFromSelector(commandSelector) isEqual:@"insertTab:"] &&
        [self.ymDelegate respondsToSelector:@selector(ymTextDidClickTap:)]) {
        [self.ymDelegate ymTextDidClickTap:self];
    } else {
        if ([textView respondsToSelector:commandSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [textView performSelector:commandSelector];
#pragma clang diagnostic pop
        }
    }
    return YES;
}

- (BOOL)becomeFirstResponder {
    if ([self.ymDelegate respondsToSelector:@selector(ymTextBecomeFirstResponder:)]) {
        [self.ymDelegate ymTextBecomeFirstResponder:self];
    }
    return [super becomeFirstResponder];
}

- (BOOL)performKeyEquivalent:(NSEvent *)event {
    if ((event.modifierFlags & NSEventModifierFlagCommand) > 0) {
        // 全选
        if (event.keyCode == kVK_ANSI_A) {
            return [NSApp sendAction:@selector(selectAll:) to:self.window.firstResponder from:self];
        }
        // 拷贝
        else if (event.keyCode == kVK_ANSI_C) {
            return [NSApp sendAction:@selector(copy:) to:self.window.firstResponder from:self];
        }
        // 粘贴
        else if (event.keyCode == kVK_ANSI_V) {
            return [NSApp sendAction:@selector(paste:) to:self.window.firstResponder from:self];
        }
        // 剪切
        else if (event.keyCode == kVK_ANSI_X) {
            return [NSApp sendAction:@selector(cut:) to:self.window.firstResponder from:self];
        }
        // 回退/撤销
        else if (event.keyCode == kVK_ANSI_Z) {
            if ((event.modifierFlags & NSEventModifierFlagShift) > 0) {
                [self.window.firstResponder.undoManager redo];
            } else {
                [self.window.firstResponder.undoManager undo];
            }
            
            return YES;
        }
        else {
            return [super performKeyEquivalent:event];
        }
    } else {
        if ([self.ymDelegate respondsToSelector:@selector(ymTextDidTouchKey:keyType:)]) {
            if (event.keyCode ==  kVK_Return || event.keyCode == kVK_ANSI_KeypadEnter) {
                [self.ymDelegate ymTextDidTouchKey:self keyType:kCustomTextFieldKey_Enter];
                return NO;
            }
        }
        return [super performKeyEquivalent:event];
    }
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    
}

#pragma mark 懒加载

@end
