//
//  UIViewController+YMHUDCategory.h
//  DS_Lottery
//
//  Created by huangyuzhou on 2018/9/9.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (YMHUDCategory)

/**
 * 显示加载器 (没有文字)
 */
-(void)showhud;

/**
 * 显示加载器 (有文字)
 */
-(void)showhudtext:(NSString *)text;

/**
 *  隐藏加载器
 */
-(void)hidehud;

/**
 * 文字提示
 */
-(void)showMessagetext:(NSString *)text;

/**
 * 加载成功
 */
-(void)hudSuccessText:(NSString *)text;

/**
 * 加载失败
 */
-(void)hudErrorText:(NSString *)text;


@end
