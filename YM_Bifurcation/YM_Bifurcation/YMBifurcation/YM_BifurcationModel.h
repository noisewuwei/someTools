//
//  YM_BifurcationModel.h
//  DS_Sports
//
//  Created by huangyuzhou on 2018/8/27.
//  Copyright © 2018年 companyName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YM_BifurcationModel : NSObject

/** 左边队伍信息 */
@property (copy, nonatomic) NSString * left_TeamID;
@property (copy, nonatomic) NSString * left_TeamLogo;
@property (copy, nonatomic) NSString * left_TeamName;

/** 右边队伍信息 */
@property (copy, nonatomic) NSString * right_TeamID;
@property (copy, nonatomic) NSString * right_TeamLogo;
@property (copy, nonatomic) NSString * right_TeamName;

/** 分数 */
@property (copy, nonatomic) NSString * score;

/** 开始 日期+时间（2018-09-17 16:00:00） */
@property (copy, nonatomic) NSString * date;

/** 竞赛ID */
@property (copy, nonatomic) NSString * match_id;

/** 左边队伍胜利 */
@property (assign, nonatomic) BOOL leftWin;

@end
