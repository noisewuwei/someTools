//
//  UIImage+YMCategory.h
//  YM_Category
//
//  Created by 黄玉洲 on 2019/11/5.
//  Copyright © 2019年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^kImageRGB_Block)(uint8_t *r, uint8_t *g, uint8_t *b, int index);
typedef void(^kImageARGB_Block)(uint8_t *a, uint8_t *r, uint8_t *g, uint8_t *b, int index);
@interface UIImage (YMCategory)

/// 设置UIImage透明度
@property (copy, nonatomic, readonly) UIImage * (^ymAlpha)(CGFloat);

/// UIImage等比例缩放
@property (copy, nonatomic, readonly) UIImage * (^ymTransform)(CGFloat ratio);

/// UIImage自定义大小
@property (copy, nonatomic, readonly) UIImage * (^ymSize)(CGFloat width, CGFloat height);

/// UIImage灰度处理
@property (copy, nonatomic, readonly) UIImage * (^ymGray)(void);

#pragma mark 像素处理
/// 获取每一帧像素，做相应的处理
/// @param rgbBlock 返回当前帧的像素值
- (UIImage *)ymImageRGB:(kImageRGB_Block)rgbBlock;

/// 获取每一帧像素，做相应的处理
/// @param rgbBlock 返回当前帧的像素值
- (UIImage *)ymImageARGB:(kImageARGB_Block)rgbBlock;

#pragma mark 颜色空间
/// 获取RGBA数据
/// @param imageRef CGImageRef
+ (NSData *)ymRGBADataWithImageRef:(CGImageRef)imageRef;

/// 从RGBA中获取UIImage
/// 注意：按理说每个int的数据都应该是RGBA，但是由于iOS是小端，R存储在低位，所以实际上每个int的内容为ABGR
/// @param pData RGBA
/// @param width 宽度
/// @param height 高度
+ (UIImage *)ymImageFromRGBA:(void*)pData width:(size_t)width height:(size_t)height;
@end

NS_ASSUME_NONNULL_END
