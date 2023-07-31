//
//  YM_DownScoreView.h
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_BifurcationModel.h"
/** 向下的比分图 */
@interface YM_DownScoreView : UIView

@property (strong, nonatomic) YM_BifurcationModel * model;

/**
 调整分数视图所在位置
 @param inCenter 分数视图是否在队伍的居中位置
 */
- (void)scoreLabInCenter:(BOOL)inCenter;


@end
