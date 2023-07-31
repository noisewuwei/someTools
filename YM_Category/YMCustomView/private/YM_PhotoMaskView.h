//
//  YM_PhotoMaskView.h
//  ToDesk-iOS
//
//  Created by 蒋天宝 on 2021/2/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YM_PhotoMaskViewDelegate;
@interface YM_PhotoMaskView : UIView

@property (nonatomic, weak) id <YM_PhotoMaskViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame cropSize:(CGFloat)cropSize;

/// 背景色
@property (strong, nonatomic) UIColor * backColor;

/// 阴影色
@property (strong, nonatomic) UIColor * shadowColor;

/// 设置阴影色透明度 默认：0.4
@property (assign, nonatomic) CGFloat   shadowAlpha;

/// 边框线颜色
@property (strong, nonatomic) UIColor * borderColor;

/// 虚线间隔 例如@[@2,@2]，表示每条实线的长度和实线间的间隔，默认为@[@1, @0]
@property (strong, nonatomic) NSArray <NSNumber *> * lineDashPattern;

@end

@protocol YM_PhotoMaskViewDelegate <NSObject>

@optional
- (void)photoMaskView:(YM_PhotoMaskView *)maskView scrollViewRect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
