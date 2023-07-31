//
//  UIColor+YMCustomView.h
//  YMCustomView
//
//  Created by 黄玉洲 on 2021/5/19.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (YMCustomView)

/** UIColor转换为UIImage */
- (UIImage *)toImage;

/** 获取当前颜色指定alpha的UIColor */
@property (copy, nonatomic) UIColor * (^ymAlpha)(CGFloat);

@end

NS_ASSUME_NONNULL_END
