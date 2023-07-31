//
//  YMMouseTool.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/9/11.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMMouseHeader.h"



@class NSScreen;

/// 鼠标注入
@interface YMMouseTool : NSObject

+ (instancetype)share;

/// 鼠标滚轮滚动的距离（-10~10），默认-10/10px
@property (assign, nonatomic) CGFloat mouseScrollEdge;

/// 鼠标滚动时，是否使用kCGScrollEventUnitLine模式
@property (assign, nonatomic) bool useUnitLine;

/// 设置当前屏幕ID
@property (assign, nonatomic) CGDirectDisplayID displayID;

/// 当前鼠标所在的屏幕（以设置displayID后为准）
@property (strong, nonatomic, readonly) NSScreen * currentScreen;

/// 鼠标注入时带的事件类型，新API才能使用（默认0x77）
@property (assign, nonatomic) NSInteger mouseSubtype;

/// 打开日志打印
@property (assign, nonatomic) bool logEnable;

/// 使用新版API
/// @param use 是否使用
- (void)useNewAPI:(bool)use;

/// 发送鼠标事件
/// @param mouseBtn 鼠标按键
/// @param point 坐标位置
- (void)postMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point deltax:(int32_t)deltax deltay:(int32_t)deltay;

/// 发送鼠标事件
/// @param mouseBtn 鼠标按键
/// @param point 坐标位置
- (void)postMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point;

/// 添加鼠标监听（需要授权辅助功能）
- (id)addListeningMouse:(YMMouseEventType)eventType callback:(kListningMouseCallBack)callback error:(NSError **)error;

/// 添加鼠标监听（需要授权辅助功能）
- (id)addListeningMouse:(YMMouseEventType)eventType callback:(kListningMouseCallBack)callback userInfo:(id)userInfo error:(NSError **)error;

/// 移除鼠标监听
- (void)removeListeningMouse:(id _Nullable)listeningObj;

/// 是否为当前进程发出的事件
/// @param event CGEventRef
- (bool)isThisProcess:(CGEventRef _Nullable)event;

/// 发出该事件的进程ID。如果返回-1，说明发生错误
/// @param event CGEventRef
- (int)pidWithEvent:(CGEventRef _Nullable)event;

/// 判断事件是否包含在指定的范围内
/// @param event CGEventRef
/// @param rect NSRect
/// @param inBottom 事件坐标起始点是否需要转换为左下角起始
- (bool)event:(CGEventRef _Nullable)event inRect:(NSRect)rect inBottom:(BOOL)inBottom;

#pragma mark - getter
/// 获取事件响应坐标
/// @param event CGEventRef
+ (CGPoint)potinWithEvent:(CGEventRef _Nullable)event;

/// 获取当前指针所在位置
+ (NSPoint)mousePoint;

/// 获取当前指针所在的屏幕
+ (NSScreen *)mouseInScreen;

@end

