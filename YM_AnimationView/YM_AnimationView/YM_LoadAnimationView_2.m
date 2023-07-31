//
//  YM_LoadAnimationView_2.m
//  YM_AnimationView
//
//  Created by huangyuzhou on 2018/9/12.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_LoadAnimationView_2.h"

@interface YM_LoadAnimationView_2 ()

@property (strong, nonatomic) UIImageView * frameAnimationView;

@property (strong, nonatomic) NSArray <UIImage *> * images;

@end

@implementation YM_LoadAnimationView_2


- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self layoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _frameAnimationView.frame = self.bounds;
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    [self addSubview:self.frameAnimationView];
}

#pragma mark - public
/** 开始动画 */
- (void)startAnimation:(CGFloat)duration {
    if (duration <= 0.0f) {
        duration = [self.images count] * 0.1;
    }
    [self stopAnimation];
    _frameAnimationView.animationImages = self.images;
    _frameAnimationView.animationDuration = duration;
    [_frameAnimationView startAnimating];
}

/** 结束动画 */
- (void)stopAnimation {
    [_frameAnimationView stopAnimating];
}

#pragma mark - getter
- (NSArray<UIImage *> *)images {
    if (!_images) {
        NSMutableArray * images = [NSMutableArray array];
        for (NSInteger i = 0; i < 47; i++) {
            NSString * imageName = [NSString stringWithFormat:@"loading_%ld", i];
            UIImage * image = [UIImage imageNamed:imageName];
            [images addObject:image];
        }
        _images = images;
    }
    return _images;
}

#pragma mark - 懒加载
- (UIImageView *)frameAnimationView {
    if (!_frameAnimationView) {
        _frameAnimationView = [UIImageView new];
    }
    return _frameAnimationView;
}

@end
