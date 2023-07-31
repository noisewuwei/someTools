//
//  YM_SizeToFitLabel.h
//  YM_SizeToFitLabel
//
//  Created by 黄玉洲 on 2018/6/19.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YM_SizeToFitLabel : UILabel


/**
 *  自适应大小（默认使用对象自身的Font，方法会自动改变大小）
 *
 *  @param size 大小-若宽为0，则适应高度，若高为0则相反。
 *
 *  @return 返回适应后的大小
 */
- (CGSize)sizeToFitWithSize:(CGSize)size;

/**
 *  设置字体颜色
 *
 *  @param color 颜色
 *  @param text  文本内容
 *  @param range 颜色位置
 */
- (void)attributeWithColor:(UIColor *)color text:(NSString *)text range:(NSRange)range;

/**
 *  设置文本样式
 *
 *  @param font  样式
 *  @param text  文本内容
 *  @param range 样式位置
 */
- (void)attributeWithFont:(UIFont *)font text:(NSString *)text range:(NSRange)range;

/**
 *  重置Attribute属性
 */
- (void)resetAttribute;

@end
