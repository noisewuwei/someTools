//
//  YMOldMouseTool.m
//  YM_Category_macOS
//
//  Created by 黄玉洲 on 2021/12/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YMOldMouseTool.h"
#import "YMNewMouseTool.h"

@interface YMOldMouseTool ()
{
    CGEventType _eventType;
}

@end

@implementation YMOldMouseTool

static YMOldMouseTool * instance;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMOldMouseTool alloc] init];
    });
    return instance;
}

/// 旧版API接口
/// @param mouseBtn 按钮类型
/// @param point 坐标
- (void)oldPostMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point {
    // 鼠标松开
    if (mouseBtn == YMMouseButton_Empty) {
        // 如果存在点击了其他键，则释放掉
        if ((_eventType & kCGEventOtherMouseDown) == kCGEventOtherMouseDown) {
            _eventType = (CGEventType)(_eventType & ~kCGEventOtherMouseDown);
            [self simpleMouseEvent:kCGEventOtherMouseUp point:point];
        }
        
        // 如果存在点击了右键，则释放掉
        if ((_eventType & kCGEventRightMouseDown) == kCGEventRightMouseDown) {
            _eventType = (CGEventType)(_eventType & ~kCGEventRightMouseDown);
            [self simpleMouseEvent:kCGEventRightMouseUp point:point];
        }
        
        // 如果存在点击了左键，则释放掉
        if ((_eventType & kCGEventLeftMouseDown) == kCGEventLeftMouseDown) {
            _eventType = (CGEventType)(_eventType & ~kCGEventLeftMouseDown);
            [self simpleMouseEvent:kCGEventLeftMouseUp point:point];
        }

        // 鼠标移动
        [self simpleMouseEvent:kCGEventMouseMoved point:point];
    }
    // 鼠标左键
    else if (mouseBtn == YMMouseButton_Left) {
        _eventType = (CGEventType)(_eventType | kCGEventLeftMouseDown);
        [self simpleMouseEvent:kCGEventLeftMouseDown point:point];
    }
    // 鼠标右键
    else if (mouseBtn == YMMouseButton_Right) {
        _eventType = (CGEventType)(_eventType | kCGEventRightMouseDown);
        [self simpleMouseEvent:kCGEventRightMouseDown point:point];

//        _eventType |= kCGEventRightMouseUp;
//        [self _CGPostMouseEvent:kCGEventRightMouseUp point:point];
    }
    // 鼠标中键
    else if (mouseBtn == YMMouseButton_Center) {
        _eventType = (CGEventType)(_eventType | kCGEventOtherMouseDown);
        [self simpleMouseEvent:kCGEventOtherMouseDown point:point];
    }
    // 其他按键
    else if (mouseBtn == YMMouseButton_Other1) {
        _eventType = (CGEventType)(_eventType | kCGEventOtherMouseDown);
        YMMouseModel * mouseModel = [[YMMouseModel alloc] init];
        mouseModel.mousePoint = point;
        mouseModel.eventType = kCGEventOtherMouseDown;
        mouseModel.otherMouseDown1 = YES;
        mouseModel.otherMouseDown2 = NO;
        [self processMouseEvent:mouseModel];
    }
    // 其他按键
    else if (mouseBtn == YMMouseButton_Other2) {
        _eventType = (CGEventType)(_eventType | kCGEventOtherMouseDown);
        YMMouseModel * mouseModel = [[YMMouseModel alloc] init];
        mouseModel.mousePoint = point;
        mouseModel.eventType = kCGEventOtherMouseDown;
        mouseModel.otherMouseDown1 = NO;
        mouseModel.otherMouseDown2 = YES;
        [self processMouseEvent:mouseModel];
    }
    // 鼠标滚轮上下滚动
    else if (mouseBtn == YMMouseButton_WheelUp || mouseBtn == YMMouseButton_WheelDown) {
        [self postMouseScrollEvent:mouseBtn == YMMouseButton_WheelUp ? self.mouseScrollEdge : -self.mouseScrollEdge
                        horizontal:NO deltax:0 deltay:0];
    }
    // 鼠标滚轮左右滚动
    else if (mouseBtn == YMMouseButton_WheelLeft || mouseBtn == YMMouseButton_WheelRight) {
        [self postMouseScrollEvent:mouseBtn == YMMouseButton_WheelLeft ? -self.mouseScrollEdge : self.mouseScrollEdge
                        horizontal:YES deltax:0 deltay:0];
    }
}

#pragma mark - private
- (void)simpleMouseEvent:(CGEventType)eventType point:(CGPoint)point {
    YMMouseModel * mouseModel = [[YMMouseModel alloc] init];
    mouseModel.mousePoint = point;
    mouseModel.eventType = eventType;
    
    if (eventType == kCGEventOtherMouseDown) {
        mouseModel.middleMouseDown = YES;
    }
    if (eventType == kCGEventLeftMouseDown) {
        mouseModel.leftMouseDown = YES;
    }
    if (eventType == kCGEventRightMouseDown) {
        mouseModel.rightMouseDown = YES;
    }
    [self processMouseEvent:mouseModel];
}

/// 旧API鼠标注入
/// @param mouseModel 鼠标事件模型
- (void)processMouseEvent:(YMMouseModel *)mouseModel {
    // 鼠标移动
    if (mouseModel.eventType == kCGEventMouseMoved) {
        [self postMouseMoveEvent:mouseModel];
    }
    // 其他鼠标操作（滚轮除外）
    else {
        [self postMouseEvent:mouseModel];
    }
}

#pragma makr - 鼠标注入
/// 注入鼠标事件
/// @param mouseModel 鼠标注入模型
- (void)postMouseEvent:(YMMouseModel *)mouseModel {
    CGPostMouseEvent(mouseModel.mousePoint, true, 5,
                     mouseModel.leftMouseDown, mouseModel.rightMouseDown, mouseModel.middleMouseDown,
                     mouseModel.otherMouseDown1, mouseModel.otherMouseDown2);
}

/// 鼠标移动事件
/// @param mouseModel 鼠标注入模型
- (void)postMouseMoveEvent:(YMMouseModel *)mouseModel {
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef theEvent = CGEventCreateMouseEvent(source, mouseModel.eventType, mouseModel.mousePoint, kCGMouseButtonLeft);
    CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, 0);
    CGEventSetType(theEvent, mouseModel.eventType);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
    CFRelease(source);
}



@end
