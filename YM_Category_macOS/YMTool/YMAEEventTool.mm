//
//  YMAEEventTool.m
//  YMTool
//
//  Created by 黄玉洲 on 2021/2/4.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "YMAEEventTool.h"
#import "YMDeviceInfoTool.h"
#include <dlfcn.h>
@implementation YMAEEventTool
static YMAEEventTool * instance = nil;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMAEEventTool alloc] init];
        
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

/// 系统指令
/// @param eventToSendID AEEventID
OSStatus SendAppleEventToSystemProcess(AEEventID eventToSendID) {
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = {0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent eventToSend = {typeNull, NULL};

    OSStatus status = AECreateDesc(typeProcessSerialNumber,
         &kPSNOfSystemProcess, sizeof(kPSNOfSystemProcess), &targetDesc);

    if (status != noErr) return status;

    status = AECreateAppleEvent(kCoreEventClass, eventToSendID,
          &targetDesc, kAutoGenerateReturnID, kAnyTransactionID, &eventToSend);

    AEDisposeDesc(&targetDesc);

    if (status != noErr) return status;

    status = AESendMessage(&eventToSend, &eventReply,
                          kAENormalPriority, kAEDefaultTimeout);

    AEDisposeDesc(&eventToSend);
    if (status != noErr) return status;
    AEDisposeDesc(&eventReply);
    return status;
}

/// 锁定屏幕
+ (OSStatus)ymSendLockScreen {
    typedef void (*SACLockScreenImmediate_F)(void);
    void* libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY);
    if (libHandle) {
        SACLockScreenImmediate_F SACLockScreenImmediate = (SACLockScreenImmediate_F)dlsym(libHandle, "SACLockScreenImmediate");
        if (SACLockScreenImmediate) {
            SACLockScreenImmediate();
            dlclose(libHandle);
            return 0;
        }
    }
    dlclose(libHandle);
    
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Applications/Utilities/Keychain Access.app/Contents/Resources/Keychain.menu"];
    Class principalClass = [bundle principalClass];
    id instance = [[principalClass alloc] init];
    [instance performSelector:@selector(_lockScreenMenuHit:) withObject:nil];
    
//    NSString *versionString = [YMDeviceInfoTool ymDeviceSystemVersion];
//    if ([versionString integerValue] >= 10.14) {
//
//    } else if ([versionString integerValue] <= 10.12) {
//
//        return 0;
//    }
    return 0;
}

/// 发送Apple事件（包括重启、关机等，具体查看kAppleEvent）
/// @param appleEvent 事件枚举
+ (OSStatus)ymSendAppleEvent:(kAppleEvent)appleEvent {
    AEEventID eventID = (int)appleEvent;
    switch (appleEvent) {
        case kAppleEvent_Restart: eventID = kAERestart; break; // system("reboot"); 需要root
        case kAppleEvent_ShutDown: eventID = kAEShutDown; break; // system("shutdown -h now"); 需要root
        case kAppleEvent_Logout: eventID = kAELogOut; break;
        case kAppleEvent_ReallyLogout: eventID = kAEReallyLogOut; break;
        case kAppleEvent_Sleep: eventID = kAESleep; break;
        case kAppleEvent_LockScreen: return [self ymSendLockScreen];
        case kAppleEvent_ScreenSaverEngine: { // 支持沙盒
            NSString * script = @"activate application \"ScreenSaverEngine\"";
            NSAppleScript *lockScript = [[NSAppleScript alloc] initWithSource:script];
            [lockScript executeAndReturnError:nil];
            break;
        }
        case kAppleEvent_QuitAll: eventID = kAEQuitAll; break;
        default: break;
    }
    return SendAppleEventToSystemProcess(eventID);
}

/// 获取应用退出原因（可以在applicationShouldTerminate:中进行调用），可能为空
+ (kQuitReason)ymAppleEventQuitReason {
    return [self ymAppleEventQuitReasonFrom:nil];
}

+ (kQuitReason)ymAppleEventQuitReasonFrom:(NSAppleEventDescriptor **)appleEventDescriptor {
    NSAppleEventDescriptor *appleEvent = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
    if (appleEventDescriptor) {
        *appleEventDescriptor = appleEvent;
    }
    
    // reason可能为空，导致不准确
    NSAppleEventDescriptor *reason = [appleEvent attributeDescriptorForKeyword:kAEQuitReason];
    
    if (reason) {
        if ([reason typeCodeValue] == kAEShutDown) {
            return kQuitReasonShutDown;
        } else if ([reason typeCodeValue] == kAERestart) {
            return kQuitReasonRestart;
        } else if ([reason typeCodeValue] == kAELogOut) {
            return kQuitReasonLogOut;
        } else if ([reason typeCodeValue] == kAEReallyLogOut) {
            return kQuitReasonReallyLogOut;
        } else if ([reason typeCodeValue] == kAEQuitAll) {
            return kQuitReasonQuitAll;
        }
    }
    
    return kQuitReasonNone;
}

@end

