//
//  YMKeyChain.m
//  YMTool
//
//  Created by 黄玉洲 on 2021/9/29.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YMKeyChain.h"
#import "YMSaveKeyChain.h"
@interface YMKeyChain ()

@property (copy, nonatomic) NSString * bundleID;

@end

@implementation YMKeyChain

static YMKeyChain * instance = nil;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMKeyChain alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (void)setBundleID:(NSString *)bundleID {
    if (bundleID) {
        [YMKeyChain share].bundleID = bundleID;
    } else {
        [self printfError];
    }
}

+ (void)saveObject:(id)object forKey:(NSString *)key {
    NSString * bundleID = [YMKeyChain share].bundleID;
    if (bundleID.length == 0) {
        [self printfError];
        return;
    }
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    [mDic setValuesForKeysWithDictionary:(NSMutableDictionary *)[YMSaveKeyChain load:bundleID]];
    if (!object) {
        [mDic removeObjectForKey:key];
    } else {
        [mDic setObject:object forKey:key];
    }
    [YMSaveKeyChain save:bundleID data:mDic];
}

+ (id)readObjectForKey:(NSString *)key {
    NSString * bundleID = [YMKeyChain share].bundleID;
    if (bundleID.length == 0) {
        [self printfError];
        return nil;
    }
    
    NSMutableDictionary *mDic = (NSMutableDictionary *)[YMSaveKeyChain load:bundleID];
    return [mDic objectForKey:key];
}

+ (void)deleteObjectForKey:(NSString *)key {
    NSString * bundleID = [YMKeyChain share].bundleID;
    if (bundleID.length == 0) {
        [self printfError];
        return;
    }
    
    NSMutableDictionary *mDic = (NSMutableDictionary *)[YMSaveKeyChain load:bundleID];
    [mDic removeObjectForKey:key];
    [YMSaveKeyChain save:bundleID data:mDic];
}

+ (void)deleteAllObject {
    NSString * bundleID = [YMKeyChain share].bundleID;
    if (bundleID.length == 0) {
        [self printfError];
        return;
    }
    
    [YMSaveKeyChain delete:bundleID];
}

+ (void)printfError {
    NSLog(@"YMKeyChina BundleID不能为空, 请执行setBundleID:");
}

@end
