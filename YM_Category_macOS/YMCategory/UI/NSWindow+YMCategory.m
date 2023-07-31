//
//  NSWindow+YMCategory.m
//  ToDesk
//
//  Created by 黄玉洲 on 2021/8/27.
//

#import "NSWindow+YMCategory.h"
#import "NSObject+YMCategory.h"
@implementation NSWindow (YMCategory)

/// 通过坐标获取NSWindow（限当前应用程序，无法获取其他应用程序的窗口）
/// @param point 坐标
+ (NSWindow *)ymWindowFromPoint:(CGPoint)point {
    int windowNumber = [NSWindow windowNumberAtPoint:point belowWindowWithWindowNumber:0];
    NSWindow * window = [NSApp windowWithWindowNumber:windowNumber];
    return window;
}

/// 是否处于全屏状态
- (bool)isFullScreen {
    return (([self styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask);
}

/// 是否处于最大化
- (bool)isMaximize {
    return self.isZoomed;
}

/// 全屏切换
/// @param fullScreen 是否切换到全屏
- (void)toggleFullScreenWithState:(bool)fullScreen {
    if (fullScreen && !self.isFullScreen) {
        self.collectionBehavior = NSWindowCollectionBehaviorFullScreenAuxiliary | NSWindowCollectionBehaviorFullScreenPrimary;
        [self toggleFullScreen:nil];
    } else if (!fullScreen && self.isFullScreen) {
        self.collectionBehavior = NSWindowCollectionBehaviorFullScreenAuxiliary | NSWindowCollectionBehaviorFullScreenPrimary;
        [self toggleFullScreen:nil];
    }
}



@end
