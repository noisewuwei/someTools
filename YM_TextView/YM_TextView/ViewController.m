//
//  ViewController.m
//  YM_TextView
//
//  Created by 黄玉洲 on 2018/8/1.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "ViewController.h"
#import "YM_TextView.h"
@interface ViewController () <YM_TextViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * string = @"点击链接打开跳转链接 测试测试";
    
    NSString * tipStr = string;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tipStr];
    NSRange strRange = [tipStr rangeOfString:string];
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"openUrl://agreement"
                             range:strRange];
    
    YM_TextView * textView = [[YM_TextView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    textView.textColor = [UIColor blueColor];
    textView.placeholder = @"占位符";
    textView.text = string;
    textView.attributedText = attributedString;
    textView.placeholderColor = [UIColor redColor];
    textView.placeholderFont = [UIFont systemFontOfSize:18.0f];
    textView.font = [UIFont systemFontOfSize:15];
    textView.returnKeyType = UIReturnKeyGo;
    textView.delegate = self;
//    textView.editable = NO;
    
    [self.view addSubview:textView];
}


- (BOOL)kTextView:(YM_TextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}

- (BOOL)textView:(YM_TextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    
    return YES;
}

@end
