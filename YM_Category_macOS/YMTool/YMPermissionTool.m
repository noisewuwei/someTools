//
//  YMPermissionTool.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/9/27.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "YMPermissionTool.h"
#import <pwd.h>
#import <AVFoundation/AVFoundation.h>

@interface YMPermissionTool ()

@end

@implementation YMPermissionTool

#pragma mark 屏幕录制
/// 屏幕录制权限
+ (BOOL)screenRecordPermissions {
    if (@available(macOS 10.15, *)) {
        // 该方案需要重启App才能更新授权状态
        // bool result = CGPreflightScreenCaptureAccess();
        
        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
        if (windowList) {
            NSUInteger numberOfWindows = CFArrayGetCount(windowList);
            NSUInteger numberOfWindowsWithInfoGet = 0;
            for (int idx = 0; idx < numberOfWindows; idx++) {
                NSDictionary *windowInfo = (NSDictionary *)CFArrayGetValueAtIndex(windowList, idx);
                NSString * windowName = windowInfo[(id)kCGWindowName];
                NSNumber* sharingType = windowInfo[(id)kCGWindowSharingState];
                if (windowName || kCGWindowSharingNone != sharingType.intValue) {
                    numberOfWindowsWithInfoGet++;
                }
            }
            CFRelease(windowList);
            if (numberOfWindows == numberOfWindowsWithInfoGet) {
                return YES;
            } else {
                return NO;
            }
        }
    }

    return YES;
}

/// 弹出屏幕录取授权框
+ (void)showScreenRecordPermissions {
    //    CGDisplayCreateImage(CGMainDisplayID());
    if (@available(macOS 10.15, *)) {
        CGRequestScreenCaptureAccess();
    }

}

/// 跳转屏幕录制权限设置页
+ (void)jumpScreenRecordPermissions {
    NSURL *URL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"];
    [[NSWorkspace sharedWorkspace] openURL:URL];
}

#pragma mark 辅助功能
/// 辅助功能权限
+ (BOOL)accessibilityPermissions {
//    if (@available(macOS 10.9, *)) {
//        return AXAPIEnabled();
//    }
    NSDictionary* options = @{(__bridge NSString*)kAXTrustedCheckOptionPrompt: @NO};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
}

/// 弹出辅助功能授权框
+ (void)showAccessibilityPermissions {
    NSDictionary* options = @{(__bridge NSString*)kAXTrustedCheckOptionPrompt: @YES};
    AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        CGEventRef push = CGEventCreateKeyboardEvent(NULL, -1, true);
//        CGEventSetFlags(push, kCGEventFlagMaskNonCoalesced);
//        CGEventPost(kCGHIDEventTap, push);
//    });
}

/// 打开辅助功能授权列表页
+ (void)jumpAccessibilityPermissions {
    NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}


#pragma mark 完全访问磁盘功能
/// 完全访问磁盘功能权限
+ (BOOL)allFilesPermissions {
    NSString * userHomePath = NSHomeDirectory();
    BOOL isSandboxed = (nil != NSProcessInfo.processInfo.environment[@"APP_SANDBOX_CONTAINER_ID"]);
    
    if (isSandboxed) {
        struct passwd *pw = getpwuid(getuid());
        assert(pw);
        userHomePath = [NSString stringWithUTF8String:pw->pw_dir];
    }

    NSString *path = [userHomePath stringByAppendingPathComponent:@"Library/Safari"];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    NSArray <NSString *> * paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    if (paths == nil && fileExists){
        return NO;
    } else if (fileExists) {
        return YES;
    } else { // unkwno
        return NO;
    }
}

/// 打开完全访问磁盘功能授权页
+ (void)jumpAllFilesPermissions {
    if (@available(macOS 10.14, *)){
        NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
    }
}

#pragma mark 摄像头
+ (BOOL)cameraPermission
{
    if (@available(macOS 10.14, *))
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

+ (void)showCameraPermission:(void(^)(BOOL result))resultBlock {
    dispatch_block_t workBlock;
    if (@available(macOS 10.14, *)) {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == AVAuthorizationStatusAuthorized) {
                workBlock = ^{
                    if (resultBlock) resultBlock(YES);
                };
                // do your logic
            } else if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
                workBlock = ^{
                    if (resultBlock) resultBlock(NO);
                };
                // denied
            } else if(authStatus == AVAuthorizationStatusNotDetermined){
                // not determined?!
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (resultBlock) resultBlock(NO);
                }];
                return;
            }
        }else {
            workBlock = ^{
                if (resultBlock) resultBlock(YES);
            };
        }
        dispatch_async(dispatch_get_main_queue(), workBlock);
}


+ (void)jumpCameraPermission
{
    if (@available(macOS 10.14, *)){
        NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Camera";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
    }
}

#pragma mark 麦克风
+ (BOOL)microphonePermission {
    if (@available(macOS 10.14, *))
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            return YES;
        }
        else {
            return NO;
        }
    }
    return YES;
}

+ (void)showMicrophonePermission:(void(^)(BOOL result))resultBlock {
    if (@available(macOS 10.14, *)) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (resultBlock) {
                resultBlock(granted);
            }
        }];
    } else {
        if (resultBlock) {
            resultBlock(NO);
        }
    }
}

+ (void)jumpMicrophonePermission {
    if (@available(macOS 10.14, *)){
        NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
    }
}

@end
