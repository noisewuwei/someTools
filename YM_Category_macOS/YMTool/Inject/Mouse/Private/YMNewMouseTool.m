//
//  YMNewMouseTool.m
//  YM_Category_macOS
//
//  Created by 黄玉洲 on 2021/12/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YMNewMouseTool.h"
#import "YMMouseModel.h"
#import "YMTimerTool.h"

/// 鼠标操作类型
typedef NS_ENUM(NSInteger, kMouseType) {
    kMouseType_LeftClick,           // 左键单击
    kMouseType_LeftDoubleClick,     // 左键双击
    kMouseType_LeftThreeClick,      // 左键三击
    kMouseType_LeftDrag,            // 左键拖拽
    
    kMouseType_RightClick,          // 右键单击
    kMouseType_RightDoubleClick,    // 右键双击
    kMouseType_RightDrag,           // 右键拖拽
    
    kMouseType_MiddleClick,         // 中键单击
    kMouseType_MiddleDoubleClick,   // 中键双击
    kMouseType_MiddleDrag,          // 中键拖拽
    
    kMouseType_Other1Click,         // 侧边后键单击
    kMouseType_Other2Click,         // 侧边前键单击
    
    kMouseType_Move,                // 鼠标移动
};

@interface YMNewMouseTool ()
{
    CGEventType _eventType;
}

@property (strong, nonatomic) dispatch_source_t timer;

@property (assign, nonatomic) int   leftClickCount;
@property (assign, nonatomic) int   rightClickCount;
@property (assign, nonatomic) int   middleClickCount;

@property (assign, nonatomic) BOOL leftDraged;
@property (assign, nonatomic) BOOL rightDraged;
@property (assign, nonatomic) BOOL centerDraged;

@end

@implementation YMNewMouseTool

static YMNewMouseTool * instance;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMNewMouseTool alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self resetMouseState];
    }
    return self;
}

