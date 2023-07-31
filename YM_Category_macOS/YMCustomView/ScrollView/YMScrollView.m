//
//  YMScrollView.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/27.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "YMScrollView.h"

@interface YMScrollView ()

@end

@implementation YMScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self layoutView];
    }
    return self;
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    
}

- (void)scrollToTop {
    if (self.documentView) {
        if (self.documentView.isFlipped) {
            [self.documentView scrollPoint:CGPointZero];
        } else {
            CGFloat maxHeight = MAX(self.bounds.size.height, self.documentView.bounds.size.height);
            [self.documentView scrollPoint:CGPointMake(0, maxHeight)];
        }
    }
}

#pragma mark 重写
- (BOOL)isFlipped {
    return YES;
}

#pragma mark 懒加载

@end
