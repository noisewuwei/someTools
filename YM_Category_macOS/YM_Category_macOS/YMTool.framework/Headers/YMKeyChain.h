//
//  YMKeyChain.h
//  YMTool
//
//  Created by 黄玉洲 on 2021/9/29.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMKeyChain : NSObject

+ (void)setBundleID:(NSString *)bundleID;

+ (void)saveObject:(id)object forKey:(NSString *)key;
+ (id)readObjectForKey:(NSString *)key;
+ (void)deleteObjectForKey:(NSString *)key;
+ (void)deleteAllObject;

@end

NS_ASSUME_NONNULL_END
