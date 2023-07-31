//
//  YMCGSCursor.m
//  YMCGSInternal
//
//  Created by 黄玉洲 on 2022/2/18.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "YMCGSCursor.h"

#pragma mark - HIServices
/// 注销所有注册的游标
/// @param cid 进程连接ID
CG_EXTERN CGError CoreCursorUnregisterAll(YMCGSConnectionID cid);
CGError YMCoreCursorUnregisterAll(YMCGSConnectionID cid) {
    return CoreCursorUnregisterAll(cid);
}

/// 设置游标样式
/// @param cid 进程连接ID
/// @param cursorID 游标ID
CG_EXTERN CGError CoreCursorSet(YMCGSConnectionID cid, int cursorID);
CGError YMCoreCursorSet(YMCGSConnectionID cid, YMCGSCursorID cursorID) {
    return CoreCursorSet(cid, cursorID);
}

/// 设置并放回游标的变化数值
/// @param cid 进程连接ID
/// @param cursorNum 游标数？
/// @param seed 变化数值
CG_EXTERN CGError CoreCursorSetAndReturnSeed(YMCGSConnectionID cid, int cursorNum, int *seed);
CGError YMCoreCursorSetAndReturnSeed(YMCGSConnectionID cid, int cursorNum, int *seed) {
    return CoreCursorSetAndReturnSeed(cid, cursorNum, seed);
}

/// 拷贝游标的图片数据
/// @param cid 进程连接ID
/// @param cursorID 游标ID
/// @param images 图标数据
/// @param imageSize 图标大小
/// @param hotSpot 热点
/// @param frameCount 帧数?
/// @param frameDuration 帧持续时长?
CG_EXTERN CGError CoreCursorCopyImages(YMCGSConnectionID cid, int cursorID, CFArrayRef *images, CGSize *imageSize, CGPoint *hotSpot, NSUInteger *frameCount, CGFloat *frameDuration);
CGError YMCoreCursorCopyImages(YMCGSConnectionID cid, YMCGSCursorID cursorID, CFArrayRef *images, CGSize *imageSize, CGPoint *hotSpot, NSUInteger *frameCount, CGFloat *frameDuration) {
    return CoreCursorCopyImages(cid, cursorID, images, imageSize, hotSpot, frameCount, frameDuration);
}

#pragma mark - 光标api在Lion 10.7.3上被Alex Zielenski逆转
/// 验证,稳定
/// 在当前CGSConnection或全局中注册一个游标

/// 注册游标
/// @param cid 进程连接ID
/// @param cursorName 游标名
/// @param setGlobally 是否全局
/// @param instantly 立即变更
/// @param frameCount 帧数
/// @param imageArray 图标数组
/// @param cursorSize 游标大小
/// @param hotspot 热点
/// @param seed 变化数
/// @param bounds 大小
/// @param frameDuration 帧时长
/// @param repeatCount 重复次数
CG_EXTERN CGError CGSRegisterCursorWithImages(YMCGSConnectionID cid, char *cursorName, bool setGlobally, bool instantly, NSUInteger frameCount, CFArrayRef imageArray, CGSize cursorSize, CGPoint hotspot, int *seed, CGRect bounds, CGFloat frameDuration, NSInteger repeatCount);
CGError YMCGSRegisterCursorWithImages(YMCGSConnectionID cid, char *cursorName, bool setGlobally, bool instantly, NSUInteger frameCount, CFArrayRef imageArray, CGSize cursorSize, CGPoint hotspot, int *seed, CGRect bounds, CGFloat frameDuration, NSInteger repeatCount) {
    return CGSRegisterCursorWithImages(cid, cursorName, setGlobally, instantly, frameCount, imageArray, cursorSize, hotspot, seed, bounds, frameDuration, repeatCount);
}

/// 设置系统定义游标
/// @param cid 进程连接ID
/// @param cursorID 游标ID
CG_EXTERN CGError CGSSetSystemDefinedCursor(YMCGSConnectionID cid, int cursorID);
CGError YMCGSSetSystemDefinedCursor(YMCGSConnectionID cid, YMCGSCursorID cursorID) {
    return CGSSetSystemDefinedCursor(cid, cursorID);
}

/// 设置当前游标为系统定义的游标，并返回seed
/// @param cid 进程连接ID
/// @param systemCursor 系统游标样式ID
/// @param cursorSeed seed
CG_EXTERN void CGSSetSystemDefinedCursorWithSeed(YMCGSConnectionID cid, int systemCursor, int *cursorSeed);
void YMCGSSetSystemDefinedCursorWithSeed(YMCGSConnectionID cid, YMCGSCursorID systemCursor, int *cursorSeed) {
    CGSSetSystemDefinedCursorWithSeed(cid, systemCursor, cursorSeed);
}

