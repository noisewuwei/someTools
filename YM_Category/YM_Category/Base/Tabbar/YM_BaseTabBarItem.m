//
//  YM_BaseTabBarItem.m
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import "YM_BaseTabBarItem.h"
#import "YM_TabbarInfo.h"
#import "YM_BaseTool.h"
@interface YM_BaseTabBarItem()
{
    UIImage * _normalImage;  // 常态时的图片
    UIImage * _hightLightImage;  // 选中时的图片
    UIColor * _normalColor;
    UIColor * _selectedColor;
    NSString * _title;       // 标题
    NSInteger _index;
}

// 元素图片
@property (nonatomic, strong) UIImageView * itemImageView;

// 标题
@property (nonatomic, strong) UILabel     * titleLab;

@property (nonatomic, strong) UIButton    * button;

@end

@implementation YM_BaseTabBarItem

/**
 初始化
 @param normal 默认图片
 @param hightLight 高亮图片
 @param title 标题
 @param index 索引
 @return YM_BaseTabBarItem
 */
- (instancetype)initWithNormal:(NSString *)normal
                    hightLight:(NSString *)hightLight
                         title:(NSString *)title
                         index:(NSInteger)index {
    if (self = [super init]) {
        _normalImage = [UIImage imageNamed:normal];
        _hightLightImage = [UIImage imageNamed:hightLight];
        _title = title;
        _index = index;
        _normalColor = [UIColor colorWithRed:108 / 255.0 green:113 / 255.0 blue:129 / 255.0 alpha:1.0];
        _selectedColor = [UIColor colorWithRed:2 / 255.0 green:166 / 255.0 blue:241 / 255.0 alpha:1.0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutView];
}

#pragma mark - 初始化
/**
 界面初始化
 */
- (void)layoutView {
    [self addSubview:self.itemImageView];
    if (_index == 0) {
        _itemImageView.frame = CGRectMake((self.frame.size.width - 30) / 2.0, 5, 30, 22);
    } else {
        _itemImageView.frame = CGRectMake((self.frame.size.width - 25) / 2.0, 5, 25, 25);
    }
    
    [self addSubview:self.titleLab];
    _titleLab.frame = CGRectMake(0, self.frame.size.height - ymSafeAreaHeight - 20 + 3, self.frame.size.width, 20);
    
    [self addSubview:self.button];
    _button.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - 按钮事件
- (void)buttonAction:(UIButton *)sender {
    if (self.selectedBlock) {
        self.selectedBlock(_index);
    }
}

#pragma mark - setter
/**
 设置是否选中
 @param isSelected 是否选中
 */
- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    UIImage * currentImage = isSelected == YES ? _hightLightImage : _normalImage;
    self.itemImageView.image = currentImage;
    self.titleLab.textColor = isSelected == YES ? _selectedColor : _normalColor;
}

- (void)setTitleColor:(UIColor *)normalColor
             selColor:(UIColor *)selColor {
    if (![normalColor isKindOfClass:NSClassFromString(@"UIPlaceholderColor")]) {
        _normalColor = normalColor;
    }
    if (![selColor isKindOfClass:NSClassFromString(@"UIPlaceholderColor")]) {
        _selectedColor = selColor;
    }
}
#pragma mark - 懒加载
- (UIImageView *)itemImageView {
    if (!_itemImageView) {
        _itemImageView = [[UIImageView alloc] initWithImage:_normalImage];
        _itemImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _itemImageView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.text = _title;
        _titleLab.font = [UIFont systemFontOfSize:11.0f];
        _titleLab.textColor = [UIColor grayColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

@end
