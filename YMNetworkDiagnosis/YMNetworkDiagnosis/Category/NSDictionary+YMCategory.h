//
//  NSDictionary+YMCategory.h
//  youqu
//
//  Created by 黄玉洲 on 2019/5/7.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (YMCategory)

/**
 转换为字符串
 @return ymConverToJson
 */
- (NSString*)ymConverToJson;

@end

NS_ASSUME_NONNULL_END
