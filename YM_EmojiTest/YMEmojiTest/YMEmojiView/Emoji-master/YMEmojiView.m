//
//  YMEmojiView.m
//  YMEmojiTest
//
//  Created by 黄玉洲 on 16/10/27.
//  Copyright © 2016年 黄玉洲. All rights reserved.
//

#import "YMEmojiView.h"
#import "Emoji.h"

#define FACE_COUNT_ALL  120     // 表情总数
#define FACE_COUNT_ROW  4       // 行数
#define FACE_COUNT_CLU  14      // 列数
#define FACE_COUNT_PAGE ( FACE_COUNT_ROW * FACE_COUNT_CLU )     // 每一页的总数
#define FACE_ICON_SIZE  44      // 表情大小
#define MIDX(v) CGRectGetMidX(v)
#define MIDY(v) CGRectGetMidY(v)
#define MAXX(v) CGRectGetMaxX(v)
#define MAXY(v) CGRectGetMaxY(v)
#define COLOR(R,G,B) [UIColor colorWithRed:R green:G blue:B alpha:0]
@implementation YMEmojiView

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)initializeUserInterface
{
    self.frame = CGRectMake(0, 0, 1024, 216);
    self.backgroundColor = COLOR(242, 242, 242);
    
    // UIScrollView
    _faceScrollView = [[UIScrollView alloc] init];
    _faceScrollView.frame = CGRectMake(0, 0, 640,190);
    _faceScrollView.center = CGPointMake(MIDX(self.bounds),
                                         MAXY(self.bounds) - MIDY(_faceScrollView.bounds));
    _faceScrollView.pagingEnabled = YES;
    _faceScrollView.contentSize =
    CGSizeMake((FACE_COUNT_ALL / FACE_COUNT_PAGE + 1) * 640,190);
    _faceScrollView.showsHorizontalScrollIndicator = NO;
    _faceScrollView.delegate = self;
    
    // 获取所有表情
    _faces = [Emoji allEmoji];
    
    for (int i = 0; i < FACE_COUNT_ALL; i++) {
        UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.tag = i;
        [faceButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        // 计算每一个表情的坐标和在哪一屏
        CGFloat x = ((i % FACE_COUNT_PAGE) % FACE_COUNT_CLU) * FACE_ICON_SIZE + 6 + (i / FACE_COUNT_PAGE * 640);
        CGFloat y = ((i % FACE_COUNT_PAGE) / FACE_COUNT_CLU) * FACE_ICON_SIZE + 8;
        faceButton.frame = CGRectMake(x, y, FACE_ICON_SIZE, FACE_ICON_SIZE);
        [faceButton.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
        [faceButton setTitle:[_faces objectAtIndex:i] forState:UIControlStateNormal];
        [_faceScrollView addSubview:faceButton];
    }
    [self addSubview:_faceScrollView];
}

#pragma mark - 自定义方法
- (void)buttonPressed:(UIButton *)sender
{
    if (self.inputTextView) {
        // 获取输入框内容
        NSMutableString *faceString = [[NSMutableString alloc] initWithString:self.inputTextView.text];
        // 获取按钮的title
        [faceString appendString:[sender currentTitle]];
        self.inputTextView.text = faceString;
        // 调用代理方法
        [self.delegate textViewDidChange:self.inputTextView];
    }
}


@end
