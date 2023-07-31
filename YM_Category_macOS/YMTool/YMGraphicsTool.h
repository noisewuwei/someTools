//
//  YMGraphicsTool.h
//  ToDesk_Service
//
//  Created by 海南有趣 on 2020/11/17.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

struct kRGB {
    int r;
    int g;
    int b;
};

struct kYUV {
    int y;
    int u;
    int v;
};

@interface YMGraphicsTool : NSObject

#pragma mark YUV RGB互转
/// yuv转rgb
/// http://paulbourke.net/dataformats/nv12/
/// https://docs.microsoft.com/en-us/windows/win32/medfound/about-yuv-video
/// @param y 颜色的亮度值（灰阶值）
/// @param u 色度值或色差值
/// @param v 色度值或色差值
+ (struct kRGB)ymYUV_To_RGB:(int)y u:(int)u v:(int)v;

/// rgb转yuv
/// https://philm.gitbook.io/philm-ios-wiki/mei-zhou-yue-du/yuv-yan-se-bian-ma-jie-xi
/// @param r 红
/// @param g 绿
/// @param b 蓝
+ (struct kYUV)ymRGB_To_YUV:(int)r g:(int)g b:(int)b;

#pragma mark NV12
/// NV12转I420
/// @param data NV12数据
/// @param dataWidth 图像宽度
/// @param dataHeight 图像高度
+ (unsigned char *)ymNV12_To_I420:(unsigned char *)data dataWidth:(int)dataWidth dataHeight:(int)dataHeight;

/// NV12旋转90°
/// @param dst 旋转后的数据
/// @param src 旋转前的数据
/// @param srcWidth 图像宽度
/// @param srcHeight 图像高度
+ (void)ymRotate90NV12:(unsigned char *)dst src:(const unsigned char *)src srcWidth:(int)srcWidth srcHeight:(int)srcHeight;


#pragma mark YUV
/// YUV420sp旋转270°
/// @param dst 旋转后的数据
/// @param src 旋转前的数据
/// @param srcWidth 图像宽度
/// @param srcHeight 图像高度
+ (void)ymRotate270_YUV420sp:(unsigned char *)dst src:(const unsigned char *)src srcWidth:(int)srcWidth srcHeight:(int)srcHeight;



@end
