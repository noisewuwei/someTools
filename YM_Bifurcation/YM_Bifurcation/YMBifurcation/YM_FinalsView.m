//
//  YM_FinalsView.m
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_FinalsView.h"
#import "YM_TeamView.h"
#import <Masonry/Masonry.h>
#import "YM_BifurcationConfig.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface YM_FinalsView ()
/** 总决赛比分 */
@property (strong, nonatomic) UILabel * finalsScoreLab;

/** 左侧队伍 */
@property (strong, nonatomic) UIImageView * leftTeamLogo;
@property (strong, nonatomic) UILabel     * leftTeamNameLab;

/** 右侧队伍 */
@property (strong, nonatomic) UIImageView * rightTeamLogo;
@property (strong, nonatomic) UILabel     * rightTeamNameLab;

/** 时间 */
@property (strong, nonatomic) UILabel * dateLab;

@end

@implementation YM_FinalsView


- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self layoutView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    [self addSubview:self.finalsScoreLab];
    [_finalsScoreLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(Screen_Ratio(100));
        make.height.mas_equalTo(Screen_Ratio(40));
    }];
    
    [self addSubview:self.dateLab];
    [_dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_finalsScoreLab);
        make.width.mas_equalTo(_finalsScoreLab);
        make.top.mas_equalTo(_finalsScoreLab.mas_bottom);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.leftTeamLogo];
    [_leftTeamLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_finalsScoreLab.mas_left);
        make.width.mas_equalTo(self.mas_height).multipliedBy(0.7);
        make.centerY.mas_equalTo(_finalsScoreLab);
        make.height.mas_equalTo(self.mas_height).multipliedBy(0.5);
    }];
    
    [self addSubview:self.leftTeamNameLab];
    [_leftTeamNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_leftTeamLogo);
        make.top.mas_equalTo(_leftTeamLogo.mas_bottom);
    }];
    
    [self addSubview:self.rightTeamLogo];
    [_rightTeamLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_finalsScoreLab.mas_right);
        make.width.mas_equalTo(_leftTeamLogo);
        make.centerY.mas_equalTo(_finalsScoreLab);
        make.height.mas_equalTo(_leftTeamLogo);
    }];
    
    [self addSubview:self.rightTeamNameLab];
    [_rightTeamNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_rightTeamLogo);
        make.top.mas_equalTo(_rightTeamLogo.mas_bottom);
    }];
}

#pragma mark - 手势
/**
 跳转比赛详情
 @param recognize 手势
 */
- (void)tapAction:(UITapGestureRecognizer *)recognize {
    [[NSNotificationCenter defaultCenter] postNotificationName:Match_Tap_Notify object:_model.match_id];
}

/**
 左侧国标点击手势
 @param recognize 手势
 */
- (void)leftTapAction:(UITapGestureRecognizer *)recognize {
    [[NSNotificationCenter defaultCenter] postNotificationName:Team_Tap_Notify object:_model.left_TeamID];
}

/**
 右侧国标点击手势
 @param recognize 手势
 */
- (void)rightTapAction:(UITapGestureRecognizer *)recognize {
    [[NSNotificationCenter defaultCenter] postNotificationName:Team_Tap_Notify object:_model.right_TeamID];
}

#pragma mark - setter
- (void)setModel:(YM_BifurcationModel *)model {
    if (model) {
        _model = model;
        
        // 左侧队伍
        NSURL * a_logoURL = [NSURL URLWithString:model.left_TeamLogo];
        [_leftTeamLogo sd_setImageWithURL:a_logoURL];
        _leftTeamNameLab.text = model.left_TeamName;
 
        // 右侧队伍
        NSURL * b_logoURL = [NSURL URLWithString:model.right_TeamLogo];
        [_rightTeamLogo sd_setImageWithURL:b_logoURL];
        _rightTeamNameLab.text = model.right_TeamName;
        
        // 比分
        _finalsScoreLab.text = model.score;
        
        // 时间转化
        NSDateFormatter * dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * date = [dateFormatter dateFromString:model.date];
        NSTimeInterval time = date.timeIntervalSince1970 + 3600 * 8;
        
        date = [NSDate dateWithTimeIntervalSince1970:time];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        NSString * dateStr = [dateFormatter stringFromDate:date];
        _dateLab.text = dateStr;
    }
}

#pragma mark - 懒加载
- (UILabel *)finalsScoreLab {
    if (!_finalsScoreLab) {
        _finalsScoreLab = [UILabel new];
        _finalsScoreLab.font = [UIFont systemFontOfSize:Screen_Ratio(20.0f)];
        _finalsScoreLab.text = @"4:2";
        _finalsScoreLab.textAlignment = NSTextAlignmentCenter;
        _finalsScoreLab.textColor = score_Color;
    }
    return _finalsScoreLab;
}

- (UIImageView *)leftTeamLogo {
    if (!_leftTeamLogo) {
        _leftTeamLogo = [UIImageView new];
        _leftTeamLogo.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapAction:)];
        [_leftTeamLogo addGestureRecognizer:tap];
    }
    return _leftTeamLogo;
}

- (UILabel *)leftTeamNameLab {
    if (!_leftTeamNameLab) {
        _leftTeamNameLab = [UILabel new];
        _leftTeamNameLab.textAlignment = NSTextAlignmentCenter;
        _leftTeamNameLab.font = [UIFont systemFontOfSize:Screen_Ratio(14.0f)];
        _leftTeamNameLab.textColor = teamName_Color;
    }
    return _leftTeamNameLab;
}

- (UIImageView *)rightTeamLogo {
    if (!_rightTeamLogo) {
        _rightTeamLogo = [UIImageView new];
        _rightTeamLogo.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapAction:)];
        [_rightTeamLogo addGestureRecognizer:tap];
    }
    return _rightTeamLogo;
}

- (UILabel *)rightTeamNameLab {
    if (!_rightTeamNameLab) {
        _rightTeamNameLab = [UILabel new];
        _rightTeamNameLab.textAlignment = _leftTeamNameLab.textAlignment;
        _rightTeamNameLab.font = _leftTeamNameLab.font;
        _rightTeamNameLab.textColor = _leftTeamNameLab.textColor;
    }
    return _rightTeamNameLab;
}

- (UILabel *)dateLab {
    if (!_dateLab) {
        _dateLab = [UILabel new];
        _dateLab.font = [UIFont systemFontOfSize:Screen_Ratio(15.0f)];
        _dateLab.text = @"2014-07-13";
        _dateLab.textAlignment = NSTextAlignmentCenter;
        _dateLab.textColor = [UIColor grayColor];
        _dateLab.adjustsFontSizeToFitWidth = YES;
    }
    return _dateLab;
}

@end
