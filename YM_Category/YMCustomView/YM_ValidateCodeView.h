//
//  YM_ValidateCodeView.h
//  YM_ValidateCodeView
//
//  Created by huangyuzhou on 2018/9/21.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 随机验证码生成
@interface YM_ValidateCodeView : UIView

- (instancetype)initWithCodeNumber:(NSInteger)codeNumber;

/// 自定义验证码的取值范围
- (void)customRandomCodes:(NSArray <NSString *> *)codes;

/** 验证码回调 */
@property (copy, nonatomic) void(^validateCodeBlock)(NSString *);

/** 是否旋转 */
@property (assign, nonatomic) BOOL isRatation;

/** 刷新验证码 */
- (void)refreshCode;


@end

NS_ASSUME_NONNULL_END
