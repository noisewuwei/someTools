//
//  UIView+YMCustomView.h
//  YMCustomView
//
//  Created by 黄玉洲 on 2021/5/19.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (YMCustomView)

#pragma mark point
@property (assign, nonatomic) CGPoint origin;
@property (assign, nonatomic, readonly) CGPoint topLeft;
@property (assign, nonatomic, readonly) CGPoint topRight;
@property (assign, nonatomic, readonly) CGPoint bottomLeft;
@property (assign, nonatomic, readonly) CGPoint bottomRight;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@property (assign, nonatomic) CGFloat top;
@property (assign, nonatomic) CGFloat left;
@property (assign, nonatomic) CGFloat bottom;
@property (assign, nonatomic) CGFloat right;

@property (assign, nonatomic, readonly) CGFloat x;
@property (assign, nonatomic, readonly) CGFloat y;

#pragma mark size
@property (assign, nonatomic) CGSize  size;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat width;

@end

NS_ASSUME_NONNULL_END
