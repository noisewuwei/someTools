//
//  YMKeyChain.h
//  YMTool
//
//  Created by 黄玉洲 on 2019/12/18.
//  Copyright © 2019年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ========= YMKeyChain =========
@interface YMKeyChain : NSObject

+ (void)saveObject:(id)object forKey:(NSString *)key;
+ (id)readObjectForKey:(NSString *)key;
+ (void)deleteObjectForKey:(NSString *)key;
+ (void)deleteAllObject;

@end

NS_ASSUME_NONNULL_END
