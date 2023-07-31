//
//  CABasicAnimation+YMCategory.m
//  youqu
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import "CABasicAnimation+YMCategory.h"

@implementation CABasicAnimation (YMCategory)

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
                             repeatCount:(NSInteger)repeatCount {
    NSString * property = @"";
    switch (type) {
        case kRotationCoordinate_X: property = @"transform.rotation.x"; break;
        case kRotationCoordinate_Y: property = @"transform.rotation.y"; break;
        case kRotationCoordinate_Z: property = @"transform.rotation.z"; break;
            
        default:
            break;
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:property];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.autoreverses = NO;
    animation.fillMode = fillMode;
    //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    animation.repeatCount = repeatCount;
    // 动画结束是否恢复
    animation.removedOnCompletion = NO;
    return animation;
}

@end
