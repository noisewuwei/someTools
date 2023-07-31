//
//  YM_TextField.h
//  ToDesk-iOS
//
//  Created by 海南有趣 on 2020/7/16.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <UIKit/UIKit.h>


/// 删除按钮被点击
static NSString * UITextFieldTextDidDeleteNotification = @"UITextFieldTextDidDeleteNotification";

@class YM_TextField;
@protocol YM_TextField_Delegate <NSObject>

@optional
/// 是否允许开始编辑
- (BOOL)ymTextFieldShouldBeginEditing:(YM_TextField *)textField;

/// 开始编辑
- (void)ymTextFieldDidBeginEditing:(YM_TextField *)textField;

/// 是否允许结束编辑
- (BOOL)ymTextFieldShouldEndEditing:(YM_TextField *)textField;

/// 结束编辑
- (void)ymTextFieldDidEndEditing:(YM_TextField *)textField;

/// 结束编辑并返回原因
- (void)ymTextFieldDidEndEditing:(YM_TextField *)textField reason:(UITextFieldDidEndEditingReason)reason API_AVAILABLE(ios(10.0));

/// 输入框即将发生改变
- (BOOL)ymTextField:(YM_TextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/// 输入框选择发生变化
- (void)ymTextFieldDidChangeSelection:(YM_TextField *)textField;

/// 点击了清除按钮
- (BOOL)ymTextFieldShouldClear:(YM_TextField *)textField;

/// 点击了return键
- (BOOL)ymTextFieldShouldReturn:(YM_TextField *)textField;

/// 输入框发生了删除操作
/// @param textField YM_TextField
- (void)ymTextFieldDidDelete:(YM_TextField *)textField;

/// 输入框内容发生变化
/// @param textField YM_TextField
/// @param string 新输入的字符串
/// @param del 是否先进行删除（在英文九键的情况下，快速点击会导致最后一个字符替换，所以正常操作应该是先删除，后添加字符）
- (void)ymTextFieldDidChange:(YM_TextField *)textField replacementString:(NSString *)string del:(BOOL)del;

@end


/// 输入框视图
@interface YM_TextField : UITextField

@property (weak, nonatomic) id <YM_TextField_Delegate> ymDelegate;

@end



