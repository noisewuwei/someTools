//
//  MainWindowController.m
//  ToDesk
//
//  Created by rayootech on 16/6/16.
//  Copyright © 2016年 rayootech. All rights reserved.
//


#include <stdlib.h>
#include <stdlib.h>
#include <limits.h>

#include <IOKit/graphics/IOGraphicsLib.h>
#include <IOKit/graphics/IOGraphicsLib.h>
#include <CoreVideo/CVBase.h>
#include <CoreVideo/CVDisplayLink.h>
#include <ApplicationServices/ApplicationServices.h>


#import "MainWindowController.h"
#import "TestView.h"
@interface MainWindowController ()

@end

@implementation MainWindowController
- (void)dealloc {
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
//    NSButton * button = [[NSButton alloc] setButtonType:NSButtonTypeRadio];
    //被控端能否可控
    [self.window setMinSize:CGSizeMake(717, 500)];
    [self.window setMaxSize:CGSizeMake(717, 500)];
    self.window.contentView.wantsLayer = YES;
    self.window.contentView.layer.backgroundColor = CGColorCreateGenericRGB(243/255.0, 243/255.0, 243/255.0, 1.0f);
//    self.window.styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullScreen ;
    self.window.title = @"";
    
    [self.window makeKeyAndOrderFront:self];
    [self.window makeMainWindow];
    
    
    TestView * view = [TestView new];
    view.frame = self.window.contentView.bounds;
    view.wantsLayer = YES;
//    view.layer.backgroundColor = [NSColor redColor].CGColor;
    [self.window.contentView addSubview:view];
    
    /* 全屏下隐藏菜单栏 */
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeKeyNotification:) name:NSWindowDidBecomeKeyNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeMainNotification:) name:NSWindowDidBecomeMainNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterFullScreenNotification:) name:NSWindowDidEnterFullScreenNotification object:nil];

    
    
    
}
#pragma mark - 全屏下隐藏菜单栏
- (void)didBecomeKeyNotification:(NSNotification *)notifi {
    NSWindow * window = notifi.object;
    if ((([window styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSApplication sharedApplication] setPresentationOptions: NSApplicationPresentationAutoHideToolbar];
            [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
            [NSApp setPresentationOptions:NSApplicationPresentationDefault];
            [NSMenu setMenuBarVisible:NO];
            [NSMenu setMenuBarVisible:YES];
        });
    }
}

- (void)didBecomeMainNotification:(NSNotification *)notifi {
    NSWindow * window = notifi.object;
    if ((([window styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSApplication sharedApplication] setPresentationOptions: NSApplicationPresentationAutoHideToolbar];
            [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
            [NSApp setPresentationOptions:NSApplicationPresentationDefault];
            [NSMenu setMenuBarVisible:NO];
            [NSMenu setMenuBarVisible:YES];
        });
    }
}

- (void)didEnterFullScreenNotification:(NSNotification *)notifi {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp setPresentationOptions:NSApplicationPresentationDefault];
    [NSMenu setMenuBarVisible:NO];
    [NSMenu setMenuBarVisible:YES];
}

@end
