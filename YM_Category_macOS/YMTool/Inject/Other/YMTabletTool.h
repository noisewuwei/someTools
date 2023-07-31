//
//  YMTabletTool.h
//  YMTool
//
//  Created by zuler on 2022/8/1.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 数位板注入
@interface YMTabletTool : NSObject

+ (instancetype)share;

- (void)postMouseAction:(int)status point:(CGPoint)point;

- (void)postMouseMovePoint:(CGPoint)point;

- (void)postTabletProximity:(int)value penType:(int)type vendorType:(int)vendorpointertype mask:(int)capabilitymask;

- (void)postTabletPenEventPoint:(CGPoint)point pressure:(double)pressure retation:(double)rotation tiltx:(double)tiltx tilty:(double)tilty;

@end

NS_ASSUME_NONNULL_END
