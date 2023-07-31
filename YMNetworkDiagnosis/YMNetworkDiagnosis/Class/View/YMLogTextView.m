//
//  YMLogTextView.m
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import "YMLogTextView.h"

@interface YMLogTextView ()

@end

@implementation YMLogTextView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutView];
        self.backgroundColor = [UIColor blackColor];
        self.textColor = [UIColor greenColor];
        self.font = kFontRatio(14.0f);
        self.layer.cornerRadius = 10;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    
}

- (void)setLog:(NSString *)log {
    if (log.length > 0) {
        NSString * text = [NSString stringWithFormat:@"%@\n%@", self.text, log];
        self.text = text;
        [self scrollRangeToVisible:NSMakeRange(self.text.length, 0)];
    }
}

#pragma mark - 懒加载

@end
