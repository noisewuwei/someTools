//
//  YM_TabControlCell.m
//  DS_lottery
//
//  Created by 黄玉洲 on 2018/7/11.
//  Copyright © 2018年 海南达生实业有限公司. All rights reserved.
//

#import "YM_TabControlCell.h"


@interface YM_TabControlCell ()

@property (strong, nonatomic) UIView * indicatorView;

@end

@implementation YM_TabControlCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutView];
}

#pragma mark - 界面
- (void)layoutView {
    
    CGFloat lineHeight = lineHeight = [self.cellDelegate ym_lineHeightWithIndex:_index];
    
    [self.contentView addSubview:self.indicatorView];
    _indicatorView.frame = CGRectMake(0, self.bounds.size.height - lineHeight, self.bounds.size.width, lineHeight);

}

#pragma mark - setter
- (void)setIsShowLine:(BOOL)isShowLine {
    _isShowLine = isShowLine;
    _indicatorView.hidden = !isShowLine;
}

#pragma mark - 懒加载
- (UIView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [UIView new];
        _indicatorView.hidden = !_isShowLine;
        _indicatorView.backgroundColor = [self.cellDelegate ym_lineColorWithIndex:_index];
    }
    return _indicatorView;
}

@end

