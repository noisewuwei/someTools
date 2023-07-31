//
//  YMNotifyTool.m
//  YM_Category
//
//  Created by 海南有趣 on 2020/5/18.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//


#import "YMNotifyTool.h"

@interface YMNotifyTool ()

@property (nonatomic, strong) NSMapTable * observerMapTable;
@property (nonatomic, strong) NSMapTable * blockDictionaryMapTable;
@property (nonatomic, strong) NSMapTable * mainThreadDictionaryMapTable;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation YMNotifyTool

static YMNotifyTool * instance = nil;
+ (instancetype)defaltTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [YMNotifyTool new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _observerMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        _blockDictionaryMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        _mainThreadDictionaryMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        _semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_signal(_semaphore);
    }
    return self;
}

/// 根据标识符添加观察者
/// 注意：在回调中使用self会导致强引用，导致无法释放。可添加weakSelf、strongSelf解决
/// @param observer 观察者
/// @param identifier 唯一标识
/// @param mainThread 首付在主线程上回调
/// @param actionBlock 监听响应
+ (void)addObserver:(id)observer
         identifier:(NSString *)identifier
         mainThread:(BOOL)mainThread
        actionBlock:(YMNotifyToolActionBlock)actionBlock {
    [self addObserver:observer objc:nil identifier:identifier mainThread:mainThread actionBlock:actionBlock];
}

/// 根据标识符添加观察者
/// 注意：在回调中使用self会导致强引用，导致无法释放。可添加weakSelf、strongSelf解决
/// @param observer 观察者
/// @param objc 要携带的数据
/// @param identifier 唯一标识
/// @param mainThread 首付在主线程上回调
/// @param actionBlock 监听响应
+ (void)addObserver:(id)observer
               objc:(id)objc
         identifier:(NSString *)identifier
         mainThread:(BOOL)mainThread
        actionBlock:(YMNotifyToolActionBlock)actionBlock {
    dispatch_semaphore_wait([YMNotifyTool defaltTool].semaphore, DISPATCH_TIME_FOREVER);
    
    // 注册通知
    [[self defaltTool] registerNotify:identifier object:objc];
    
    // 观察者数据
    NSString * key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], identifier];
    [[YMNotifyTool defaltTool].observerMapTable setObject:observer forKey:key];
    
    // block数据
    NSString * blockKey = [key stringByAppendingString:@"-blockKey"];
    NSMutableDictionary *blockDictionary = [[YMNotifyTool defaltTool].blockDictionaryMapTable objectForKey:observer];
    if (!blockDictionary) {
        blockDictionary = [NSMutableDictionary dictionary];
    }
    [blockDictionary setObject:actionBlock forKey:blockKey];
    [[YMNotifyTool defaltTool].blockDictionaryMapTable setObject:blockDictionary forKey:observer];
    
    // 线程数据
    NSString * mainThreadKey = [key stringByAppendingString:@"-mainThreadKey"];
    NSMutableDictionary *mainThreadDictionary = [[YMNotifyTool defaltTool].mainThreadDictionaryMapTable objectForKey:observer];
    if (!mainThreadDictionary) {
        mainThreadDictionary = [NSMutableDictionary dictionary];
    }
    [mainThreadDictionary setObject:[NSNumber numberWithBool:mainThread] forKey:mainThreadKey];
    [[YMNotifyTool defaltTool].mainThreadDictionaryMapTable setObject:mainThreadDictionary forKey:observer];
    
    dispatch_semaphore_signal([YMNotifyTool defaltTool].semaphore);
}

