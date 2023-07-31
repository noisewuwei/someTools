//
//  YMSampleBufferTool.m
//  YMTool
//
//  Created by 蒋天宝 on 2021/4/12.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import "YMSampleBufferTool.h"

@interface YMSampleBufferTool ()


@end

@implementation YMSampleBufferTool

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark 图像帧处理
/// CVPixelBufferRef转UIImage
/// kCVPixelFormatType_420YpCbCr8BiPlanarFullRange(420f)测试通过
/// kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange(420v)测试通过
/// @param imageBuffer CVPixelBufferRef/CVImageBufferRef
+ (UIImage *)ymImageFromImageBufferRef:(CVImageBufferRef)imageBuffer {
    CIImage   * ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    if (ciImage) {
        CIContext * temporaryContext = [CIContext contextWithOptions:nil];
        CGImageRef  videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
        UIImage * image = [UIImage imageWithCGImage:videoImage];
        CGImageRelease(videoImage);
        return image;
    }
    return nil;
}

/// CVPixelBufferRef转UIImage
/// kCVPixelFormatType_420YpCbCr8BiPlanarFullRange(420f)测试通过
/// kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange(420v)测试通过
/// @param imageBuffer CVPixelBufferRef/CVImageBufferRef
/// @param orientation 朝向
+ (UIImage *)ymImageFromImageBufferRef:(CVImageBufferRef)imageBuffer
                           orientation:(UIImageOrientation)orientation {
    CIImage   * ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    if (ciImage) {
        CIContext * temporaryContext = [CIContext contextWithOptions:nil];
        CGImageRef  videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
        UIImage * image = [UIImage imageWithCGImage:videoImage scale:[UIScreen mainScreen].scale orientation:orientation];
        CGImageRelease(videoImage);
        return image;
    }
    return nil;
}

/// CGImageRef转CVPixelBufferRef(目前无法处理PNG透明部分，与ymImageFromImageBufferRef配合使用)
/// 注：使用完后要调用CVPixelBufferRelease(pixelBufferRef);
/// @param imageRef UIImage
/// @param pixelFormatType kPixelFormatType
+ (CVPixelBufferRef)ymPixelBufferFromImageRef:(CGImageRef)imageRef pixelFormatType:(UInt32)pixelFormatType {
    @autoreleasepool {
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        
        CVPixelBufferRef pixelBuffer = NULL;
        
        if (pixelFormatType == kPixelFormatType_32bgra) {
            CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormatType , nil, &pixelBuffer);
            if (status != kCVReturnSuccess) {
                return nil;
            }
            
            CVPixelBufferLockBaseAddress(pixelBuffer, 0);
            
            void * data = CVPixelBufferGetBaseAddress(pixelBuffer);
            
            CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(data,
                                                         width, height,
                                                         8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace,
                                                         kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
            CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
            
            CGContextRelease(context);
            CFRelease(rgbColorSpace);
            CGColorSpaceRelease(rgbColorSpace);
    
        } else {
            NSUInteger bytesPerPixel = 4;
            NSUInteger bytesPerRow = ((bytesPerPixel*width+255)/256)*256;
            NSUInteger bitsPerComponent = 8;
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            GLubyte* bitmapData = (GLubyte *)malloc(bytesPerRow*height); // if 4 components per pixel (RGBA)
            CGContextRef context = CGBitmapContextCreate(bitmapData, width, height,
                                                         bitsPerComponent, bytesPerRow, colorSpace,
                                                         kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
            CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
            
            // 创建YUV pixelbuffer
            
            CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, (void*)[NSDictionary dictionary]);
            CFDictionarySetValue(attrs, kCVPixelBufferOpenGLESCompatibilityKey, (void*)[NSNumber numberWithBool:YES]);
            
            CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, (int)width, (int)height, pixelFormatType, attrs, &pixelBuffer);
            if (err) {
                return NULL;
            }
            CFRelease(attrs);

            CVPixelBufferLockBaseAddress(pixelBuffer, 0);

            uint8_t * yPtr = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
            size_t strideY = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);

            uint8_t * uvPtr = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
            size_t strideUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);

            for (int j = 0; j < height; j++) {
                for (int i = 0; i < width; i++) {
                    float r  = bitmapData[j*bytesPerRow + i*4 + 0];
                    float g  = bitmapData[j*bytesPerRow + i*4 + 1];
                    float b  = bitmapData[j*bytesPerRow + i*4 + 2];

                    int16_t y = (0.257*r + 0.504*g + 0.098*b) + 16;
                    if (y > 255) {
                        y = 255;
                    } else if (y < 0) {
                        y = 0;
                    }

                    yPtr[j*strideY + i] = (uint8_t)y;
                }
            }

            for (int j = 0; j < height/2; j++) {
                for (int i = 0; i < width/2; i++) {
                    float r  = bitmapData[j*2*bytesPerRow + i*2*4 + 0];
                    float g  = bitmapData[j*2*bytesPerRow + i*2*4 + 1];
                    float b  = bitmapData[j*2*bytesPerRow + i*2*4 + 2];

                    int16_t u = (-0.148*r - 0.291*g + 0.439*b) + 128;
                    int16_t v = (0.439*r - 0.368*g - 0.071*b) + 128;

                    if (u > 255) {
                        u = 255;
                    } else if (u < 0) {
                        u = 0;
                    }

                    if (v > 255) {
                        v = 255;
                    } else if (v < 0) {
                        v = 0;
                    }

                    uvPtr[j*strideUV + i*2 + 0] = (uint8_t)u;
                    uvPtr[j*strideUV + i*2 + 1] = (uint8_t)v;
                }
            }

            free(bitmapData);
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
            
            CGContextRelease(context);
            CFRelease(colorSpace);
            CGColorSpaceRelease(colorSpace);
        }
        
        return pixelBuffer;
    }
}

/// CVPixelBufferRef(BGRA) 转 UIImage
/// @param pixelBufferRef CVPixelBufferRef
+ (UIImage *)ymImageFromBGRAPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    CVImageBufferRef imageBuffer = pixelBufferRef;
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    
    CGImageRef cgImage = CGImageCreate(width, height,
                                       8, 32,
                                       bytesPerRow, rgbColorSpace,
                                       kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault,
                                       provider, NULL, true, kCGRenderingIntentDefault);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return [UIImage imageWithData:UIImagePNGRepresentation(image)];
}

/// CGImage 转 CVPixelBufferRef(BGRA)
/// 注：使用完后要调用CVPixelBufferRelease(pixelBufferRef);
/// @param imageRef CGImageRef
+ (CVPixelBufferRef)ymBGRAPixelBufferFromImageRef:(CGImageRef)imageRef {
    NSDictionary *options = @{(NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferIOSurfacePropertiesKey: [NSDictionary dictionary]};
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(imageRef);
    CGFloat frameHeight = CGImageGetHeight(imageRef);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, frameWidth, frameHeight), imageRef);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

#pragma mark getter
/// 获取CVImageBufferRef
/// @param sampleBufferRef CMSampleBufferRef
+ (CVImageBufferRef)ymImageBufferRefFromSampleBufferRef:(CMSampleBufferRef)sampleBufferRef {
    CVImageBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(sampleBufferRef);
    return imageBufferRef;
}

/// 获取图像类型
/// @param pixelBuffer CVPixelBufferRef
+ (NSString *)ymPixelBufferType:(CVPixelBufferRef)pixelBuffer {
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    NSString * string = YMFourCharCode(type);
    return string;
}

@end
