//
//  ViewController.m
//  YMEmojiTest
//
//  Created by 黄玉洲 on 16/10/27.
//  Copyright © 2016年 黄玉洲. All rights reserved.
//

#import "ViewController.h"
#import "YM_EmojiView.h"
@interface ViewController ()<YMEmojiViewDelegate>

@property (strong, nonatomic) UILabel * label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    YM_EmojiView * emojiView = [[YM_EmojiView alloc] init];
    emojiView.delegate = self;
    [self.view addSubview:emojiView];
    
    UITextView * textView = [[UITextView alloc] init];
    textView.frame = CGRectMake(0, 100, 200, 30);
    textView.text = @"a";
    textView.tag = 2000;
    [self.view addSubview:textView];
//    textView.inputView = emojiView;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - <YMEmojiViewDelegate>
- (void)emojiView:(YM_EmojiView *)emojiView emojiStr:(NSString *)emojiStr
{
    UITextView * textView = (UITextView *)[self.view viewWithTag:2000];
    textView.text = [NSString stringWithFormat:@"%@%@",textView.text,emojiStr];
}

@end