/// 指示停靠栏是否可以更改/覆盖光标的标志
/// @param cid 进程连接ID
/// @param flag 是否可以更改/覆盖
CG_EXTERN void CGSSetDockCursorOverride(YMCGSConnectionID cid, bool flag);
void YMCGSSetDockCursorOverride(YMCGSConnectionID cid, bool flag) {
    CGSSetDockCursorOverride(cid, flag);
}

/// 获取指定光标的原始 ARGB 数据的大小（以字节为单位）
/// @param cid 进程连接ID
/// @param cursorName 游标名
/// @param size 大小
CG_EXTERN CGError CGSGetRegisteredCursorDataSize(YMCGSConnectionID cid, char *cursorName, size_t *size);
CGError YMCGSGetRegisteredCursorDataSize(YMCGSConnectionID cid, char *cursorName, size_t *size) {
    return CGSGetRegisteredCursorDataSize(cid, cursorName, size);
}

/// 创建并返回 CGImage 表示和名称的光标热点。 所有权遵循创建规则
/// @param cid  进程连接ID
/// @param cursorName 游标名
/// @param hotSpot 热点
CG_EXTERN CGImageRef CGSCreateRegisteredCursorImage(YMCGSConnectionID cid, char *cursorName, CGPoint *hotSpot);
CGImageRef YMCGSCreateRegisteredCursorImage(YMCGSConnectionID cid, char *cursorName, CGPoint *hotSpot) {
    return CGSCreateRegisteredCursorImage(cid, cursorName, hotSpot);
}

/// 将当前游标设置为游标名。 返回当前游标的种子。
/// @param cid 进程连接ID
/// @param cursorName 游标名
/// @param seed 变化数值
CG_EXTERN CGError CGSSetRegisteredCursor(YMCGSConnectionID cid, char *cursorName, int *seed);
CGError YMCGSSetRegisteredCursor(YMCGSConnectionID cid, char *cursorName, int *seed) {
    return CGSSetRegisteredCursor(cid, cursorName, seed);
}

/// 检索注册的 ARGB 光标数据和其他一些重要信息
/// @param cid 进程连接ID
/// @param cursorName 游标名
/// @param data 游标数据
/// @param dataSize 游标数据大小
/// @param bytesPerRow ？？
/// @param imageSize 图片大小
/// @param cursorSize 游标大小
/// @param hotSpot 热点
/// @param bitsPerPixel ？？
/// @param samplesPerPixel ？？
/// @param bitsPerSample ？？
/// @param frameCount ？？
/// @param frameDuration ？？
CG_EXTERN CGError CGSGetRegisteredCursorData2(YMCGSConnectionID cid, char *cursorName, void *data, size_t *dataSize, int *bytesPerRow, CGSize *imageSize, CGSize *cursorSize, CGPoint *hotSpot, int *bitsPerPixel, int *samplesPerPixel, int *bitsPerSample, int *frameCount, float *frameDuration);
CGError YMCGSGetRegisteredCursorData2(YMCGSConnectionID cid, char *cursorName, void *data, size_t *dataSize, int *bytesPerRow, CGSize *imageSize, CGSize *cursorSize, CGPoint *hotSpot, int *bitsPerPixel, int *samplesPerPixel, int *bitsPerSample, int *frameCount, float *frameDuration) {
    return CGSGetRegisteredCursorData2(cid, cursorName, data, dataSize, bytesPerRow, imageSize, cursorSize, hotSpot, bitsPerPixel, samplesPerPixel, bitsPerSample, frameCount, frameDuration);
}

/// 显示游标
/// @param cid 进程连接ID
CG_EXTERN CGError CGSShowCursor(YMCGSConnectionID cid);
CGError YMCGSShowCursor(YMCGSConnectionID cid) {
    return CGSShowCursor(cid);
}

/// 隐藏游标
/// @param cid 进程连接ID
CG_EXTERN CGError CGSHideCursor(YMCGSConnectionID cid);
CGError YMCGSHideCursor(YMCGSConnectionID cid) {
    return CGSHideCursor(cid);
}

/// 隐藏光标直到鼠标移动
/// @param cid 进程连接ID
CG_EXTERN CGError CGSObscureCursor(YMCGSConnectionID cid);
CGError YMCGSObscureCursor(YMCGSConnectionID cid) {
    return CGSObscureCursor(cid);
}

/// 获取光标位置
/// @param cid 进程连接ID
/// @param outPos 坐标
CG_EXTERN CGError CGSGetCurrentCursorLocation(YMCGSConnectionID cid, CGPoint *outPos);
CGError YMCGSGetCurrentCursorLocation(YMCGSConnectionID cid, CGPoint *outPos) {
    return CGSGetCurrentCursorLocation(cid, outPos);
}

