//
//  NSButton+YMCategory.m
//  ToDesk
//
//  Created by 黄玉洲 on 2020/8/2.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "NSButton+YMCategory.h"

#import <AppKit/AppKit.h>


@implementation NSButton (YMCategory)

/// 添加事件
- (NSButton * _Nonnull (^)(id _Nonnull, SEL _Nonnull))ymAction {
    return ^NSButton *(id targer, SEL action) {
        self.target = targer;
        self.action = action;
        return self;
    };
}

@end
