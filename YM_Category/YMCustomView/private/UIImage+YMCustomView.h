//
//  UIImage+YMCustomView.h
//  YMCustomView
//
//  Created by 黄玉洲 on 2021/5/19.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (YMCustomView)

/// 设置UIImage透明度
@property (copy, nonatomic, readonly) UIImage * (^ymAlpha)(CGFloat);

@end

NS_ASSUME_NONNULL_END
