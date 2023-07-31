//
//  YM_AlertSheetView.h
//  ToDesk-iOS
//
//  Created by 海南有趣 on 2020/7/24.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import <UIKit/UIKit.h>



#pragma mark - YM_AlertSheetView
@class YM_AlertSheetAction;

/// 底部弹起的提示框
@interface YM_AlertSheetView : UIView

- (instancetype)initWithTitle:(NSString *)title message:(nullable NSString *)message;


@property (strong, nonatomic) UIFont  * titleFont;  // 默认系统文本15.0f
@property (strong, nonatomic) UIColor * titleColor; // 默认纯黑色


@property (strong, nonatomic) UIFont  * messgeFont;  // 默认系统文本13.0f
@property (strong, nonatomic) UIColor * messgeColor; // 默认灰色

@property (assign, nonatomic) CGFloat   animationDuration;
@property (strong, nonatomic) UIColor * backColor;

@property (copy, nonatomic) void(^didRemoveBlock)(void);

- (void)addAction:(YM_AlertSheetAction *)action;

/// 显示提示框
- (void)show;

@end

#pragma mark - YM_AlertSheetAction
typedef void(^AlertSheetActionBlock)(NSInteger index);

typedef NS_ENUM(NSInteger, kAlertSheetAction) {
    kAlertSheetAction_Default,
    kAlertSheetAction_Cancel,
};

@interface YM_AlertSheetAction : NSObject

+ (YM_AlertSheetAction *)actionTitle:(NSString *)title
                               image:(UIImage *)image
                               style:(kAlertSheetAction)style
                               block:(AlertSheetActionBlock)block;

@property (assign, nonatomic, readonly) kAlertSheetAction actionStyle;
@property (strong, nonatomic, readonly) NSString * title;
@property (strong, nonatomic, readonly) UIImage  * image;
@property (copy, nonatomic, readonly) AlertSheetActionBlock block;
@property (strong, nonatomic) UIColor * titleColor;
@property (strong, nonatomic) UIFont  * titleFont;

// 默认白色
@property (strong, nonatomic) UIColor * backgroundColor;

@end
