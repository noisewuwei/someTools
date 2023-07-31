//
//  YM_DownScoreView.m
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DownScoreView.h"
#import "YM_DownBifurcationView.h"
#import "YM_TeamView.h"
#import "YM_BifurcationConfig.h"
#import <Masonry/Masonry.h>
@interface YM_DownScoreView ()
{
    BOOL _scoreInTeamCenter;
}

@property (strong, nonatomic) YM_DownBifurcationView * bifurcationView;

/** 左侧队伍 */
@property (strong, nonatomic) YM_TeamView * leftTeamView;

/** 右侧队伍 */
@property (strong, nonatomic) YM_TeamView * rightTeamView;

/** 分数 */
@property (strong, nonatomic) UILabel * scoreLab;
@end

@implementation YM_DownScoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self layoutView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

/** 界面完成加载后 进行布局 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 分叉图
    [_bifurcationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self).multipliedBy(0.5);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(_leftTeamView.mas_top).offset(-5);
        make.top.mas_equalTo(0);
    }];
    
    // 左侧队伍
    [_leftTeamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(self.bounds.size.height / 2.0 + 5);
    }];
    
    // 右侧队伍
    [_rightTeamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_centerX);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(_leftTeamView);
    }];
    
    // 分数
    [_scoreLab mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_scoreInTeamCenter) {
            make.top.mas_equalTo(_leftTeamView.mas_top).offset(5);
        } else {
            make.centerY.mas_equalTo(_bifurcationView.mas_centerY).offset(10);
        }
        make.left.mas_equalTo(_bifurcationView.mas_left);
        make.right.mas_equalTo(_bifurcationView.mas_right);
        make.height.mas_equalTo(20);
    }];
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    // 分叉图
    [self addSubview:self.bifurcationView];
    
    // 左侧队伍
    [self addSubview:self.leftTeamView];
    
    // 右侧队伍
    [self addSubview:self.rightTeamView];
    
    // 分数
    [self addSubview:self.scoreLab];
}

#pragma mark - public
/**
 调整分数视图所在位置
 @param inCenter 分数视图是否在队伍的居中位置
 */
- (void)scoreLabInCenter:(BOOL)inCenter {
    _scoreInTeamCenter = inCenter;
}

#pragma mark - 手势
/**
 跳转比赛详情
 @param recognize 手势
 */
- (void)tapAction:(UITapGestureRecognizer *)recognize {
    [[NSNotificationCenter defaultCenter] postNotificationName:Match_Tap_Notify object:_model.match_id];
}

#pragma mark - setter
- (void)setModel:(YM_BifurcationModel *)model {
    if (model) {
        _model = model;
        [_leftTeamView setTeamID:model.left_TeamID
                        teamLogo:model.left_TeamLogo
                        teamName:model.left_TeamName];
        [_rightTeamView setTeamID:model.right_TeamID
                         teamLogo:model.right_TeamLogo
                         teamName:model.right_TeamName];
        _scoreLab.text = model.score;
        _bifurcationView.leftWin = model.leftWin;
    }
}

#pragma mark - 懒加载
- (YM_DownBifurcationView *)bifurcationView {
    if (!_bifurcationView) {
        _bifurcationView = [YM_DownBifurcationView new];
    }
    return _bifurcationView;
}

- (YM_TeamView *)leftTeamView {
    if (!_leftTeamView) {
        _leftTeamView = [YM_TeamView new];
    }
    return _leftTeamView;
}

- (YM_TeamView *)rightTeamView {
    if (!_rightTeamView) {
        _rightTeamView = [YM_TeamView new];
    }
    return _rightTeamView;
}

- (UILabel *)scoreLab {
    if (!_scoreLab) {
        _scoreLab = [UILabel new];
        _scoreLab.textAlignment = NSTextAlignmentCenter;
        _scoreLab.font = [UIFont systemFontOfSize:Screen_Ratio(12.0f)];
        _scoreLab.textColor = score_Color;
    }
    return _scoreLab;
}


@end
