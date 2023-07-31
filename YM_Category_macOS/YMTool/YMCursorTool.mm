//
//  YMCursorTool.m
//  YMTool
//
//  Created by 黄玉洲 on 2020/12/17.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "YMCursorTool.h"

#import "YMDesktopSize.h"
#import "YMDesktopPoint.h"
#import "YMDesktopFrame.h"

#include <stdio.h>
#include <algorithm>

static const int kYMBytesPerPixel = 4;

/// private NSCursor_Private.h
@interface YMCursorTool ()

/// 允许监听
@property (assign, nonatomic) BOOL allowListening;

@property (strong, nonatomic) NSMutableArray <NSImage *> * allCursorImage;
@property (strong, nonatomic) NSMutableArray <NSData *> * allCursorImageData;

/// 发生改变
@property (assign, nonatomic) NSInteger cursorType;

@property (strong, nonatomic) NSImage* last_cursor;
@property (strong, nonatomic) NSData * last_cursor_data;
@property (assign, nonatomic) int32_t  last_cursor_width;
@property (assign, nonatomic) int32_t  last_cursor_height;
@property (assign, nonatomic) int32_t  last_cursor_hoty;
@property (assign, nonatomic) int32_t  last_cursor_hotx;

@end

@implementation YMCursorTool

static YMCursorTool * instance = nil;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMCursorTool alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

#pragma mark init
- (void)initData {
    _cycleDuration = 0.3;
    _allCursorImageData = [NSMutableArray array];
    _allCursorImage = [NSMutableArray array];
    [self _addCursor:[NSCursor arrowCursor]];
    [self _addCursor:[NSCursor IBeamCursor]];
    [self _addCursor:[NSCursor pointingHandCursor]];
    [self _addCursor:[NSCursor closedHandCursor]];
    [self _addCursor:[NSCursor openHandCursor]];
    [self _addCursor:[NSCursor resizeLeftCursor]];
    [self _addCursor:[NSCursor resizeRightCursor]];
    [self _addCursor:[NSCursor resizeLeftRightCursor]];
    [self _addCursor:[NSCursor resizeUpCursor]];
    [self _addCursor:[NSCursor resizeDownCursor]];
    [self _addCursor:[NSCursor resizeUpDownCursor]];
    [self _addCursor:[NSCursor crosshairCursor]];
    [self _addCursor:[NSCursor disappearingItemCursor]];
    [self _addCursor:[NSCursor operationNotAllowedCursor]];
    [self _addCursor:[NSCursor contextualMenuCursor]];
    [self _addCursor:[NSCursor dragCopyCursor]];
    [self _addCursor:[NSCursor dragLinkCursor]];
//    [self _addCursorWithSelName:@"_copyDragCursor"];
//    [self _addCursorWithSelName:@"_handCursor"];
//    [self _addCursorWithSelName:@"_closedHandCursor"];
//    [self _addCursorWithSelName:@"_moveCursor"];
//    [self _addCursorWithSelName:@"_waitCursor"];
//    [self _addCursorWithSelName:@"_crosshairCursor"];
//    [self _addCursorWithSelName:@"_zoomInCursor"];
//    [self _addCursorWithSelName:@"_zoomOutCursor"];
//    [self _addCursorWithSelName:@"_windowResizeEastCursor"];
//    [self _addCursorWithSelName:@"_windowResizeWestCursor"];
//    [self _addCursorWithSelName:@"_windowResizeEastWestCursor"];
//    [self _addCursorWithSelName:@"_windowResizeNorthCursor"];
//    [self _addCursorWithSelName:@"_windowResizeSouthCursor"];
//    [self _addCursorWithSelName:@"_windowResizeNorthSouthCursor"];
//    [self _addCursorWithSelName:@"_windowResizeNorthEastCursor"];
//    [self _addCursorWithSelName:@"_windowResizeNorthWestCursor"];
//    [self _addCursorWithSelName:@"_windowResizeSouthEastCursor"];
//    [self _addCursorWithSelName:@"_windowResizeSouthWestCursor"];
//    [self _addCursorWithSelName:@"_windowResizeNorthEastSouthWestCursor"];
//    [self _addCursorWithSelName:@"_windowResizeNorthWestSouthEastCursor"];

}

