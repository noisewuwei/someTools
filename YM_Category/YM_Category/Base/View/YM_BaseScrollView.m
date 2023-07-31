//
//  YM_BaseScrollView.m
//  ToDesk-iOS
//
//  Created by 蒋天宝 on 2021/3/26.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YM_BaseScrollView.h"

@interface YM_BaseScrollView ()

@end

@implementation YM_BaseScrollView

+ (YM_BaseScrollView *)xib {
    return
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([YM_BaseScrollView class])
                                  owner:self
                                options:nil].firstObject;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIButton class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

#pragma mark 懒加载

@end
