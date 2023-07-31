//
//  YMMouseTool.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/9/11.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "YMMouseTool.h"
#import "YMNewMouseTool.h"
#import "YMOldMouseTool.h"
#import "YMPermissionTool.h"




typedef NS_ENUM(NSInteger, YMMouseError) {
    YMMouseErrorUnauthorized = 1, // 未授权
};


@interface YMMouseTool ()

@property (strong, nonatomic) dispatch_queue_t mouseQueue;
@property (strong, nonatomic) NSScreen * currentScreen;
@property (assign, nonatomic) CGScrollEventUnit scrollEventUnit;
 
@property (assign, nonatomic) BOOL useNewAPI;

@end

@implementation YMMouseTool

static YMMouseTool * instance;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMMouseTool alloc] init];
    });
    return instance;
}

/// 屏幕分辨率发生变化时会触发
//void screenDidChangeCallBack(CGDirectDisplayID display, CGDisplayChangeSummaryFlags flags, void * __nullable userInfo) {
//    YMMouseTool * tool = (__bridge YMMouseTool *)userInfo;
//    tool.screenIndex = tool.screenIndex;
//}

- (instancetype)init {
    if (self = [super init]) {
        [YMOldMouseTool share];
        [YMNewMouseTool share];
        
        self.mouseScrollEdge = 10;
        self.displayID = CGMainDisplayID();
        self.scrollEventUnit = kCGScrollEventUnitPixel;
        self.mouseSubtype = 0x77;
        
        // 监听屏幕比例
//        CGError err = CGDisplayRegisterReconfigurationCallback(screenDidChangeCallBack,  (void *)CFBridgingRetain(self));
    }
    return self;
}

/// 使用新版API
/// @param use 是否使用
- (void)useNewAPI:(BOOL)use {
    _useNewAPI = use;
}

#pragma mark 鼠标操作命令
- (void)postMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point deltax:(int32_t)deltax deltay:(int32_t)deltay{
    // 异步处理数据再到主线程处理鼠标移动
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.mouseQueue, ^{
        __strong __typeof(weakSelf) self = weakSelf;
        if (self.useNewAPI) {
            [[YMNewMouseTool share] newPostMouseEvent:mouseBtn point:point deltax:deltax deltay:deltay];
        } else {
            [[YMOldMouseTool share] oldPostMouseEvent:mouseBtn point:point];
        }
    });
}

#pragma mark 鼠标操作命令
- (void)postMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point{
    // 异步处理数据再到主线程处理鼠标移动
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.mouseQueue, ^{
        __strong __typeof(weakSelf) self = weakSelf;
        if (self.useNewAPI) {
            [[YMNewMouseTool share] newPostMouseEvent:mouseBtn point:point];
        } else {
            [[YMOldMouseTool share] oldPostMouseEvent:mouseBtn point:point];
        }
    });
}

/// 发送鼠标事件（仅限使用新版API）
/// @param mouseBtn 鼠标按键
/// @param point 坐标位置
/// @param buttonCount 0:左键 1:右键 2:中键 3~32：其他按键
- (void)postMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point buttonCount:(NSInteger)buttonCount {
    // 异步处理数据再到主线程处理鼠标移动
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.mouseQueue, ^{
        __strong __typeof(weakSelf) self = weakSelf;
        if (self.useNewAPI) {
            [[YMNewMouseTool share] newPostMouseEvent:mouseBtn point:point deltax:0 deltay:0];
        }
    });
}

#pragma mark 监听事件
/// 添加鼠标监听（需要授权辅助功能）
- (id)addListeningMouse:(YMMouseEventType)eventType callback:(kListningMouseCallBack)callback error:(NSError **)error {
    return [self addListeningMouse:eventType callback:callback userInfo:nil error:error];
}