#pragma mark 新版API接口（需要自己计算双击逻辑）
- (void)newPostMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point deltax:(int32_t)deltax deltay:(int32_t)deltay{
    // 鼠标松开
    if (mouseBtn == YMMouseButton_Empty) {
        BOOL alread = NO;
        // 如果存在点击了中键键，则释放掉
        if ((_eventType & kCGEventOtherMouseDown) == kCGEventOtherMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标中间键松开");
            alread = YES;
            _eventType = (CGEventType)(_eventType & ~kCGEventOtherMouseDown);
            _centerDraged = NO;
            [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:1];
        }
        
        // 如果存在点击了右键，则释放掉
        if ((_eventType & kCGEventRightMouseDown) == kCGEventRightMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标右键松开");
            alread = YES;
            _eventType = (CGEventType)(_eventType & ~kCGEventRightMouseDown);
            _rightDraged = NO;
            [self newPostMouseEvent:kCGEventRightMouseUp point:point button:kCGMouseButtonRight clickCount:1];
        }
        
        // 如果存在点击了左键，则释放掉
        if ((_eventType & kCGEventLeftMouseDown) == kCGEventLeftMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标左键松开");
            alread = YES;
            _eventType = (CGEventType)(_eventType & ~kCGEventLeftMouseDown);
            _leftDraged = NO;
            [self newPostMouseEvent:kCGEventLeftMouseUp point:point button:kCGMouseButtonLeft clickCount:1];
        }
        
        [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:1 buttonNumber:3];
        [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:1 buttonNumber:4];
        
        // 鼠标移动
        if (!alread) {
            [self _CGPostMouseEvent:kMouseType_Move point:point];
        } else if (_leftDraged || _rightDraged || _centerDraged) {
            [self _CGPostMouseEvent:kMouseType_Move point:point];
        }
    }
    // 鼠标左键
    else if (mouseBtn == YMMouseButton_Left) {
        if ((_eventType & kCGEventLeftMouseDown) == kCGEventLeftMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标左键拖拽");
            [self _CGPostMouseEvent:kMouseType_LeftDrag point:point];
            return;
        }
        
        _eventType = (CGEventType)(_eventType | kCGEventLeftMouseDown);
        if (self.leftClickCount == 1) {
            YMMouseLog(@"mouseBtn:鼠标左键单击");
            [self startTimer];
            self.leftClickCount++;
            [self _CGPostMouseEvent:kMouseType_LeftClick point:point];
        } else if (self.leftClickCount == 2) {
            YMMouseLog(@"mouseBtn:鼠标左键双击");
            self.leftClickCount++;
            [self _CGPostMouseEvent:kMouseType_LeftDoubleClick point:point];
        } else if (self.leftClickCount == 3) {
            YMMouseLog(@"mouseBtn:鼠标左键三击");
            self.leftClickCount++;
            [self _CGPostMouseEvent:kMouseType_LeftThreeClick point:point];
        }
    }
    // 鼠标右键
    else if (mouseBtn == YMMouseButton_Right) {
        if ((_eventType & kCGEventRightMouseDown) == kCGEventRightMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标右键拖拽");
            [self _CGPostMouseEvent:kMouseType_RightDrag point:point];
            return;
        }
        
        _eventType = (CGEventType)(_eventType | kCGEventRightMouseDown);
        if (self.rightClickCount == 1) {
            YMMouseLog(@"mouseBtn:鼠标右键单击");
            [self startTimer];
            self.rightClickCount++;
            [self _CGPostMouseEvent:kMouseType_RightClick point:point];
        } else if (self.rightClickCount == 2) {
            YMMouseLog(@"mouseBtn:鼠标右键双击");
            self.rightClickCount++;
            [self _CGPostMouseEvent:kMouseType_RightDoubleClick point:point];
        }
    }
    // 鼠标中键
    else if (mouseBtn == YMMouseButton_Center) {
        if ((_eventType & kCGEventOtherMouseDown) == kCGEventOtherMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标中键拖拽");
            [self _CGPostMouseEvent:kMouseType_MiddleDrag point:point];
            return;
        }
        
        _eventType = (CGEventType)(_eventType | kCGEventOtherMouseDown);
        if (self.middleClickCount == 1) {
            YMMouseLog(@"mouseBtn:鼠标中键单击");
            [self startTimer];
            self.middleClickCount++;
            [self _CGPostMouseEvent:kMouseType_MiddleClick point:point];
        } else if (self.middleClickCount == 2) {
            YMMouseLog(@"mouseBtn:鼠标中键双击");
            self.middleClickCount++;
            [self _CGPostMouseEvent:kMouseType_MiddleDoubleClick point:point];
        }
    }
    // 鼠标滚轮上下滚动
    else if (mouseBtn == YMMouseButton_WheelUp || mouseBtn == YMMouseButton_WheelDown) {
        [self postMouseScrollEvent:mouseBtn == YMMouseButton_WheelUp ? self.mouseScrollEdge : -self.mouseScrollEdge
                        horizontal:NO deltax:deltax deltay:deltay];
    }
    // 鼠标滚轮左右滚动
    else if (mouseBtn == YMMouseButton_WheelLeft || mouseBtn == YMMouseButton_WheelRight) {
        [self postMouseScrollEvent:mouseBtn == YMMouseButton_WheelLeft ? -self.mouseScrollEdge : self.mouseScrollEdge
                        horizontal:YES deltax:deltax deltay:deltay];
    }
    // 侧边后键
    else if (mouseBtn == YMMouseButton_Other1) {
        _eventType = (CGEventType)(_eventType | kCGEventLeftMouseDown);
        [self _CGPostMouseEvent:kMouseType_Other1Click point:point];
    }
    // 侧边前键
    else if (mouseBtn == YMMouseButton_Other2) {
        _eventType = (CGEventType)(_eventType | kCGEventLeftMouseDown);
        [self _CGPostMouseEvent:kMouseType_Other2Click point:point];
    }
}

