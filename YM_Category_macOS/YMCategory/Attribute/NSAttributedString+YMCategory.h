//
//  NSAttributedString+YMCategory.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/6/4.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - NSAttributedString (Character) 字符属性
@interface NSAttributedString (Character)

/// 字体大小
@property (nullable, nonatomic, strong, readonly) NSFont * ymFont;

/// 字间距
@property (nullable, nonatomic, strong, readonly) NSNumber *ymKern;

/// 字体颜色
@property (nullable, nonatomic, strong, readonly) NSColor * ymColor;

/// 背景色
@property (nullable, nonatomic, strong, readonly) NSColor * ymBackgroundColor;

/// 笔画宽度
@property (nullable, nonatomic, strong, readonly) NSNumber * ymStrokeWidth;

/// 笔画颜色
@property (nullable, nonatomic, strong, readonly) NSColor * ymStrokeColor;

/// 文本阴影
@property (nullable, nonatomic, strong, readonly) NSShadow * ymShadow;

/// 删除线的风格
@property (nonatomic, readonly) NSUnderlineStyle ymStrikethroughStyle;

/// 删除线的颜色
@property (nullable, nonatomic, strong, readonly) NSColor * ymStrikethroughColor;

/// 下划线风格
@property (nonatomic, readonly) NSUnderlineStyle ymUnderlineStyle;

/// 下划线颜色
@property (nullable, nonatomic, strong, readonly) NSColor * ymUnderlineColor;

/// 连体字。 默认值为1
/// 0 表示没有连体字符。
/// 1 表示使用默认的连体字符。
/// 2表示使用所有连体符号。
@property (nullable, nonatomic, strong, readonly) NSNumber * ymLigature;

/// 文字特效打印效果
@property (nullable, nonatomic, strong, readonly) NSString * ymTextEffect;

/// 设置字体倾斜（正数向右倾斜 负数向左倾斜）
@property (nullable, nonatomic, strong, readonly) NSNumber * ymObliqueness;

/// 设置字体压缩、拉伸（正数拉伸 负数压缩）
@property (nullable, nonatomic, strong, readonly) NSNumber * ymExpansion;

/// 基线的偏移，以点为单位（垂直方向，正数往上，负数往下）
@property (nullable, nonatomic, strong, readonly) NSNumber * ymBaselineOffset;

/// 字体方向
@property (nonatomic, readonly) BOOL ymVerticalGlyphForm;

/// 指定文本的语言
@property (nullable, nonatomic, strong, readonly) NSString * ymLanguage;

/// 书写方向（只支持一下四种）
/// @[@(NSWritingDirectionLeftToRight | NSTextWritingDirectionEmbedding)]
/// @[@(NSWritingDirectionLeftToRight | NSTextWritingDirectionOverride)]
/// @[@(NSWritingDirectionRightToLeft | NSTextWritingDirectionEmbedding)]
/// @[@(NSWritingDirectionRightToLeft | NSTextWritingDirectionOverride)]）
@property (nullable, nonatomic, strong, readonly) NSArray<NSNumber *> * ymWritingDirection;

/// 段落风格
@property (nullable, nonatomic, strong, readonly) NSParagraphStyle * ymParagraphStyle;

@end


#pragma mark - NSMutableAttributedString (Character) 字符属性
@interface NSMutableAttributedString (Character)

/// 字体大小
@property (nullable, nonatomic, strong, readwrite) NSFont * ymFont;

/// 字间距
@property (nullable, nonatomic, strong, readwrite) NSNumber *ymKern;

/// 字体颜色
@property (nullable, nonatomic, strong, readwrite) NSColor * ymColor;

/// 背景色
@property (nullable, nonatomic, strong, readwrite) NSColor * ymBackgroundColor;

/// 笔画宽度
@property (nullable, nonatomic, strong, readwrite) NSNumber * ymStrokeWidth;

/// 笔画颜色
@property (nullable, nonatomic, strong, readwrite) NSColor * ymStrokeColor;

/// 文本阴影
@property (nullable, nonatomic, strong, readwrite) NSShadow * ymShadow;

/// 删除线的风格
@property (nonatomic, readwrite) NSUnderlineStyle ymStrikethroughStyle;

/// 删除线的颜色
@property (nullable, nonatomic, strong, readwrite) NSColor * ymStrikethroughColor;

/// 下划线风格
@property (nonatomic, readwrite) NSUnderlineStyle ymUnderlineStyle;

/// 下划线颜色
@property (nullable, nonatomic, strong, readwrite) NSColor * ymUnderlineColor;

/// 连体字。 默认值为1
/// 0 表示没有连体字符。
/// 1 表示使用默认的连体字符。
/// 2表示使用所有连体符号。
@property (nullable, nonatomic, strong, readwrite) NSNumber * ymLigature;

/// 文字特效打印效果
@property (nullable, nonatomic, strong, readwrite) NSString * ymTextEffect;

/// 设置字体倾斜（正数向右倾斜 负数向左倾斜）
@property (nullable, nonatomic, strong, readwrite) NSNumber * ymObliqueness;

/// 设置字体压缩、拉伸（正数拉伸 负数压缩）
@property (nullable, nonatomic, strong, readwrite) NSNumber * ymExpansion;

/// 基线的偏移，以点为单位（垂直方向，正数往上，负数往下）
@property (nullable, nonatomic, strong, readwrite) NSNumber * ymBaselineOffset;

/// 字体方向
@property (nonatomic, readwrite) BOOL ymVerticalGlyphForm;

/// 指定文本的语言
@property (nullable, nonatomic, strong, readwrite) NSString * ymLanguage;

