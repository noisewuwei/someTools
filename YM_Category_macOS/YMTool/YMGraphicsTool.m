//
//  YMGraphicsTool.m
//  ToDesk_Service
//
//  Created by 海南有趣 on 2020/11/17.
//  Copyright © 2020 海南有趣. All rights reserved.
//
#import <AppKit/AppKit.h>
#import "YMGraphicsTool.h"

@interface YMGraphicsTool ()

@end

@implementation YMGraphicsTool

int clamp(int value, int lower, int upper) {
    return MIN(MAX(value, lower), upper);
}

#pragma mark YUV RGB互转
/// yuv转rgb
/// http://paulbourke.net/dataformats/nv12/
/// https://docs.microsoft.com/en-us/windows/win32/medfound/about-yuv-video
/// @param y 颜色的亮度值（灰阶值）
/// @param u 色度值或色差值
/// @param v 色度值或色差值
+ (struct kRGB)ymYUV_To_RGB:(int)y u:(int)u v:(int)v {
    int r,g,b;
    
    // u and v are +-0.5
    u -= 128;
    v -= 128;

    /* Conversion
    r = y + 1.370705 * v;
    g = y - 0.698001 * v - 0.337633 * u;
    b = y + 1.732446 * u;
    */
    r = y + 1.402 * v;
    g = y - 0.34414 * u - 0.71414 * v;
    b = y + 1.772 * u;

    // Clamp to 0..1
    if (r < 0) r = 0;
    if (g < 0) g = 0;
    if (b < 0) b = 0;
    if (r > 255) r = 255;
    if (g > 255) g = 255;
    if (b > 255) b = 255;
    
    struct kRGB rgb = {r, g, b};
    
    return rgb;
}

/// rgb转yuv
/// https://philm.gitbook.io/philm-ios-wiki/mei-zhou-yue-du/yuv-yan-se-bian-ma-jie-xi
/// http://www.php361.com/index.php?c=index&a=view&id=8076
/// #RGB转YUV
/// #[Y]        [0.299  0.587   0.114   ][R]
/// #[U]    =   [-0.147 -0.289  0.436   ][G]
/// #[V]        [0.615  -0.515  -0.100  ][B]
/// @param r 红
/// @param g 绿
/// @param b 蓝
+ (struct kYUV)ymRGB_To_YUV:(int)r g:(int)g b:(int)b {
    int y = 0.299 * r + 0.587 * g + 0.114 * b;
    int u = - 0.1687 * r - 0.3313 * g + 0.5 * b + 128;
    int v = 0.5 * r - 0.4187 * g - 0.0813 * b + 128;
    struct kYUV yuv = {y, u, v};
    return yuv;
}

/// Y'UV420sp（NV21）到RGB转换（Android）
/// @param y 颜色的亮度值（灰阶值）
/// @param u 色度值或色差值
/// @param v 色度值或色差值
+ (struct kRGB)ymYUV420sp_To_RGB:(int)y u:(int)u v:(int)v {
    int rTmp = y + (1.370705 * (v-128));
    int gTmp = y - (0.698001 * (v-128)) - (0.337633 * (u-128));
    int bTmp = y + (1.732446 * (u-128));
    
    struct kRGB rgb = {clamp(rTmp, 0, 255), clamp(gTmp, 0, 255), clamp(bTmp, 0, 255)};
    return rgb;
}

#pragma mark RGBA
/// RGBA 转 YV12
/// [RGBA轉YV12](https://www.mdeditor.tw/pl/ppP0/zh-tw())
/// @param r 红
/// @param g 绿
/// @param b 蓝
+ (struct kYUV)ymRGBA_To_YV12:(int)r g:(int)g b:(int)b {
    int y, u, v;
    
    // 1 常規轉換標準 - 浮點運算，精度高
    y =  0.29882  * r + 0.58681  * g + 0.114363 * b;
    u = -0.172485 * r - 0.338718 * g + 0.511207 * b;
    v =  0.51155  * r - 0.42811  * g - 0.08343  * b;

    // 2 常規轉換標準 通過位移來避免浮點運算，精度低
    y = ( 76  * r + 150 * g + 29  * b)>>8;
    u = (-44  * r - 87  * g + 131 * b)>>8;
    v = ( 131 * r - 110 * g - 21  * b)>>8;
    
    // 3 常規轉換標準 通過位移來避免乘法運算，精度低
    y = ( (r<<6) + (r<<3) + (r<<2) + (g<<7) + (g<<4) + (g<<2) + (g<<1) + (b<<4) + (b<<3) + (b<<2) + b)>>8;
    u = (-(r<<5) - (r<<3) - (r<<2) - (g<<6) - (g<<4) - (g<<2) - (g<<1) - g + (b<<7) + (b<<1) + b)>>8;
    v = ((r<<7) + (r<<1) + r - (g<<6) - (g<<5) - (g<<3) - (g<<2) - (g<<1) - (b<<4) - (b<<2) - b)>>8;
    
    // 4 高清電視標準：BT.709 常規方法：浮點運算，精度高
    y =  0.2126  * r + 0.7152  * g + 0.0722  * b;
    u = -0.09991 * r - 0.33609 * g + 0.436   * b;
    v =  0.615   * r - 0.55861 * g - 0.05639 * b;
    
    v += 128;
    u += 128;
    struct kYUV yuv = {y, u, v};
    return yuv;
}

