//
//  YMKeyCommandTool.m
//  iOSKeyTest
//
//  Created by 海南有趣 on 2020/10/24.
//

#import <UIKit/UIKit.h>
#import "YMKeyCommandTool.h"
#import "YMKeyboardHeader.h"
#pragma mark - YMKeyCommand
@interface YMKeyCommand : UIKeyCommand

@property (copy, nonatomic) kKeyCommandBlock keyCommandBlock;

@end

@implementation YMKeyCommand

+ (instancetype)keyCommandWithInput:(NSString *)input
                      modifierFlags:(UIKeyModifierFlags)modifierFlags
                              block:(kKeyCommandBlock)block {
    YMKeyCommand * keyCommand = [YMKeyCommand keyCommandWithInput:input modifierFlags:modifierFlags action:@selector(commandTarget:)];
    keyCommand.keyCommandBlock = block;
    return keyCommand;
}

+ (instancetype)keyCommandWithInput:(NSString *)input
                      modifierFlags:(UIKeyModifierFlags)modifierFlags
                                sel:(SEL)sel {
    YMKeyCommand * keyCommand = [YMKeyCommand keyCommandWithInput:input modifierFlags:modifierFlags action:sel];
//    keyCommand.keyCommandBlock = block;
    return keyCommand;
}

#pragma mark 事件
/// 事件回调
- (void)commandTarget:(YMKeyCommand *)keyCommand {
    keyCommand.keyCommandBlock(keyCommand.input, keyCommand.modifierFlags);
}
@end

#pragma mark - YMKeyCommandTool
@interface YMKeyCommandTool ()

/// 常用键盘（iOS预设键值名）
@property (strong, nonatomic) NSDictionary <NSString *, NSNumber *> * commonlyKeyboard;


/// mac键盘值所映射各个平台的键值
@property (strong, nonatomic) NSDictionary <NSString *, NSString *> * keyCodePlist;

@end

@implementation YMKeyCommandTool

static YMKeyCommandTool * instance;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMKeyCommandTool alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSArray<UIKeyCommand *> *)keyCommandsWithSel:(SEL)sel {
    NSMutableArray * mArray = [NSMutableArray array];
    
    // 常用按键（单按键）
//    NSString * keyNames = @"!@#$%^&*()~`_+{}|:\"<>?abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=[]\\;',./ ";
    
    // 常用按键（单按键）
    NSMutableArray * keyNames = [[self.commonlyKeyboard allKeys] mutableCopy];
    
    // 组合键组合
    NSArray * flags = @[@(kNilOptions),
                        @(UIKeyModifierAlphaShift), @(UIKeyModifierShift),
                        @(UIKeyModifierControl), @(UIKeyModifierAlternate),
                        @(UIKeyModifierCommand), @(UIKeyModifierNumericPad),
                        @(UIKeyModifierControl | UIKeyModifierAlternate), // Control + Alt
                        @(UIKeyModifierControl | UIKeyModifierCommand),   // Control + Command
                        @(UIKeyModifierControl | UIKeyModifierShift),     // Control + Shift
                        @(UIKeyModifierControl | UIKeyModifierAlternate | UIKeyModifierCommand), // Control + Alt + Command
                        @(UIKeyModifierAlternate | UIKeyModifierCommand), // Alt + Command
                        @(UIKeyModifierAlternate | UIKeyModifierShift),   // Alt + Shift
                        @(UIKeyModifierCommand | UIKeyModifierShift),     // Command + Shift
    ];
   
    // 申请按键监听
    for (NSInteger i = 0; i < [keyNames count]; i++) {
        NSString * keyName = keyNames[i];
        for (NSNumber * flagNum in flags) {
            UIKeyModifierFlags flag = (UIKeyModifierFlags)[flagNum integerValue];
            [mArray addObject:[YMKeyCommand keyCommandWithInput:keyName
                                                  modifierFlags:flag
                                                            sel:sel]];
        }
    }
    for (NSNumber * flagNum in flags) {
        if ([flagNum integerValue] == kNilOptions) {
            continue;
        }
        UIKeyModifierFlags flag = (UIKeyModifierFlags)[flagNum integerValue];
        [mArray addObject:[YMKeyCommand keyCommandWithInput:@""
                                              modifierFlags:flag
                                                        sel:sel]];
    }
    
//    // Caps Lock
//    [mArray addObject:[YMKeyCommand keyCommandWithInput:@""
//                                          modifierFlags:UIKeyModifierAlphaShift
//                                                    sel:sel]];
//
//    // Shift
//    [mArray addObject:[YMKeyCommand keyCommandWithInput:@""
//                                          modifierFlags:UIKeyModifierShift
//                                                    sel:sel]];
//
//    // NumericPad
//    [mArray addObject:[YMKeyCommand keyCommandWithInput:@""
//                                          modifierFlags:UIKeyModifierNumericPad
//                                                    sel:sel]];
    
    return mArray;
}

/// 通过键名获取键值
/// @param keyName 键名
- (NSInteger)keyCodeWithKeyName:(NSString *)keyName {
//    @"`1234567890-=[]\;',./qwertyuiopasdfghjklzxcvbnm";
    NSNumber * number = self.commonlyKeyboard[keyName];
    if (number) {
        NSString * macKeycode = [NSString stringWithFormat:@"%@", number];
        NSString * usbKeycode = self.keyCodePlist[macKeycode];
        if (usbKeycode) {
            return [usbKeycode integerValue];
        }
    }
    return -1;
}