/// 添加鼠标监听（需要授权辅助功能）
- (id)addListeningMouse:(YMMouseEventType)eventType callback:(kListningMouseCallBack)callback userInfo:(id)userInfo error:(NSError **)error {
    if (![YMPermissionTool accessibilityPermissions]) {
        if (error) {
            *error = [self errorWithCode:YMMouseErrorUnauthorized];
        }
        return nil;
    }
    CGEventMask eventMask = 0;
    if (eventType & YMMouseEventType_All) {
        eventMask = CGEventMaskBit(kCGEventLeftMouseDown) | CGEventMaskBit(kCGEventLeftMouseUp) |
                    CGEventMaskBit(kCGEventRightMouseDown) | CGEventMaskBit(kCGEventRightMouseUp) |
                    CGEventMaskBit(kCGEventMouseMoved) |
                    CGEventMaskBit(kCGEventLeftMouseDragged) | CGEventMaskBit(kCGEventRightMouseDragged) |
                    CGEventMaskBit(kCGEventScrollWheel) |
                    CGEventMaskBit(kCGEventOtherMouseDown) | CGEventMaskBit(kCGEventOtherMouseUp) |
                    CGEventMaskBit(kCGEventOtherMouseDragged);
    } else {
        eventMask = (eventType & YMMouseEventType_Null) ? (eventMask | CGEventMaskBit(kCGEventNull)) : eventMask;
        eventMask = eventType & YMMouseEventType_LeftMouseDown ? (eventMask | CGEventMaskBit(kCGEventLeftMouseDown)) : eventMask;
        eventMask = eventType & YMMouseEventType_LeftMouseUp ? (eventMask | CGEventMaskBit(kCGEventLeftMouseUp)) : eventMask;
        eventMask = eventType & YMMouseEventType_RightMouseDown ? (eventMask | CGEventMaskBit(kCGEventRightMouseDown)) : eventMask;
        eventMask = eventType & YMMouseEventType_RightMouseUp ? eventMask | CGEventMaskBit(kCGEventRightMouseUp) : eventMask;
        eventMask = eventType & YMMouseEventType_MouseMoved ? eventMask | CGEventMaskBit(kCGEventMouseMoved) : eventMask;
        eventMask = eventType & YMMouseEventType_LeftMouseDragged ? eventMask | CGEventMaskBit(kCGEventLeftMouseDragged) : eventMask;
        eventMask = eventType & YMMouseEventType_RightMouseDragged ? eventMask | CGEventMaskBit(kCGEventRightMouseDragged) : eventMask;
        eventMask = eventType & YMMouseEventType_ScrollWheel ? eventMask | CGEventMaskBit(kCGEventScrollWheel) : eventMask;
        eventMask = eventType & YMMouseEventType_OtherMouseDown ? eventMask | CGEventMaskBit(kCGEventOtherMouseDown) : eventMask;
        eventMask = eventType & YMMouseEventType_OtherMouseUp ? eventMask | CGEventMaskBit(kCGEventOtherMouseUp) : eventMask;
        eventMask = eventType & YMMouseEventType_OtherMouseDragged ? eventMask | CGEventMaskBit(kCGEventOtherMouseDragged) : eventMask;
    }
    
    CFMachPortRef eventTap = nil;
    if (userInfo) {
        eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, eventMask, callback, (__bridge void * _Nullable)(userInfo));
    } else {
        eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, eventMask, callback, NULL);
    }
    
    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    CFRelease(eventTap);
    CFRelease(runLoopSource);
    return (__bridge id)(eventTap);
}

/// 移除鼠标监听
- (void)removeListeningMouse:(id)listeningObj {
    if (!listeningObj) {
        return;
    }
    CGEventTapEnable((__bridge CFMachPortRef)listeningObj, false);
}

/// 是否为当前进程发出的事件
/// @param event CGEventRef
- (BOOL)isThisProcess:(CGEventRef _Nullable)event {
    if (!event) {
        return NO;
    }
    int thisProcessPID = getpid();
    int eventProcessPID = [self pidWithEvent:event];
    return thisProcessPID == eventProcessPID;
}

/// 发出该事件的进程ID。如果返回-1，说明发生错误
/// @param event CGEventRef
- (int)pidWithEvent:(CGEventRef _Nullable)event {
    if (!event) {
        return -1;
    }
    
    int processID = (int)CGEventGetIntegerValueField(event, kCGEventTargetUnixProcessID);
    return processID;
}