#pragma mark 监听
/// 开启监听
- (void)startListening {
    _allowListening = YES;
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.hyz.cursor", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        __strong __typeof(weakSelf) self = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.cycleDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self listeningAction];
        });
    });
}

- (void)listeningAction {
    if (!_allowListening) {
        return;
    }
    
    // 获取当前鼠标样式
    NSImage *file = [NSCursor currentSystemCursor].image;
    NSData *imgData = [file TIFFRepresentation];
    BOOL exit = NO;
    
    // 判断鼠标样式是否在数组中已存在，如果不存在就存入数组
    for (int i = 0; i < _allCursorImageData.count; i++) {
        NSData * data = _allCursorImageData[i];
        if ([data isEqualToData:imgData]) {
            exit = YES;
            // 如果鼠标发生改变，进行设值
            if (i != self.cursorType) {
                self.cursorType = i;
            }
            break;
        }
    }
    if (!exit && imgData) {
        [_allCursorImageData addObject:imgData];
        self.cursorType = [_allCursorImageData count] - 1;
    }
    
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_cycleDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) self = weakSelf;
        [self listeningAction];
    });
}

/// 停止监听
- (void)stopListening {
    _allowListening = NO;
}

#pragma mark - getter
/// 当前光标的图标
- (NSImage *)currentCursorImage {
    return _allCursorImage[_cursorType];
}

/// 当前光标的图标数据
- (NSData *)currentCursorData {
    return _allCursorImageData[_cursorType];
}


#pragma mark - 当前指针数据
/// 获取当前指针所在位置
- (NSPoint)mousePoint {
    return [NSEvent mouseLocation];
}

/// 获取当前指针所在的屏幕
- (NSScreen *)mouseInScreen {
    CGPoint mousePoint = [self mousePoint];
    for (NSScreen * screen in NSScreen.screens) {
        if (NSMouseInRect(mousePoint, screen.frame, false)) {
            return screen;
        }
    }
    return nil;
}

#pragma mark - 获取当前指针RGBA数据
CGImageRef YMCreateScaledCGImage(CGImageRef image, int width, int height) {
  // Create context, keeping original image properties.
  CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
  CGContextRef context = CGBitmapContextCreate(nullptr,
                                               width,
                                               height,
                                               CGImageGetBitsPerComponent(image),
                                               width * kYMBytesPerPixel,
                                               colorspace,
                                               CGImageGetBitmapInfo(image));

  if (!context) return nil;

  // Draw image to context, resizing it.
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
  // Extract resulting image from context.
  CGImageRef imgRef = CGBitmapContextCreateImage(context);
  CGContextRelease(context);

  return imgRef;
}

