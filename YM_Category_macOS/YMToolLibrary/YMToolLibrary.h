//
//  YMToolLibary.h
//  YMToolLibary
//
//  Created by 黄玉洲 on 2020/12/18.
//  Copyright © 2020 海南有趣. All rights reserved.
//

// 需要导入CoreWLAN.framework、SystemConfiguration.framework

#import <Foundation/Foundation.h>

// 延迟释放
#ifdef __GNUC__
__unused static void cleanUpBlock(__strong void(^*block)(void)) {
    (*block)();
}
#define YMDefer(block_name) __strong void(^block_name)(void) __attribute__((cleanup(cleanUpBlock), unused)) = ^
#endif

#import "YMCVPixelBufferTool.h"
#import "YMDeviceInfoTool.h"
#import "YMGraphicsTool.h"
#import "YMKeyboardTool.h"
#import "YMMouseTool.h"
#import "YMTabletTool.h"
#import "YMNotifyTool.h"
#import "YMPermissionTool.h"
#import "YMProcessInfoTool.h"
#import "YMCursorTool.h"
#import "YMIOPMLibTool.h"
#import "YMAEEventTool.h"
#import "YMTimerTool.h"
#import "YMRunShellTool.h"
#import "YMNetworkTool.h"
#import "YMKeyChain.h"
#import "YMDisplayTool.h"