/// 根据标识符调用
/// @param identifier 标识符
/// @param object     数据
/// @param userInfo   数据
+ (void)postIdentifier:(NSString *)identifier
                object:(id)object
              userInfo:(NSDictionary *)userInfo {
    dispatch_semaphore_wait([YMNotifyTool defaltTool].semaphore, DISPATCH_TIME_FOREVER);
    NSArray<NSString *> *keyArray = [[[YMNotifyTool defaltTool].observerMapTable keyEnumerator] allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", identifier];
    NSArray<NSString *> *array = [keyArray filteredArrayUsingPredicate:predicate];
    for (NSString *key in array) {
        id observer = [[YMNotifyTool defaltTool].observerMapTable objectForKey:key];
        
        // block数据
        NSString * blockKey = [key stringByAppendingString:@"-blockKey"];
        NSMutableDictionary * blockDictionary = [[YMNotifyTool defaltTool].blockDictionaryMapTable objectForKey:observer];
        YMNotifyToolActionBlock block = [blockDictionary objectForKey:blockKey];
        
        // 线程数据
        NSString * mainThreadKey = [key stringByAppendingString:@"-mainThreadKey"];
        NSMutableDictionary *mainThreadDictionary = [[YMNotifyTool defaltTool].mainThreadDictionaryMapTable objectForKey:observer];
        BOOL mainThread = [[mainThreadDictionary objectForKey:mainThreadKey] boolValue];
        
        // 执行回调
        if (block) {
            if (mainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(observer, object, userInfo);
                });
            }else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    block(observer, object, userInfo);
                });
            }
        }
    }
    dispatch_semaphore_signal([YMNotifyTool defaltTool].semaphore);
}

/// 删除指定对象下的指定通知（一般情况下不需要调用，除非发生强引用导致内存无法释放）
/// @param observer 观察者
/// @param identifier 唯一标识
+ (void)removeObserver:(id)observer
            identifier:(NSString *)identifier {
    dispatch_semaphore_wait([YMNotifyTool defaltTool].semaphore, DISPATCH_TIME_FOREVER);
    
    // 观察者数据
    NSString * key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], identifier];
    [[YMNotifyTool defaltTool].observerMapTable removeObjectForKey:key];
    
    // 回调数据
    NSString * blockKey = [key stringByAppendingString:@"-blockKey"];
    NSMutableDictionary *blockDictionary = [[YMNotifyTool defaltTool].blockDictionaryMapTable objectForKey:observer];
    [blockDictionary removeObjectForKey:blockKey];
    [[YMNotifyTool defaltTool].blockDictionaryMapTable setObject:blockDictionary forKey:observer];
    
    // 线程数据
    NSString * mainThreadKey = [key stringByAppendingString:@"-mainThreadKey"];
    NSMutableDictionary * mainThreadDictionary = [[YMNotifyTool defaltTool].mainThreadDictionaryMapTable objectForKey:observer];
    [mainThreadDictionary removeObjectForKey:mainThreadKey];
    [[YMNotifyTool defaltTool].mainThreadDictionaryMapTable setObject:mainThreadDictionary forKey:observer];
    
    dispatch_semaphore_signal([YMNotifyTool defaltTool].semaphore);
}

/// 删除指定对象下的所有通知（一般情况下不需要调用，除非发生强引用导致内存无法释放）
/// @param observer 观察者
+ (void)removeObserver:(id)observer {
    dispatch_semaphore_wait([YMNotifyTool defaltTool].semaphore, DISPATCH_TIME_FOREVER);
    
    // 观察者数据
    NSString * prefixKey = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%p",observer]];
    NSMutableArray * keys = [NSMutableArray array];
    NSArray * allKeys = [[[YMNotifyTool defaltTool].observerMapTable keyEnumerator] allObjects];
    for (NSString * key in allKeys) {
        if ([key containsString:prefixKey]) {
            [keys addObject:key];
        }
    }
    for (NSString * key in keys) {
        [[YMNotifyTool defaltTool].observerMapTable removeObjectForKey:key];
    }
    
    [[YMNotifyTool defaltTool].blockDictionaryMapTable removeObjectForKey:observer];
    [[YMNotifyTool defaltTool].mainThreadDictionaryMapTable removeObjectForKey:observer];
    
    dispatch_semaphore_signal([YMNotifyTool defaltTool].semaphore);
}

#pragma mark - 系统通知
- (void)registerNotify:(NSString *)notifyIdentity object:(id)object {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notifyIdentity object:object];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyAction:)
                                                 name:notifyIdentity
                                               object:object];
}

- (void)notifyAction:(NSNotification *)notify {
    [[self class] postIdentifier:notify.name object:notify.object userInfo:notify.userInfo];
}


@end
