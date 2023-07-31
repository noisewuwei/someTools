//
//  YM_SizeToFitLabel.m
//  YM_SizeToFitLabel
//
//  Created by 黄玉洲 on 2018/6/19.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_SizeToFitLabel.h"

@interface YM_SizeToFitLabel () {
    NSMutableAttributedString * _mAttribute;
}

@end

@implementation YM_SizeToFitLabel


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - 适应
/**
 *  自适应大小（默认使用对象自身的Font，方法会自动改变大小，emoji表情需要给高度增加2）
 *
 *  @param size 大小-若宽为0，则适应高度，若高为0则相反。
 *
 *  @return 返回适应后的大小
 */
- (CGSize)sizeToFitWithSize:(CGSize)size
{
    self.numberOfLines = 0;
    CGSize newSize = [self calculateRectWithSize:size andString:self.text andFont:self.font];
    CGRect newFrame = self.frame;
    newFrame.size = newSize;
    self.frame = newFrame;
    
    // 自适应
    [self sizeToFit];
    
    return self.bounds.size;
}

#pragma mark - 样式
/**
 *  设置字体颜色
 *
 *  @param color 颜色
 *  @param text  文本内容
 *  @param range 颜色位置
 */
- (void)attributeWithColor:(UIColor *)color text:(NSString *)text range:(NSRange)range
{
    [self mutableAttributeWithText:text withValue:color attributeName:NSForegroundColorAttributeName range:range];
}

/**
 *  设置内容样式
 *
 *  @param font  内容样式
 *  @param text  内容
 *  @param range 样式位置
 */
- (void)attributeWithFont:(UIFont *)font text:(NSString *)text range:(NSRange)range
{
    [self mutableAttributeWithText:text withValue:font attributeName:NSFontAttributeName range:range];
}

/**
 *  设置文本样式
 *
 *  @param text          内容
 *  @param value         样式值
 *  @param attributeName 样式键
 *  @param range         位置
 */
- (void)mutableAttributeWithText:(NSString *)text withValue:(id)value attributeName:(NSString *)attributeName range:(NSRange)range
{
    self.text = text;
    if (!_mAttribute) {
        _mAttribute = [[NSMutableAttributedString alloc] initWithString:text];
    }
    [_mAttribute addAttribute:attributeName value:value range:range];
    self.attributedText = _mAttribute;
}

/**
 *  重置Attribute属性
 */
- (void)resetAttribute
{
    NSMutableAttributedString * mAttribute = [[NSMutableAttributedString alloc] initWithString:self.text];
    self.attributedText = mAttribute;
}

#pragma mark - 计算
/**
 *  显示界面(必须将文本设置为自动换行模式,numberOfLines = 0)
 *
 *  @param size   大小限制
 *  @param string 对该字符串进行计算
 *  @param font   该字符串所要显示的字体
 *
 *  @return 返回所需要的高度或宽度
 */
- (CGSize)calculateRectWithSize:(CGSize)size andString:(NSString *)string andFont:(UIFont *)font
{
    if (!string) {
        string = @"";
    }
    
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    CGSize retSize = [string boundingRectWithSize:size
                                          options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                       attributes:attribute
                                          context:nil].size;
    return retSize;
}


@end
