//
//  AppDelegate.m
//  YM_Category_macOS
//
//  Created by 海南有趣 on 2020/7/8.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "AppDelegate.h"
#import "YMToolLibrary.h"
#import <Carbon/Carbon.h>
#import <YMCategory/NSAppleEventDescriptor+YMCategory.h>
@interface NSAppleEventDescriptor (YMCategory)

@end

@implementation NSAppleEventDescriptor (YMCategory)

- (NSAppleEventDescriptor *)descriptorForKeyword:(AEKeyword)keywor {
    return [self attributeDescriptorForKeyword:keywor];
}

- (OSType)osTypeForKeyword:(AEKeyword)keywor {
    return [[self attributeDescriptorForKeyword:keywor] typeCodeValue];
}

- (DescType)descTypeForKeyword:(AEKeyword)keywor {
    return [[self attributeDescriptorForKeyword:keywor] descriptorType];
}

@end

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(receiveEventWithEvent:replyEvent:) forEventClass:kCoreEventClass andEventID:kAEQuitApplication];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

/// 拦截终止
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    NSLog(@"QuitReason: %ld", [YMProcessInfoTool ymAppQuitViaDock]);
    return NSTerminateCancel;
}

- (void)receiveEventWithEvent:(NSAppleEventDescriptor*)event replyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSAppleEventDescriptor *appleEvent = event; // <NSAppleEventDescriptor: 'aevt'\'quit'{ &'subj':null(), &'csig':65536 }>
    NSLog(@"appleEvent:%@",  appleEvent);
    NSLog(@"'attr':%@ ",  [appleEvent ymDescriptorForKeyword:kAppleEventKey_ATTR]);
    NSLog(@"keyEventClassAttr:%@ value:%d",  [appleEvent ymDescriptorForKeyword:kAppleEventKey_EVCL], [appleEvent ymOSTypeForKeyword:kAppleEventKey_EVCL] == kAppleEventDescType_AEVT); // aevt
    NSLog(@"keyEventIDAttr:%@ value:%d",  [appleEvent ymDescriptorForKeyword:kAppleEventKey_EVID], [appleEvent ymOSTypeForKeyword:kAppleEventKey_EVID] == kAppleEventID_QUIT); // quit
    NSLog(@"keySubjectAttr:%@ value:%d",  [appleEvent ymDescriptorForKeyword:kAppleEventKey_SUBJ], [appleEvent ymDescTypeForKeyword:kAppleEventKey_SUBJ] == kAppleEventDescType_NULL); // subj
    NSLog(@"enumConsidsAndIgnores:%@ value:%d",  [appleEvent ymDescriptorForKeyword:kAppleEventKey_CSIG], [appleEvent ymDescTypeForKeyword:kAppleEventKey_CSIG] == 65536); // csig
    NSLog(@"keySenderPIDAttr:%@ value:%d",  [appleEvent ymDescriptorForKeyword:kAppleEventKey_PID], [appleEvent ymOSTypeForKeyword:kAppleEventKey_PID]);
    NSLog(@"'stat':%@ value:%d",  [appleEvent ymDescriptorForKeyword:kAppleEventKey_STAT], [appleEvent ymBooleanTypeForKeyword:kAppleEventKey_STAT]);
    NSLog(@"keyAddressAttr:%@",  [appleEvent ymDescriptorForKeyword:keyAddressAttr]);
    
    
    NSAppleEventDescriptor *reason = [appleEvent attributeDescriptorForKeyword:kAEQuitReason];
    if (reason) {
        if ([reason typeCodeValue] == kAEShutDown) {
            NSLog(@"kQuitReasonShutDown");
        } else if ([reason typeCodeValue] == kAERestart) {
            NSLog(@"kQuitReasonRestart");
        } else if ([reason typeCodeValue] == kAELogOut) {
            NSLog(@"kQuitReasonLogOut");
        } else if ([reason typeCodeValue] == kAEReallyLogOut) {
            NSLog(@"kQuitReasonReallyLogOut");
        } else if ([reason typeCodeValue] == kAEQuitAll) {
            NSLog(@"kQuitReasonQuitAll");
        }
    }
}

@end
