//
//  YM_SearchBarView.h
//  KKCap
//
//  Created by 海南有趣 on 2020/4/16.
//  Copyright © 2020 TouchingApp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YM_SearchBarViewDelegate;

/// 搜索框
@interface YM_SearchBarView : UIView

@property (weak, nonatomic) id <YM_SearchBarViewDelegate> delegate;

@property (nonatomic, copy) NSString   * placeHolder;       // 占位符
@property (strong, nonatomic) UIFont   * placeHolderFont;   // 占位符字体
@property (nonatomic, strong) UIColor  * placeHolderColor;  // 占位符颜色
@property (strong, nonatomic) UIImage  * icon;              // 占位符图标

@property (assign, nonatomic) CGFloat    cancelBtnWidth; // 取消按钮宽度（默认60）
@property (strong, nonatomic) UIColor  * cancelBtnColor; // 取消按钮文本颜色（默认白色）
@property (strong, nonatomic) UIFont   * cancelBtnFont;  // 取消按钮文本属性（默认14.0f）
@property (copy, nonatomic)   NSString * cancelBtnTitle; // 取消按钮文本内容（默认"取消"）

@property (copy, nonatomic)   NSString * content;      // 输入框内容（默认""）
@property (strong, nonatomic) UIFont   * contentFont;  // 输入框文本属性(默认14.0f)
@property (strong, nonatomic) UIColor  * contentColor; // 输入框文本颜色(默认黑色)

@property (strong, nonatomic) UIColor  * inputViewBackColor;// 输入框的背景颜色

/** 内容发生变化后的回调 */
@property (copy, nonatomic) void(^contentDidChangeBlock)(NSString * content);

/** 输入框右侧删除键图标名（如果有则显示删除按钮，不传则没有） */
@property (copy, nonatomic) NSString * deleteImageName;

@end

@protocol YM_SearchBarViewDelegate <NSObject>

@optional
/// 内容发生变化
/// @param view YM_SearchBarView
/// @param content 输入后的内容
- (void)searchBar:(YM_SearchBarView *)view contentDidChange:(NSString *)content;

/// 点击取消编辑
/// @param view YM_SearchBarView
- (void)searchBarDidCancel:(YM_SearchBarView *)view;

/// 开始编辑
/// @param view YM_SearchBarView
- (void)searchBarDidStartEdit:(YM_SearchBarView *)view;

/// 结束编辑
/// @param view view descriptionYM_SearchBarView
- (void)searchBarDidEndEdit:(YM_SearchBarView *)view;

@end

NS_ASSUME_NONNULL_END
