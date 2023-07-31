//
//  UIGestureRecognizer+YMCategory.m
//  ToDesk-iOS
//
//  Created by 海南有趣 on 2020/6/16.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "UIGestureRecognizer+YMCategory.h"
#import "NSObject+YMCategory.h"
#pragma mark - UIGestureRecognizer (YMCategory)
@implementation UIGestureRecognizer (YMCategory)

#pragma mark public
/// 在手势触发过程中，中断这个手势
- (void)cancel {
    self.state = UIGestureRecognizerStateCancelled;
}

#pragma mark getter/setter
static char kGestureType;
- (NSInteger)gestureType {
    return [self.getProperty(&kGestureType) integerValue];
}

- (void)setGestureType:(NSInteger)gestureType {
    self.setProperty(&kGestureType, @(gestureType));
}

@end

#pragma mark - UIPanGestureRecognizer (YMCategory)
@implementation UIPanGestureRecognizer (YMCategory)
@dynamic gestureType;

static char kPanGestureBlockKey;
- (instancetype)initWithType:(kPanGesture)type block:(kPanGestureBlock)block {
    if (self = [super init]) {
        if (block) {
            self.setProperty(&kPanGestureBlockKey, block);
        }
        self.gestureType = type;
        [self config:type];
        [self addTarget:self action:@selector(panAction:)];
    }
    return self;
}

- (void)panAction:(UIPanGestureRecognizer *)recognize {
    if (recognize.state == UIGestureRecognizerStateBegan) {
        self.lastOffsetX = 0;
        self.lastOffsetY = 0;
    }
    
    kPanGestureBlock block = self.getProperty(&kPanGestureBlockKey);
    if (block) {
        block(self.gestureType, recognize);
    }
}

/// 根据点击类型进行配置
/// @param tapType 点击类型
- (void)config:(kPanGesture)tapType {
    switch (tapType) {
        case kPanGesture_Single:
            self.minimumNumberOfTouches = 1;
            self.maximumNumberOfTouches = 1;
            break;
        case kPanGesture_Double:
            self.minimumNumberOfTouches = 2;
            self.maximumNumberOfTouches = 2;
            break;
        case kPanGesture_Three:
            self.minimumNumberOfTouches = 3;
            self.maximumNumberOfTouches = 3;
            break;
        default:
            break;
    }
}

#pragma mark public
- (kPanDirect)panDirect {
    return [self panDirectWithView:self.view];
}

- (kPanDirect)panDirectWithView:(UIView *)view {
    return [self panDirectWithView:view offset:2];
}

- (kPanDirect)panDirectWithView:(UIView *)view offset:(CGFloat)offset {
    CGPoint point = [self translationInView:view];
    CGFloat absX = fabs(point.x);
    CGFloat absY = fabs(point.y);
    // 设置滑动有效距离
    if (MAX(absX, absY) < offset)
        return kPanDirect_Not;
    
    // 发生滚动
    if (absX > absY) {
        BOOL isLeft = point.x > self.lastOffsetX;
        self.lastOffsetX = point.x;
        return isLeft ? kPanDirect_Left : kPanDirect_Right;
    } else if (absY > absX) {
        BOOL isUp = point.y < self.lastOffsetY;
        self.lastOffsetY = point.y;
        return isUp ? kPanDirect_Up : kPanDirect_Down;
    }
    
    return kPanDirect_Not;
}

static char kLastOffsetX;
- (CGFloat)lastOffsetX {
    return [self.getProperty(&kLastOffsetX) floatValue];
}

- (void)setLastOffsetX:(CGFloat)lastOffsetX {
    self.setProperty(&kLastOffsetX, @(lastOffsetX));
}

static char kLastOffsetY;
- (CGFloat)lastOffsetY {
    return [self.getProperty(&kLastOffsetY) floatValue];
}

- (void)setLastOffsetY:(CGFloat)lastOffsetY {
    self.setProperty(&kLastOffsetY, @(lastOffsetY));
}

