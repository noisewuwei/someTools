//
//
// YM_BifurcationConfig.h
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#ifndef BifurcationConfig_h
#define BifurcationConfig_h

#define deselect_Color [UIColor purpleColor]
#define selected_Color [UIColor greenColor]

#define teamName_Color [UIColor redColor]
#define score_Color    [UIColor redColor]

#define Screen_Ratio(m) m * Screen_Width
#define Screen_Width  Realy_WIDTH / 375.0
#define Realy_WIDTH ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height)

/** 球队点击通知 */
#define Team_Tap_Notify  @"Team_Tap_Notify"

/** 比赛点击通知 */
#define Match_Tap_Notify @"Match_Tap_Notify"

#endif /* BifurcationConfig_h */
