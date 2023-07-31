//
//  NSObject+YMCategory.m
//  youqu
//
//  Created by 黄玉洲 on 2019/5/17.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import "NSObject+YMCategory.h"
#import <objc/runtime.h>
#pragma mark - ======= NSObject (YMCategory) =======
@implementation NSObject (YMCategory)

static char kYMTag;
- (NSInteger)ymTag {
    return [self.getProperty(&kYMTag) integerValue];
}
- (void)setYmTag:(NSInteger)ymTag {
    self.setProperty(&kYMTag, @(ymTag));
}

#pragma mark - 动态属性生成和获取
@dynamic setProperty;
- (id (^)(char *, id))setProperty {
    return ^id (char* key, id value) {
        objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
        return self;
    };
}

@dynamic setClassProperty;
+ (id (^)(char *, id))setClassProperty {
    return ^id (char* key, id value) {
        objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
        return self;
    };
}

@dynamic getProperty;
- (id (^)(char *))getProperty {
    return ^id (char* key) {
        return objc_getAssociatedObject(self, key);
    };
}

@dynamic getClassProperty;
+ (id (^)(char *))getClassProperty {
    return ^id (char* key) {
        return objc_getAssociatedObject(self, key);
    };
}

#pragma mark 同进程通知
/// 注册通知
/// @param notifyName 通知键
/// @param selector   回调方法
/// @param object     携带对象
- (void)registerNotify:(NSString *)notifyName selector:(SEL)selector object:(id)object {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:selector
                                                 name:notifyName
                                               object:object];
}

/// 注册通知（有可能无法释放，需要手动释放，执行removeNotifyWithName:）
/// @param notifyName 通知键
/// @param queue 线程
/// @param selector 回调方法
- (void)registerNotify:(NSString *)notifyName queue:(NSOperationQueue *)queue selector:(SEL)selector {
    __weak __typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:notifyName object:nil queue:queue ?: [NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (selector) {
            [self performSelector:selector withObject:note];
        }
    }];
}

/// 删除所有通知
- (void)removeNotify {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// 删除指定通知
/// @param notifyName 通知键
- (void)removeNotifyWithName:(NSString *)notifyName {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notifyName object:nil];
}

/// 发送通知
/// @param notifyName 通知键
/// @param object 携带对象
/// @param userInfo 携带字典
- (void)postNotifyWithName:(NSString *)notifyName object:(id)object userInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:notifyName
                                                        object:object
                                                      userInfo:userInfo];
}

#pragma mark 进程间通知
/// 注册进程间通知
/// @param notifyName 通知名
/// @param callBack 回调
/// 如:void handle(CFNotificationCenterRef center, void * observer, CFStringRef name, void const * object, CFDictionaryRef userInfo)
- (void)registerProcessNotify:(NSString *)notifyName callback:(CFNotificationCallback)callBack {
    if (notifyName.length == 0) {
        return;
    }
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)notifyName;
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(self),
                                    callBack,
                                    str,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

/// 发送进程间通知
/// @param notifyName 通知名
- (void)postProcessNotify:(nullable NSString *)notifyName {
    if (notifyName.length == 0) {
        return;
    }
    CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDarwinNotifyCenter(),
                                                    (__bridge CFStringRef)notifyName,
                                                    NULL, NULL,
                                                    0);
}

/// 删除进程间通知
/// @param notifyName 通知名
- (void)removeProcessNotify:(NSString *)notifyName {
    if (notifyName.length == 0) {
        return;
    }
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)notifyName;
    CFNotificationCenterRemoveObserver(center,
                                       (__bridge const void *)(self),
                                       str,
                                       NULL);
}

@end


#pragma mark - ======= NSObject (YMRuntimeCategory) =======
@implementation NSObject (YMRuntimeCategory)

/** 获取所有key值 */
- (NSArray *)ymGetAllIvar {
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int count;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *keyChar = ivar_getName(ivar);
        NSString *keyStr = [NSString stringWithCString:keyChar encoding:NSUTF8StringEncoding];
        @try {
            id valueStr = [self valueForKey:keyStr];
            NSDictionary *dic = nil;
            if (valueStr) {
                dic = @{keyStr : valueStr};
            } else {
                dic = @{keyStr : @"值为nil"};
            }
            [array addObject:dic];
        }
        @catch (NSException *exception) {}
    }
    return [array copy];
}

/** 获得所有属性 */
- (NSArray *)ymGetAllProperty {
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int count;
    objc_property_t *propertys = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertys[i];
        const char *nameChar = property_getName(property);
        NSString *nameStr = [NSString stringWithCString:nameChar encoding:NSUTF8StringEncoding];
        [array addObject:nameStr];
    }
    free(propertys);
    return [array mutableCopy];
}

/// 获取实例方法
/// @param classObj 要检查的类
/// @param sel 要检索的方法的选择器
+ (Method)ymMethodOfInstanceWithClass:(Class)classObj sel:(SEL)sel {
    return class_getInstanceMethod(classObj, sel);
}

/// 获取类方法
/// @param classObj 要检查的类
/// @param sel 要检索的方法的选择器
+ (Method)ymMethodOfClassWithClass:(Class)classObj sel:(SEL)sel {
    return class_getClassMethod(classObj, sel);
}

/// 替换方法实现
/// @param method 要替换的方法实现
/// @param newMethod 新的方法实现
+ (void)ymExchangeImpOfMethod:(Method)method newMethod:(Method)newMethod {
    method_exchangeImplementations(method, newMethod);
}

/// 判断类是否实现某方法
/// @param classObj 要检查的类
/// @param sel 要检索的方法的选择器
+ (BOOL)ymRespondsSelector:(Class)classObj sel:(SEL)sel {
    return class_respondsToSelector(classObj, sel);
}

@end

