//
//  YMButton.h
//  macOS_Test
//
//  Created by 海南有趣 on 2020/7/30.
//  Copyright © 2020 黄玉洲. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, YMButtonStatus) {
    /// 默认状态
    YMButtonStatus_Normal,
    /// 高亮状态
    YMButtonStatus_Highlight,
    /// 鼠标停留状态
    YMButtonStatus_Enter,
    /// 禁用状态
    YMButtonStatus_Disabled
};

typedef NS_ENUM(NSInteger, YMButtonCorners) {
    YMButtonCorners_All = 1 << 0,
    YMButtonCorners_TopLeft = 1 << 1,
    YMButtonCorners_TopRight = 1 << 2,
    YMButtonCorners_BottomLeft = 1 << 3,
    YMButtonCorners_BottomRight = 1 << 4,
};

/// 文本对齐
typedef NS_ENUM(NSInteger, YMButtonAlign) {
    YMButtonAlign_Left = 1 << 0,
    YMButtonAlign_Right = 1 << 1,
    YMButtonAlign_Center = 1 << 2
};

/// 图标排版
typedef NS_ENUM(NSInteger, YMButtonPosition) {
    YMButtonPosition_Left = 1 << 0,
    YMButtonPosition_Right = 1 << 1,
    YMButtonPosition_Top = 1 << 2,
    YMButtonPosition_Bottom = 1 << 3,
};

IB_DESIGNABLE
@interface YMButton : NSButton

/// 添加事件
@property (copy, nonatomic, readonly) YMButton * (^ymAction)(id targer, SEL action);

/// 鼠标移至区域是否显示小手
@property (copy, nonatomic, readonly) YMButton * (^ymHandCursor)(BOOL);

/// 圆角
@property (copy, nonatomic, readonly) YMButton * (^ymRadius)(CGFloat, YMButtonCorners);

/// 排版
@property (copy, nonatomic, readonly) YMButton * (^ymTypography)(YMButtonAlign, YMButtonPosition);
/// 圆角
@property (assign, nonatomic, readonly) CGFloat radius;
/// 圆角位置
@property (assign, nonatomic, readonly) YMButtonCorners radiusCorners;

/// 标题
@property (copy, nonatomic, readonly) YMButton * (^ymTitle)(NSString *, YMButtonStatus);

/// 文本属性
@property (copy, nonatomic, readonly) YMButton * (^ymFont)(NSFont *);

/// 标题富文本
@property (copy, nonatomic, readonly) YMButton * (^ymTitleAttribute)(NSAttributedString *, YMButtonStatus);

/// 标题色
@property (copy, nonatomic, readonly) YMButton * (^ymTitleColor)(NSColor *, YMButtonStatus);

/// 图标
@property (copy, nonatomic, readonly) YMButton * (^ymImage)(NSImage *, YMButtonStatus);

/// 图标间距
@property (copy, nonatomic, readonly) YMButton * (^ymSpace)(CGFloat);

/// 背景图
@property (copy, nonatomic, readonly) YMButton * (^ymBackImage)(NSImage *, YMButtonStatus);
- (NSImage *)backImage;

/// 鼠标进入的回调
@property (copy, nonatomic) void(^enterBlock)(YMButton * button);

/// 鼠标离开的回调
@property (copy, nonatomic) void(^exitedBlock)(YMButton * button);

/// 重新绘制
- (void)reset;

@end

