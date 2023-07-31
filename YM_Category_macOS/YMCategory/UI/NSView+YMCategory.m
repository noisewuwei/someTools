//
//  NSView+YMCategory.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/6/3.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "NSView+YMCategory.h"
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NSObject+YMCategory.h"
typedef NS_OPTIONS(NSUInteger, kTrackingAreaOptions) {
    /*
     跟踪区域的类型。
     您必须在-initWithRect：options：owner：userInfo的NSTrackingAreaOptions参数中从此列表中指定一种或多种类型：
     */
    /// 拥有者在鼠标进入区域时收到mouseEnter，而在鼠标离开区域时获得mouseExit
    kTrackingMouseEnteredAndExited     = 0x01,
    /// 当鼠标在区域内时，所有者收到mouseMoved。 请注意，mouseMoved事件不包含userInfo
    kTrackingMouseMoved                = 0x02,
    /// 鼠标进入区域时，所有者收到cursorUpdate。 鼠标离开区域时，光标设置正确
    kTrackingCursorUpdate         = 0x04,

    /*
     跟踪区域的行为。
     这些值在NSTrackingAreaOptions中使用。
     您可以在-initWithRect：options：owner：userInfo的NSTrackingAreaOptions参数中指定以下任意数目：
     */
    /// 所有者在视图为第一响应者时收到mouseEntered / exited，mouseMoved或cursorUpdate
    kTrackingActiveWhenFirstResponder     = 0x10,
    /// 当视图在关键窗口中时，所有者收到mouseEntered / Exited，mouseMoved或cursorUpdate
    kTrackingActiveInKeyWindow         = 0x20,
    /// 所有者在应用程序激活时收到mouseEntered / Exited，mouseMoved或cursorUpdate
    kTrackingActiveInActiveApp     = 0x40,
    /// 所有者不考虑激活而收到mouseEntered / Exited或mouseMoved。 NSTrackingCursorUpdate不支持。
    kTrackingActiveAlways         = 0x80,
    
    

    /*
     跟踪区域的行为。
     这些值在NSTrackingAreaOptions中使用。
     您可以在-initWithRect：options：owner：userInfo的NSTrackingAreaOptions参数中指定以下任意数目：
     */
    /// 如果设置，则在鼠标离开区域时生成mouseExited事件
    /// （与不赞成使用的addTrackingRect：owner：userData：assumeInside：中的acceptInside参数相同）
    kTrackingAssumeInside              = 0x100,
    /// 如果设置，跟踪将在view的visibleRect中发生，而rect被忽略
    kTrackingInVisibleRect             = 0x200,
    /// 如果设置，将在拖动鼠标时生成mouseEntered事件。
    /// 如果未设置，则将在移动鼠标时以及拖动后在mouseUp上生成mouseEntered事件。
    /// mouseExited事件与mouseEntered事件配对，因此它们的传递受到间接影响。
    /// 也就是说，如果生成了mouseEntered事件，并且鼠标随后移出trackingArea，则无论鼠标是移动还是拖动，都将生成mouseExited事件，而与该标志无关。
    kTrackingEnabledDuringMouseDrag    = 0x400
};


@implementation NSView (YMCategory)

/// 添加鼠标移动监听
- (void)ymAddTrackArea {
    NSTrackingAreaOptions options = kTrackingActiveAlways | kTrackingInVisibleRect | kTrackingMouseEnteredAndExited | kTrackingMouseMoved;
    NSTrackingArea * trackingArea = [[NSTrackingArea alloc] initWithRect:self.frame options:options owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

/// NSPoint是否被包含在当前视图中
/// @param point NSPoint
- (BOOL)ymContainPoint:(NSPoint)point {
    return CGRectContainsPoint(self.frame, point);
}

/// NSRect是否被包含在当前视图中
/// @param rect NSRect
- (BOOL)ymContainRect:(NSRect)rect {
    return CGRectContainsRect(self.frame, rect);
}

/// 移除所有子视图
- (void)removeAllChild {
    NSMutableArray * mArray = [NSMutableArray array];
    for (NSView * view in self.subviews) {
        [mArray addObject:view];
    }
    
    for (NSView * view in mArray) {
        [view removeFromSuperview];
    }
}

#pragma mark - setter
/// 背景色
- (NSView * _Nonnull (^)(NSColor * _Nonnull))ymBackgroundColor {
    return ^NSView *(NSColor * color) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = color.CGColor;
        return self;
    };
}

/// 边框
- (NSView * _Nonnull (^)(NSColor * _Nonnull, CGFloat))ymBorder {
    return ^NSView *(NSColor * _Nonnull color, CGFloat width) {
        self.wantsLayer = YES;
        self.layer.borderColor = color.CGColor;
        self.layer.borderWidth = width;
        return self;
    };
}

/// 阴影
- (NSView * _Nonnull (^)(NSColor * _Nonnull, CGSize, CGFloat))ymShadow {
    return ^NSView *(NSColor * _Nonnull color, CGSize offset, CGFloat blurRadius) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = color;
        shadow.shadowOffset = offset;
        shadow.shadowBlurRadius = blurRadius;
        [self setShadow:shadow];
        return self;
    };
}

