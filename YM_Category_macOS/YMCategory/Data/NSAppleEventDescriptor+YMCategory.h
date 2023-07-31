//
//  NSAppleEventDescriptor+YMCategory.h
//  YMCategory
//
//  Created by 黄玉洲 on 2022/10/31.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>


typedef NS_ENUM(int, kAppleEventKeyword) {
    kAppleEventKey_ATTR = 'attr',                // attr，所有keyword
    kAppleEventKey_EVCL = keyEventClassAttr,     // AEEventClass
    kAppleEventKey_EVID = keyEventIDAttr,        // AEEventID
    kAppleEventKey_SUBJ = keySubjectAttr,        // subj
    kAppleEventKey_CSIG = enumConsidsAndIgnores, // 'csig'
    kAppleEventKey_PID  = keySenderPIDAttr,      // 'spid'，进程id
    kAppleEventKey_STAT = 'stat',                // 'stat'，pkg进行安装，在关闭App时发送的命令中包含
};

typedef NS_ENUM(int, kAppleEventDescType)  {
    kAppleEventDescType_AEVT = kCoreEventClass,      // 'aevt'
    kAppleEventDescType_NULL = typeNull,             // 'null'
};

typedef NS_ENUM(int, kAppleEventID) {
    kAppleEventID_QUIT = kAEQuitApplication,        // 'quit'
};

@interface NSAppleEventDescriptor (YMCategory)

- (NSAppleEventDescriptor *)ymDescriptorForKeyword:(int)keywor;

- (OSType)ymOSTypeForKeyword:(int)keywor;

- (DescType)ymDescTypeForKeyword:(int)keywor;

- (DescType)ymBooleanTypeForKeyword:(int)keywor;

@end


