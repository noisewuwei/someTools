//
//  NSObject+YMCategory.h
//  youqu
//
//  Created by 黄玉洲 on 2019/5/17.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#pragma mark - ======= NSObject (YMCategory) =======
@interface NSObject (YMCategory)

#pragma mark - 标记
@property (assign, nonatomic) NSInteger ymTag;

#pragma mark - 动态属性生成和获取
@property (copy, nonatomic, class) id (^setClassProperty)(char*, id value);
@property (copy, nonatomic, class) id (^getClassProperty)(char*);
@property (copy, nonatomic) id (^setProperty)(char*, id value);
@property (copy, nonatomic) id (^getProperty)(char*);

#pragma mark 同进程通知
/// 注册通知
/// @param notifyName 通知键
/// @param selector   回调方法
/// @param object     携带对象
- (void)registerNotify:(NSString *)notifyName selector:(SEL)selector object:(id)object;

/// 注册通知（有可能无法释放，需要手动释放，执行removeNotifyWithName:）
/// @param notifyName 通知键
/// @param queue 线程
/// @param selector 回调方法
- (void)registerNotify:(NSString *)notifyName queue:(NSOperationQueue *)queue selector:(SEL)selector;

/// 删除所有通知
- (void)removeNotify;

/// 删除指定通知
/// @param notifyName 通知键
- (void)removeNotifyWithName:(NSString *)notifyName;

/// 发送通知
/// @param notifyName 通知键
/// @param object 携带对象
/// @param userInfo 携带字典
- (void)postNotifyWithName:(NSString *)notifyName object:(id)object userInfo:(NSDictionary *)userInfo;

#pragma mark 进程间通知
/// 注册进程间通知
/// @param notifyName 通知名
/// @param callBack 回调
/// 如:void handle(CFNotificationCenterRef center, void * observer, CFStringRef name, void const * object, CFDictionaryRef userInfo)
- (void)registerProcessNotify:(NSString *)notifyName callback:(CFNotificationCallback)callBack;

/// 发送进程间通知
/// @param notifyName 通知名
- (void)postProcessNotify:(nullable NSString *)notifyName;

/// 删除进程间通知
/// @param notifyName 通知名
- (void)removeProcessNotify:(NSString * _Nullable)notifyName;


@end

#pragma mark - ======= NSObject (YMRuntimeCategory) =======
@interface NSObject (YMRuntimeCategory)

/** 获取所有key值 */
- (NSArray *)ymGetAllIvar;

/** 获得所有属性 */
- (NSArray *)ymGetAllProperty;

/// 获取实例方法
/// @param classObj 要检查的类
/// @param sel 要检索的方法的选择器
+ (Method)ymMethodOfInstanceWithClass:(Class _Nullable)classObj sel:(SEL _Nullable)sel;

/// 获取类方法
/// @param classObj 要检查的类
/// @param sel 要检索的方法的选择器
+ (Method)ymMethodOfClassWithClass:(Class _Nullable)classObj sel:(SEL _Nullable)sel;

/// 替换方法实现
/// @param method 要替换的方法实现
/// @param newMethod 新的方法实现
+ (void)ymExchangeImpOfMethod:(Method _Nullable)method newMethod:(Method _Nullable)newMethod;

/// 判断类是否实现某方法
/// @param classObj 要检查的类
/// @param sel 要检索的方法的选择器
+ (BOOL)ymRespondsSelector:(Class)classObj sel:(SEL)sel;

@end
