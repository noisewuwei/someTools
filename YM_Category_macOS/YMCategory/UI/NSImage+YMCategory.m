//
//  NSImage+YMCategory.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/28.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "NSImage+YMCategory.h"

#import <AppKit/AppKit.h>
#import <CoreImage/CoreImage.h>
#import "NSData+YMCategory.h"
#import "NSString+YMCategory.h"

static NSString * kCorrectionLevelL = @"L";// L: 7%
static NSString * kCorrectionLevelM = @"M";// M: 15%
static NSString * kCorrectionLevelQ = @"Q";// Q: 25%
static NSString * kCorrectionLevelH = @"H";// H: 30%
@implementation NSImage (YMCategory)

- (NSImage * _Nonnull (^)(CGFloat))ymAlpha {
    return ^NSImage *(CGFloat alpha) {
        NSImage * tempImage = [[NSImage alloc] initWithSize:[self size]];
        [tempImage lockFocus];
        [self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:alpha];
        [tempImage unlockFocus];
        
        return tempImage;
    };
}

#pragma mark getter
/// 通过CGImageRef获得NSImage（测试通过）
/// @param cgImage CGImageRef
+ (NSImage *)ymImageFromCGImage:(CGImageRef)cgImage {
    NSImage * image = [[NSImage alloc] initWithCGImage:cgImage size:NSZeroSize];
    return image;
}

/// 转换为CGImage(需要主动释放)
- (CGImageRef)ymCGImage {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[self TIFFRepresentation], NULL);
    CGImageRef imgRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CFRelease(source);
    return imgRef;
}

/// 获取CGImage格式
- (OSType)ymCGImageFormat {
    CGImageRef imageRef = [self ymCGImage];
    int format = [NSImage ymCGImageFormatFromCGImage:imageRef];
    CGImageRelease(imageRef);
    imageRef = NULL;
    return format;
}

/// 通过CGImage获取图片的类型
/// @param cgImage CGImageRef
/// @return kCVPixelFormatType
+ (int)ymCGImageFormatFromCGImage:(CGImageRef)cgImage {
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage);
    BOOL alphaFirst = alphaInfo == kCGImageAlphaPremultipliedFirst ||
                      alphaInfo == kCGImageAlphaFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst;
    BOOL alphaLast  = alphaInfo == kCGImageAlphaPremultipliedLast ||
                      alphaInfo == kCGImageAlphaLast ||
                      alphaInfo == kCGImageAlphaNoneSkipLast;
    BOOL endianLittle = bitmapInfo == kCGImageByteOrder32Little;

    if (alphaFirst && endianLittle) {
        return kCVPixelFormatType_32BGRA;
    } else if (alphaFirst) {
        return kCVPixelFormatType_32ARGB;
    } else if (alphaLast && endianLittle) {
        return kCVPixelFormatType_32ABGR;
    } else if (alphaLast) {
        return kCVPixelFormatType_32RGBA;
    } else {
        return 0;
    }
}

