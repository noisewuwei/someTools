//
//  YMKeyboardTool.m
//  macOS_Test
//
//  Created by 海南有趣 on 2020/9/9.
//  Copyright © 2020 黄玉洲. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Carbon/Carbon.h>

#import <IOKit/hidsystem/IOHIDShared.h>
#import <IOKit/hidsystem/IOHIDParameter.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/graphics/IOGraphicsTypes.h>

#import "YMKeyboardTool.h"
#import "YMPermissionTool.h"

typedef NS_ENUM(NSInteger, YMKeyError) {
    YMKeyErrorUnauthorized = 1, // 未授权
};

@interface YMKeyboardTool ()
{
    CGEventFlags _currentModifiers;
    BOOL _isCapsLock;
}

@property (strong, nonatomic) NSDictionary * usb_mac_keylist;
@property (strong, nonatomic) NSDictionary * mac_usb_keylist;

@end

@implementation YMKeyboardTool

static YMKeyboardTool * instance;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [YMKeyboardTool new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _keyboardSubtype = 0x77;
    }
    return self;
}

#pragma mark 键盘点击
/// 发送键盘命令
/// @param macKeyCode macOS键盘码
/// @param keyDown    是否按下
/// @param flags      状态建
- (void)postKeyboardEvent:(NSInteger)macKeyCode
                  keyDown:(BOOL)keyDown
                     flags:(YMEventFlagMask)flags {
    [self _postKeyboardEvent:macKeyCode keyDown:keyDown flags:flags];
}

/// 发送键盘命令
/// @param macKeyCode macOS键盘码
/// @param keyDown    是否按下
/// @param flags      状态建
- (void)_postKeyboardEvent:(NSInteger)macKeyCode
                   keyDown:(BOOL)keyDown
                     flags:(YMEventFlagMask)flags {
    // 大小写锁定
    _currentModifiers &= ~YMEventFlagMask_Caps;
    if (macKeyCode == kVK_CapsLock) {
        _isCapsLock = !_isCapsLock;
        if (_isCapsLock) {
            _currentModifiers |= YMEventFlagMask_Shift;
        } else {
            _currentModifiers &= ~YMEventFlagMask_Shift;
        }
    }
    // Fn键盘
    else if (macKeyCode == kVK_Function) {
        if (keyDown) {
            _currentModifiers |= YMEventFlagMask_SecondaryFn;
        } else {
            _currentModifiers &= ~YMEventFlagMask_SecondaryFn;
        }
    }
    // control键
    else if (macKeyCode == kVK_Control || macKeyCode == kVK_RightControl) {
        if (keyDown) {
            _currentModifiers |= YMEventFlagMask_Control;
        } else {
            _currentModifiers &= ~YMEventFlagMask_Control;
        }
    }
    // command键
    else if (macKeyCode == kVK_Command || macKeyCode == kVK_RightCommand) {
        if (keyDown) {
            _currentModifiers |= YMEventFlagMask_Command;
        } else {
            _currentModifiers &= ~YMEventFlagMask_Command;
        }
    }
    // alt键
    else if (macKeyCode == kVK_Option || macKeyCode == kVK_RightOption) {
        if (keyDown) {
            _currentModifiers |= YMEventFlagMask_Alternate;
        } else {
            _currentModifiers &= ~YMEventFlagMask_Alternate;
        }
    }
    // shift键
    else if (macKeyCode == kVK_Shift || macKeyCode == kVK_RightShift) {
        if (keyDown) {
            _currentModifiers |= YMEventFlagMask_Shift;
        } else {
            _currentModifiers &= ~YMEventFlagMask_Shift;
        }
    }
    // fn功能键
    else if (macKeyCode == kVK_F1 ||
             macKeyCode == kVK_F2 ||
             macKeyCode == kVK_F3 ||
             macKeyCode == kVK_F4 ||
             macKeyCode == kVK_F5 ||
             macKeyCode == kVK_F6 ||
             macKeyCode == kVK_F7 ||
             macKeyCode == kVK_F8 ||
             macKeyCode == kVK_F9 ||
             macKeyCode == kVK_F10 ||
             macKeyCode == kVK_F11 ||
             macKeyCode == kVK_F12 ||
             macKeyCode == kVK_F13 ||
             macKeyCode == kVK_F14 ||
             macKeyCode == kVK_F15 ||
             macKeyCode == kVK_F16 ||
             macKeyCode == kVK_F17 ||
             macKeyCode == kVK_F18 ||
             macKeyCode == kVK_F19 ||
             macKeyCode == kVK_F20) {
        if (keyDown) {
            flags = (YMEventFlagMask)(flags | YMEventFlagMask_SecondaryFn);
        } else {
            flags = (YMEventFlagMask)(flags & ~YMEventFlagMask_SecondaryFn);
        }
    }
    // control + ↑、↓、←、→
    else if ((macKeyCode == kVK_LeftArrow  ||
              macKeyCode == kVK_RightArrow ||
              macKeyCode == kVK_DownArrow  ||
              macKeyCode == kVK_UpArrow) &&
             (_currentModifiers & YMEventFlagMask_Control) == YMEventFlagMask_Control) {
        if (keyDown) {
            flags = (YMEventFlagMask)(flags | YMEventFlagMask_SecondaryFn);
        } else {
            flags = (YMEventFlagMask)(flags & ~YMEventFlagMask_SecondaryFn);
        }
    }
    // numlock(关闭)+左侧数字键盘
    else if (keyDown &&
             ((macKeyCode >= kVK_ANSI_Keypad0 && macKeyCode <= kVK_ANSI_Keypad9) ||
              macKeyCode == kVK_ANSI_KeypadDecimal) &&
             (flags & YMEventFlagMask_NumericPad) != YMEventFlagMask_NumericPad) {
        macKeyCode = [self macKeyFromLeftKeyboard:macKeyCode flags:&flags];
    }
        
    flags = (YMEventFlagMask)(flags | _currentModifiers);
    [self sendKeyCode:macKeyCode flags:flags down:keyDown];
}

