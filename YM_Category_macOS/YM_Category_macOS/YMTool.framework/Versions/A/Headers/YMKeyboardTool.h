//
//  YMKeyboardTool.h
//  macOS_Test
//
//  Created by 海南有趣 on 2020/9/9.
//  Copyright © 2020 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YMEventSourceState) {
    /// 代表专门的应用，如远程控制程序可以生成和跟踪事件源状态独立于其他进程。
    YMEventSourceState_Private,
    /// 该状态表反映了所有事件源的组合状态发布到当前用户的登录会话。
    /// 如果您的程序发布的事件在一个登录会话，您应该使用这个源状态当你创建一个事件源。
    YMEventSourceState_CombinedSessionState,
    /// 该状态表反映了组合硬件输入源从 HID 系统硬件层面发送的事件源。
    /// 生成的事件,就是外接键盘或者 macbook 本机键盘以及一些系统定义的按键点击事件。
    YMEventSourceState_HIDSystemState,
};

typedef NS_ENUM(uint64_t, YMEventFlagMask) {
    /// 没有任何键按下
    YMEventFlagMask_NonCoalesced = NX_NONCOALSESCEDMASK,
    /// 大小写锁定键是否处于开启状态
    YMEventFlagMask_Caps  = NX_ALPHASHIFTMASK,
    /// Shift 键是否按下
    YMEventFlagMask_Shift       = NX_SHIFTMASK,
    /// Control 键是否按下
    YMEventFlagMask_Control     = NX_CONTROLMASK,
    /// Alt 键是否按下，对应 Mac 键盘的 option 键
    YMEventFlagMask_Alternate   = NX_ALTERNATEMASK,
    /// Command 键是否按下，对应 Windows 的 WIN 键
    YMEventFlagMask_Command     = NX_COMMANDMASK,
    /// Help 键
    YMEventFlagMask_Help        = NX_HELPMASK,
    /// Fn 键
    YMEventFlagMask_SecondaryFn = NX_SECONDARYFNMASK,
    /// 数字键盘
    YMEventFlagMask_NumericPad  = NX_NUMERICPADMASK,
};

typedef CF_ENUM(int32_t, YMKeyEventType) {
    // 空事件
    YMKeyEventTypeNull = 0,
    // 键盘按下
    YMKeyEventTypeDown = 1 << 0,
    // 键盘松开
    YMKeyEventTypeUp = 1 << 1,
    // 状态键（command/shift等）
    YMKeyEventTypeModifierFlags = 1 << 2,
};

/// 键盘监听回调
typedef CGEventRef __nullable YMListningKeyCallBack(CGEventTapProxy  proxy,
                                                    CGEventType type,
                                                    CGEventRef  event,
                                                    void * _Nullable userInfo);

@interface YMKeyboardTool : NSObject

+ (instancetype)share;

/// 键盘注入时带的事件类型（默认0x77）
@property (assign, nonatomic) NSInteger keyboardSubtype;

#pragma 命令发送
/// 发送键盘命令
/// @param macKeyCode macOS键盘码
/// @param keyDown    是否按下
/// @param flags      状态建
- (void)postKeyboardEvent:(NSInteger)macKeyCode
                  keyDown:(BOOL)keyDown
                    flags:(YMEventFlagMask)flags;

/// 打印一段文字到前端
/// @param content 打印内容
- (void)postString:(NSString *)content;

/// 通过usb键值获得mac键值
/// @param usbKeyCode usb键值
- (NSInteger)macKeyCodeFromUsbKeyCode:(NSInteger)usbKeyCode;

#pragma mark 监听事件
/// 添加键盘监听（需要授权辅助功能）
/// @param eventType 要监听的按钮事件
/// @param callback 监听的回调
/// @param error 错误信息
/// @return 返回监听对方，在移除监听时，需要用到
- (id)addListeningKey:(YMKeyEventType)eventType callback:(YMListningKeyCallBack)callback error:(NSError **)error;

/// 移除键盘监听
/// @param listeningObj 添加监听时获取的对象
- (void)removeListeningKey:(id)listeningObj;

#pragma mark getter
/// 返回一个布尔值，指示Quartz事件源的当前键盘状态。如果为true，则该键为down;如果为false，则该键为up。
/// @param macKeyCode macOS 按键值
+ (BOOL)ymKeyStateWithCode:(uint16_t)macKeyCode;

/// 通过usb键值获取mac键值（找不到时会返回@""）
/// @param usbKeycode usb键值
+ (NSString *)ymMacCodeFromUSBCode:(int)usbKeycode;

/// 通过mac键值获取usb键值（找不到时会返回@""）
/// @param macKeycode mac键值
+ (NSString *)ymUSBCodeFromMacCode:(int)macKeycode;

/// 通过mac键值获取键名（找不到时会返回@""）
/// @param macKeycode mac键值
+ (NSString *)ymKeynameFromMacCode:(int)macKeycode;

/// 获取所有键值
+ (NSDictionary <NSString *, NSDictionary *> *)ymKeyCodeList;

@end

NS_ASSUME_NONNULL_END
