//
//  YMSampleBufferTool.h
//  YMTool
//
//  Created by 蒋天宝 on 2021/4/12.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

#pragma mark OSType、OSStatus、OSErr等状态值转NSString
#include <TargetConditionals.h>
#if TARGET_RT_BIG_ENDIAN
#   define YMFourCharCode(fourcc) @((const char[]){*((char*)&fourcc), *(((char*)&fourcc)+1), *(((char*)&fourcc)+2), *(((char*)&fourcc)+3),0})
#else
#   define YMFourCharCode(fourcc) @((const char[]){*(((char*)&fourcc)+3), *(((char*)&fourcc)+2), *(((char*)&fourcc)+1), *(((char*)&fourcc)+0),0})
#endif

/// 像素类型
typedef NS_ENUM(UInt32, kPixelFormatType) {
    kPixelFormatType_420f = '420f',     // kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    kPixelFormatType_420v = '420v',     // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    kPixelFormatType_y420 = 'y420',     // kCVPixelFormatType_420YpCbCr8Planar
    kPixelFormatType_32bgra = 'BGRA',   // kCVPixelFormatType_32BGRA
};

// https://www.uiimage.com/post/blog/audio-and-video/yuv/
/*
 YUV 主要有两大类：
 ●  NV12：（双平面 BiPlanar）
    ● kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange 即 420v
    ● kCVPixelFormatType_420YpCbCr8BiPlanarFullRange 即 420f
 ● YUV420P：（单平面 Planar）
    ● kCVPixelFormatType_420YpCbCr8Planar 即 y420
*/
@interface YMSampleBufferTool : NSObject

#pragma mark 图像帧处理
/// CVPixelBufferRef转UIImage
/// kCVPixelFormatType_420YpCbCr8BiPlanarFullRange(420f)测试通过
/// kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange(420v)测试通过
/// @param imageBuffer CVPixelBufferRef/CVImageBufferRef
+ (UIImage *)ymImageFromImageBufferRef:(CVImageBufferRef)imageBuffer;

/// CVPixelBufferRef转UIImage
/// kCVPixelFormatType_420YpCbCr8BiPlanarFullRange(420f)测试通过
/// kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange(420v)测试通过
/// @param imageBuffer CVPixelBufferRef/CVImageBufferRef
/// @param orientation 朝向
+ (UIImage *)ymImageFromImageBufferRef:(CVImageBufferRef)imageBuffer
                           orientation:(UIImageOrientation)orientation;

/// CGImageRef转CVPixelBufferRef(目前无法处理PNG透明部分，与ymImageFromImageBufferRef配合使用)
/// 注：使用完后要调用CVPixelBufferRelease(pixelBufferRef);
/// @param imageRef UIImage
/// @param pixelFormatType kPixelFormatType
+ (CVPixelBufferRef)ymPixelBufferFromImageRef:(CGImageRef)imageRef pixelFormatType:(UInt32)pixelFormatType;

/// CVPixelBufferRef(BGRA) 转 UIImage
/// @param pixelBufferRef CVPixelBufferRef
+ (UIImage *)ymImageFromBGRAPixelBuffer:(CVPixelBufferRef)pixelBufferRef;

/// CGImage 转 CVPixelBufferRef(BGRA)
/// 注：使用完后要调用CVPixelBufferRelease(pixelBufferRef);
/// @param imageRef CGImageRef
+ (CVPixelBufferRef)ymBGRAPixelBufferFromImageRef:(CGImageRef)imageRef;

#pragma mark getter
/// 获取CVImageBufferRef
/// @param sampleBufferRef CMSampleBufferRef
+ (CVImageBufferRef)ymImageBufferRefFromSampleBufferRef:(CMSampleBufferRef)sampleBufferRef;

/// 获取图像类型
/// @param pixelBuffer CVPixelBufferRef
+ (NSString *)ymPixelBufferType:(CVPixelBufferRef)pixelBuffer;

@end
