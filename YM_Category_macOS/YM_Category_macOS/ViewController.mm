//
//  ViewController.m
//  YM_Category_macOS
//
//  Created by 海南有趣 on 2020/7/8.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "ViewController.h"
#import "NSWindow+YMCategory.h"
#import "NSImage+YMCategory.h"
//#import <YMCustomView/YMCustomView.h>
#import <YMTool/YMTool.h>
#import <YMCategory/NSString+YMCategory.h>
//#import "YMCategoryLibary.h"
//#import "YMToolLibrary.h"
//#import "YMCategoryLibrary.h"
//#import "YMSMC.h"

#include <stdio.h>
#include <algorithm>
#include <stdarg.h>

#import <mach/mach.h>
#import <sys/sysctl.h>
#import <Carbon/Carbon.h>
@interface ViewController ()
{
    natural_t   _numCPUsU;
    processor_info_array_t _cpuInfo;
    mach_msg_type_number_t _numCpuInfo;
    processor_info_array_t _prevCpuInfo;
    mach_msg_type_number_t _numPrevCpuInfo;
}

@property (strong, nonatomic) NSLock * CPUUsageLock;
@property (strong, nonatomic) NSMutableArray  <NSNumber *> * usagePerCore;
@property (strong, nonatomic) NSTextField * displayTextField;
@property (strong, nonatomic) NSTextField * numberTextField;

@end

CGEventRef __nullable callBack(CGEventTapProxy  proxy,
                                       CGEventType type,
                                       CGEventRef  event,
                                       void * _Nullable userInfo) {
    if (type != kCGEventNull ) {
        NSEvent * nsevent = [NSEvent eventWithCGEvent:event];
        NSWindow * windwo = [NSWindow ymWindowFromPoint:nsevent.locationInWindow];
        NSLog(@"nsevent.mouseLocation:%@ windows:%@", NSStringFromPoint(nsevent.locationInWindow), windwo);
    }
    return event;
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(screenSleep) name:NSWorkspaceScreensDidSleepNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(screenWakeup) name:NSWorkspaceScreensDidWakeNotification object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(screenLock) name:@"com.apple.screenIsLocked" object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(screenunLock) name:@"com.apple.screenIsUnlocked" object:nil];
    
//    NSImage * image = [NSImage ymQRImageWithContent:@"https://www.baidu.com" level:kCorrectionLevel_L toSize:CGSizeMake(200, 200)];
  
    NSLog(@"%ld %ld %@ %@", [YMDeviceInfoTool ymCPUCoreCount], [YMDeviceInfoTool ymCPUThreadCount], [YMDeviceInfoTool ymCPUName], [YMDeviceInfoTool ymCPUArchitecture]);

    NSButton * button = [[NSButton alloc] init];
    button.title = @"点击按钮";
    button.target = self;
    button.action = @selector(buttonAction);
    button.frame = CGRectMake(100, 0, 100, 100);
    [self.view addSubview:button];
    
    NSButton * button1 = [[NSButton alloc] init];
    button1.title = @"切换分辨率";
    button1.target = self;
    button1.action = @selector(buttonAction1);
    button1.frame = CGRectMake(230, 0, 100, 100);
    [self.view addSubview:button1];
    
    NSButton * button2 = [[NSButton alloc] init];
    button2.title = @"添加监听";
    button2.target = self;
    button2.action = @selector(buttonAction2);
    button2.frame = CGRectMake(360, 0, 100, 100);
    [self.view addSubview:button2];
    
    self.displayTextField = [[NSTextField alloc] init];
    self.displayTextField.placeholderString = @"输入屏幕ID";
    self.displayTextField.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:self.displayTextField];
    
    self.numberTextField = [[NSTextField alloc] init];
    self.numberTextField.placeholderString = @"输入分辨率ID";
    self.numberTextField.frame = CGRectMake(200, 100, 100, 100);
    [self.view addSubview:self.numberTextField];
    
//    [YMIOPMLibTool ymIOPMSchedulePowerEvent:kPowerEvent_WakeUp date:[NSDate dateWithTimeIntervalSinceNow:1]];
//    [YMPermissionTool showCameraPermission:nil];
//    NSLog(@"ymNetworkStatus:%d", [YMNetworkTool ymNetworkStatus]);
//    NSLog(@"ymPreLogin:%d", [YMDeviceInfoTool ymPreLogin]);
    
    // 屏幕数量
//    NSError * error;
//    int count = [YMDisplayTool ymDisplayCount:&error];
//    NSLog(@"count:%d %@", count, error);
    
    // 进程信息
//    for (YMProcessInfoModel * infoModel in [YMProcessInfoTool ymProcessInfoModelListWithName:@"ToDesk_Host_Service"]) {
//        NSLog(@"%@", [YMProcessInfoTool  ymProcessLaunchParameterWithPID:infoModel.pid]);
//    }

    
//    YMDisplayTool * displayTool = [[YMDisplayTool alloc] init];
//    [displayTool ymDisplayBrightness:0.5 displayID:1];
}