#pragma mark 新版API接口（需要自己计算双击逻辑）
- (void)newPostMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point{
    // 鼠标松开
    if (mouseBtn == YMMouseButton_Empty) {
        BOOL alread = NO;
        // 如果存在点击了中键键，则释放掉
        if ((_eventType & kCGEventOtherMouseDown) == kCGEventOtherMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标中间键松开");
            alread = YES;
            _eventType = (CGEventType)(_eventType & ~kCGEventOtherMouseDown);
            _centerDraged = NO;
            [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:1];
        }
        
        // 如果存在点击了右键，则释放掉
        if ((_eventType & kCGEventRightMouseDown) == kCGEventRightMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标右键松开");
            alread = YES;
            _eventType = (CGEventType)(_eventType & ~kCGEventRightMouseDown);
            _rightDraged = NO;
            [self newPostMouseEvent:kCGEventRightMouseUp point:point button:kCGMouseButtonRight clickCount:1];
        }
        
        // 如果存在点击了左键，则释放掉
        if ((_eventType & kCGEventLeftMouseDown) == kCGEventLeftMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标左键松开");
            alread = YES;
            _eventType = (CGEventType)(_eventType & ~kCGEventLeftMouseDown);
            _leftDraged = NO;
            [self newPostMouseEvent:kCGEventLeftMouseUp point:point button:kCGMouseButtonLeft clickCount:1];
        }
        
        [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:1 buttonNumber:3];
        [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:1 buttonNumber:4];
        
        // 鼠标移动
        if (!alread) {
            [self _CGPostMouseEvent:kMouseType_Move point:point];
        } else if (_leftDraged || _rightDraged || _centerDraged) {
            [self _CGPostMouseEvent:kMouseType_Move point:point];
        }
    }
    // 鼠标左键
    else if (mouseBtn == YMMouseButton_Left) {
        if ((_eventType & kCGEventLeftMouseDown) == kCGEventLeftMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标左键拖拽");
            [self _CGPostMouseEvent:kMouseType_LeftDrag point:point];
            return;
        }
        
        _eventType = (CGEventType)(_eventType | kCGEventLeftMouseDown);
        if (self.leftClickCount == 1) {
            YMMouseLog(@"mouseBtn:鼠标左键单击");
            [self startTimer];
            self.leftClickCount++;
            [self _CGPostMouseEvent:kMouseType_LeftClick point:point];
        } else if (self.leftClickCount == 2) {
            YMMouseLog(@"mouseBtn:鼠标左键双击");
            self.leftClickCount++;
            [self _CGPostMouseEvent:kMouseType_LeftDoubleClick point:point];
        } else if (self.leftClickCount == 3) {
            YMMouseLog(@"mouseBtn:鼠标左键三击");
            self.leftClickCount++;
            [self _CGPostMouseEvent:kMouseType_LeftThreeClick point:point];
        }
    }
    // 鼠标右键
    else if (mouseBtn == YMMouseButton_Right) {
        if ((_eventType & kCGEventRightMouseDown) == kCGEventRightMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标右键拖拽");
            [self _CGPostMouseEvent:kMouseType_RightDrag point:point];
            return;
        }
        
        _eventType = (CGEventType)(_eventType | kCGEventRightMouseDown);
        if (self.rightClickCount == 1) {
            YMMouseLog(@"mouseBtn:鼠标右键单击");
            [self startTimer];
            self.rightClickCount++;
            [self _CGPostMouseEvent:kMouseType_RightClick point:point];
        } else if (self.rightClickCount == 2) {
            YMMouseLog(@"mouseBtn:鼠标右键双击");
            self.rightClickCount++;
            [self _CGPostMouseEvent:kMouseType_RightDoubleClick point:point];
        }
    }
    // 鼠标中键
    else if (mouseBtn == YMMouseButton_Center) {
        if ((_eventType & kCGEventOtherMouseDown) == kCGEventOtherMouseDown) {
            YMMouseLog(@"mouseBtn:鼠标中键拖拽");
            [self _CGPostMouseEvent:kMouseType_MiddleDrag point:point];
            return;
        }
        
        _eventType = (CGEventType)(_eventType | kCGEventOtherMouseDown);
        if (self.middleClickCount == 1) {
            YMMouseLog(@"mouseBtn:鼠标中键单击");
            [self startTimer];
            self.middleClickCount++;
            [self _CGPostMouseEvent:kMouseType_MiddleClick point:point];
        } else if (self.middleClickCount == 2) {
            YMMouseLog(@"mouseBtn:鼠标中键双击");
            self.middleClickCount++;
            [self _CGPostMouseEvent:kMouseType_MiddleDoubleClick point:point];
        }
    }
    // 鼠标滚轮上下滚动
    else if (mouseBtn == YMMouseButton_WheelUp || mouseBtn == YMMouseButton_WheelDown) {
        [self postMouseScrollEvent:mouseBtn == YMMouseButton_WheelUp ? self.mouseScrollEdge : -self.mouseScrollEdge
                        horizontal:NO];
    }
    // 鼠标滚轮左右滚动
    else if (mouseBtn == YMMouseButton_WheelLeft || mouseBtn == YMMouseButton_WheelRight) {
        [self postMouseScrollEvent:mouseBtn == YMMouseButton_WheelLeft ? -self.mouseScrollEdge : self.mouseScrollEdge
                        horizontal:YES];
    }
    // 侧边后键
    else if (mouseBtn == YMMouseButton_Other1) {
        _eventType = (CGEventType)(_eventType | kCGEventLeftMouseDown);
        [self _CGPostMouseEvent:kMouseType_Other1Click point:point];
    }
    // 侧边前键
    else if (mouseBtn == YMMouseButton_Other2) {
        _eventType = (CGEventType)(_eventType | kCGEventLeftMouseDown);
        [self _CGPostMouseEvent:kMouseType_Other2Click point:point];
    }
}