/// 通过mac键值获取usb键值
/// @param macKeycode mac键值
- (NSInteger)usbKeycodeWithMacKeycode:(NSInteger)macKeycode {
    NSString * keycodeStr = [NSString stringWithFormat:@"%ld", macKeycode];
    NSString * usbKeycode = self.keyCodePlist[keycodeStr];
    if (usbKeycode) {
        return [usbKeycode integerValue];
    }
    return -1;
}

/// mac键值表
- (NSDictionary<NSString *, NSString *> *)keyCodePlist {
    if (!_keyCodePlist) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"macKeycode" ofType:@"plist"];
        NSDictionary * tempKeyCodePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSMutableDictionary * mDic = [NSMutableDictionary dictionary];
        for (NSString * key in tempKeyCodePlist.allKeys) {
            NSDictionary * tempKeyCodeInfo = tempKeyCodePlist[key];
            if (tempKeyCodeInfo[@"usb"]) {
                [mDic setObject:tempKeyCodeInfo[@"usb"] forKey:[key lowercaseString]];
            }
        }
        _keyCodePlist = mDic;
    }
    return _keyCodePlist;
}

/// 常用键盘（iOS预设键值名）
- (NSDictionary<NSString *, NSNumber *> *)commonlyKeyboard {
    if (!_commonlyKeyboard) {
        NSMutableDictionary * mDic =
        [
         @{@"1" : @(kVK_ANSI_1), @"2" : @(kVK_ANSI_2), @"3" : @(kVK_ANSI_3),
           @"4" : @(kVK_ANSI_4), @"5" : @(kVK_ANSI_5), @"6" : @(kVK_ANSI_6),
           @"7" : @(kVK_ANSI_7), @"8" : @(kVK_ANSI_8), @"9" : @(kVK_ANSI_9),
           @"0" : @(kVK_ANSI_0), @"-" : @(kVK_ANSI_Minus), @"=" : @(kVK_ANSI_Equal),
           @"[" : @(kVK_ANSI_LeftBracket), @"]" : @(kVK_ANSI_RightBracket),
           @"\\" : @(kVK_ANSI_Backslash), @";" : @(kVK_ANSI_Semicolon),
           @"'" : @(kVK_ANSI_Quote), @"," : @(kVK_ANSI_Comma), @"." : @(kVK_ANSI_Period),
           @"/" : @(kVK_ANSI_Slash), @"q" : @(kVK_ANSI_Q), @"w" : @(kVK_ANSI_W),
           @"e" : @(kVK_ANSI_E), @"r" : @(kVK_ANSI_R), @"t" : @(kVK_ANSI_T),
           @"y" : @(kVK_ANSI_Y), @"u" : @(kVK_ANSI_U), @"i" : @(kVK_ANSI_I),
           @"o" : @(kVK_ANSI_O), @"p" : @(kVK_ANSI_P), @"a" : @(kVK_ANSI_A),
           @"s" : @(kVK_ANSI_S), @"d" : @(kVK_ANSI_D), @"f" : @(kVK_ANSI_F),
           @"g" : @(kVK_ANSI_G), @"h" : @(kVK_ANSI_H), @"j" : @(kVK_ANSI_J),
           @"k" : @(kVK_ANSI_K), @"l" : @(kVK_ANSI_L), @"z" : @(kVK_ANSI_Z),
           @"x" : @(kVK_ANSI_X), @"c" : @(kVK_ANSI_C), @"v" : @(kVK_ANSI_V),
           @"b" : @(kVK_ANSI_B), @"n" : @(kVK_ANSI_N), @"m" : @(kVK_ANSI_M),
           @"`" : @(kVK_ANSI_Grave), @"\b" : @(kVK_Delete), @"\r" : @(kVK_Return),
           @"\t" : @(kVK_Tab), @" " : @(kVK_Space), UIKeyInputUpArrow : @(kVK_UpArrow),
           UIKeyInputDownArrow : @(kVK_DownArrow), UIKeyInputLeftArrow : @(kVK_LeftArrow),
           UIKeyInputRightArrow : @(kVK_RightArrow), UIKeyInputEscape : @(kVK_Escape),
           UIKeyInputPageUp : @(kVK_PageUp), UIKeyInputPageDown : @(kVK_PageDown)} mutableCopy];
        
        
        if (@available(iOS 13.4, *)) {
            NSDictionary * dic =
            @{UIKeyInputHome : @(kVK_Home), UIKeyInputEnd : @(kVK_End),
              UIKeyInputF1 : @(kVK_F1), UIKeyInputF2 : @(kVK_F2),
              UIKeyInputF3 : @(kVK_F3), UIKeyInputF4 : @(kVK_F4),
              UIKeyInputF5 : @(kVK_F5), UIKeyInputF6 : @(kVK_F6),
              UIKeyInputF7 : @(kVK_F7), UIKeyInputF8 : @(kVK_F8),
              UIKeyInputF9 : @(kVK_F9), UIKeyInputF10 : @(kVK_F10),
              UIKeyInputF11 : @(kVK_F11), UIKeyInputF12 : @(kVK_F12)
            };

            [mDic addEntriesFromDictionary:dic];
        }
        
        _commonlyKeyboard = mDic;
    }
    return _commonlyKeyboard;
}

@end