#pragma mark 测试代码
/// 测试代码：由Image转ABGR再转Image（测试通过）
/// 注意：示例代码需要导入libyuv框架
+ (void)ymTest_Image_To_ABGR_To_Image {
    // 获取图片
//    NSImage * image = [[NSImage alloc] initWithContentsOfFile:@"/Users/xxx/Desktop/capture0.jpg"];
    
    // 获取bgraPixelBuffer再获取bgraData
//    CVPixelBufferRef bgraPixelBuffer = [self ymBGRA_PixelBufferFromImage:image];
//    unsigned char * bgraData = (unsigned char *)[self ymBGRA_DataFromPixelBuffer:bgraPixelBuffer];
    
    // 申请YUV空间
//    int pixelWidth = image.size.width;
//    int pixelHeight = image.size.height;
//    uint8_t *i420_y = (uint8_t *)malloc(pixelWidth * pixelHeight);
//    uint8_t *i420_u = (uint8_t *)malloc(pixelWidth * pixelHeight / 4);
//    uint8_t *i420_v = (uint8_t *)malloc(pixelWidth * pixelHeight / 4);
//    int dst_stride_y = (int)pixelWidth;
//    int dst_stride_u = (int)pixelWidth / 2;
//    int dst_stride_v = (int)pixelWidth / 2;

    // 格式转换
//    int result =
//    libyuv::BGRAToI420(bgraData, 4,
//                       i420_y, dst_stride_y,
//                       i420_u, dst_stride_u,
//                       i420_v, dst_stride_v,
//                       pixelWidth, pixelHeight);
//
//    unsigned char * abga = (uint8_t *)malloc(pixelWidth * pixelHeight * 4);
//    result =
//    libyuv::I420ToABGR(i420_y, dst_stride_y,
//                       i420_u, dst_stride_u,
//                       i420_v, dst_stride_v,
//                       abga,
//                       4,
//                       1920,
//                       1080);
//    NSImage * image1 = [NSImage ymImageFromABGR:abga width:pixelWidth height:pixelHeight];
//    NSLog(@"%@", image1);
}

#pragma mark BGRA PixelBuffer
/// 通过CGImage获得BGRA CVPixelBufferRef(测试通过)
/// @param cgImage CGImage
+ (CVPixelBufferRef)ymBGRA_PixelBufferFromCGImage:(CGImageRef)cgImage {
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGSize size = CGSizeMake(width, height);
    
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32BGRA , nil, &pixelBuffer);
    
    if (status != kCVReturnSuccess) {
        return nil;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    void * data = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data,
                                                 size.width, size.height,
                                                 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), cgImage);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CGImageRelease(cgImage);
    CGContextRelease(context);
    CFRelease(rgbColorSpace);
    CGColorSpaceRelease(rgbColorSpace);
    free(data);
    
    return pixelBuffer;
}

#pragma BGRA Data
/// 通过BGRA CVPixelBufferRef获取BGRA数据（测试通过）
/// @param pixelBuffer CVPixelBufferRef
+ (NSData *)ymBGRA_DataFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    if (type != kCVPixelFormatType_32BGRA) {
        return nil;
    }
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    int bytesLength = width*height*4;
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void * bgraData = CVPixelBufferGetBaseAddress(pixelBuffer);
    NSData * data = [NSData dataWithBytes:bgraData length:bytesLength];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return data;
}

/// 通过NSImage获取BGRA Data(未测试过，可能无法渲染)
+ (NSData *)ymBGRA_DataFromNSImage:(NSImage *)image {
    CGImageRef cgImage = image.ymCGImage;
    NSData * data = [[NSData alloc] initWithData:[self ymBGRA_DataFromCGImage:cgImage]];
    CGImageRelease(cgImage);
    return data;
}

/// 通过CGImage获取BGRA Data
/// 使用完记得要执行CGImageRelease(cgImage)
+ (NSData *)ymBGRA_DataFromCGImage:(CGImageRef)cgImage {
    if (cgImage == NULL) {
        return nil;
    }
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesLength = width * height * bytesPerPixel;
    
    unsigned char *imageBytes = malloc(bytesLength);
    
    @autoreleasepool {
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(imageBytes, width, height,
                                                     bitsPerComponent, bytesPerRow, colorspace,
                                                     kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGRect rect = CGRectMake(0 , 0 , width , height);
        CGContextDrawImage(context , rect ,cgImage);
        NSData * data = [[NSData alloc] initWithBytes:imageBytes length:width * height * bytesPerPixel];
        CGContextRelease(context);
        CGColorSpaceRelease(colorspace);
        free(imageBytes);
        
        return data;
    }
}

#pragma mark NSData To NSImage
/// 由ARGB转为NSImage
/// @param argbData ARGB
/// @param width 图像宽度
/// @param height 图像高度
+ (NSImage *)ymImageFromARGBData:(NSData *)argbData
                           width:(int32_t)width
                          height:(int32_t)height {
    if (!argbData) {
        return nil;
    }
    size_t bitsPerComponent = 8; // 32/4 (4: R G BA)
    size_t bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate([argbData bytes],
                                                    width,
                                                    height,
                                                    bitsPerComponent,
                                                    bytesPerRow,
                                                    colorSpaceRef,
                                                    kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little);

    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:CGSizeMake(25, 25)];
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    return image;
}