@end

#pragma mark - UITapGestureRecognizer (YMCategory)
@implementation UITapGestureRecognizer (YMCategory)
@dynamic gestureType;

static char kTapGestureBlockKey;
- (instancetype)initWithType:(kTapGesture)type block:(kTapGestureBlock)block {
    if (self = [super init]) {
        if (block) {
            self.setProperty(&kTapGestureBlockKey, block);
        }
        self.gestureType = type;
        [self config:type];
        [self addTarget:self action:@selector(tapAction:)];
    }
    return self;
}

- (void)tapAction:(UITapGestureRecognizer *)recognize {
    kTapGestureBlock block = self.getProperty(&kTapGestureBlockKey);
    if (block) {
        block(self.gestureType, recognize);
    }
}

/// 根据点击类型进行配置
/// @param tapType 点击类型
- (void)config:(kTapGesture)tapType {
    switch (tapType) {
        case kTapGesture_Click:
            self.numberOfTapsRequired = 1;    // 点击次数
            self.numberOfTouchesRequired = 1; // 所需手指数
            break;
        case kTapGesture_DoubleClick:
            self.numberOfTapsRequired = 2;
            self.numberOfTouchesRequired = 1;
            break;
        case kTapGesture_DoubleRefers:
            self.numberOfTapsRequired = 1;
            self.numberOfTouchesRequired = 2;
            break;
        case kTapGesture_ThreeRefers:
            self.numberOfTapsRequired = 1;
            self.numberOfTouchesRequired = 3;
            break;
        default:
            break;
    }
}

#pragma mark public

@end


#pragma mark - UILongPressGestureRecognizer (YMCategory)
@implementation UILongPressGestureRecognizer (YMCategory)
@dynamic gestureType;

static char kLongGestureBlockKey;
- (instancetype)initWithType:(kLongGesture)type block:(kLongGestureBlock)block {
    if (self = [super init]) {
        if (block) {
            self.setProperty(&kLongGestureBlockKey, block);
        }
        self.gestureType = type;
        [self config:type];
        [self addTarget:self action:@selector(longAction:)];
    }
    return self;
}

- (void)longAction:(UILongPressGestureRecognizer *)recognize {
    kLongGestureBlock block = self.getProperty(&kLongGestureBlockKey);
    if (block) {
        block(self.gestureType, recognize);
    }
}

/// 根据点击类型进行配置
/// @param tapType 点击类型
- (void)config:(kLongGesture)tapType {
    self.numberOfTapsRequired = 0;
    switch (tapType) {
        case kLongGesture_Single:
            self.numberOfTouchesRequired = 1;
            break;
        case kLongGesture_Double:
            self.numberOfTouchesRequired = 2;
            break;
        default:
            break;
    }
}

#pragma mark public

@end


#pragma mark - UISwipeGestureRecognizer (YMCategory)
@implementation UISwipeGestureRecognizer (YMCategory)
@dynamic gestureType;

static char kSwipeGestureBlockKey;
- (instancetype)initWithType:(kSwipeGesture)type block:(kSwipeGestureBlock)block {
    if (self = [super init]) {
        if (block) {
            self.setProperty(&kSwipeGestureBlockKey, block);
        }
        self.gestureType = type;
        [self config:type];
        [self addTarget:self action:@selector(swipeAction:)];
    }
    return self;
}

- (void)swipeAction:(UISwipeGestureRecognizer *)recognize {
    kSwipeGestureBlock block = self.getProperty(&kSwipeGestureBlockKey);
    if (block) {
        block(self.gestureType, recognize);
    }
}

/// 根据点击类型进行配置
/// @param tapType 点击类型
- (void)config:(kSwipeGesture)tapType {
    switch (tapType) {
        case kSwipeGesture_Single:
            self.numberOfTouchesRequired = 1;
            break;
        case kSwipeGesture_Double:
            self.numberOfTouchesRequired = 2;
            break;
        default:
            break;
    }
}

#pragma mark public

@end