/// 发送键盘命令
/// @param macKeyCode 键码
/// @param flags 事件
- (void)sendKeyCode:(NSInteger)macKeyCode flags:(YMEventFlagMask)flags down:(BOOL)down {
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef push = CGEventCreateKeyboardEvent(source, (CGKeyCode)macKeyCode, down);
    
    // vim里头shift+’+‘因为有numpad的缘故，导致输出异常
    if (macKeyCode == kVK_ANSI_Equal &&
        flags & YMEventFlagMask_Shift &&
        flags & YMEventFlagMask_NumericPad) {
        CGEventSetFlags(push, (CGEventFlags)(flags & ~YMEventFlagMask_NumericPad));
    } else {
        CGEventSetFlags(push, (CGEventFlags)flags);
    }
    CGEventSetIntegerValueField(push, kCGKeyboardEventKeyboardType, _keyboardSubtype);
    CGEventPost(kCGHIDEventTap, push);
    CFRelease(push);
    CFRelease(source);
//    CGPostKeyboardEvent(nil, macKeyCode, down);
}

/// 将左侧数字键盘的键码替换为macOS的键码
/// @param keypad 左侧数字键盘的键码
- (NSInteger)macKeyFromLeftKeyboard:(NSInteger)keypad flags:(YMEventFlagMask *)flags{
    NSInteger macKey = keypad;
    switch (keypad) {
        case kVK_ANSI_Keypad1: macKey = kVK_DownArrow; *flags = (YMEventFlagMask)(*flags | YMEventFlagMask_Command); break;
        case kVK_ANSI_Keypad2: macKey = kVK_DownArrow; break;
        case kVK_ANSI_Keypad3: macKey = kVK_DownArrow; *flags = (YMEventFlagMask)(*flags | YMEventFlagMask_Control); break;
        case kVK_ANSI_Keypad4: macKey = kVK_LeftArrow; break;
        case kVK_ANSI_Keypad5: macKey = -1; break;
        case kVK_ANSI_Keypad6: macKey = kVK_RightArrow; break;
        case kVK_ANSI_Keypad7: macKey = kVK_UpArrow; *flags = (YMEventFlagMask)(*flags | YMEventFlagMask_Command); break;
        case kVK_ANSI_Keypad8: macKey = kVK_UpArrow; break;
        case kVK_ANSI_Keypad9: macKey = kVK_UpArrow; *flags = (YMEventFlagMask)(*flags | YMEventFlagMask_Control); break;
        default: macKey = -1; break;
    }
    return macKey;
}

/// 切换caps状态
- (void)toggleCaps:(BOOL)caps {
    io_connect_t ioConnect = 0;
    io_service_t ioService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching(kIOHIDSystemClass));
    IOServiceOpen(ioService, mach_task_self_, kIOHIDParamConnectType, &ioConnect);
    IOHIDSetModifierLockState(ioConnect, kIOHIDCapsLockState, caps);
    IOServiceClose(ioConnect);
}

#pragma mark 文字打印
/// 打印一段文字到前端
/// @param content 打印内容
- (void)postString:(NSString *)content {
    NSString * string = content;
    
    // 1 - Get the string length in bytes.
    NSUInteger l = [string lengthOfBytesUsingEncoding:NSUTF16StringEncoding];

    // 2 - Get bytes for unicode characters
    UniChar *uc = (UniChar *)malloc(l);
    [string getBytes:uc maxLength:l usedLength:NULL encoding:NSUTF16StringEncoding options:0 range:NSMakeRange(0, l) remainingRange:NULL];

    // 3 - create an empty tap event, and set unicode string
    CGEventRef tap = CGEventCreateKeyboardEvent(NULL,0, YES);
    CGEventKeyboardSetUnicodeString(tap, string.length, uc);

    // 4 - Send event and tear down
    CGEventPost(kCGSessionEventTap, tap);
    CFRelease(tap);
    free(uc);
}

#pragma mark 监听事件
/// 添加键盘监听（需要授权辅助功能）
/// @param eventType 要监听的按钮事件
/// @param callback 监听的回调
/// @param error 错误信息
/// @return 返回监听对方，在移除监听时，需要用到
- (id)addListeningKey:(YMKeyEventType)eventType callback:(YMListningKeyCallBack)callback error:(NSError **)error {
    return [self addListeningKey:eventType callback:callback userInfo:nil error:error];
}

