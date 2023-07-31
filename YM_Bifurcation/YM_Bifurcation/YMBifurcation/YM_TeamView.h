//
//  YM_TeamView.h
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YM_TeamView : UIView

/**
 设置数据
 @param teamID   队伍ID
 @param teamLogo 队伍logo
 @param teamName 队伍名
 */
- (void)setTeamID:(NSString *)teamID
         teamLogo:(NSString *)teamLogo
         teamName:(NSString *)teamName;

@end
