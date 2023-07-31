//
//  YM_ImageInterceptionView.h
//  EditImage-Demo
//
//  Created by 蒋天宝 on 2021/2/22.
//  Copyright © 2021 chk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 图像截取
@interface YM_ImageInterceptionView : UIView

+ (YM_ImageInterceptionView *)xib;

/// 初始化
/// @param size 截取范围
- (instancetype)initWithCircleSize:(CGFloat)size;

/// 设置源图像
/// @param image 要截取的图像
- (void)setSourceImage:(UIImage *)image;

/// 裁剪图片
- (UIImage *)cropImage;


/// 背景色
@property (strong, nonatomic) UIColor * backColor;

/// 阴影色
@property (strong, nonatomic) UIColor * shadowColor;

/// 设置阴影色透明度 默认：0.4
@property (assign, nonatomic) CGFloat   shadowAlpha;

/// 边框线颜色
@property (strong, nonatomic) UIColor * borderColor;

/// 虚线间隔 例如@[@2,@2]，表示每条实线的长度和实线间的间隔，默认为@[@1, @0]
@property (strong, nonatomic) NSArray <NSNumber *> * lineDashPattern;


@end

NS_ASSUME_NONNULL_END
