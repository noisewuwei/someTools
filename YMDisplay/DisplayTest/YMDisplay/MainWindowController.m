//
//  MainWindowController.m
//  ToDesk
//
//  Created by rayootech on 16/6/16.
//  Copyright © 2016年 rayootech. All rights reserved.
//

#import "MainWindowController.h"
#import "VirtualDisplayManager.h"
#import "DisplayDefinition.h"
#import "VirtualDisplay.h"
#import "YMDisplayTool.h"
#import "VirtualDisplayManager.h"

#import <CoreGraphics/CGDirectDisplay.h>
#import <CoreGraphics/CGDisplayConfiguration.h>

@interface MainWindowController ()

@property (strong, nonatomic) VirtualDisplayManager * manager;
@end

@implementation MainWindowController
- (void)dealloc {
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[VirtualDisplayManager share] removeColorFileWithDisplayName:@"ToDesk"];
    
//    NSButton * button = [[NSButton alloc] setButtonType:NSButtonTypeRadio];
    //被控端能否可控
    [self.window setMinSize:CGSizeMake(717, 500)];
    [self.window setMaxSize:CGSizeMake(717, 500)];
    self.window.contentView.wantsLayer = YES;
    self.window.contentView.layer.backgroundColor = CGColorCreateGenericRGB(243/255.0, 243/255.0, 243/255.0, 1.0f);
    self.window.title = @"";
    
    [self.window makeKeyAndOrderFront:self];
    [self.window makeMainWindow];

    NSButton * button = [[NSButton alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    button.title = @"创建虚拟屏";
    button.action = @selector(buttonAction);
    button.target = self;
    [self.window.contentView addSubview:button];
    
    NSButton * changeBtn = [[NSButton alloc] initWithFrame:CGRectMake(200, 100, 100, 30)];
    changeBtn.title = @"切换分辨率";
    changeBtn.action = @selector(changeBtnAction);
    changeBtn.target = self;
    [self.window.contentView addSubview:changeBtn];
    
    NSButton * deleteBtn = [[NSButton alloc] initWithFrame:CGRectMake(300, 100, 100, 30)];
    deleteBtn.title = @"删除虚拟屏";
    deleteBtn.action = @selector(deleteBtnAction);
    deleteBtn.target = self;
    [self.window.contentView addSubview:deleteBtn];
    
    NSButton * disableBtn = [[NSButton alloc] initWithFrame:CGRectMake(400, 100, 100, 30)];
    disableBtn.title = @"禁用物理屏";
    disableBtn.action = @selector(disableBtnAction);
    disableBtn.target = self;
    [self.window.contentView addSubview:disableBtn];
    
    NSString * version = @"0";
    if (@available(macOS 10.15, *)) {
        version = @">=10.15";
    } else {
        version = @"<10.15";
    }
    
    NSString * version1 = @"<MAC_OS_X_VERSION_10_15";
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_15
    version1 = @">=MAC_OS_X_VERSION_10_15";
#endif
    
    NSTextField * textfield = [[NSTextField alloc] init];
    textfield.frame = CGRectMake(100, 300, 500, 200);
    textfield.stringValue = [NSString stringWithFormat:@"%@\nMAC_OS_X_VERSION_MAX_ALLOWED=%d\nMAC_OS_X_VERSION_MIN_REQUIRED=%d", version, MAC_OS_X_VERSION_MAX_ALLOWED, MAC_OS_X_VERSION_MIN_REQUIRED];
    [self.window.contentView addSubview:textfield];
}

- (void)buttonAction {
    DisplayDefinition * definition = [DisplayDefinition defaltDisplayDefinitions][1];
    VirtualDisplay * virtualDisplay = [[VirtualDisplayManager share] createVirtualDisplay:definition displayName:@"ToDesk"];
    NSLog(@"%@", virtualDisplay);
//    DisplayResolutionDefinition * resolutionDefinition = [DisplayResolutionDefinition defaltDisplayDefinitions][2];
//    unsigned long number = [VirtualDisplayManager share].virtualDisplays.count + 1;
//    NSString * displayNum = [NSString stringWithFormat:@"%d显示器", number];
//    [[VirtualDisplayManager share] createFixedResolutionVirtualDisplay:resolutionDefinition displayName:displayNum];
}

- (void)changeBtnAction {
    VirtualDisplay * display = [[[VirtualDisplayManager share] virtualDisplays] firstObject];
    NSArray <DisplayResolution *> * array = [[VirtualDisplayManager share] resolutionsWithDisplayID:display.displayID];
    [[VirtualDisplayManager share] changeResolution:display.displayID modeNumber:array.firstObject.modeNumber error:nil];
    NSLog(@"array:%@", array);
}

- (void)deleteBtnAction {
    VirtualDisplay * display = [[[VirtualDisplayManager share] virtualDisplays] firstObject];
    [[VirtualDisplayManager share] removeVirtualDisplay:display];
//    [[VirtualDisplayManager share] removeAllVirtualDisplay];
}

- (void)disableBtnAction {
//    static bool disabled = false;
//    if (!disabled) {
//        disabled = true;
//        NSLog(@"%@", [[VirtualDisplayManager share] ymDisplayDisable:disabled displayId:2]);
//    } else {
//        disabled = false;
//        NSLog(@"%@", [[VirtualDisplayManager share] ymDisplayDisable:disabled displayId:2]);
//    }
    
    NSArray * array = [YMDisplayTool ymDisplayList];
    for (NSString * displayID in array) {
        int displayIDInt = [displayID integerValue];
        CGColorSpaceRef colorSpace = CGDisplayCopyColorSpace(displayIDInt);
        CFStringRef cfStr = CGColorSpaceGetName(colorSpace);
        NSString * string = (__bridge NSString *)cfStr;
        NSLog(@"屏幕：%d 屏幕顺序：%d 供应商ID：%d 模型ID：%d", displayIDInt, CGDisplayUnitNumber(displayIDInt), CGDisplayVendorNumber(displayIDInt), CGDisplayModelNumber(displayIDInt), CGDisplaySerialNumber(displayIDInt));
    }
}


@end