/// NV12转I420
/// @param data NV12数据
/// @param dataWidth 图像宽度
/// @param dataHeight 图像高度
+ (unsigned char *)ymNV12_To_I420:(unsigned char *)data dataWidth:(int)dataWidth dataHeight:(int)dataHeight {
    unsigned char *ybase, *ubase;
    ybase = data;
    ubase = data + dataWidth*dataHeight;
    unsigned char* tmpData = (unsigned char*)malloc(dataWidth*dataHeight * 1.5);
    int offsetOfU = dataWidth*dataHeight;
    int offsetOfV = dataWidth*dataHeight* 5/4;
    memcpy(tmpData, ybase, dataWidth*dataHeight);
    for (int i = 0; i < dataWidth*dataHeight/2; i++) {
        if (i % 2 == 0) {
            tmpData[offsetOfU] = ubase[i];
            offsetOfU++;
        }else{
            tmpData[offsetOfV] = ubase[i];
            offsetOfV++;
        }
    }
    free(data);
    return tmpData;
}

/// NV12旋转90°
/// @param dst 旋转后的数据
/// @param src 旋转前的数据
/// @param srcWidth 图像宽度
/// @param srcHeight 图像高度
+ (void)ymRotate90NV12:(unsigned char *)dst src:(const unsigned char *)src srcWidth:(int)srcWidth srcHeight:(int)srcHeight {
    int wh = srcWidth * srcHeight;
    int uvHeight = srcHeight / 2;
    int uvWidth = srcWidth / 2;
    //旋转Y
    int i = 0, j = 0;
    int srcPos = 0, nPos = 0;
    for(i = 0; i < srcHeight; i++) {
        nPos = srcHeight - 1 - i;
        for(j = 0; j < srcWidth; j++) {
            dst[j * srcHeight + nPos] = src[srcPos++];
        }
    }

    srcPos = wh;
    for(i = 0; i < uvHeight; i++) {
        nPos = (uvHeight - 1 - i) * 2;
        for(j = 0; j < uvWidth; j++) {
            dst[wh + j * srcHeight + nPos] = src[srcPos++];
            dst[wh + j * srcHeight + nPos + 1] = src[srcPos++];
        }
    }
}

/// YUV420sp旋转270°
/// @param dst 旋转后的数据
/// @param src 旋转前的数据
/// @param srcWidth 图像宽度
/// @param srcHeight 图像高度
+ (void)ymRotate270_YUV420sp:(unsigned char *)dst src:(const unsigned char *)src srcWidth:(int)srcWidth srcHeight:(int)srcHeight {
    int nWidth = 0, nHeight = 0;
    int wh = 0;
    int uvHeight = 0;
    if(srcWidth != nWidth || srcHeight != nHeight)
    {
        nWidth = srcWidth;
        nHeight = srcHeight;
        wh = srcWidth * srcHeight;
        uvHeight = srcHeight >> 1;//uvHeight = height / 2
    }

    //旋转Y
    int k = 0;
    for(int i = 0; i < srcWidth; i++){
        int nPos = srcWidth - 1;
        for(int j = 0; j < srcHeight; j++)
        {
            dst[k] = src[nPos - i];
            k++;
            nPos += srcWidth;
        }
    }

    for(int i = 0; i < srcWidth; i+=2){
        int nPos = wh + srcWidth - 1;
        for(int j = 0; j < uvHeight; j++) {
            dst[k] = src[nPos - i - 1];
            dst[k + 1] = src[nPos - i];
            k += 2;
            nPos += srcWidth;
        }
    }
}

@end
