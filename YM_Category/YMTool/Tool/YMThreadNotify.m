//
//  YMThreadNotify.m
//  YMTool
//
//  Created by 海南有趣 on 2020/4/24.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import "YMThreadNotify.h"

@interface YMThreadNotify ()

@property (nonatomic, strong) NSMapTable * observerMapTable;
@property (nonatomic, strong) NSMapTable * blockDictionaryMapTable;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation YMThreadNotify

static YMThreadNotify * instance = nil;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [YMThreadNotify new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _observerMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        _blockDictionaryMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        _semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_signal(_semaphore);
    }
    return self;
}

#pragma mark - public
/// 注册线程间通知
/// @param observer 发送者
/// @param identifier 唯一标识符
/// @param actionBlock 回调
+ (void)registerForObserver:(id)observer
                 identifier:(NSString *)identifier
                actionBlock:(void(^)(void))actionBlock {
    dispatch_semaphore_wait([YMThreadNotify share].semaphore, DISPATCH_TIME_FOREVER);
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], identifier];
    NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock"];
    
    NSMutableDictionary *blockDictionary = [[YMThreadNotify share].blockDictionaryMapTable objectForKey:observer];
    if (!blockDictionary) {
        blockDictionary = [NSMutableDictionary dictionary];
    }
    [blockDictionary setObject:actionBlock forKey:actionBlockKey];

    [[YMThreadNotify share].observerMapTable setObject:observer forKey:key];
    [[YMThreadNotify share].blockDictionaryMapTable setObject:blockDictionary forKey:observer];
    [[YMThreadNotify share] registerForNotificationsWithIdentifier:identifier];
    
    dispatch_semaphore_signal([YMThreadNotify share].semaphore);
}

/// 发送线程间通知
/// @param identifier 唯一标识符
+ (void)postIdentifier:(NSString *)identifier {
    [[YMThreadNotify share] postNotifycationWithIdentitifier:identifier];
}

#pragma mark - private
/** 注册线程通知 */
- (void)registerForNotificationsWithIdentifier:(nullable NSString *)identifier {
    [self unregisterForNotificationsWithIdentifier:identifier];
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(self),
                                    MyHoleNotificationCallback,
                                    str,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

/** 注销线程通知 */
- (void)unregisterForNotificationsWithIdentifier:(nullable NSString *)identifier {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterRemoveObserver(center,
                                       (__bridge const void *)(self),
                                       str,
                                       NULL);
}

/** 发送线程通知 */
- (void)postNotifycationWithIdentitifier:(nullable NSString *)identifier {
    CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDarwinNotifyCenter(),
                                                    (__bridge CFStringRef)identifier,
                                                    NULL, NULL,
                                                    0);
}

/** 接收到线程通知并执行回调 */
- (void)receiveForNotificationsWithIdentifier:(nullable NSString *)identifier
                                     observer:(id)observer {
    dispatch_semaphore_wait([YMThreadNotify share].semaphore, DISPATCH_TIME_FOREVER);
    NSArray<NSString *> *keyArray = [[[YMThreadNotify share].observerMapTable keyEnumerator] allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", identifier];
    NSArray<NSString *> *array = [keyArray filteredArrayUsingPredicate:predicate];
    for (NSString *key in array) {
        NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock"];
        
        id observer = [[YMThreadNotify share].observerMapTable objectForKey:key];
        NSMutableDictionary *blockDictionary = [[YMThreadNotify share].blockDictionaryMapTable objectForKey:observer];
        
        void(^block)(id observer) = [blockDictionary objectForKey:actionBlockKey];
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(observer);
            });
        }
    }
    dispatch_semaphore_signal([YMThreadNotify share].semaphore);
}

/** 接收到通知 */
void MyHoleNotificationCallback(CFNotificationCenterRef center,
                                   void * observer,
                                   CFStringRef name,
                                   void const * object,
                                   CFDictionaryRef userInfo) {
    NSString *identifier = (__bridge NSString *)name;
    NSObject *sender = (__bridge NSObject *)observer;
    [[YMThreadNotify share] receiveForNotificationsWithIdentifier:identifier observer:sender];
}

@end
