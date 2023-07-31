//
//  YM_TextView.h
//  YM_TextView
//
//  Created by 黄玉洲 on 2018/8/1.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YM_TextView;
@protocol YM_TextViewDelegate <NSObject, UIScrollViewDelegate>

@optional

- (BOOL)ymTextViewShouldBeginEditing:(YM_TextView *)textView;
- (BOOL)ymTextViewShouldEndEditing:(YM_TextView *)textView;

- (void)ymTextViewDidBeginEditing:(YM_TextView *)textView;
- (void)ymTextViewDidEndEditing:(YM_TextView *)textView;

- (BOOL)ymTextView:(YM_TextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)ymTextViewDidChange:(YM_TextView *)textView;

- (void)ymTextViewDidChangeSelection:(YM_TextView *)textView;

- (BOOL)ymTextView:(YM_TextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange;

- (BOOL)ymTextView:(YM_TextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange;

/// 回车
- (BOOL)ymTextViewShouldReturn:(YM_TextView *)textView;

/// Del
- (void)ymTextViewDidDelete:(YM_TextView *)textView;

@end

/// 输入框视图
@interface YM_TextView : UITextView


/** 占位符、占位符颜色、占位符字体 */
@property (copy, nonatomic)  NSString  * placeholder;
@property (strong, nonatomic) UIColor  * placeholderColor;
@property (strong, nonatomic) UIFont   * placeholderFont;

/** 最大字符数 */
@property (assign, nonatomic) NSInteger   maxLength;

@property (nullable, nonatomic, weak) id <YM_TextViewDelegate> ymDelegate;

@end
