//
//  CABasicAnimation+YMCategory.h
//  youqu
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kRotationCoordinate) {
    /** X轴旋转 */
    kRotationCoordinate_X,
    /** Y轴旋转 */
    kRotationCoordinate_Y,
    /** Z轴旋转 */
    kRotationCoordinate_Z,
};

@interface CABasicAnimation (YMCategory)

/**
 便利构造旋转动画
 
 @param type 旋转轴
 @param fromValue 旋转开始角度
 @param toValue 旋转结束角度
 @param duration 时长
 @param fillMode 动画类型
 @param repeatCount 重复次数
 @return CABasicAnimation
 */
+ (CABasicAnimation *)ymRotationWithType:(kRotationCoordinate)type
                               fromValue:(id)fromValue
                                 toValue:(id)toValue
                                duration:(CFTimeInterval)duration
                                fillMode:(CAMediaTimingFillMode)fillMode
                             repeatCount:(NSInteger)repeatCount;

#pragma mark - 操作

@end

NS_ASSUME_NONNULL_END
