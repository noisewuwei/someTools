//
//  NSButton+YMCategory.h
//  ToDesk
//
//  Created by 黄玉洲 on 2020/8/2.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSButton (YMCategory)

/// 添加事件
@property (copy, nonatomic, readonly) NSButton * (^ymAction)(id targer, SEL action);

@end

NS_ASSUME_NONNULL_END