- (void)_CGPostMouseEvent:(kMouseType)mouseEvent point:(CGPoint)point {
    switch (mouseEvent) {
        case kMouseType_LeftClick: {
            [self newPostMouseEvent:kCGEventLeftMouseDown point:point button:kCGMouseButtonLeft clickCount:1];
            break;
        }
        case kMouseType_LeftDoubleClick: {
            [self newPostMouseEvent:kCGEventLeftMouseDown point:point button:kCGMouseButtonLeft clickCount:2];
            [self newPostMouseEvent:kCGEventLeftMouseUp point:point button:kCGMouseButtonLeft clickCount:2];
            _eventType = (CGEventType)(_eventType & ~kCGEventLeftMouseDown);
            break;
        }
        case kMouseType_LeftThreeClick: {
            [self newPostMouseEvent:kCGEventLeftMouseDown point:point button:kCGMouseButtonLeft clickCount:3];
            [self newPostMouseEvent:kCGEventLeftMouseUp point:point button:kCGMouseButtonLeft clickCount:3];
            self.leftClickCount = 1;
            _eventType = (CGEventType)(_eventType & ~kCGEventLeftMouseDown);
            break;
        }
        case kMouseType_LeftDrag: {
            if (!_leftDraged) {
                if (!(_eventType & kCGEventLeftMouseDown)) {
                    [self newPostMouseEvent:kCGEventLeftMouseDown point:point button:kCGMouseButtonLeft clickCount:1];
                }
                _leftDraged = YES;
            }
            [self newPostMouseEvent:kCGEventLeftMouseDragged point:point button:kCGMouseButtonLeft clickCount:1];
            break;
        }
        case kMouseType_RightClick: {
            [self newPostMouseEvent:kCGEventRightMouseDown point:point button:kCGMouseButtonRight clickCount:1];
            break;
        }
        case kMouseType_RightDoubleClick: {
            [self newPostMouseEvent:kCGEventRightMouseDown point:point button:kCGMouseButtonRight clickCount:2];
            [self newPostMouseEvent:kCGEventRightMouseUp point:point button:kCGMouseButtonRight clickCount:2];
            self.rightClickCount = 1;
            _eventType = (CGEventType)(_eventType & ~kCGEventRightMouseDown);
            break;
        }
        case kMouseType_RightDrag: {
            if (!_rightDraged) {
                if (!(_eventType & kCGEventRightMouseDown)) {
                    [self newPostMouseEvent:kCGEventRightMouseDown point:point button:kCGMouseButtonRight clickCount:1];
                }
                _rightDraged = YES;
            }
            [self newPostMouseEvent:kCGEventRightMouseDragged point:point button:kCGMouseButtonRight clickCount:1];
            break;
        }
        case kMouseType_MiddleClick: {
            [self newPostMouseEvent:kCGEventOtherMouseDown point:point button:kCGMouseButtonCenter clickCount:1];
            break;
        }
        case kMouseType_MiddleDoubleClick: {
            [self newPostMouseEvent:kCGEventOtherMouseDown point:point button:kCGMouseButtonCenter clickCount:2];
            [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:2];
            self.middleClickCount = 1;
            _eventType = (CGEventType)(_eventType & ~kCGEventOtherMouseDown);
            break;
        }
        case kMouseType_MiddleDrag: {
            if (!_leftDraged) {
                if (!(_eventType & kCGEventOtherMouseDown)) {
                    [self newPostMouseEvent:kCGEventOtherMouseDown point:point button:kCGMouseButtonCenter clickCount:1];
                }
                _leftDraged = YES;
            }
            [self newPostMouseEvent:kCGEventOtherMouseDragged point:point button:kCGMouseButtonCenter clickCount:1];
            break;
        }
            // 侧边键后
        case kMouseType_Other1Click: {
            [self newPostMouseEvent:kCGEventOtherMouseDown point:point button:kCGMouseButtonCenter clickCount:1 buttonNumber:3];
//            [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:1 buttonNumber:3];
            break;
        }
            // 侧边键前
        case kMouseType_Other2Click: {
            [self newPostMouseEvent:kCGEventOtherMouseDown point:point button:kCGMouseButtonCenter clickCount:1 buttonNumber:4];
//            [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:1 buttonNumber:4];
            break;
        }
            // 鼠标移动
        case kMouseType_Move: {
            if (_leftDraged) {
//                _leftDraged = NO;
//                [self newPostMouseEvent:kCGEventLeftMouseUp point:point button:kCGMouseButtonLeft clickCount:1];
            }
            if (_rightDraged) {
//                _rightDraged = NO;
//                [self newPostMouseEvent:kCGEventRightMouseUp point:point button:kCGMouseButtonRight clickCount:1];
            }
            if (_centerDraged) {
//                _centerDraged = NO;
//                [self newPostMouseEvent:kCGEventOtherMouseUp point:point button:kCGMouseButtonCenter clickCount:1 buttonNumber:2];
            }
            [self newPostMouseEvent:kCGEventMouseMoved point:point button:kCGMouseButtonLeft clickCount:0];
            break;
        }
        default: break;
    }
}

