//
//  YM_DottedLineView.h
//  ToDesk-iOS
//
//  Created by 黄玉洲 on 2020/12/27.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 虚线绘制
@interface YM_DottedLineView : UIView

/// 默认画线方式
/// @param lineSize 线宽和线高
/// @param lineSpace 线间距
/// @param lineColor 线颜色
/// @param horizontal 是否水平
- (instancetype)initWithLineSize:(CGSize)lineSize
                       lineSpace:(int)lineSpace
                       lineColor:(UIColor *)lineColor
                   lineDirection:(BOOL)horizontal;

@end

NS_ASSUME_NONNULL_END
