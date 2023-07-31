//
//  YM_PromotionView.h
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_UpwardBifurcationView.h"
//#import "DSDataIntegralListModel.h"
@interface YM_PromotionView : UIView

/** 世界杯赛况树形图 */
//@property (strong, nonatomic) DSDataIntegralRoundsModel * model;

/** 视图高度 */
- (CGFloat)sumHeight;

/** 队伍详情 */
@property (copy, nonatomic) void(^teamDetailBlock)(NSString * teamID);

/** 比赛详情 */
@property (copy, nonatomic) void(^matchDetailBlock)(NSString * matchID);

@end
