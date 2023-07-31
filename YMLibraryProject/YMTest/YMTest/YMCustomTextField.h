//
//  YMCustomTextField.h
//  HelloWorld
//
//  Created by 海南有趣 on 2020/8/4.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Cocoa/Cocoa.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kCustomTextFieldKey) {
    kCustomTextFieldKey_Enter
};

@protocol YMCustomTextFieldDelegate;
@interface YMCustomTextField : NSTextField

@property (assign, nonatomic) id <YMCustomTextFieldDelegate> ymDelegate;

@property (assign, nonatomic) BOOL wraps;
@property (assign, nonatomic) BOOL scrollable;

@end

@protocol YMCustomTextFieldDelegate <NSObject>

@optional
- (BOOL)ymTextShouldBeginEditing:(YMCustomTextField *)textField;
- (BOOL)ymTextShouldEndEditing:(YMCustomTextField *)textField;
- (void)ymTextDidBeginEditing:(YMCustomTextField *)textField;
- (void)ymTextDidEndEditing:(YMCustomTextField *)textField;
- (void)ymTextDidChange:(YMCustomTextField *)textField;
- (void)ymTextBecomeFirstResponder:(YMCustomTextField *)textField;
- (void)ymTextResignFirstResponder:(YMCustomTextField *)textField;
- (void)ymTextDidClickTap:(YMCustomTextField *)textField;
- (void)ymTextDidTouchKey:(YMCustomTextField *)textField keyType:(kCustomTextFieldKey)keyType;
@end

NS_ASSUME_NONNULL_END
