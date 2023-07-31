//
//  YM_AlertViewItem.m
//  YM_AlertView
//
//  Created by 黄玉洲 on 2021/5/22.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import "YM_AlertViewItem.h"

@interface YM_AlertViewItem ()


@end

@implementation YM_AlertViewItem

+ (instancetype)defaltWithTitle:(NSString *)title {
    YM_AlertViewItem * item = [[YM_AlertViewItem alloc] init];
    item.text = title;
    return item;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor colorWithRed:0.04 green:0.52 blue:1 alpha:1];
    }
    return _textColor;
}

- (UIFont *)textFont {
    if (!_textFont) {
        _textFont = [UIFont fontWithName:@"Arial" size:16.0f];
    }
    return _textFont;
}

@end

