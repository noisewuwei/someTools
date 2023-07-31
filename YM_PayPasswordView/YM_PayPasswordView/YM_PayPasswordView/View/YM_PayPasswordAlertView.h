//
//  YM_PayPasswordAlertView.h
//  YM_PayPasswordView
//
//  Created by huangyuzhou on 2018/10/31.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 密码输入提示视图
 */
@interface YM_PayPasswordAlertView : UIView


/**
 标题
 */
@property (copy, nonatomic) NSString *title;

/**
 密码长度
 */
@property (assign, nonatomic) NSUInteger length;

/**
 回调 Block
 */
@property (copy, nonatomic) void (^completeAction)(NSString *text);

/**
 显示界面
 */
- (void)show;


@end

NS_ASSUME_NONNULL_END
