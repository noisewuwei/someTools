//
//  YMMarqueeView.h
//  YMMarqueeView
//
//  Created by 黄玉洲 on 2019/7/31.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kMarqueeDirection) {
    kMarqueeDirection_Left,
    kMarqueeDirection_Right,
    kMarqueeDirection_HorizontalReset,
    kMarqueeDirection_Top,
    kMarqueeDirection_Bottom,
    kMarqueeDirection_VerticalReset
};

@interface YMMarqueeView : UIView

/** 方向 默认：左 */
@property (assign, nonatomic) kMarqueeDirection direction;

/** 两个视图之间的间距 默认：12 */
@property (assign, nonatomic) CGFloat contentMargin;

/** 多少帧回调一次 默认：1/60秒 */
@property (assign, nonatomic) NSInteger frameInterval;

/** 每次移动的距离 默认：0.5 */
@property (assign, nonatomic) CGFloat   pointsPerFrame;

/** 要展示的视图 */
@property (strong, nonatomic) UIView * contentView;

/** 当contentView的内容宽度没有超过显示宽度，无需开启跑马灯效果。
    这个时候contentView的size，默认是调用sizeToFit之后的尺寸。
    如果想要特殊配置，比如让contentView的size等于YMMarqueeView，就需要在该闭包自定义配置。 */
@property (copy, nonatomic) void (^contentViewFrameConfigWhenCantMarquee)(UIView * view);

/** 渐变色视图大小 默认：5 */
@property (assign, nonatomic) CGFloat   gradientSize;

/** 渐变色(如果有透明度，由深至浅传) 默认：nil，不显示渐变色 */
@property (strong, nonatomic) NSArray * gradientColors;

@end

NS_ASSUME_NONNULL_END
