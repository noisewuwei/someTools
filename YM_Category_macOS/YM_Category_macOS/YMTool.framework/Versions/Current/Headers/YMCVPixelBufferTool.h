//
//  YMCVPixelBufferTool.h
//  ToDesk_Service
//
//  Created by 海南有趣 on 2020/11/17.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
NS_ASSUME_NONNULL_BEGIN

@interface YMCVPixelBufferTool : NSObject

/// 获取CVPixelBufferRef这种数据类型的ID
+ (CFTypeID)ymGetTypeID;

/// 让PixelBuffer引用计数增加1
/// 一般调用CVPixelBufferRetain()时，都是将当前pixerbuffer赋值给另一个pixelbuffer，这样新的pixelbuffer就可以控制变量内存的生命周期。
/// 注意要和CVPixelBufferRelease()成对调用
/// @param texture CVPixelBufferRef
+ (CVPixelBufferRef)ymRetain:(CVPixelBufferRef)texture;

/// 让PixelBuffer引用计数减1
/// @param texture CVPixelBufferRef
+ (void)ymRelease:(CVPixelBufferRef)texture;

/// 获取描述各种像素缓冲区属性的CFDictionary对象的CFArray，并尝试将它们解析为单个字典。
/// 当您需要解决缓冲区的不同潜在客户端之间的多个需求时，这很有用。
/// @param allocator 如kCFAllocatorDefault
/// @param attributes 包含kCVPixelBuffer键/值对的CFDictionaries的CFArray属性。
/// @param resolvedDictionaryOut 结果字典将放在此处。
+ (CVReturn)ymCreateResolvedAttributesDictionary:(CFAllocatorRef)allocator
                                      attributes:(CFArrayRef)attributes
                           resolvedDictionaryOut:(CV_RETURNS_RETAINED_PARAMETER CFDictionaryRef CV_NULLABLE * CV_NONNULL)resolvedDictionaryOut;

/// 通过给定的大小和pixelFormatType创建单个PixelBuffer。
/// 它根据pixelBufferAttributes中描述的像素尺寸，pixelFormatType和扩展像素分配必要的内存。
/// 此处并非使用pixelBufferAttributes的所有参数。
/// @param allocator 如kCFAllocatorDefault
/// @param width 宽度
/// @param height 高度
/// @param pixelFormatType 像素格式
/// @param pixelBufferAttributes 包含像素缓冲区的其他属性
/// @param pixelBufferOut 新的像素缓冲区将在此处返回
+ (CVReturn)ymCreatePixelBuffer:(CFAllocatorRef CV_NULLABLE)allocator
                          width:(size_t)width
                         height:(size_t)height
                pixelFormatType:(OSType)pixelFormatType
          pixelBufferAttributes:(CFDictionaryRef CV_NULLABLE)pixelBufferAttributes
                 pixelBufferOut:(CV_RETURNS_RETAINED_PARAMETER CVPixelBufferRef CV_NULLABLE * CV_NONNULL)pixelBufferOut;

/// 锁上解锁基地址
/// 在访问buffer内部裸数据的地址時（读或写都一样），需要先将其锁上，用完了再放开
/// @param pixelBuffer pixelBuffer
/// @param lockFlags lockFlags
+ (CVReturn)ymLockBaseAddress:(CVPixelBufferRef)pixelBuffer lockFlags:(CVPixelBufferLockFlags)lockFlags;


/// 解锁基地址
/// 在访问buffer内部裸数据的地址時（读或写都一样），需要先将其锁上，用完了再放开
/// @param pixelBuffer pixelBuffer
/// @param unlockFlags lockFlags
+ (CVReturn)ymUnlockBaseAddress:(CVPixelBufferRef)pixelBuffer unlockFlags:(CVPixelBufferLockFlags)unlockFlags;

/// 获取宽度
/// @param pixelBuffer CVPixelBufferRef
+ (size_t)ymGetWidth:(CVPixelBufferRef)pixelBuffer;

/// 获取高度
/// @param pixelBuffer CVPixelBufferRef
+ (size_t)ymGetHeight:(CVPixelBufferRef)pixelBuffer;

/// 获取类型
/// @param pixelBuffer CVPixelBufferRef
+ (OSType)ymGetType:(CVPixelBufferRef)pixelBuffer;

/// 返回PixelBuffer的基地址。
/// @param pixelBuffer CVPixelBufferRef
/// @result像素的基地址。
/// 对于块状缓冲区，这将返回指向缓冲区中0,0像素的指针
/// 对于平面缓冲区，这将返回一个指向PlanarComponentInfo结构的指针（在QuickTime中定义）。
+ (void *)ymGetBaseAddress:(CVPixelBufferRef)pixelBuffer;

/// 返回图像数据每行的字节数。
/// 每行图像数据的字节数。对于平面缓冲区，这将返回一个rowBytes值，这样bytesPerRow * height将覆盖整个图像，包括所有平面。
/// @param pixelBuffer CVPixelBufferRef
+ (size_t)ymGetBytesPerRow:(CVPixelBufferRef)pixelBuffer;

/// 返回PixelBuffer连续平面的数据大小。
/// @param pixelBuffer CVPixelBufferRef
/// @return 返回CVPixelBufferCreateWithPlanarBytes中使用的数据大小。
+ (size_t)ymGetDataSize:(CVPixelBufferRef)pixelBuffer;

/// 如果PixelBuffer是平面的，则返回。
/// @param pixelBuffer CVPixelBufferRef
/// @return 如果PixelBuffer是使用CVPixelBufferCreateWithPlanarBytes创建的，则为true。
+ (Boolean)ymCheckPlanar:(CVPixelBufferRef)pixelBuffer;

/// 返回PixelBuffer的平面数。
/// @param pixelBuffer CVPixelBufferRef
/// @return 平面数量。 对于非平面的CVPixelBufferRefs，返回0。
+ (size_t)ymGetPlaneCount:(CVPixelBufferRef)pixelBuffer;

/// 返回像素缓冲区中planeIndex处平面的宽度。
/// @param pixelBuffer CVPixelBufferRef
/// @param planeIndex 平面标识
/// @return 以像素为单位的宽度，对于非平面的CVPixelBufferRefs为0。
+ (size_t)ymGetWidthOfPlane:(CVPixelBufferRef)pixelBuffer planeIndex:(size_t)planeIndex;

/// 返回像素缓冲区中planeIndex处平面的高度。
/// @param pixelBuffer CVPixelBufferRef
/// @param planeIndex 平面标识
/// @return 以像素为单位的高度，对于非平面的CVPixelBufferRefs为0。
+ (size_t)ymGetHeightOfPlane:(CVPixelBufferRef)pixelBuffer planeIndex:(size_t)planeIndex;

/// 返回像素缓冲区中planeIndex处平面的基地址。
/// @param pixelBuffer CVPixelBufferRef
/// @param planeIndex 平面标识
/// @return 平面的基地址，对于非平面的CVPixelBufferRefs，则为NULL。
+ (void *)ymGetBaseAddress:(CVPixelBufferRef)pixelBuffer planeIndex:(size_t)planeIndex;

/// 返回像素缓冲区中planeIndex处平面每行的字节数。
/// @param pixelBuffer CVPixelBufferRef
/// @param planeIndex 平面标识
+ (size_t)ymGetBytesPerRowOfPlane:(CVPixelBufferRef)pixelBuffer planeIndex:(size_t)planeIndex;

@end



NS_ASSUME_NONNULL_END