- (void)buttonAction {
//    NSImage * image = [NSImage imageNamed:@"user_arrow"];
//    NSLog(@"Format:%@", [@"http://www.baidu.com" ymDomainToRealIP]);
//    NSLog(@"ymNetworkStatus:%@", [@"测试泄露" ymPinyin:NO]);
//    NSLog(@"ymNetworkStatus:%@", [@"测试泄露" ymPinyin:YES]);
//    [YMPermissionTool showAccessibilityPermissions];
    return;
//    NSLog(@"%@", [YMNetworkTool ymProcessBandwidth]);
//    NSLog(@"%@", [YMNetworkTool ymAllNetworkEquipment]);
//    NSLog(@"%@", [YMNetworkTool ymActiveInterface]);
//    NSLog(@"%@", [YMNetworkTool ymSSID]);
    
    
//    float systemUsage = 0;
//    float userUsage = 0;
//    float idleUsage = 0;
//    NSArray * usages;
//    [YMDeviceInfoTool ymCPUUsage:&systemUsage userUsage:&userUsage idleUsage:&idleUsage cpuUsagesPerCore:&usages];
//    NSLog(@"%lf %lf %lf %@ %lf%%", systemUsage, userUsage, idleUsage, usages, (systemUsage + userUsage) * 100);
//
//
//    int fanNum = [YMDeviceInfoTool getFanNum];
//    for (int i = 0; i < fanNum; i++) {
//        int RPM = [YMDeviceInfoTool getFanRPM:i];
//        NSLog(@"rpm:%d", RPM);
//    }
//
//    static int mode = [YMDeviceInfoTool getFanMode:0];
//    if (mode == 0) {
//        mode = 1;
//        [YMDeviceInfoTool setFanAuto:NO fanNumber:0];
//        [YMDeviceInfoTool setFanSpeed:5000 fanNumber:0];
//    } else {
//        mode = 0;
//        [YMDeviceInfoTool setFanAuto:YES fanNumber:0];
//    }
    
//    [[YMKeyboardTool share] toggleCaps:YES];
//    for (NSScreen * temp_screen in [NSScreen screens]) {
//        NSLog(@"%@", NSStringFromRect(temp_screen.frame));
//    }
//
    
//    int32_t width, height, hotX, hotY;
//    NSData * data = [[YMCursorTool share] cursorDataWithWidth:&width height:&height hotX:&hotX hotY:&hotY];
//    if (data) {
//        uint8_t* cursor_image = (uint8_t*)[data bytes];
//        size_t cursor_size = width * height;
//        std::unique_ptr<uint8_t[]> mimage = std::make_unique<uint8_t[]>(cursor_size * 4);
//        memcpy(mimage.get(), cursor_image, cursor_size * 4);
//    }
    
    for (NSString * displayID in [YMDisplayTool ymDisplayList]) {
        NSScreen * screen = [YMDisplayTool ymScreenWithDisplayID:(int)[displayID integerValue]];
        NSLog(@"displayID:%@ scale:%lf", displayID, screen.backingScaleFactor);
        YMDisplayItem * item = [[YMDisplayItem alloc] initWithDisplayID:(int)[displayID integerValue] duplicateRemove:false withHiDPI:true];
        for (YMDisplayResolution * resolution in item.resolutions) {
            NSLog(@"displayID:%@ resolution:%@", displayID, resolution);
        }
        NSLog(@"======================================================================");
    }
    
//    NSArray <YMDisplay *> * array = [YMDisplayTool ymDisplayModelList];
//    for (YMDisplay * display in array) {
//        NSScreen * screen = [YMDisplayTool ymScreenWithDisplayID:display.displayID];
//        CGRect rect = [YMDisplayTool ymDisplayBoundsWithID:[NSString stringWithFormat:@"%d", display.displayID]];
//        NSLog(@"%@ %@" ,  NSStringFromRect(screen.frame), NSStringFromRect(rect));
//    }
}

- (void)buttonAction1 {
    NSLog(@"accessibilityPermissions:%d", [YMPermissionTool accessibilityPermissions]);
    return;
    int displayID = (int)[self.displayTextField.stringValue integerValue];
    int number = (int)[self.numberTextField.stringValue integerValue];
    if (displayID > 0) {
        NSString * err = nil;
        [YMDisplayTool ymDisplayID:[NSString stringWithFormat:@"%d", displayID] checkModeNumber:number error:&err];
        if (err) {
            NSLog(@"err:%@", err);
        }
    } else {
        for (NSString * displayID in [YMDisplayTool ymDisplayList]) {
            YMDisplayItem * item = [[YMDisplayItem alloc] initWithDisplayID:(int)[displayID integerValue] duplicateRemove:false withHiDPI:true];
            for (YMDisplayResolution * resolution in item.resolutions) {
                NSString * err = nil;
                [YMDisplayTool ymDisplayID:displayID checkModeNumber:resolution.modeNumber error:&err];
                if (err) {
                    NSLog(@"err:%@", err);
                }
            }
            NSLog(@"======================================================================");
        }
    }
}

- (void)buttonAction2 {
    //    int RPM = [YMDeviceInfoTool getFanRPM:0];
    //    NSLog(@"rpm:%d %d", RPM, [YMDeviceInfoTool getFanMode:0]);
    //    NSError * error;
    //    [YMPermissionTool showAccessibilityPermissions];
    //    [[YMMouseTool share] addListeningMouse:YMMouseEventType_All callback:callBack error:&error];
    //    NSLog(@"监听：%@", error);
    //    [[YMKeyboardTool share] toggleCaps:NO];
        
    NSLog(@"[YMDeviceInfoTool ymPreLogin]:%d", [YMDeviceInfoTool ymPreLogin]);
    
    static bool caps = false;
    if (caps) {
        [[YMKeyboardTool share] toggleCaps:true];
    } else {
        [[YMKeyboardTool share] toggleCaps:false];
    }
    caps = !caps;
}

#pragma mark - Notification
- (void)screenSleep {
    NSLog(@"屏幕休眠");
}

- (void)screenWakeup {
    NSLog(@"屏幕唤醒");
}

- (void)screenLock {
    NSLog(@"屏幕锁定");
}

- (void)screenunLock {
    NSLog(@"屏幕解锁");
}


@end
