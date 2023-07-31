//
//  YM_PasswordInputView.h
//  YM_PayPasswordView
//
//  Created by huangyuzhou on 2018/10/31.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 密码输入框视图
 */
@interface YM_PasswordInputView : UIView


/**
 支付密码长度
 */
@property (assign, nonatomic) NSUInteger length;

/**
 输入完成回调
 */
@property (copy, nonatomic) void (^inputDidCompletion)(NSString *pwd);

@end

NS_ASSUME_NONNULL_END
