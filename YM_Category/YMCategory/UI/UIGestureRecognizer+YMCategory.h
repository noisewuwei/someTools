//
//  UIGestureRecognizer+YMCategory.h
//  ToDesk-iOS
//
//  Created by 海南有趣 on 2020/6/16.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


#pragma mark - UIGestureRecognizer (YMCategory)
@interface UIGestureRecognizer (YMCategory)

#pragma mark public
/// 在手势触发过程中，中断这个手势
- (void)cancel;

@end

#pragma mark - UIPanGestureRecognizer (YMCategory)
typedef NS_ENUM(NSInteger, kPanGesture) {
    /// 单指拖拽
    kPanGesture_Single,
    /// 双指拖拽
    kPanGesture_Double,
    /// 三指拖拽
    kPanGesture_Three,
};
typedef NS_ENUM(NSInteger, kPanDirect) {
    /// 未滑动
    kPanDirect_Not,
    /// 左滑
    kPanDirect_Left,
    /// 右滑
    kPanDirect_Right,
    /// 上滑
    kPanDirect_Up,
    /// 下滑
    kPanDirect_Down
};
typedef void (^kPanGestureBlock)(kPanGesture type, UIPanGestureRecognizer * recognizer);
@interface UIPanGestureRecognizer (YMCategory)

- (instancetype)initWithType:(kPanGesture)type block:(kPanGestureBlock)block;

@property (assign, nonatomic, readonly) kPanGesture gestureType;

#pragma mark public
/// 获取当前手势所在的视图上的滑动方向
- (kPanDirect)panDirect;

/// 获取当前手势在指定视图上的滑动方向（offset默认为2）
/// @param view 指定视图
- (kPanDirect)panDirectWithView:(UIView *)view;

/// 获取当前手势在指定视图上的滑动方向
/// @param view 指定视图
/// @param offset 最小偏移量（如果小于这个数值，则判断为未进行滑动）
- (kPanDirect)panDirectWithView:(UIView *)view offset:(CGFloat)offset;

@end

#pragma mark - UITapGestureRecognizer (YMCategory)
typedef NS_ENUM(NSInteger, kTapGesture) {
    /// 单击
    kTapGesture_Click,
    /// 双击
    kTapGesture_DoubleClick,
    /// 双指
    kTapGesture_DoubleRefers,
    /// 三指
    kTapGesture_ThreeRefers,
};
typedef void (^kTapGestureBlock)(kTapGesture type, UITapGestureRecognizer * recognizer);
@interface UITapGestureRecognizer (YMCategory)

- (instancetype)initWithType:(kTapGesture)type block:(kTapGestureBlock)block;

@property (assign, nonatomic, readonly) kTapGesture gestureType;

@end

#pragma mark - UILongPressGestureRecognizer (YMCategory)
typedef NS_ENUM(NSInteger, kLongGesture) {
    /// 单指
    kLongGesture_Single,
    /// 双指
    kLongGesture_Double,
};
typedef void (^kLongGestureBlock)(kLongGesture type, UILongPressGestureRecognizer * recognizer);
@interface UILongPressGestureRecognizer (YMCategory)

- (instancetype)initWithType:(kLongGesture)type block:(kLongGestureBlock)block;

@property (assign, nonatomic, readonly) kLongGesture gestureType;

@end

#pragma mark - UISwipeGestureRecognizer (YMCategory)
typedef NS_ENUM(NSInteger, kSwipeGesture) {
    /// 单指
    kSwipeGesture_Single,
    /// 双指
    kSwipeGesture_Double,
};
typedef void (^kSwipeGestureBlock)(kSwipeGesture type, UISwipeGestureRecognizer * recognizer);
@interface UISwipeGestureRecognizer (YMCategory)

- (instancetype)initWithType:(kSwipeGesture)type block:(kSwipeGestureBlock)block;

@property (assign, nonatomic, readonly) kSwipeGesture gestureType;

@end


NS_ASSUME_NONNULL_END
