//
//  YMPermissionTool.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/9/27.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 权限管理器 */
@interface YMPermissionTool : NSObject
#pragma mark 屏幕录制
/// 屏幕录制权限
+ (BOOL)screenRecordPermissions;

/// 弹出屏幕录取授权框
+ (void)showScreenRecordPermissions;

/// 跳转屏幕录制权限设置页
+ (void)jumpScreenRecordPermissions;

#pragma mark 辅助功能
/// 辅助功能权限
+ (BOOL)accessibilityPermissions;

/// 弹出辅助功能授权框
+ (void)showAccessibilityPermissions;

/// 打开辅助功能授权列表页
+ (void)jumpAccessibilityPermissions;

#pragma mark 完全访问磁盘功能
/// 完全访问磁盘功能权限
+ (BOOL)allFilesPermissions;

/// 打开完全访问磁盘功能授权页
+ (void)jumpAllFilesPermissions;

#pragma mark 摄像头
+ (BOOL)cameraPermission;
+ (void)showCameraPermission:(void(^)(BOOL result))resultBlock;
+ (void)jumpCameraPermission;

#pragma mark 麦克风
+ (BOOL)microphonePermission;
+ (void)showMicrophonePermission:(void(^)(BOOL result))resultBlock;
+ (void)jumpMicrophonePermission;

@end
