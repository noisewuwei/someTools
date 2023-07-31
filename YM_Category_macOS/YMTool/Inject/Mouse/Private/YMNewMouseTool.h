//
//  YMNewMouseTool.h
//  YM_Category_macOS
//
//  Created by 黄玉洲 on 2021/12/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YMMouseBaseTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMNewMouseTool : YMMouseBaseTool

+ (instancetype)share;

- (void)newPostMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point deltax:(int32_t)deltax deltay:(int32_t)deltay;

- (void)newPostMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
