//
//  YM_EmojiView.h
//  YMEmojiTest
//
//  Created by 黄玉洲 on 16/10/27.
//  Copyright © 2016年 黄玉洲. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMEmojiViewDelegate;
@interface YM_EmojiView : UIView

- (instancetype)init;

@property (nonatomic,assign) id<YMEmojiViewDelegate> delegate;

@end

@protocol YMEmojiViewDelegate <NSObject>

@optional
- (void)emojiView:(YM_EmojiView *)emojiView emojiStr:(NSString *)emojiStr;

@end
