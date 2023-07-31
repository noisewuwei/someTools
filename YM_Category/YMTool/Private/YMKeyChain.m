//
//  YMKeyChain.m
//  YMTool
//
//  Created by 黄玉洲 on 2019/12/18.
//  Copyright © 2019年 huangyuzhou. All rights reserved.
//

#import "YMKeyChain.h"
#import "YMSaveKeyChain.h"
#define BUNDLE_ID [[NSBundle mainBundle] bundleIdentifier]
@implementation YMKeyChain

+ (void)saveObject:(id)object forKey:(NSString *)key {
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    [mDic setValuesForKeysWithDictionary:(NSMutableDictionary *)[YMSaveKeyChain load:BUNDLE_ID]];
    if (!object) {
        [mDic removeObjectForKey:key];
    } else {
        [mDic setObject:object forKey:key];
    }
    [YMSaveKeyChain save:BUNDLE_ID data:mDic];
}

+ (id)readObjectForKey:(NSString *)key {
    NSMutableDictionary *mDic = (NSMutableDictionary *)[YMSaveKeyChain load:BUNDLE_ID];
    return [mDic objectForKey:key];
}

+ (void)deleteObjectForKey:(NSString *)key {
    NSMutableDictionary *mDic = (NSMutableDictionary *)[YMSaveKeyChain load:BUNDLE_ID];
    [mDic removeObjectForKey:key];
    [YMSaveKeyChain save:BUNDLE_ID data:mDic];
}

+ (void)deleteAllObject {
    [YMSaveKeyChain delete:BUNDLE_ID];
}

@end
