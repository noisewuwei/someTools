//
//  YMLabel.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/27.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ymVerticalAlign) {
    ymVerticalAlign_Top,
    ymVerticalAlign_Center
};

@interface YMLabel : NSTextField

/// 垂直居中
- (void)verticalAlign:(ymVerticalAlign)align;

@end

NS_ASSUME_NONNULL_END