/// 判断事件是否包含在指定的范围内
/// @param event CGEventRef
/// @param rect NSRect
/// @param inBottom 事件坐标起始点是否需要转换为左下角起始
- (BOOL)event:(CGEventRef _Nullable)event inRect:(NSRect)rect inBottom:(BOOL)inBottom {
    if (!event) {
        return NO;
    }
    
    CGPoint loc = [YMMouseTool potinWithEvent:event];
    if (inBottom) {
        loc = CGPointMake(loc.x, self.currentScreen.frame.size.height - loc.y);
    }
    
    return CGRectContainsPoint(rect, loc);
}

#pragma mark - getter
/// 获取事件响应坐标
/// @param event CGEventRef
+ (CGPoint)potinWithEvent:(CGEventRef _Nullable)event {
    if (!event) {
        return CGPointMake(0, 0);
    }
    CGPoint loc = CGEventGetLocation(event);
    return loc;
}

/// 获取error
/// @param code error code
- (NSError *)errorWithCode:(YMMouseError)code {
    NSString * errorReason = @"";
    switch (code) {
        case YMMouseErrorUnauthorized: errorReason = @"Auxiliary functions are not authorized"; break;
        default: break;
    }
    NSError * error = [NSError errorWithDomain:@"MouseTool"
                                          code:code
                                      userInfo:@{NSLocalizedDescriptionKey: errorReason}];
    return error;
}

- (NSScreen *)currentScreen {
    NSScreen * screen = nil;
    for (NSScreen * temp_screen in [NSScreen screens]) {
        if ([[[temp_screen deviceDescription] objectForKey:@"NSScreenNumber"] integerValue] == self.displayID) {
            screen = temp_screen;
            break;
        }
    }
    return screen;
}

#pragma mark - class method
/// 获取当前指针所在位置
+ (NSPoint)mousePoint {
    return [NSEvent mouseLocation];
}

/// 获取当前指针所在的屏幕
+ (NSScreen *)mouseInScreen {
    CGPoint mousePoint = [self mousePoint];
    for (NSScreen * screen in NSScreen.screens) {
        if (NSMouseInRect(mousePoint, screen.frame, false)) {
            return screen;
        }
    }
    return nil;
}

#pragma mark - setter
- (void)setMouseScrollEdge:(CGFloat)mouseScrollEdge {
    _mouseScrollEdge = mouseScrollEdge;
    [YMOldMouseTool share].mouseScrollEdge = mouseScrollEdge;
    [YMNewMouseTool share].mouseScrollEdge = mouseScrollEdge;
}

- (void)setUseUnitLine:(BOOL)useUnitLine {
    _useUnitLine = useUnitLine;
    [YMOldMouseTool share].useUnitLine = useUnitLine;
    [YMNewMouseTool share].useUnitLine = useUnitLine;
    
    self.scrollEventUnit = _useUnitLine ? kCGScrollEventUnitLine : kCGScrollEventUnitPixel;
}

- (void)setDisplayID:(CGDirectDisplayID)displayID {
    _displayID = displayID;
    [YMOldMouseTool share].displayID = displayID;
    [YMNewMouseTool share].displayID = displayID;
    
}

- (void)setScrollEventUnit:(CGScrollEventUnit)scrollEventUnit {
    _scrollEventUnit = scrollEventUnit;
    [YMOldMouseTool share].scrollEventUnit = scrollEventUnit;
    [YMNewMouseTool share].scrollEventUnit = scrollEventUnit;
}

- (void)setMouseSubtype:(NSInteger)mouseSubtype {
    _mouseSubtype = mouseSubtype;
    [YMOldMouseTool share].mouseSubtype = mouseSubtype;
    [YMNewMouseTool share].mouseSubtype = mouseSubtype;
}

- (void)setLogEnable:(bool)logEnable {
    _logEnable = logEnable;
    [YMOldMouseTool share].logEnable = logEnable;
    [YMNewMouseTool share].logEnable = logEnable;
}

#pragma mark 异步串行线程
- (dispatch_queue_t)mouseQueue {
    if (!_mouseQueue) {
        _mouseQueue = dispatch_queue_create("postMouseEvent", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return _mouseQueue;
}

@end
