//
//  YM_FullScreenCameraPlayView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YM_FullScreenCameraPlayView : UIView

@property (assign, nonatomic) CGFloat progress;

@property (strong, nonatomic) UIColor *color;

- (void)clean;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color;

@end
