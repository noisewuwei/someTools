//
//  NSView+YMCategory.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/6/3.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSView (YMCategory)

/// 添加鼠标移动监听
- (void)ymAddTrackArea;

/// NSPoint是否被包含在当前视图中
/// @param point NSPoint
- (BOOL)ymContainPoint:(NSPoint)point;

/// NSRect是否被包含在当前视图中
/// @param rect NSRect
- (BOOL)ymContainRect:(NSRect)rect;

/// 背景色
@property (copy, nonatomic, readonly) NSView * (^ymBackgroundColor)(NSColor * color);

/// 边框
/// @param color 颜色
/// @param width 宽度
@property (copy, nonatomic, readonly) NSView * (^ymBorder)(NSColor * color, CGFloat width);

/// 阴影
/// @param color 颜色
/// @param offset 阴影与原始绘图的偏移量，在默认用户空间单位中，正值向上和向右
/// @param blurRadius 阴影半径
@property (copy, nonatomic, readonly) NSView * (^ymShadow)(NSColor * color, CGSize offset, CGFloat blurRadius);

/// 移除所有子视图
- (void)removeAllChild;

@end

#pragma mark - 坐标、尺寸
@interface NSView (Frame)

#pragma mark point
@property (assign, nonatomic) CGPoint origin;
@property (assign, nonatomic, readonly) CGPoint topLeft;
@property (assign, nonatomic, readonly) CGPoint topRight;
@property (assign, nonatomic, readonly) CGPoint bottomLeft;
@property (assign, nonatomic, readonly) CGPoint bottomRight;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@property (assign, nonatomic) CGPoint center;
@property (assign, nonatomic) CGFloat top;
@property (assign, nonatomic) CGFloat left;
@property (assign, nonatomic) CGFloat bottom;
@property (assign, nonatomic) CGFloat right;

#pragma mark size
@property (assign, nonatomic) CGSize  size;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat width;

#pragma mark transform
/** 在原有的基础上缩放 */
- (void)ymScaleBy:(CGFloat)scaleFactor;

/** 根据给定的尺寸，缩放成最贴近的尺寸 */
- (void)ymFitInSize:(CGSize)aSize;

#pragma mark xib
/// 获取nib对象
+ (NSView *)nibView;

- (void)loadNib;

@end

NS_ASSUME_NONNULL_END
