//
//  YMKeyCommandTool.h
//  iOSKeyTest
//
//  Created by 海南有趣 on 2020/10/24.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



enum {
    kKeycode_CapsLock = 458809,
    kKeycode_Shift = 458977,
    kKeycode_Command = 458979,
    kKeycode_Alt = 458978,
    kKeycode_Control = 458976,
    kKeycode_NumLock = 458835,
};

typedef void(^kKeyCommandBlock)(NSString * keyName, UIKeyModifierFlags flags);

/// 外接键盘工具类
@interface YMKeyCommandTool : NSObject

+ (instancetype)share;

- (NSArray<UIKeyCommand *> *)keyCommandsWithSel:(SEL)sel;

/// 通过键名获取键值
/// @param keyName 键名
- (NSInteger)keyCodeWithKeyName:(NSString *)keyName;

/// 通过mac键值获取usb键值
/// @param macKeycode mac键值
- (NSInteger)usbKeycodeWithMacKeycode:(NSInteger)macKeycode;

@property (assign, nonatomic) BOOL   isCapsLock;

@end

NS_ASSUME_NONNULL_END
