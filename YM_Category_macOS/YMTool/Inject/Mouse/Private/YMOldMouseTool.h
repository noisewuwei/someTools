//
//  YMOldMouseTool.h
//  YM_Category_macOS
//
//  Created by 黄玉洲 on 2021/12/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YMMouseBaseTool.h"
#import "YMMouseHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface YMOldMouseTool : YMMouseBaseTool

+ (instancetype)share;

/// 旧版API接口
/// @param mouseBtn 按钮类型
/// @param point 坐标
- (void)oldPostMouseEvent:(YMMouseButton)mouseBtn point:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