/// 获取系统游标的名称(以反向DNS形式)。
/// @param cursor 游标ID
CG_EXTERN char *CGSCursorNameForSystemCursor(int cursor);
char *YMCGSCursorNameForSystemCursor(YMCGSCursorID cursor) {
    return CGSCursorNameForSystemCursor(cursor);
}

/// 获取当前游标的数据大小
/// @param cid 进程连接ID
/// @param outDataSize 数据大小
CG_EXTERN CGError CGSGetCursorDataSize(YMCGSConnectionID cid, int *outDataSize);
CGError YMCGSGetCursorDataSize(YMCGSConnectionID cid, int *outDataSize) {
    return CGSGetCursorDataSize(cid, outDataSize);
}

/// 获取当前游标的输出数据
/// @param cid 进程连接ID
/// @param outData 输出数据
CG_EXTERN CGError CGSGetCursorData(YMCGSConnectionID cid, void *outData);
CGError YMCGSGetCursorData(YMCGSConnectionID cid, void *outData) {
    return CGSGetCursorData(cid, outData);
}

/// 获取全局游标的输出数据的大小
/// @param cid 进程连接ID
/// @param outDataSize 输出数据大小
CG_EXTERN CGError CGSGetGlobalCursorDataSize(YMCGSConnectionID cid, int *outDataSize);
CGError YMCGSGetGlobalCursorDataSize(YMCGSConnectionID cid, int *outDataSize) {
    return CGSGetGlobalCursorDataSize(cid, outDataSize);
}

/// 获取全局游标的数据
/// @param cid 进程连接ID
/// @param outData 输出数据
/// @param outDataSize 数据长度
/// @param outSize 输出长度
/// @param outHotSpot 热点
/// @param outDepth 深度
/// @param outComponents  组件
/// @param outBitsPerComponent 每位/组件
/// @param m ??
CG_EXTERN CGError CGSGetGlobalCursorData(YMCGSConnectionID cid, void *outData, int *outDataSize, CGSize *outSize, CGPoint *outHotSpot, int *outDepth, int *outComponents, int *outBitsPerComponent, int *m);
CGError YMCGSGetGlobalCursorData(YMCGSConnectionID cid, void *outData, int *outDataSize, CGSize *outSize, CGPoint *outHotSpot, int *outDepth, int *outComponents, int *outBitsPerComponent, int *m) {
    return CGSGetGlobalCursorData(cid, outData, outDataSize, outSize, outHotSpot, outDepth, outComponents, outBitsPerComponent, m);
}

/// 获取系统定义游标的数据大小
/// @param cid 进程连接ID
/// @param cursor 游标ID
/// @param outDataSize 游标大小
CG_EXTERN CGError CGSGetSystemDefinedCursorDataSize(YMCGSConnectionID cid, YMCGSCursorID cursor, int *outDataSize);
CGError YMCGSGetSystemDefinedCursorDataSize(YMCGSConnectionID cid, YMCGSCursorID cursor, int *outDataSize) {
    return CGSGetSystemDefinedCursorDataSize(cid, cursor, outDataSize);
}

/// 获取系统定义游标的数据
/// @param cid 进程连接ID
/// @param cursor 游标ID
/// @param outData 游标数据
/// @param outRowBytes ??
/// @param outRect ??
/// @param outHotSpot ??
/// @param outDepth ??
/// @param outComponents ??
/// @param outBitsPerComponent ??
/// @param mystery ??
CG_EXTERN CGError CGSGetSystemDefinedCursorData(YMCGSConnectionID cid, YMCGSCursorID cursor, void *outData, int *outRowBytes, CGRect *outRect, CGRect *outHotSpot, int *outDepth, int *outComponents, int *outBitsPerComponent, int *mystery);
CGError YMCGSGetSystemDefinedCursorData(YMCGSConnectionID cid, YMCGSCursorID cursor, void *outData, int *outRowBytes, CGRect *outRect, CGRect *outHotSpot, int *outDepth, int *outComponents, int *outBitsPerComponent, int *mystery) {
    return CGSGetSystemDefinedCursorData(cid, cursor, outData, outRowBytes, outRect, outHotSpot, outDepth, outComponents, outBitsPerComponent, mystery);
}

/// 获取光标的变化数值（光标每变化一次，数值都会变化）
CG_EXTERN int CGSCurrentCursorSeed(void);
int YMCGSCurrentCursorSeed(void) {
    return CGSCurrentCursorSeed();
}

/// 显示或隐藏沙滩球
/// @param cid 进程连接ID
/// @param showWaitCursor 是否展示
CG_EXTERN CGError CGSForceWaitCursorActive(YMCGSConnectionID cid, bool showWaitCursor);
CGError  YMCGSForceWaitCursorActive(int cid, bool showWaitCursor) {
    return CGSForceWaitCursorActive(cid, showWaitCursor);
}
