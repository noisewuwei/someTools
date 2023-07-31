//
//  YMNotifyTool.h
//  YM_Category
//
//  Created by 海南有趣 on 2020/5/18.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^YMNotifyToolActionBlock)(id observer, id object, NSDictionary * userInfo);

/// 所有响应block生命周期和观察者对象生命周期一样，一个对象多次添加同一类型或者同一标识符的观察者
/// 只会添加最后一次，响应的block回掉会随着观察者对象销毁自动销毁，建议使用枚举管理所有标识符
@interface YMNotifyTool : NSObject

/// 根据标识符添加观察者
/// 注意：在回调中使用self会导致强引用，导致无法释放。可添加weakSelf、strongSelf解决
/// @param observer 观察者
/// @param identifier 唯一标识
/// @param mainThread 首付在主线程上回调
/// @param actionBlock 监听响应
+ (void)addObserver:(id)observer
         identifier:(NSString *)identifier
         mainThread:(BOOL)mainThread
        actionBlock:(YMNotifyToolActionBlock)actionBlock;

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
        actionBlock:(YMNotifyToolActionBlock)actionBlock;

/// 根据标识符调用
/// @param identifier 标识符
/// @param object     数据
/// @param userInfo   数据
+ (void)postIdentifier:(NSString *)identifier
                object:(id)object
              userInfo:(NSDictionary *)userInfo;


/// 删除指定对象下的指定通知（一般情况下不需要调用，除非发生强引用导致内存无法释放）
/// @param observer 观察者
/// @param identifier 唯一标识
+ (void)removeObserver:(id)observer
            identifier:(NSString *)identifier;

/// 删除指定对象下的所有通知（一般情况下不需要调用，除非发生强引用导致内存无法释放）
/// @param observer 观察者
+ (void)removeObserver:(id)observer;



@end
