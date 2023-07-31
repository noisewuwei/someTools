//
//  YM_InputView.h
//  KKCap
//
//  Created by 黄玉洲 on 2020/4/12.
//  Copyright © 2020 TouchingApp. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 输入框视图
@interface YM_InputView : UIView


- (instancetype)initWithLeftView:(UIView *)leftView
                       rightView:(UIView *)rightView;

@property (strong, nonatomic, readonly) UIView * leftView;
@property (assign, nonatomic) CGFloat   leftEdge;

@property (strong, nonatomic, readonly) UIView * rightView;
@property (assign, nonatomic) CGFloat   rightEdge;

/// 设置右侧视图是否展示
/// @param isShow 是否展示
- (void)setRightViewShow:(BOOL)isShow;

@property (strong, nonatomic, readonly) UITextField * textField;

/** 分隔线颜色 */
@property (strong, nonatomic) UIColor * separatorViewColor;

/** 整个视图的触摸事件 */
@property (copy, nonatomic) void(^tapGestureBlock)(YM_InputView * view);

#pragma mark - 输入框
/** 输入框是否可以点击 */
@property (assign, nonatomic) BOOL textViewEdit;

/** 输入框内容 */
@property (copy, nonatomic) NSString * content;
@property (strong, nonatomic) UIFont * textFont;

/** 占位符 */
@property (copy, nonatomic) NSString * placeHolder;
@property (strong, nonatomic) UIColor * placeHolderColor;
@property (strong, nonatomic) UIFont * placeHolderFont;
@property (strong, nonatomic) NSAttributedString * attributedPlaceholder;

/** 输入框颜色 */
@property (strong, nonatomic) UIColor * textColor;

@property (weak, nonatomic) id <UITextFieldDelegate> delegate;

@property (assign, nonatomic) CGFloat   corner;

@end


