//
//  UIImage+YMCategory.m
//  YM_Category
//
//  Created by 黄玉洲 on 2019/11/5.
//  Copyright © 2019年 huangyuzhou. All rights reserved.
//

#import "UIImage+YMCategory.h"

@implementation UIImage (YMCategory)

/// 设置UIImage透明度
- (UIImage * _Nonnull (^)(CGFloat))ymAlpha {
    return ^UIImage * (CGFloat alpha){
        UIGraphicsBeginImageContextWithOptions(self.size,NO,0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGRect area = CGRectMake(0,0,self.size.width,self.size.height);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -area.size.height);
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
        CGContextSetAlpha(ctx, alpha);
        CGContextDrawImage(ctx, area,self.CGImage);
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    };
}

/// UIImage等比例缩放
- (UIImage * _Nonnull (^)(CGFloat))ymTransform {
    return ^UIImage * (CGFloat radio) {
        UIImage * image = self;
        
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * radio,
                                               image.size.height * radio));
        [image drawInRect:CGRectMake(0, 0,
                                     image.size.width * radio,
                                     image.size.height * radio)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaledImage;
    };
}

/// UIImage自定义大小
- (UIImage * _Nonnull (^)(CGFloat, CGFloat))ymSize {
    return ^UIImage *(CGFloat width, CGFloat height) {
        UIImage * image = self;
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    };
}

/// UIImage灰度处理
- (UIImage * _Nonnull (^)(void))ymGray {
    return ^UIImage *(void) {
        UIImage * image = self;
        
        int bitmapInfo = kCGImageAlphaPremultipliedLast;
        
        int scale = image.scale;
        int width = image.size.width * scale;
        int height = image.size.height * scale;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate (nil, width, height, 8, 0, colorSpace, bitmapInfo);
        CGColorSpaceRelease(colorSpace);
        if (context == NULL) {
            return nil;
        }
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
        CGImageRef cgImage = CGBitmapContextCreateImage(context);
        UIImage * grayImage = [UIImage imageWithCGImage:cgImage scale:2 orientation:UIImageOrientationUp];
        CGContextRelease(context);
        CGImageRelease(cgImage);
        return grayImage;
    };
}

#pragma mark 像素处理
/// 获取每一帧像素，做相应的处理
/// @param rgbBlock 返回当前帧的像素值
- (UIImage *)ymImageRGB:(kImageRGB_Block)rgbBlock {
    UIImage * image = [self ymImageARGB:^(uint8_t * _Nonnull a, uint8_t * _Nonnull r, uint8_t * _Nonnull g, uint8_t * _Nonnull b, int index) {
        if (rgbBlock) {
            rgbBlock(r, g, b, index);
        }
    }];
    return image;
}

/// 获取每一帧像素，做相应的处理
/// @param rgbBlock 返回当前帧的像素值
- (UIImage *)ymImageARGB:(kImageARGB_Block)rgbBlock {
    if (!self) {
        return nil;
    }
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;

    // 像素将画在这个数组
    uint32_t *pixels = (uint32_t *)malloc(width *height *sizeof(uint32_t));
    
    // 清空像素数组
    memset(pixels, 0, width*height*sizeof(uint32_t));

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width*sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);

    // 逐像素处理
    int pixelNum = width * height;
    uint32_t* pCurPtr = pixels;
    for (int i = 0; i < pixelNum; i++, pCurPtr++) {
        uint8_t *ptr = (uint8_t*)pCurPtr;
        if (rgbBlock) {
            rgbBlock(&ptr[0], &ptr[1], &ptr[2], &ptr[3], i);
        }
    }


    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    UIImage * image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    return image;
}

#pragma mark 颜色空间
/// 获取RGBA数据
/// @param imageRef CGImageRef
+ (NSData *)ymRGBADataWithImageRef:(CGImageRef)imageRef {
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerPixel = 32;    // 可以理解为每个通道的bit数
    NSUInteger bytesPerPixel = 4; // 每个像素点的byte大小
    NSUInteger bitsPerComponent = 8; // 每一個像素由4个通道构成(RGBA)，每一個通道都是1個byte，4个通道也就是32个bit
    NSUInteger bytesPerRow = bytesPerPixel * width;  // 每一行的位元组数
    unsigned char *rawData = (unsigned char *) malloc(bytesPerPixel * width * height);
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    NSData * data = [[NSData dataWithBytes:rawData length:width * height * sizeof(unsigned char) * bytesPerPixel] mutableCopy];
    free(rawData);
    return data;
}

/// 从RGBA中获取UIImage
/// @param pData RGBA
/// @param width 宽度
/// @param height 高度
+ (UIImage *)ymImageFromRGBA:(const void *)pData width:(size_t)width height:(size_t)height {
    return [self ymImageFromBuffer:pData bitmap:kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderMask width:width height:height];
}

/// 从指定的颜色缓存区中生成UIImage
/// @param colorBuffer 颜色缓冲区
/// @param bitmap 位信息
/// @param width 宽度
/// @param height 高度
+ (UIImage *)ymImageFromBuffer:(const void *)colorBuffer
                   bitmap:(CGBitmapInfo)bitmap
                    width:(size_t)width
                   height:(size_t)height {
    size_t bitsPerComponent = 8; // 每一個像素由4個通道构成(RGBA)，每一個通道都是1個byte，4个通道也就是32个bit
    size_t bitsPerPixel = 32;    // 可以理解为每個通道的bit数
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent; // 每个像素点的byte大小
    size_t bytesPerRow = width * bytesPerPixel; // 每一行的位元組數
    size_t bufferLength = width * height * bytesPerPixel; // 整個buffer的size
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); // 指定顏色空間為RGB
    void *colorData = (void *)colorBuffer;
    CGDataProviderRef bridgedData = CGDataProviderCreateWithData(NULL, colorData, bufferLength, NULL);
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       bitsPerComponent,
                                       bitsPerPixel,
                                       bytesPerRow,
                                       colorSpace,
                                       bitmap,
                                       bridgedData,
                                       NULL,
                                       TRUE,
                                       kCGRenderingIntentDefault);

    UIImage * image = [UIImage imageWithCGImage:cgImage];
    CFRelease(colorSpace);
    CFRetain(bridgedData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgImage);
    return [UIImage imageWithData:UIImagePNGRepresentation(image)];
}

@end
