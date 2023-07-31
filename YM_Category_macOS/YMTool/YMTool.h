//
//  YMTool.h
//  YMTool
//
//  Created by 海南有趣 on 2020/7/16.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for YMTool.
FOUNDATION_EXPORT double YMToolVersionNumber;

//! Project version string for YMTool.
FOUNDATION_EXPORT const unsigned char YMToolVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <YMTool/PublicHeader.h>

// 延迟释放
#ifdef __GNUC__
__unused static void cleanUpBlock(__strong void(^*block)(void)) {
    (*block)();
}
#define YMDefer(block_name) __strong void(^block_name)(void) __attribute__((cleanup(cleanUpBlock), unused)) = ^
#endif


#import <YMTool/YMCVPixelBufferTool.h>
#import <YMTool/YMDeviceInfoTool.h>
#import <YMTool/YMGraphicsTool.h>
#import <YMTool/YMKeyboardTool.h>
#import <YMTool/YMMouseTool.h>
#import <YMTool/YMTabletTool.h>
#import <YMTool/YMNotifyTool.h>
#import <YMTool/YMPermissionTool.h>
#import <YMTool/YMProcessInfoTool.h>
#import <YMTool/YMCursorTool.h>
#import <YMTool/YMIOPMLibTool.h>
#import <YMTool/YMAEEventTool.h>
#import <YMTool/YMTimerTool.h>
#import <YMTool/YMRunShellTool.h>
#import <YMTool/YMNetworkTool.h>
#import <YMTool/YMKeyChain.h>
#import <YMTool/YMDisplayTool.h>
