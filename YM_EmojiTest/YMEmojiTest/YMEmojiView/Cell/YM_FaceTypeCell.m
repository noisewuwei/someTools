//
//  YM_FaceTypeCell.m
//  YMEmojiTest
//
//  Created by 黄玉洲 on 2018/6/19.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "YM_FaceTypeCell.h"

@interface YM_FaceTypeCell()

@property (strong, nonatomic) UILabel * label;

@end

@implementation YM_FaceTypeCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = self.contentView.bounds;
}

#pragma mark - setter
- (void)setEmojiType:(NSString *)emojiType {
    if (emojiType) {
        _emojiType = emojiType;
        _label.text = emojiType;
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _label.textColor = isSelected ? [UIColor orangeColor] : [UIColor blackColor];
}

#pragma mark - 懒加载
- (UILabel *)label {
    if (!_label) {
        _label = [UILabel new];
        _label.font = [UIFont systemFontOfSize:15.0f];
        _label.textColor = [UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

@end
