//
//  AppDelegate.m
//  YMTest
//
//  Created by 黄玉洲 on 2022/4/7.
//

#import "AppDelegate.h"
#import "YMCGSInternal.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
//    YMCGSForceWaitCursorActive(YMCGSMainConnectionID(), true);
    
    // 主控制器
    _mainWindows = [[MainWindowController alloc]initWithWindowNibName:@"MainWindowController"];
    [[_mainWindows window] center];
    [_mainWindows.window orderFront:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
