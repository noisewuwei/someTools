//
//  YM_PromotionView.m
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PromotionView.h"
#import "YM_UpwardScoreView.h"
#import "YM_DownScoreView.h"
#import "YM_FinalsView.h"
#import "YM_BifurcationConfig.h"
#import "YM_TeamView.h"
#import "YM_BifurcationModel.h"
#import <Masonry/Masonry.h>
@interface YM_PromotionView ()
{
    CGFloat _sumHeight;
//    NSMutableArray <DSDataIntegralContentDataModel *> * _datas;
}
@end

@implementation YM_PromotionView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self registerNotify];
        [self layoutView];
    }
    return self;
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width / 4.0;
    CGFloat height = Screen_Ratio(80);
    YM_UpwardScoreView * view1 = [YM_UpwardScoreView new];
    view1.model = [self testModel];
    [self addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];
    
    YM_UpwardScoreView * view2 = [YM_UpwardScoreView new];
    view2.model = [self testModel];
    [self addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view1.mas_right);
        make.top.mas_equalTo(view1);
        make.size.mas_equalTo(view1);
    }];
    
    YM_UpwardScoreView * view3 = [YM_UpwardScoreView new];
    view3.model = [self testModel];
    [self addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view2.mas_right);
        make.top.mas_equalTo(view1);
        make.size.mas_equalTo(view1);
    }];
    
    YM_UpwardScoreView * view4 = [YM_UpwardScoreView new];
    view4.model = [self testModel];
    [self addSubview:view4];
    [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view3.mas_right);
        make.top.mas_equalTo(view1);
        make.size.mas_equalTo(view1);
    }];
    
    width = [[UIScreen mainScreen] bounds].size.width / 2.0;
    YM_UpwardScoreView * view5 = [YM_UpwardScoreView new];
    view5.model = [self testModel];
    [view5 scoreLabInCenter:YES];
    [self addSubview:view5];
    [view5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(view1.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];
    
    YM_UpwardScoreView * view6 = [YM_UpwardScoreView new];
    [view6 scoreLabInCenter:YES];
    view6.model = [self testModel];
    [self addSubview:view6];
    [view6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view5.mas_right);
        make.top.mas_equalTo(view1.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];
    
    width = [[UIScreen mainScreen] bounds].size.width;
    YM_UpwardScoreView * view7 = [YM_UpwardScoreView new];
    [view7 scoreLabInCenter:YES];
    view7.model = [self testModel];
    [self addSubview:view7];
    [view7 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(view6.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];
    
    
    YM_FinalsView * finalsView = [YM_FinalsView new];
    finalsView.model = [self testModel];
    [self addSubview:finalsView];
    [finalsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(view7.mas_bottom);
        make.height.mas_equalTo(Screen_Ratio(90));
    }];
    
    YM_DownScoreView * view8 = [YM_DownScoreView new];
    [view8 scoreLabInCenter:YES];
    view8.model = [self testModel];
    [self addSubview:view8];
    [view8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(finalsView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];
    
    width = [[UIScreen mainScreen] bounds].size.width / 2.0;
    YM_DownScoreView * view9 = [YM_DownScoreView new];
    view9.model = [self testModel];
    [view9 scoreLabInCenter:YES];
    [self addSubview:view9];
    [view9 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(view8.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];
    
    YM_DownScoreView * view10 = [YM_DownScoreView new];
    [view10 scoreLabInCenter:YES];
    view10.model = [self testModel];
    [self addSubview:view10];
    [view10 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view9.mas_right);
        make.top.mas_equalTo(view8.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];
    
    width = [[UIScreen mainScreen] bounds].size.width / 4.0;
    YM_DownScoreView * view11 = [YM_DownScoreView new];
    view11.model = [self testModel];
    [self addSubview:view11];
    [view11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(view10.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];
    
    YM_DownScoreView * view12 = [YM_DownScoreView new];
    view12.model = [self testModel];
    [self addSubview:view12];
    [view12 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view11.mas_right);
        make.top.mas_equalTo(view11);
        make.size.mas_equalTo(view11);
    }];
    
    YM_DownScoreView * view13 = [YM_DownScoreView new];
    view13.model = [self testModel];
    [self addSubview:view13];
    [view13 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view12.mas_right);
        make.top.mas_equalTo(view11);
        make.size.mas_equalTo(view11);
    }];
    
    YM_DownScoreView * view14 = [YM_DownScoreView new];
    view14.model = [self testModel];
    [self addSubview:view14];
    [view14 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view13.mas_right);
        make.top.mas_equalTo(view11);
        make.size.mas_equalTo(view11);
    }];
    
    [self layoutIfNeeded];
    _sumHeight = view14.frame.origin.y + view14.frame.size.height;
}

#pragma mark - 通知
/** 注册通知 */
- (void)registerNotify {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(matchDetailNotify:)
                                                 name:Match_Tap_Notify
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(teamDetailNotify:)
                                                 name:Team_Tap_Notify
                                               object:nil];
}

- (void)matchDetailNotify:(NSNotification *)notify {
    NSString * matchID = notify.object;
    if (self.matchDetailBlock) {
        self.matchDetailBlock(matchID);
    }
}

- (void)teamDetailNotify:(NSNotification *)notify {
    NSString * teamID = notify.object;
    if (self.teamDetailBlock) {
        self.teamDetailBlock(teamID);
    }
}

#pragma mark - public
/** 视图高度 */
- (CGFloat)sumHeight {
    return _sumHeight;
}

#pragma mark - setter
//- (void)setModel:(DSDataIntegralRoundsModel *)model {
//    if (model) {
//        _model = model;
//        _datas = model.content.data;
//        [self layoutView];
//    }
//}

#pragma mark - private
/**
 获取比分图模型
 @param model 数据来源
 @return 比分图模型
 */
//- (YM_BifurcationModel *)modelWithData:(DSDataIntegralContentDataModel *)model {
//    YM_BifurcationModel * bifurcationModel = [YM_BifurcationModel new];
//    bifurcationModel.left_TeamID = model.team_A_id;
//    bifurcationModel.left_TeamName = model.team_A_name;
//    bifurcationModel.left_TeamLogo = model.team_A_logo;
//
//    bifurcationModel.right_TeamID = model.team_B_id;
//    bifurcationModel.right_TeamName = model.team_B_name;
//    bifurcationModel.right_TeamLogo = model.team_B_logo;
//
//    bifurcationModel.score = [NSString stringWithFormat:@"%@:%@", model.fs_A, model.fs_B];
//
//    bifurcationModel.date = model.start_play;
//
//    return bifurcationModel;
//}

/**
 测试数据
 @return 比分图模型
 */
- (YM_BifurcationModel *)testModel {
    YM_BifurcationModel * bifurcationModel = [YM_BifurcationModel new];
    bifurcationModel.left_TeamID = @"1";
    bifurcationModel.left_TeamName = @"法国";
    bifurcationModel.left_TeamLogo = @"https://img.dongqiudi.com/data/pic/2300.png";
    
    bifurcationModel.right_TeamID = @"2";
    bifurcationModel.right_TeamName = @"克罗地亚";
    bifurcationModel.right_TeamLogo = @"https://img.dongqiudi.com/data/pic/1772.png";
    
    bifurcationModel.score = [NSString stringWithFormat:@"4:2"];
    
    bifurcationModel.date = @"2018-07-15 15:00:00";
    
    bifurcationModel.leftWin = arc4random() % 2 == 1 ? YES : NO;
    
    return bifurcationModel;
}



@end
