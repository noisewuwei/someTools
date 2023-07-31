//
//  YM_TeamView.m
//  Test
//
//  Created by huangyuzhou on 2018/8/26.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_TeamView.h"
#import "YM_BifurcationConfig.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
@interface YM_TeamView ()
{
    NSString * _teamID;
    NSString * _teamName;
    NSString * _teamLogo;
}

@property (strong, nonatomic) UIImageView * teamLogoView;

@property (strong, nonatomic) UILabel     * teamNameLab;

@end

@implementation YM_TeamView


- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutView];
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    CGFloat height = self.bounds.size.height * 10 / 16;
    CGFloat width = height * 1.2;
 
    [self addSubview:self.teamLogoView];
    [_teamLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(width, height));
        make.top.mas_equalTo(0);
    }];
    
    [self addSubview:self.teamNameLab];
    [_teamNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_teamLogoView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - 手势
/**
 跳转球队详情
 @param recognize 手势
 */
- (void)tapAction:(UITapGestureRecognizer *)recognize {
    [[NSNotificationCenter defaultCenter] postNotificationName:Team_Tap_Notify object:_teamID];
}

#pragma mark - setter
/**
 设置数据
 @param teamID   队伍ID
 @param teamLogo 队伍logo
 @param teamName 队伍名
 */
- (void)setTeamID:(NSString *)teamID
         teamLogo:(NSString *)teamLogo
         teamName:(NSString *)teamName {
    
    if (teamID) {
        _teamID = teamID;
    } else {
        _teamID = @"";
    }
    
    if (teamLogo) {
        _teamLogo = teamLogo;
    } else {
        _teamLogo = @"";
    }
    
    if (teamName) {
        _teamName = teamName;
    } else {
        _teamName = @"";
    }
}

#pragma mark - 懒加载
- (UIImageView *)teamLogoView {
    if (!_teamLogoView) {
        _teamLogoView = [UIImageView new];
        _teamLogoView.userInteractionEnabled = YES;
        
        NSURL * logoURL = [NSURL URLWithString:_teamLogo];
        [_teamLogoView sd_setImageWithURL:logoURL];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_teamLogoView addGestureRecognizer:tap];
    }
    return _teamLogoView;
}

- (UILabel *)teamNameLab {
    if (!_teamNameLab) {
        _teamNameLab = [UILabel new];
        _teamNameLab.textAlignment = NSTextAlignmentCenter;
        _teamNameLab.font = [UIFont systemFontOfSize:Screen_Ratio(13.0f)];
        _teamNameLab.adjustsFontSizeToFitWidth = YES;
        _teamNameLab.text = _teamName;
        _teamNameLab.textColor = teamName_Color;
    }
    return _teamNameLab;
}

@end
