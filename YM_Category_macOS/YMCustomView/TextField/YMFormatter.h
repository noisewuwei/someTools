//
//  YMFormatter.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/20.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kNumberFormatterType) {
    kNumberFormatterType_Normal,
    kNumberFormatterType_Number,
    kNumberFormatterType_Phone,
};

@interface YMFormatter : NSNumberFormatter

@property (assign, nonatomic) kNumberFormatterType type;

/// 自定义正则表达式
@property (copy, nonatomic) NSString * customRegex;

@end

NS_ASSUME_NONNULL_END