@end


#pragma mark - 坐标、尺寸
@implementation NSView (Frame)
#pragma mark point
- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)aPoint {
    CGRect newframe = self.frame;
    newframe.origin = aPoint;
    self.frame = newframe;
}

- (CGPoint)topLeft {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}

- (CGPoint)topRight {
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y;
    return CGPointMake(x, y);
}

- (CGPoint)bottomRight {
    CGFloat x = self.frame.origin.x + self.frame.size.width;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)bottomLeft {
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y + self.frame.size.height;
    return CGPointMake(x, y);
}

- (CGPoint)center {
    CGPoint tempCenter = CGPointMake(self.left + self.width / 2.0,
                                     self.top + self.height / 2.0);
    return tempCenter;
}
- (void)setCenter:(CGPoint)center {
    self.left = center.x - self.width / 2.0;
    self.top = center.y - self.height / 2.0;
}

- (CGFloat)centerX {
    return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}
- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)newtop {
    CGRect newframe = self.frame;
    newframe.origin.y = newtop;
    self.frame = newframe;
}


- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)newleft {
    CGRect newframe = self.frame;
    newframe.origin.x = newleft;
    self.frame = newframe;
}


- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)newbottom {
    CGRect newframe = self.frame;
    newframe.origin.y = newbottom - self.frame.size.height;
    self.frame = newframe;
}


- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)newright {
    CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

#pragma mark size
- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)aSize {
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newheight {
    CGRect newframe = self.frame;
    newframe.size.height = newheight;
    self.frame = newframe;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newwidth {
    CGRect newframe = self.frame;
    newframe.size.width = newwidth;
    self.frame = newframe;
}


#pragma mark transform
/** 在原有的基础上缩放 */
- (void)ymScaleBy:(CGFloat)scaleFactor {
    CGRect newframe = self.frame;
    newframe.size.width *= scaleFactor;
    newframe.size.height *= scaleFactor;
    self.frame = newframe;
}

/** 根据给定的尺寸，缩放成最贴近的尺寸 */
- (void)ymFitInSize:(CGSize)aSize {
    CGFloat scale;
    CGRect newframe = self.frame;
    
    if (newframe.size.height && (newframe.size.height > aSize.height)) {
        scale = aSize.height / newframe.size.height;
        newframe.size.width *= scale;
        newframe.size.height *= scale;
    }
    
    if (newframe.size.width && (newframe.size.width >= aSize.width)) {
        scale = aSize.width / newframe.size.width;
        newframe.size.width *= scale;
        newframe.size.height *= scale;
    }
    
    self.frame = newframe;
}

#pragma mark - xib
/// 获取nib对象
+ (NSView *)nibView {
    NSString * className = NSStringFromClass(self);
    if ([className containsString:@"."]) {
        className = [className componentsSeparatedByString:@"."].lastObject;
    }
    
    NSArray * topLevelObjects;
    [[NSBundle mainBundle] loadNibNamed:className owner:self topLevelObjects:&topLevelObjects];
    for (NSView * view in topLevelObjects) {
        if ([view isKindOfClass:[NSView class]]) {
            return view;
        }
    }
    return [self new];
}

- (void)loadNib {
    NSString * className = NSStringFromClass([self class]);
    NSNib * newNib = [[NSNib alloc] initWithNibNamed:className bundle:[NSBundle bundleForClass:[self class]]];
    [newNib instantiateWithOwner:self topLevelObjects:nil];
}

static char alreadyLoadNibKey;
- (void)setAlreadyLoadNib:(BOOL)already {
    self.setProperty(&alreadyLoadNibKey, @(already));
}

- (BOOL)alreadyLoadNib {
    return [self.getProperty(&alreadyLoadNibKey) boolValue];
}

//- (void)loadNib {
//    DLog(@"%@ %d", self, [self alreadyLoadNib]);
//    if (![self alreadyLoadNib]) {
//        [self setAlreadyLoadNib:YES];
//        NSString * className = NSStringFromClass([self class]);
//        NSNib * newNib = [[NSNib alloc] initWithNibNamed:className bundle:[NSBundle bundleForClass:[self class]]];
//
////        [newNib instantiateWithOwner:self topLevelObjects:nil];
////        DLog(@"%@", self);
////        [[NSBundle mainBundle] loadNibNamed:className owner:self topLevelObjects:nil];
//    }
//
//}

@end