#pragma mark NSImage To JPG/PNG...
/// NSImage 转 JPG/PNG等数据
/// @param fileType 文件格式
/// @param compression 压缩程度，最大压缩 0~1 无压缩
- (NSData *)ymImageToFile:(NSBitmapImageFileType)fileType compression:(CGFloat)compression {
    if (compression < 0 || compression > 1) {
        return nil;
    }
    
    NSData * imageData = [self TIFFRepresentation];
    NSBitmapImageRep * imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary * imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:compression]
                                                            forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    return imageData;
}

#pragma mark 二维码生成
/// 生成二维码
/// @param content 二维码内容
/// @param level 校正水平
+ (NSImage *)ymQRImageWithContent:(NSString *)content level:(kCorrectionLevel)level toSize:(CGSize)size {
    NSData * data = [content dataUsingEncoding:NSUTF8StringEncoding];
    return [self _ymQRImageWithData:data level:level toSize:size];
}

/// 生成二维码
/// @param data 二维码内容
/// @param level 校正水平
+ (NSImage *)ymQRImageWithData:(NSData *)data level:(kCorrectionLevel)level toSize:(CGSize)size {
    return [self _ymQRImageWithData:data level:level toSize:size];
}

/// 生成二维码
/// @param data 二维码内容
/// @param level 校正水平
+ (NSImage *)_ymQRImageWithData:(NSData *)data level:(kCorrectionLevel)level toSize:(CGSize)size {
    if (!data) {
        return nil;
    }
    
    NSString * correctionLevel = @"";
    switch (level) {
        case kCorrectionLevel_L: correctionLevel = kCorrectionLevelL; break;
        case kCorrectionLevel_M: correctionLevel = kCorrectionLevelM; break;
        case kCorrectionLevel_Q: correctionLevel = kCorrectionLevelQ; break;
        case kCorrectionLevel_H: correctionLevel = kCorrectionLevelH; break;
        default: break;
    }
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"
                            withInputParameters:@{@"inputMessage": data,
                                                  @"inputCorrectionLevel": correctionLevel}];
    CIImage *codeImage = filter.outputImage;
    
    CGRect integralRect = codeImage.extent;
    CGImageRef imageRef = [[CIContext context] createCGImage:codeImage fromRect:integralRect];
    
    CGFloat sideScale = fminf(size.width / integralRect.size.width, size.width / integralRect.size.height) * 1;
    size_t contextRefWidth = ceilf(integralRect.size.width * sideScale);
    size_t contextRefHeight = ceilf(integralRect.size.height * sideScale);
    CGContextRef contextRef = CGBitmapContextCreate(nil, contextRefWidth, contextRefHeight, 8, 0, CGColorSpaceCreateDeviceGray(), (CGBitmapInfo)kCGImageAlphaNone); // 灰度、不透明
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone); // 设置上下文无插值
    CGContextScaleCTM(contextRef, sideScale, sideScale); // 设置上下文缩放
    CGContextDrawImage(contextRef, integralRect, imageRef);// 在上下文中的integralRect中绘制imageRef
    
    // 从上下文中获取CGImageRef
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    
    // 将CGImageRefc转成UIImage
    NSImage * scaledImage = [[NSImage alloc] initWithCGImage:scaledImageRef size:size];
    CGImageRelease(scaledImageRef);
    return scaledImage;
    
}


@end