/// 书写方向（只支持一下四种）
/// @[@(NSWritingDirectionLeftToRight | NSTextWritingDirectionEmbedding)]
/// @[@(NSWritingDirectionLeftToRight | NSTextWritingDirectionOverride)]
/// @[@(NSWritingDirectionRightToLeft | NSTextWritingDirectionEmbedding)]
/// @[@(NSWritingDirectionRightToLeft | NSTextWritingDirectionOverride)]）
@property (nullable, nonatomic, strong, readwrite) NSArray<NSNumber *> * ymWritingDirection;

/// 段落风格
@property (nullable, nonatomic, strong, readwrite) NSParagraphStyle * ymParagraphStyle;

@end




#pragma mark - NSAttributedString (Paragraph) 段落
@interface NSAttributedString (Paragraph)

/// 对其方式
@property (nonatomic, readonly) NSTextAlignment ymAlignment;

/// 行间距
@property (nonatomic, readonly) CGFloat ymLineSpacing;

/// 段落间距
@property (nonatomic, readonly) CGFloat ymParagraphSpacing;


/// 从页边到段落前端的距离
@property (nonatomic, readonly) CGFloat ymHeadIndent;

/// 段落页边距后边缘的距离;如果是负数或0，则从其他边距
@property (nonatomic, readonly) CGFloat ymTailIndent;

/// 从页边距到边框的距离适合文本方向
@property (nonatomic, readonly) CGFloat ymFirstLineHeadIndent;

/// 线高是从下行板底部到上行板顶部的距离;
/// 基本上就是行片段的高度。不包括行调整(在此计算之后添加)。
@property (nonatomic, readonly) CGFloat ymMinimumLineHeight;

/// 0表示没有最大值
@property (nonatomic, readonly) CGFloat ymMaximumLineHeight;

/// 换行模式
@property (nonatomic, readonly) NSLineBreakMode ymLineBreakMode;

/// 基础写作方向
@property (nonatomic, readonly) NSWritingDirection ymBaseWritingDirection;

/// 自然线高在被最小线高和最大线高限制之前，要乘以这个因子(如果是正数)
@property (nonatomic, readonly) CGFloat ymLineHeightMultiple;

/// 前一段的底部(或段落末尾)与这段的顶部之间的距离
@property (nonatomic, readonly) CGFloat ymParagraphSpacingBefore;

/// 指定连接的阈值。有效值介于0.0和1.0(包括1.0)之间。
/// 当不使用连字符的文本宽度与行片段宽度的比率小于连字符系数时，将尝试使用连字符。
/// 当它的默认值为0.0时，将使用布局管理器的连字符因子。
/// 当两者都为0.0时，将禁用连字符。
@property (nonatomic, readonly) float ymHyphenationFactor;

/// 默认的制表符间隔，用于制表符中最后一个元素以外的位置
@property (nonatomic, readonly) CGFloat ymDefaultTabInterval;

/// 一个NSTextTab数组。
/// 内容应按位置排序。
/// 默认值是由12个左对齐的制表符组成的数组，间隔为28pt
@property (nullable, nonatomic, copy, readonly) NSArray<NSTextTab *> * ymTabStops;

@end


#pragma mark - NSMutableAttributedString (Paragraph) 段落
@interface NSMutableAttributedString (Paragraph)

/// 行间距
@property (nonatomic, readwrite) CGFloat ymLineSpacing;

/// 段落间距
@property (nonatomic, readwrite) CGFloat ymParagraphSpacing;

/// 对其方式
@property (nonatomic, readwrite) NSTextAlignment ymAlignment;

/// 从页边到段落前端的距离
@property (nonatomic, readwrite) CGFloat ymHeadIndent;

/// 段落页边距后边缘的距离;如果是负数或0，则从其他边距
@property (nonatomic, readwrite) CGFloat ymTailIndent;

/// 从页边距到边框的距离适合文本方向
@property (nonatomic, readwrite) CGFloat ymFirstLineHeadIndent;

/// 线高是从下行板底部到上行板顶部的距离;
/// 基本上就是行片段的高度。不包括行调整(在此计算之后添加)。
@property (nonatomic, readwrite) CGFloat ymMinimumLineHeight;

/// 0表示没有最大值
@property (nonatomic, readwrite) CGFloat ymMaximumLineHeight;

/// 换行模式
@property (nonatomic, readwrite) NSLineBreakMode ymLineBreakMode;

/// 基础写作方向
@property (nonatomic, readwrite) NSWritingDirection ymBaseWritingDirection;

/// 自然线高在被最小线高和最大线高限制之前，要乘以这个因子(如果是正数)
@property (nonatomic, readwrite) CGFloat ymLineHeightMultiple;

/// 前一段的底部(或段落末尾)与这段的顶部之间的距离
@property (nonatomic, readwrite) CGFloat ymParagraphSpacingBefore;

/// 指定连接的阈值。有效值介于0.0和1.0(包括1.0)之间。
/// 当不使用连字符的文本宽度与行片段宽度的比率小于连字符系数时，将尝试使用连字符。
/// 当它的默认值为0.0时，将使用布局管理器的连字符因子。
/// 当两者都为0.0时，将禁用连字符。
@property (nonatomic, readwrite) float ymHyphenationFactor;

/// 默认的制表符间隔，用于制表符中最后一个元素以外的位置
@property (nonatomic, readwrite) CGFloat ymDefaultTabInterval;

/// 一个NSTextTab数组。
/// 内容应按位置排序。
/// 默认值是由12个左对齐的制表符组成的数组，间隔为28pt
@property (nullable, nonatomic, copy, readwrite) NSArray<NSTextTab *> * ymTabStops;

@end

NS_ASSUME_NONNULL_END
