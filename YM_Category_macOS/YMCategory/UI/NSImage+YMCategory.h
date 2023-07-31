//
//  NSImage+YMCategory.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/28.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <CoreMedia/CoreMedia.h>

typedef NS_ENUM(NSInteger, kCVPixelFormatType) {
    kCVPixelFormatType_NV12,
    kCVPixelFormatType_I420,
    kCVPixelFormatType_BGRA
};

/// 二维码容错率
typedef NS_ENUM(NSInteger, kCorrectionLevel) {
    kCorrectionLevel_L, // 7%
    kCorrectionLevel_M, // 15%
    kCorrectionLevel_Q, // 25%
    kCorrectionLevel_H, // 30%
};

@interface NSImage (YMCategory)

@property (copy, nonatomic) NSImage *(^ymAlpha)(CGFloat alpha);

#pragma mark getter
/// 通过CGImageRef获得NSImage（测试通过）
/// @param cgImage CGImageRef
+ (NSImage *)ymImageFromCGImage:(CGImageRef)cgImage;

/// 转换为CGImage(需要主动释放)
- (CGImageRef)ymCGImage;

/// 获取CGImage格式
- (OSType)ymCGImageFormat;

#pragma mark BGRA PixelBuffer
/// 通过CGImage获得BGRA CVPixelBufferRef(测试通过)
/// @param cgImage CGImage
+ (CVPixelBufferRef)ymBGRA_PixelBufferFromCGImage:(CGImageRef)cgImage;

#pragma BGRA Data
/// 通过BGRA CVPixelBufferRef获取BGRA数据（测试通过）
/// @param pixelBuffer CVPixelBufferRef
+ (NSData *)ymBGRA_DataFromPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/// 通过NSImage获取BGRA Data(未测试过，可能无法渲染)
+ (NSData *)ymBGRA_DataFromNSImage:(NSImage *)image;

/// 通过CGImage获取BGRA Data
/// 使用完记得要执行CGImageRelease(cgImage)
+ (NSData *)ymBGRA_DataFromCGImage:(CGImageRef)cgImage;

#pragma mark NSData To NSImage
/// 由ARGB转为NSImage
/// @param argbData ARGB
/// @param width 图像宽度
/// @param height 图像高度
+ (NSImage *)ymImageFromARGBData:(NSData *)argbData
                           width:(int32_t)width
                          height:(int32_t)height;

#pragma mark NSImage To JPG/PNG...
/// NSImage 转 JPG/PNG等数据
/// @param fileType 文件格式
/// @param compression 压缩程度，最大压缩 0~1 无压缩
- (NSData *)ymImageToFile:(NSBitmapImageFileType)fileType compression:(CGFloat)compression;

#pragma mark 二维码生成
/// 生成二维码
/// @param content 二维码内容
/// @param level 校正水平
+ (NSImage *)ymQRImageWithContent:(NSString *)content level:(kCorrectionLevel)level toSize:(CGSize)size;

/// 生成二维码
/// @param data 二维码内容
/// @param level 校正水平
+ (NSImage *)ymQRImageWithData:(NSData *)data level:(kCorrectionLevel)level toSize:(CGSize)size;

@end