/// 指针数据
/// @param width 指针宽度
/// @param height 指针高度
/// @param hotX 指针热点X
/// @param hotY 指针热点Y
- (NSData *)cursorDataWithWidth:(int32_t *)width height:(int32_t *)height hotX:(int32_t *)hotX hotY:(int32_t *)hotY {
    NSCursor* nscursor = [NSCursor currentSystemCursor];

    NSImage* nsimage = [nscursor image];
    if (nsimage == nil || !nsimage.isValid) {
      return nil;
    }
    NSSize nssize = [nsimage size];  // DIP size

    if (self.last_cursor != nil && ![self.last_cursor isKindOfClass:[NSImage class]] ) {
        self.last_cursor = nil;
        return nil;
    }

    // No need to caputre cursor image if it's unchanged since last capture.
    NSData *nsdata = [nsimage TIFFRepresentation];
    NSData *lastcdata = [self.last_cursor TIFFRepresentation];
    if ([nsdata isEqual:lastcdata]) {
        nsimage = nil;
        nsdata = nil;
        lastcdata = nil;
        nscursor = nil;
        if (width) {
            *width = self.last_cursor_width;
        }
        if (height) {
            *height = self.last_cursor_height;
        }
        if (hotX) {
            *hotX = self.last_cursor_hotx;
        }
        if (hotY) {
            *hotY = self.last_cursor_hoty;
        }
        return [self.last_cursor_data mutableCopy];
    }

    nsdata = nil;
    lastcdata = nil;

    self.last_cursor = nsimage;

    int scale = [self mouseInScreen].backingScaleFactor > 1 ? 2 : 1;
    
    YMDesktopSize size(round(nssize.width * scale),
                      round(nssize.height * scale));  // Pixel size
    NSPoint nshotspot = [nscursor hotSpot];
    YMDesktopPoint hotspot( std::max(0, std::min(size.width(), static_cast<int>(nshotspot.x * scale))),
                           std::max(0, std::min(size.height(), static_cast<int>(nshotspot.y * scale)))
                          );
    CGImageRef cg_image = [nsimage CGImageForProposedRect:NULL context:nil hints:nil];
    if (!cg_image)
      return nil;

    // Before 10.12, OSX may report 1X cursor on Retina screen. (See
    // crbug.com/632995.) After 10.12, OSX may report 2X cursor on non-Retina
    // screen. (See crbug.com/671436.) So scaling the cursor if needed.
    CGImageRef scaled_cg_image = nil;
    if (CGImageGetWidth(cg_image) != static_cast<size_t>(size.width())) {
      scaled_cg_image = YMCreateScaledCGImage(cg_image, size.width(), size.height());
      if (scaled_cg_image != nil) {
        cg_image = scaled_cg_image;
      }
    }
    if (CGImageGetBitsPerPixel(cg_image) != kYMBytesPerPixel * 8 ||
        CGImageGetWidth(cg_image) != static_cast<size_t>(size.width()) ||
        CGImageGetBitsPerComponent(cg_image) != 8) {
      if (scaled_cg_image != nil) CGImageRelease(scaled_cg_image);
      return nil;
    }

    CGDataProviderRef provider = CGImageGetDataProvider(cg_image);
    CFDataRef image_data_ref = CGDataProviderCopyData(provider);
    if (image_data_ref == NULL) {
      if (scaled_cg_image != nil) CGImageRelease(scaled_cg_image);
      return nil;
    }

    const uint8_t* src_data = reinterpret_cast<const uint8_t*>(CFDataGetBytePtr(image_data_ref));
    int src_stride = (int)CGImageGetBytesPerRow(cg_image);

    // Create a MouseCursor that describes the cursor and pass it to
    // the client.
    YMDesktopSize frame_size = YMDesktopSize(size.width(), size.height());
    std::unique_ptr<YMDesktopFrame> image = YMFrameAligned::create(frame_size, YMPixelFormat::ARGB(), 32);
    image->copyPixelsFrom(src_data, src_stride, YMDesktopRect::makeSize(size));

    CFRelease(image_data_ref);
    if (scaled_cg_image != nil) CGImageRelease(scaled_cg_image);
    
    if (image->frameData()) {
        NSData * cursor_data = [[NSData alloc] initWithBytes:image->frameData() length:image->size().width() * image->size().height() * 4];
        self.last_cursor_width = image->size().width();
        self.last_cursor_height = image->size().height();
        self.last_cursor_hotx = hotspot.x();
        self.last_cursor_hoty = hotspot.y();
        self.last_cursor_data = cursor_data;
        if (width) {
            *width = self.last_cursor_width;
        }
        if (height) {
            *height = self.last_cursor_height;
        }
        if (hotX) {
            *hotX = self.last_cursor_hotx;
        }
        if (hotY) {
            *hotY = self.last_cursor_hoty;
        }
    }
    
    return [self.last_cursor_data mutableCopy];
}

#pragma mark private
- (void)_addCursor:(NSCursor *)cursor {
    if (!cursor || ![cursor isKindOfClass:[NSCursor class]]) {
        return;
    }
    
    NSData * data = [cursor.image TIFFRepresentation];
    if (data) {
        [_allCursorImage addObject:cursor.image];
        [_allCursorImageData addObject:data];
    }
}

- (void)_addCursorWithSelName:(NSString *)selName {
    SEL sel = NSSelectorFromString(selName);
    if ([NSCursor respondsToSelector:sel]) {
        NSCursor * cursor = [NSCursor performSelector:sel];
        [self _addCursor:cursor];
    }
}

#pragma mark setter
- (void)setCursorType:(NSInteger)cursorType {
    _cursorType = cursorType;
    [[NSNotificationCenter defaultCenter] postNotificationName:kCursorDidChangeNotifycation object:self];
}

@end
