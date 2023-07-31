//
//  YMSecureTextField.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/20.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, kSecureTextFieldKey) {
    kSecureTextFieldKey_Enter
};

@protocol YMSecureTextFieldDelegate;
@interface YMSecureTextField : NSSecureTextField

@property (assign, nonatomic) id <YMSecureTextFieldDelegate> ymDelegate;

@property (assign, nonatomic) BOOL wraps;
@property (assign, nonatomic) BOOL scrollable;

@end

@protocol YMSecureTextFieldDelegate <NSObject>

@optional
- (BOOL)ymSecureTextShouldBeginEditing:(YMSecureTextField *)textField;
- (BOOL)ymSecureTextShouldEndEditing:(YMSecureTextField *)textField;
- (void)ymSecureTextDidBeginEditing:(YMSecureTextField *)textField;
- (void)ymSecureTextDidEndEditing:(YMSecureTextField *)textField;
- (void)ymSecureTextDidChange:(YMSecureTextField *)textField;
- (void)ymSecureTextBecomeFirstResponder:(YMSecureTextField *)textField;
- (void)ymSecureTextResignFirstResponder:(YMSecureTextField *)textField;
- (void)ymSecureTextDidClickTap:(YMSecureTextField *)textField;
- (void)ymSecureTextDidTouchKey:(YMSecureTextField *)textField keyType:(kSecureTextFieldKey)keyType;
@end

