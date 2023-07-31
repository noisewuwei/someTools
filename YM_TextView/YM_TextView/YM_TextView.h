//
//  YM_TextView.h
//  YM_TextView
//
//  Created by 黄玉洲 on 2018/8/1.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YM_TextView;
@protocol YM_TextViewDelegate <NSObject, UITextViewDelegate, UIScrollViewDelegate>

@optional

- (BOOL)textViewShouldBeginEditing:(YM_TextView *)textView;
- (BOOL)textViewShouldEndEditing:(YM_TextView *)textView;

- (void)textViewDidBeginEditing:(YM_TextView *)textView;
- (void)textViewDidEndEditing:(YM_TextView *)textView;

- (BOOL)textView:(YM_TextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)textViewDidChange:(YM_TextView *)textView;

- (void)textViewDidChangeSelection:(YM_TextView *)textView;

- (BOOL)textView:(YM_TextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange;

- (BOOL)textView:(YM_TextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange;

@end

@interface YM_TextView : UITextView


/** 占位符、占位符颜色、占位符字体 */
@property (copy, nonatomic)  NSString  * placeholder;
@property (strong, nonatomic) UIColor  * placeholderColor;
@property (strong, nonatomic) UIFont   * placeholderFont;

/** 最大字符数 */
@property (assign, nonatomic) NSInteger   maxLength;

@property (nullable, nonatomic, weak) id <YM_TextViewDelegate> delegate;

@end