#pragma makr - 鼠标注入
/// 鼠标注入
- (void)newPostMouseEvent:(CGEventType)type point:(CGPoint)point button:(CGMouseButton)button clickCount:(int64_t)clickCount {
    NSInteger buttonNumber = -1;
    if (type == kCGEventLeftMouseDown || type == kCGEventLeftMouseUp || type == kCGEventLeftMouseDragged) {
        buttonNumber = 0;
    } else if (type == kCGEventRightMouseDown || type == kCGEventRightMouseUp || type == kCGEventRightMouseDragged) {
        buttonNumber = 1;
    } else if (type == kCGEventOtherMouseDown || type == kCGEventOtherMouseUp || type == kCGEventOtherMouseDragged) {
        buttonNumber = 2;
    }
    [self newPostMouseEvent:type point:point button:button clickCount:clickCount buttonNumber:buttonNumber];
}

/// 鼠标注入
- (void)newPostMouseEvent:(CGEventType)type point:(CGPoint)point button:(CGMouseButton)button clickCount:(int64_t)clickCount buttonNumber:(NSInteger)buttonNumber {
    YMMouseModel * model = [[YMMouseModel alloc] init];
    model.eventType = type;
    model.mousePoint = point;
    model.button = button;
    model.clickCount = clickCount;
    model.subtype = self.mouseSubtype;
    model.buttonNumber = buttonNumber;
    [self newPostMouseEvent:model];
}

/// 鼠标注入
/// @param mouseModel 鼠标模型
- (void)newPostMouseEvent:(YMMouseModel *)mouseModel {
    switch (mouseModel.eventType) {
        case kCGEventLeftMouseDown: YMMouseLog(@"左键按下:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
        case kCGEventLeftMouseUp: YMMouseLog(@"左键松开:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
        case kCGEventRightMouseDown: YMMouseLog(@"右键按下:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
        case kCGEventRightMouseUp: YMMouseLog(@"右键松开:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
//        case kCGEventMouseMoved: YMMouseLog(@"鼠标移动:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
        case kCGEventLeftMouseDragged: YMMouseLog(@"左键拖拽:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
        case kCGEventRightMouseDragged: YMMouseLog(@"右键拖拽:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
        case kCGEventOtherMouseDown: YMMouseLog(@"其他键按下:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
        case kCGEventOtherMouseUp: YMMouseLog(@"其他键松开:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
        case kCGEventOtherMouseDragged: YMMouseLog(@"其他键拖拽:%d %d", mouseModel.clickCount, mouseModel.buttonNumber); break;
        default: break;
    }
    
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef theEvent = CGEventCreateMouseEvent(source, mouseModel.eventType, mouseModel.mousePoint, mouseModel.button);
    CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, mouseModel.clickCount);
//    CGEventSetIntegerValueField(theEvent, kCGMouseEventSubtype, mouseModel.subtype); // 使用这个会影响PhotoShp的注入
    CGEventSetIntegerValueField(theEvent, kCGEventSourceUserData, mouseModel.subtype);
    CGEventSetIntegerValueField(theEvent, kCGMouseEventButtonNumber, mouseModel.buttonNumber);
    
    CGEventSetType(theEvent, mouseModel.eventType);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
    CFRelease(source);
}

#pragma mark 计时器
- (void)startTimer {
    [self stopTimer];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak __typeof(self) weakSelf = self;
    _timer = [YMTimerTool createTimer:queue interval:400/1000.0 callback:^{
        __strong __typeof(weakSelf) self = weakSelf;
        [self timeCount];
    }];
}

- (void)timeCount {
    [self resetMouseState];
    [self stopTimer];
}

- (void)stopTimer {
    if (_timer) {
        [YMTimerTool destoryTimer:_timer];
        _timer = nil;
        [self resetMouseState];
    }
}

#pragma mark - private
- (void)resetMouseState {    
    self.leftClickCount = 1;
    self.rightClickCount = 1;
    self.middleClickCount = 1;
}

@end
