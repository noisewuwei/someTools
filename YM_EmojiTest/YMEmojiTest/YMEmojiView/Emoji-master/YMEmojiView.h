//
//  YMEmojiView.h
//  YMEmojiTest
//
//  Created by 黄玉洲 on 16/10/27.
//  Copyright © 2016年 黄玉洲. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMEmojiViewDelegate;
@interface YMEmojiView : UIView
{
    UIScrollView            *_faceScrollView;
    NSDictionary            *_faceMap;
    NSArray                 *_faces;
}

@property (nonatomic,assign) id<YMEmojiViewDelegate> delegate;

@property (nonatomic,strong) UITextView *inputTextView;

@end

@protocol YMEmojiViewDelegate <NSObject>

@optional
- (void)textViewDidChange:(UITextView *)textView;

@end
