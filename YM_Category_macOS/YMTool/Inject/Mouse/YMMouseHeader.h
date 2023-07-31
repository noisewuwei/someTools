//
//  YMMouseHeader.h
//  YM_Category_macOS
//
//  Created by 黄玉洲 on 2021/12/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <CoreGraphics/CGEventTypes.h>

/// 鼠标键类型
typedef CF_ENUM (int32_t, YMMouseButton) {
    // 空键，放开
    YMMouseButton_Empty = 0,
    // 左键单击
    YMMouseButton_Left = 1 << 0,
    // 中间键单击
    YMMouseButton_Center = 1 << 1,
    // 右键单击
    YMMouseButton_Right = 1 << 2,
    // 滚动向上
    YMMouseButton_WheelUp = 1 << 3,
    // 滚动向下
    YMMouseButton_WheelDown = 1 << 4,
    // 滚动向左
    YMMouseButton_WheelLeft = 1 << 5,
    // 滚动向右
    YMMouseButton_WheelRight = 1 << 6,
    // 鼠标侧边键后按钮
    YMMouseButton_Other1 = 1 << 7,
    // 鼠标侧边键前按钮
    YMMouseButton_Other2 = 1 << 8,
};

typedef CF_ENUM (int32_t, YMMouseEventType) {
    // 空事件
    YMMouseEventType_Null = 0,

    // 左键按下
    YMMouseEventType_LeftMouseDown = 1<<0,
    // 左键松开
    YMMouseEventType_LeftMouseUp = 1<<1,
    
    // 右键按下
    YMMouseEventType_RightMouseDown = 1<<2,
    // 右键松开
    YMMouseEventType_RightMouseUp = 1<<3,
    
    // 鼠标移动
    YMMouseEventType_MouseMoved = 1<<4,
    
    // 左键拖拽
    YMMouseEventType_LeftMouseDragged = 1<<5,
    // 右键拖拽
    YMMouseEventType_RightMouseDragged = 1<<6,

    // 滚轮滚动
    YMMouseEventType_ScrollWheel = 1<<7,
    
    // 其他键按下
    YMMouseEventType_OtherMouseDown = 1<<8,
    // 其他键松开
    YMMouseEventType_OtherMouseUp = 1<<9,
    // 其他键拖拽
    YMMouseEventType_OtherMouseDragged = 1<<10,
    
    // 所有
    YMMouseEventType_All = 1<<11,
};

/// 鼠标监听回调
typedef CGEventRef __nullable kListningMouseCallBack(CGEventTapProxy  proxy,
                                                     CGEventType type,
                                                     CGEventRef  event,
                                                     void * _Nullable userInfo);

#define YMMouseLog
#define YMMouseLog(FORMAT, ...) { \
    if (self.logEnable) { \
        NSString * log = [NSString stringWithFormat:@"%@", [NSString stringWithFormat: FORMAT, ## __VA_ARGS__]];\
        NSLog(log);\
    }\
}