/// 添加键盘监听（需要授权辅助功能）
/// @param eventType 要监听的按钮事件
/// @param callback 监听的回调
/// @param userInfo 回调对象
/// @param error 错误信息
/// @return 返回监听对方，在移除监听时，需要用到
- (id)addListeningKey:(YMKeyEventType)eventType callback:(YMListningKeyCallBack)callback userInfo:(id)userInfo error:(NSError **)error {
    if (![YMPermissionTool accessibilityPermissions]) {
        if (error) {
            *error = [self errorWithCode:YMKeyErrorUnauthorized];
        }
        return nil;
    }
    
    CGEventMask eventMask = 0;
    eventMask = (eventType & YMKeyEventTypeNull) ? (eventMask | CGEventMaskBit(kCGEventNull)) : eventMask;
    eventMask = eventType & YMKeyEventTypeDown ? (eventMask | CGEventMaskBit(kCGEventKeyDown)) : eventMask;
    eventMask = eventType & YMKeyEventTypeUp ? (eventMask | CGEventMaskBit(kCGEventKeyUp)) : eventMask;
    eventMask = eventType & YMKeyEventTypeModifierFlags ? (eventMask | CGEventMaskBit(kCGEventFlagsChanged)) : eventMask;
    
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

/// 移除键盘监听
/// @param listeningObj 添加监听时获取的对象
- (void)removeListeningKey:(id)listeningObj {
    if (!listeningObj) {
        return;
    }
    CGEventTapEnable((__bridge CFMachPortRef)listeningObj, false);
}

#pragma mark getter
/// 返回一个布尔值，指示Quartz事件源的当前键盘状态。如果为true，则该键为down;如果为false，则该键为up。
/// @param macKeyCode macOS 按键值
+ (BOOL)ymKeyStateWithCode:(uint16_t)macKeyCode {
    return CGEventSourceKeyState(kCGEventSourceStateHIDSystemState, macKeyCode);
}

/// 通过usb键值获取mac键值（找不到时会返回@""）
/// @param usbKeycode usb键值
+ (NSString *)ymMacCodeFromUSBCode:(int)usbKeycode {
    NSString * keycodeStr = [NSString stringWithFormat:@"%d", usbKeycode];
    return [YMKeyboardTool share].usb_mac_keylist[keycodeStr][@"macKeyCode"];
}

/// 通过mac键值获取usb键值（找不到时会返回@""）
/// @param macKeycode mac键值
+ (NSString *)ymUSBCodeFromMacCode:(int)macKeycode {
    NSString * keycodeStr = [NSString stringWithFormat:@"%d", macKeycode];
    NSString * usbKeycode = [YMKeyboardTool share].mac_usb_keylist[keycodeStr][@"usbKeyCode"];
    return usbKeycode ?: @"";
}

/// 通过mac键值获取键名（找不到时会返回@""）
/// @param macKeycode mac键值
+ (NSString *)ymKeynameFromMacCode:(int)macKeycode {
    NSString * keycodeStr = [NSString stringWithFormat:@"%d", macKeycode];
    NSString * keyName = [YMKeyboardTool share].mac_usb_keylist[keycodeStr][@"keyname"];
    return keyName ?: @"";
}


+ (NSDictionary<NSString *,NSDictionary *> *)ymKeyCodeList {
    return [YMKeyboardTool share].usb_mac_keylist;
}

/// 获取error
/// @param code error code
- (NSError *)errorWithCode:(YMKeyError)code {
    NSString * errorReason = @"";
    switch (code) {
        case YMKeyErrorUnauthorized: errorReason = @"Auxiliary functions are not authorized"; break;
        default: break;
    }
    NSError * error = [NSError errorWithDomain:@"KeyboardTool"
                                          code:code
                                      userInfo:@{NSLocalizedDescriptionKey: errorReason}];
    return error;
}

- (NSDictionary *)usb_mac_keylist {
    if (_usb_mac_keylist) {
        return _usb_mac_keylist;
    }
    
    _usb_mac_keylist = @{
        @"0"      : @{ @"keyname" : @"Invalid", @"macKeyCode" : @"65535" },
        @"65666"  : @{ @"keyname" : @"SystemSleep", @"macKeyCode" : @"65535" },
        @"65667"  : @{ @"keyname" : @"WakeUp", @"macKeyCode" : @"65535" },
        @"458756" : @{ @"keyname" : @"a", @"macKeyCode" : @"0" },
        @"458757" : @{ @"keyname" : @"b", @"macKeyCode" : @"11" },
        @"458758" : @{ @"keyname" : @"c", @"macKeyCode" : @"8" },
        @"458759" : @{ @"keyname" : @"d", @"macKeyCode" : @"2" },
        @"458760" : @{ @"keyname" : @"e", @"macKeyCode" : @"14" },
        @"458761" : @{ @"keyname" : @"f", @"macKeyCode" : @"3" },
        @"458762" : @{ @"keyname" : @"g", @"macKeyCode" : @"5" },
        @"458763" : @{ @"keyname" : @"h", @"macKeyCode" : @"4" },
        @"458764" : @{ @"keyname" : @"i", @"macKeyCode" : @"34" },
        @"458765" : @{ @"keyname" : @"j", @"macKeyCode" : @"38" },
        @"458766" : @{ @"keyname" : @"k", @"macKeyCode" : @"40" },
        @"458767" : @{ @"keyname" : @"l", @"macKeyCode" : @"37" },
        @"458768" : @{ @"keyname" : @"m", @"macKeyCode" : @"46" },
        @"458769" : @{ @"keyname" : @"n", @"macKeyCode" : @"45" },
        @"458770" : @{ @"keyname" : @"o", @"macKeyCode" : @"31" },
        @"458771" : @{ @"keyname" : @"p", @"macKeyCode" : @"35" },
        @"458772" : @{ @"keyname" : @"q", @"macKeyCode" : @"12" },
        @"458773" : @{ @"keyname" : @"r", @"macKeyCode" : @"15" },
        @"458774" : @{ @"keyname" : @"s", @"macKeyCode" : @"1" },
        @"458775" : @{ @"keyname" : @"t", @"macKeyCode" : @"17" },
        @"458776" : @{ @"keyname" : @"u", @"macKeyCode" : @"32" },
        @"458777" : @{ @"keyname" : @"v", @"macKeyCode" : @"9" },
        @"458778" : @{ @"keyname" : @"w", @"macKeyCode" : @"13" },
        @"458779" : @{ @"keyname" : @"x", @"macKeyCode" : @"7" },
        @"458780" : @{ @"keyname" : @"y", @"macKeyCode" : @"16" },
        @"458781" : @{ @"keyname" : @"z", @"macKeyCode" : @"6" },
        @"458782" : @{ @"keyname" : @"1", @"macKeyCode" : @"18" },
        @"458783" : @{ @"keyname" : @"2", @"macKeyCode" : @"19" },
        @"458784" : @{ @"keyname" : @"3", @"macKeyCode" : @"20" },
        @"458785" : @{ @"keyname" : @"4", @"macKeyCode" : @"21" },
        @"458786" : @{ @"keyname" : @"5", @"macKeyCode" : @"23" },
        @"458787" : @{ @"keyname" : @"6", @"macKeyCode" : @"22" },
        @"458788" : @{ @"keyname" : @"7", @"macKeyCode" : @"26" },
        @"458789" : @{ @"keyname" : @"8", @"macKeyCode" : @"28" },
        @"458790" : @{ @"keyname" : @"9", @"macKeyCode" : @"25" },
        @"458791" : @{ @"keyname" : @"0", @"macKeyCode" : @"29" },
        @"458792" : @{ @"keyname" : @"Enter", @"macKeyCode" : @"36" },
        @"458793" : @{ @"keyname" : @"Escape", @"macKeyCode" : @"53" },
        @"458794" : @{ @"keyname" : @"Backspace", @"macKeyCode" : @"51" },
        @"458795" : @{ @"keyname" : @"Tab", @"macKeyCode" : @"48" },
        @"458796" : @{ @"keyname" : @"Spacebar", @"macKeyCode" : @"49" },
        @"458797" : @{ @"keyname" : @"-_", @"macKeyCode" : @"27" },
        @"458798" : @{ @"keyname" : @"=+", @"macKeyCode" : @"24" },
        @"458799" : @{ @"keyname" : @"BracketLeft", @"macKeyCode" : @"33" },
        @"458800" : @{ @"keyname" : @"BracketRight", @"macKeyCode" : @"30" },
        @"458801" : @{ @"keyname" : @"\\|", @"macKeyCode" : @"42" },
        @"458802" : @{ @"keyname" : @"Intl Hash", @"macKeyCode" : @"65535" },
        @"458803" : @{ @"keyname" : @";:", @"macKeyCode" : @"41" },
        @"458804" : @{ @"keyname" : @"&apos;&quot;", @"macKeyCode" : @"39" },
        @"458805" : @{ @"keyname" : @"`~", @"macKeyCode" : @"50" },
        @"458806" : @{ @"keyname" : @",", @"macKeyCode" : @"43" },
        @"458807" : @{ @"keyname" : @".&gt;", @"macKeyCode" : @"47" },
        @"458808" : @{ @"keyname" : @"/?", @"macKeyCode" : @"44" },
        @"458809" : @{ @"keyname" : @"CapsLock", @"macKeyCode" : @"57" },
        @"458810" : @{ @"keyname" : @"F1", @"macKeyCode" : @"122" },
        @"458811" : @{ @"keyname" : @"F2", @"macKeyCode" : @"120" },
        @"458812" : @{ @"keyname" : @"F3", @"macKeyCode" : @"99" },
        @"458813" : @{ @"keyname" : @"F4", @"macKeyCode" : @"118" },
        @"458814" : @{ @"keyname" : @"F5", @"macKeyCode" : @"96" },
        @"458815" : @{ @"keyname" : @"F6", @"macKeyCode" : @"97" },
        @"458816" : @{ @"keyname" : @"F7", @"macKeyCode" : @"98" },
        @"458817" : @{ @"keyname" : @"F8", @"macKeyCode" : @"100" },
        @"458818" : @{ @"keyname" : @"F9", @"macKeyCode" : @"101" },
        @"458819" : @{ @"keyname" : @"F10", @"macKeyCode" : @"109" },
        @"458820" : @{ @"keyname" : @"F11", @"macKeyCode" : @"103" },
        @"458821" : @{ @"keyname" : @"F12", @"macKeyCode" : @"111" },
        @"458822" : @{ @"keyname" : @"PrintScreen", @"macKeyCode" : @"65535" },
        @"458823" : @{ @"keyname" : @"ScrollLock", @"macKeyCode" : @"65535" },
        @"458824" : @{ @"keyname" : @"Pause", @"macKeyCode" : @"65535" },
        @"458825" : @{ @"keyname" : @"Insert", @"macKeyCode" : @"114" },
        @"458826" : @{ @"keyname" : @"Home", @"macKeyCode" : @"115" },
        @"458827" : @{ @"keyname" : @"PageUp", @"macKeyCode" : @"116" },
        @"458828" : @{ @"keyname" : @"Del", @"macKeyCode" : @"117" },
        @"458829" : @{ @"keyname" : @"End", @"macKeyCode" : @"119" },
        @"458830" : @{ @"keyname" : @"PageDown", @"macKeyCode" : @"121" },
        @"458831" : @{ @"keyname" : @"ArrowRight", @"macKeyCode" : @"124" },
        @"458832" : @{ @"keyname" : @"ArrowLeft", @"macKeyCode" : @"123" },
        @"458833" : @{ @"keyname" : @"ArrowDown", @"macKeyCode" : @"125" },
        @"458834" : @{ @"keyname" : @"ArrowUp", @"macKeyCode" : @"126" },
        @"458835" : @{ @"keyname" : @"NumLock", @"macKeyCode" : @"71" },
        @"458836" : @{ @"keyname" : @"NumpadDivide", @"macKeyCode" : @"75" },
        @"458837" : @{ @"keyname" : @"Keypad_*", @"macKeyCode" : @"67" },
        @"458838" : @{ @"keyname" : @"Keypad_-", @"macKeyCode" : @"78" },
        @"458839" : @{ @"keyname" : @"NumpadAdd", @"macKeyCode" : @"69" },
        @"458840" : @{ @"keyname" : @"NumpadEnter", @"macKeyCode" : @"76" },
        @"458841" : @{ @"keyname" : @"Numpad1+End", @"macKeyCode" : @"83" },
        @"458842" : @{ @"keyname" : @"Numpad2+Down", @"macKeyCode" : @"84" },
        @"458843" : @{ @"keyname" : @"Numpad3+PageDn", @"macKeyCode" : @"85" },
        @"458844" : @{ @"keyname" : @"Numpad4+Left", @"macKeyCode" : @"86" },
        @"458845" : @{ @"keyname" : @"Numpad5", @"macKeyCode" : @"87" },
        @"458846" : @{ @"keyname" : @"Numpad6+Right", @"macKeyCode" : @"88" },
        @"458847" : @{ @"keyname" : @"Numpad7+Home", @"macKeyCode" : @"89" },
        @"458848" : @{ @"keyname" : @"Numpad8+Up", @"macKeyCode" : @"91" },
        @"458849" : @{ @"keyname" : @"Numpad9+PageUp", @"macKeyCode" : @"92" },
        @"458850" : @{ @"keyname" : @"Numpad0+Insert", @"macKeyCode" : @"82" },
        @"458851" : @{ @"keyname" : @"Keypad_. Delete", @"macKeyCode" : @"65" },
        @"458852" : @{ @"keyname" : @"IntlBackslash", @"macKeyCode" : @"10" },
        @"458853" : @{ @"keyname" : @"ContextMenu", @"macKeyCode" : @"110" },
        @"458854" : @{ @"keyname" : @"Power", @"macKeyCode" : @"65535" },
        @"458855" : @{ @"keyname" : @"NumpadEqual", @"macKeyCode" : @"81" },
        @"458856" : @{ @"keyname" : @"F13", @"macKeyCode" : @"105" },
        @"458857" : @{ @"keyname" : @"F14", @"macKeyCode" : @"107" },
        @"458858" : @{ @"keyname" : @"F15", @"macKeyCode" : @"113" },
        @"458859" : @{ @"keyname" : @"F16", @"macKeyCode" : @"106" },
        @"458860" : @{ @"keyname" : @"F17", @"macKeyCode" : @"64" },
        @"458861" : @{ @"keyname" : @"F18", @"macKeyCode" : @"79" },
        @"458862" : @{ @"keyname" : @"F19", @"macKeyCode" : @"80" },
        @"458863" : @{ @"keyname" : @"F20", @"macKeyCode" : @"90" },
        @"458864" : @{ @"keyname" : @"F21", @"macKeyCode" : @"65535" },
        @"458865" : @{ @"keyname" : @"F22", @"macKeyCode" : @"65535" },
        @"458866" : @{ @"keyname" : @"F23", @"macKeyCode" : @"65535" },
        @"458867" : @{ @"keyname" : @"F24", @"macKeyCode" : @"65535" },
        @"458868" : @{ @"keyname" : @"Execute", @"macKeyCode" : @"65535" },
        @"458869" : @{ @"keyname" : @"Help", @"macKeyCode" : @"65535" },
        @"458871" : @{ @"keyname" : @"Select", @"macKeyCode" : @"65535" },
        @"458873" : @{ @"keyname" : @"Again", @"macKeyCode" : @"65535" },
        @"458874" : @{ @"keyname" : @"Undo", @"macKeyCode" : @"65535" },
        @"458875" : @{ @"keyname" : @"Cut", @"macKeyCode" : @"65535" },
        @"458876" : @{ @"keyname" : @"Copy", @"macKeyCode" : @"65535" },
        @"458877" : @{ @"keyname" : @"Paste", @"macKeyCode" : @"65535" },
        @"458878" : @{ @"keyname" : @"Find", @"macKeyCode" : @"65535" },
        @"458879" : @{ @"keyname" : @"VolumeMute", @"macKeyCode" : @"74" },
        @"458880" : @{ @"keyname" : @"VolumeUp", @"macKeyCode" : @"72" },
        @"458881" : @{ @"keyname" : @"VolumeDown", @"macKeyCode" : @"73" },
        @"458885" : @{ @"keyname" : @"NumpadComma", @"macKeyCode" : @"95" },
        @"458887" : @{ @"keyname" : @"IntlRo", @"macKeyCode" : @"94" },
        @"458888" : @{ @"keyname" : @"KanaMode", @"macKeyCode" : @"104" },
        @"458889" : @{ @"keyname" : @"IntlYen", @"macKeyCode" : @"93" },
        @"458890" : @{ @"keyname" : @"Convert", @"macKeyCode" : @"65535" },
        @"458891" : @{ @"keyname" : @"NonConvert", @"macKeyCode" : @"65535" },
        @"458896" : @{ @"keyname" : @"Lang1", @"macKeyCode" : @"65535" },
        @"458897" : @{ @"keyname" : @"Lang2", @"macKeyCode" : @"65535" },
        @"458898" : @{ @"keyname" : @"Lang3", @"macKeyCode" : @"65535" },
        @"458899" : @{ @"keyname" : @"Lang4", @"macKeyCode" : @"65535" },
        @"458900" : @{ @"keyname" : @"Lang5", @"macKeyCode" : @"65535" },
        @"458934" : @{ @"keyname" : @"Keypad_(", @"macKeyCode" : @"65535" },
        @"458935" : @{ @"keyname" : @"Keypad_)", @"macKeyCode" : @"65535" },
        @"458967" : @{ @"keyname" : @"+/-", @"macKeyCode" : @"65535" },
        @"458976" : @{ @"keyname" : @"ControlLeft", @"macKeyCode" : @"59" },
        @"458977" : @{ @"keyname" : @"ShiftLeft", @"macKeyCode" : @"56" },
        @"458978" : @{ @"keyname" : @"AltLeft", @"macKeyCode" : @"58" },
        @"458979" : @{ @"keyname" : @"MetaLeft", @"macKeyCode" : @"55" },
        @"458980" : @{ @"keyname" : @"ControlRight", @"macKeyCode" : @"62" },
        @"458981" : @{ @"keyname" : @"ShiftRight", @"macKeyCode" : @"60" },
        @"458982" : @{ @"keyname" : @"AltRight", @"macKeyCode" : @"61" },
        @"458983" : @{ @"keyname" : @"MetaRight", @"macKeyCode" : @"54" },
        @"786528" : @{ @"keyname" : @"Info", @"macKeyCode" : @"65535" },
        @"786529" : @{ @"keyname" : @"ClosedCaptionToggle", @"macKeyCode" : @"65535" },
        @"786543" : @{ @"keyname" : @"BrightnessUp", @"macKeyCode" : @"65535" },
        @"786544" : @{ @"keyname" : @"BrightnessDown", @"macKeyCode" : @"65535" },
        @"786546" : @{ @"keyname" : @"BrightnessToggle", @"macKeyCode" : @"65535" },
        @"786547" : @{ @"keyname" : @"BrightnessMinimum", @"macKeyCode" : @"65535" },
        @"786548" : @{ @"keyname" : @"BrightnessMaximum", @"macKeyCode" : @"65535" },
        @"786549" : @{ @"keyname" : @"BrightnessAuto", @"macKeyCode" : @"65535" },
        @"786563" : @{ @"keyname" : @"MediaLast", @"macKeyCode" : @"65535" },
        @"786572" : @{ @"keyname" : @"LaunchPhone", @"macKeyCode" : @"65535" },
        @"786573" : @{ @"keyname" : @"ProgramGuide", @"macKeyCode" : @"65535" },
        @"786580" : @{ @"keyname" : @"Exit", @"macKeyCode" : @"65535" },
        @"786588" : @{ @"keyname" : @"ChannelUp", @"macKeyCode" : @"65535" },
        @"786589" : @{ @"keyname" : @"ChannelDown", @"macKeyCode" : @"65535" },
        @"786608" : @{ @"keyname" : @"MediaPlay", @"macKeyCode" : @"65535" },
        @"786610" : @{ @"keyname" : @"Media Record", @"macKeyCode" : @"65535" },
        @"786611" : @{ @"keyname" : @"MediaFastForward", @"macKeyCode" : @"65535" },
        @"786612" : @{ @"keyname" : @"MediaRewind", @"macKeyCode" : @"65535" },
        @"786613" : @{ @"keyname" : @"MediaTrackNext", @"macKeyCode" : @"65535" },
        @"786614" : @{ @"keyname" : @"MediaTrackPrevious", @"macKeyCode" : @"65535" },
        @"786615" : @{ @"keyname" : @"MediaStop", @"macKeyCode" : @"65535" },
        @"786616" : @{ @"keyname" : @"Eject", @"macKeyCode" : @"65535" },
        @"786637" : @{ @"keyname" : @"MediaPlayPause", @"macKeyCode" : @"65535" },
        @"786639" : @{ @"keyname" : @"SpeechInputToggle", @"macKeyCode" : @"65535" },
        @"786661" : @{ @"keyname" : @"BassBoost", @"macKeyCode" : @"65535" },
        @"786819" : @{ @"keyname" : @"MediaSelect", @"macKeyCode" : @"65535" },
        @"786820" : @{ @"keyname" : @"Launch Word Processor", @"macKeyCode" : @"65535" },
        @"786822" : @{ @"keyname" : @"Launch Spreadsheet", @"macKeyCode" : @"65535" },
        @"786826" : @{ @"keyname" : @"AL_EmailReader", @"macKeyCode" : @"65535" },
        @"786829" : @{ @"keyname" : @"AL Contacts/Address Book", @"macKeyCode" : @"65535" },
        @"786830" : @{ @"keyname" : @"AL Calendar/Schedule", @"macKeyCode" : @"65535" },
        @"786834" : @{ @"keyname" : @"AL_Calculator", @"macKeyCode" : @"65535" },
        @"786836" : @{ @"keyname" : @"AL_LocalMachineBrowser", @"macKeyCode" : @"65535" },
        @"786838" : @{ @"keyname" : @"Launch Internet Browser", @"macKeyCode" : @"65535" },
        @"786844" : @{ @"keyname" : @"Log Off", @"macKeyCode" : @"65535" },
        @"786846" : @{ @"keyname" : @"AL Terminal Lock/Screensaver", @"macKeyCode" : @"65535" },
        @"786847" : @{ @"keyname" : @"AL Control Panel", @"macKeyCode" : @"65535" },
        @"786850" : @{ @"keyname" : @"AL Select Task/Application", @"macKeyCode" : @"65535" },
        @"786855" : @{ @"keyname" : @"AL_Documents", @"macKeyCode" : @"65535" },
        @"786859" : @{ @"keyname" : @"Spell Check", @"macKeyCode" : @"65535" },
        @"786862" : @{ @"keyname" : @"AL Keyboard Layout", @"macKeyCode" : @"65535" },
        @"786865" : @{ @"keyname" : @"AL Screen Saver", @"macKeyCode" : @"65535" },
        @"786871" : @{ @"keyname" : @"AL Audio Browser", @"macKeyCode" : @"65535" },
        @"786945" : @{ @"keyname" : @"AC New", @"macKeyCode" : @"65535" },
        @"786947" : @{ @"keyname" : @"AC Close", @"macKeyCode" : @"65535" },
        @"786951" : @{ @"keyname" : @"AC Save", @"macKeyCode" : @"65535" },
        @"786952" : @{ @"keyname" : @"AC Print", @"macKeyCode" : @"65535" },
        @"786977" : @{ @"keyname" : @"AC_Search", @"macKeyCode" : @"65535" },
        @"786979" : @{ @"keyname" : @"AC_Home", @"macKeyCode" : @"65535" },
        @"786980" : @{ @"keyname" : @"AC_Back", @"macKeyCode" : @"65535" },
        @"786981" : @{ @"keyname" : @"AC_Forward", @"macKeyCode" : @"65535" },
        @"786982" : @{ @"keyname" : @"AC_Stop", @"macKeyCode" : @"65535" },
        @"786983" : @{ @"keyname" : @"AC_Refresh (Reload)", @"macKeyCode" : @"65535" },
        @"786986" : @{ @"keyname" : @"AC_Bookmarks (Favorites)", @"macKeyCode" : @"65535" },
        @"786989" : @{ @"keyname" : @"ZoomIn", @"macKeyCode" : @"65535" },
        @"786990" : @{ @"keyname" : @"ZoomOut", @"macKeyCode" : @"65535" },
        @"787065" : @{ @"keyname" : @"AC Redo/Repeat", @"macKeyCode" : @"65535" },
        @"787081" : @{ @"keyname" : @"AC_Reply (MailReply)", @"macKeyCode" : @"65535" },
        @"787083" : @{ @"keyname" : @"AC_ForwardMsg (MailForward)", @"macKeyCode" : @"65535" },
        @"787084" : @{ @"keyname" : @"AC_Send (MailSend)", @"macKeyCode" : @"65535" }
    };
    return _usb_mac_keylist;
}

- (NSDictionary *)mac_usb_keylist {
    if (_mac_usb_keylist) {
        return _mac_usb_keylist;
    }
    
    _mac_usb_keylist = @{
            @"0" : @{ @"keyname" : @"a", @"usbKeyCode" : @"458756" },
            @"11" : @{ @"keyname" : @"b", @"usbKeyCode" : @"458757" },
            @"8" : @{ @"keyname" : @"c", @"usbKeyCode" : @"458758" },
            @"2" : @{ @"keyname" : @"d", @"usbKeyCode" : @"458759" },
            @"14" : @{ @"keyname" : @"e", @"usbKeyCode" : @"458760" },
            @"3" : @{ @"keyname" : @"f", @"usbKeyCode" : @"458761" },
            @"5" : @{ @"keyname" : @"g", @"usbKeyCode" : @"458762" },
            @"4" : @{ @"keyname" : @"h", @"usbKeyCode" : @"458763" },
            @"34" : @{ @"keyname" : @"i", @"usbKeyCode" : @"458764" },
            @"38" : @{ @"keyname" : @"j", @"usbKeyCode" : @"458765" },
            @"40" : @{ @"keyname" : @"k", @"usbKeyCode" : @"458766" },
            @"37" : @{ @"keyname" : @"l", @"usbKeyCode" : @"458767" },
            @"46" : @{ @"keyname" : @"m", @"usbKeyCode" : @"458768" },
            @"45" : @{ @"keyname" : @"n", @"usbKeyCode" : @"458769" },
            @"31" : @{ @"keyname" : @"o", @"usbKeyCode" : @"458770" },
            @"35" : @{ @"keyname" : @"p", @"usbKeyCode" : @"458771" },
            @"12" : @{ @"keyname" : @"q", @"usbKeyCode" : @"458772" },
            @"15" : @{ @"keyname" : @"r", @"usbKeyCode" : @"458773" },
            @"1" : @{ @"keyname" : @"s", @"usbKeyCode" : @"458774" },
            @"17" : @{ @"keyname" : @"t", @"usbKeyCode" : @"458775" },
            @"32" : @{ @"keyname" : @"u", @"usbKeyCode" : @"458776" },
            @"9" : @{ @"keyname" : @"v", @"usbKeyCode" : @"458777" },
            @"13" : @{ @"keyname" : @"w", @"usbKeyCode" : @"458778" },
            @"7" : @{ @"keyname" : @"x", @"usbKeyCode" : @"458779" },
            @"16" : @{ @"keyname" : @"y", @"usbKeyCode" : @"458780" },
            @"6" : @{ @"keyname" : @"z", @"usbKeyCode" : @"458781" },
            @"18" : @{ @"keyname" : @"1", @"usbKeyCode" : @"458782" },
            @"19" : @{ @"keyname" : @"2", @"usbKeyCode" : @"458783" },
            @"20" : @{ @"keyname" : @"3", @"usbKeyCode" : @"458784" },
            @"21" : @{ @"keyname" : @"4", @"usbKeyCode" : @"458785" },
            @"23" : @{ @"keyname" : @"5", @"usbKeyCode" : @"458786" },
            @"22" : @{ @"keyname" : @"6", @"usbKeyCode" : @"458787" },
            @"26" : @{ @"keyname" : @"7", @"usbKeyCode" : @"458788" },
            @"28" : @{ @"keyname" : @"8", @"usbKeyCode" : @"458789" },
            @"25" : @{ @"keyname" : @"9", @"usbKeyCode" : @"458790" },
            @"29" : @{ @"keyname" : @"0", @"usbKeyCode" : @"458791" },
            @"36" : @{ @"keyname" : @"Enter", @"usbKeyCode" : @"458792" },
            @"53" : @{ @"keyname" : @"Escape", @"usbKeyCode" : @"458793" },
            @"51" : @{ @"keyname" : @"Backspace", @"usbKeyCode" : @"458794" },
            @"48" : @{ @"keyname" : @"Tab", @"usbKeyCode" : @"458795" },
            @"49" : @{ @"keyname" : @"Spacebar", @"usbKeyCode" : @"458796" },
            @"27" : @{ @"keyname" : @"-_", @"usbKeyCode" : @"458797" },
            @"24" : @{ @"keyname" : @"=+", @"usbKeyCode" : @"458798" },
            @"33" : @{ @"keyname" : @"BracketLeft", @"usbKeyCode" : @"458799" },
            @"30" : @{ @"keyname" : @"BracketRight", @"usbKeyCode" : @"458800" },
            @"42" : @{ @"keyname" : @"\\|", @"usbKeyCode" : @"458801" },
            @"41" : @{ @"keyname" : @";:", @"usbKeyCode" : @"458803" },
            @"39" : @{ @"keyname" : @"&apos;&quot;", @"usbKeyCode" : @"458804" },
            @"50" : @{ @"keyname" : @"`~", @"usbKeyCode" : @"458805" },
            @"43" : @{ @"keyname" : @",", @"usbKeyCode" : @"458806" },
            @"47" : @{ @"keyname" : @".&gt;", @"usbKeyCode" : @"458807" },
            @"44" : @{ @"keyname" : @"/?", @"usbKeyCode" : @"458808" },
            @"57" : @{ @"keyname" : @"CapsLock", @"usbKeyCode" : @"458809" },
            @"122" : @{ @"keyname" : @"F1", @"usbKeyCode" : @"458810" },
            @"120" : @{ @"keyname" : @"F2", @"usbKeyCode" : @"458811" },
            @"99" : @{ @"keyname" : @"F3", @"usbKeyCode" : @"458812" },
            @"118" : @{ @"keyname" : @"F4", @"usbKeyCode" : @"458813" },
            @"96" : @{ @"keyname" : @"F5", @"usbKeyCode" : @"458814" },
            @"97" : @{ @"keyname" : @"F6", @"usbKeyCode" : @"458815" },
            @"98" : @{ @"keyname" : @"F7", @"usbKeyCode" : @"458816" },
            @"100" : @{ @"keyname" : @"F8", @"usbKeyCode" : @"458817" },
            @"101" : @{ @"keyname" : @"F9", @"usbKeyCode" : @"458818" },
            @"109" : @{ @"keyname" : @"F10", @"usbKeyCode" : @"458819" },
            @"103" : @{ @"keyname" : @"F11", @"usbKeyCode" : @"458820" },
            @"111" : @{ @"keyname" : @"F12", @"usbKeyCode" : @"458821" },
            @"114" : @{ @"keyname" : @"Insert", @"usbKeyCode" : @"458825" },
            @"115" : @{ @"keyname" : @"Home", @"usbKeyCode" : @"458826" },
            @"116" : @{ @"keyname" : @"PageUp", @"usbKeyCode" : @"458827" },
            @"117" : @{ @"keyname" : @"Del", @"usbKeyCode" : @"458828" },
            @"119" : @{ @"keyname" : @"End", @"usbKeyCode" : @"458829" },
            @"121" : @{ @"keyname" : @"PageDown", @"usbKeyCode" : @"458830" },
            @"124" : @{ @"keyname" : @"ArrowRight", @"usbKeyCode" : @"458831" },
            @"123" : @{ @"keyname" : @"ArrowLeft", @"usbKeyCode" : @"458832" },
            @"125" : @{ @"keyname" : @"ArrowDown", @"usbKeyCode" : @"458833" },
            @"126" : @{ @"keyname" : @"ArrowUp", @"usbKeyCode" : @"458834" },
            @"71" : @{ @"keyname" : @"NumLock", @"usbKeyCode" : @"458835" },
            @"75" : @{ @"keyname" : @"NumpadDivide", @"usbKeyCode" : @"458836" },
            @"67" : @{ @"keyname" : @"Keypad_*", @"usbKeyCode" : @"458837" },
            @"78" : @{ @"keyname" : @"Keypad_-", @"usbKeyCode" : @"458838" },
            @"69" : @{ @"keyname" : @"NumpadAdd", @"usbKeyCode" : @"458839" },
            @"76" : @{ @"keyname" : @"NumpadEnter", @"usbKeyCode" : @"458840" },
            @"83" : @{ @"keyname" : @"Numpad1+End", @"usbKeyCode" : @"458841" },
            @"84" : @{ @"keyname" : @"Numpad2+Down", @"usbKeyCode" : @"458842" },
            @"85" : @{ @"keyname" : @"Numpad3+PageDn", @"usbKeyCode" : @"458843" },
            @"86" : @{ @"keyname" : @"Numpad4+Left", @"usbKeyCode" : @"458844" },
            @"87" : @{ @"keyname" : @"Numpad5", @"usbKeyCode" : @"458845" },
            @"88" : @{ @"keyname" : @"Numpad6+Right", @"usbKeyCode" : @"458846" },
            @"89" : @{ @"keyname" : @"Numpad7+Home", @"usbKeyCode" : @"458847" },
            @"91" : @{ @"keyname" : @"Numpad8+Up", @"usbKeyCode" : @"458848" },
            @"92" : @{ @"keyname" : @"Numpad9+PageUp", @"usbKeyCode" : @"458849" },
            @"82" : @{ @"keyname" : @"Numpad0+Insert", @"usbKeyCode" : @"458850" },
            @"65" : @{ @"keyname" : @"Keypad_. Delete", @"usbKeyCode" : @"458851" },
            @"10" : @{ @"keyname" : @"IntlBackslash", @"usbKeyCode" : @"458852" },
            @"110" : @{ @"keyname" : @"ContextMenu", @"usbKeyCode" : @"458853" },
            @"81" : @{ @"keyname" : @"NumpadEqual", @"usbKeyCode" : @"458855" },
            @"105" : @{ @"keyname" : @"F13", @"usbKeyCode" : @"458856" },
            @"107" : @{ @"keyname" : @"F14", @"usbKeyCode" : @"458857" },
            @"113" : @{ @"keyname" : @"F15", @"usbKeyCode" : @"458858" },
            @"106" : @{ @"keyname" : @"F16", @"usbKeyCode" : @"458859" },
            @"64" : @{ @"keyname" : @"F17", @"usbKeyCode" : @"458860" },
            @"79" : @{ @"keyname" : @"F18", @"usbKeyCode" : @"458861" },
            @"80" : @{ @"keyname" : @"F19", @"usbKeyCode" : @"458862" },
            @"90" : @{ @"keyname" : @"F20", @"usbKeyCode" : @"458863" },
            @"74" : @{ @"keyname" : @"VolumeMute", @"usbKeyCode" : @"458879" },
            @"72" : @{ @"keyname" : @"VolumeUp", @"usbKeyCode" : @"458880" },
            @"73" : @{ @"keyname" : @"VolumeDown", @"usbKeyCode" : @"458881" },
            @"95" : @{ @"keyname" : @"NumpadComma", @"usbKeyCode" : @"458885" },
            @"94" : @{ @"keyname" : @"IntlRo", @"usbKeyCode" : @"458887" },
            @"104" : @{ @"keyname" : @"KanaMode", @"usbKeyCode" : @"458888" },
            @"93" : @{ @"keyname" : @"IntlYen", @"usbKeyCode" : @"458889" },
            @"59" : @{ @"keyname" : @"Control", @"usbKeyCode" : @"458976" },
            @"56" : @{ @"keyname" : @"Shift", @"usbKeyCode" : @"458977" },
            @"58" : @{ @"keyname" : @"Option", @"usbKeyCode" : @"458978" },
            @"55" : @{ @"keyname" : @"Command", @"usbKeyCode" : @"458979" },
            @"62" : @{ @"keyname" : @"Control", @"usbKeyCode" : @"458980" },
            @"60" : @{ @"keyname" : @"Shift", @"usbKeyCode" : @"458981" },
            @"61" : @{ @"keyname" : @"Option", @"usbKeyCode" : @"458982" },
            @"54" : @{ @"keyname" : @"Command", @"usbKeyCode" : @"458983" },
        };

    
    return _mac_usb_keylist;
}

@end
