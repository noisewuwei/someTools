//
//  UICollectionView+YMCategory.m
//  youqu
//
//  Created by 黄玉洲 on 2019/7/2.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import "UICollectionView+YMCategory.h"
#import "NSString+YMCategory.h"

#import <objc/runtime.h>
#import <objc/message.h>

@implementation UICollectionView (YMCategory)

#pragma mark - 显示列表内容
/**
 自定义显示内容
 @param text 文本
 @param imageName 图片名
 */
- (void)showText:(NSString *)text imageName:(NSString *)imageName {
    [self showViewWithText:text imageName:imageName];
}

/**
 按类型显示内容
 @param type 类型名
 */
- (void)showTextWithType:(kCollectionViewType)type {
    NSString * text = @"";
    NSString * imageName = @"";
    switch (type) {
        case kCollectionViewType_NoShow:
            text = @"";
            break;
        case kCollectionViewType_NoData:
            text = @"暂无数据";
            break;
        case kCollectionViewType_TouchReload:
            text = @"点击重试";
            break;
        case kCollectionViewType_NetworkError:
            text = @"请检查网络";
            break;
        default: break;
    }
    [self showViewWithText:text imageName:imageName];
}

/** 隐藏文本和图片 */
- (void)hideTextAndImage {
    UIView * backView = [self viewWithTag:998];
    if (backView) {
        [backView removeFromSuperview];
    }
}

- (void)showViewWithText:(NSString *)text imageName:(NSString *)imageName {
    if (text.length == 0 && imageName.length == 0) {
        [self hideTextAndImage];
        return;
    }
    
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0) {
        return;
    }
    
    // 添加容器视图
    UIView * backView = [self viewWithTag:998];
    if (!backView) {
        backView = [UIView new];
        backView.tag = 998;
        [self addSubview:backView];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [backView addGestureRecognizer:tapGesture];
    }
    CGRect rect = self.bounds;
    rect.origin.y = rect.origin.y - self.contentOffset.y;
    backView.frame = rect;
    
    // 添加文本
    UILabel * textLabel = [backView viewWithTag:1000];
    if (!textLabel) {
        textLabel = [UILabel new];
        textLabel.font = [UIFont systemFontOfSize:15.0f];
        textLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.tag = 1000;
        [backView addSubview:textLabel];
    }
    CGSize size = [text ym_stringForSizeWithSize:CGSizeMake(self.bounds.size.width - 40, CGFLOAT_MAX) font:textLabel.font];
    CGRect textLabelFrame = textLabel.frame;
    textLabelFrame.size = size;
    textLabel.frame = textLabelFrame;
    textLabel.center = CGPointMake(backView.bounds.size.width / 2.0,
                                   backView.bounds.size.height / 2.0);
    textLabel.text = text;
    
    // 添加图片
    UIImageView * imageView = [backView viewWithTag:1001];
    if (!imageView) {
        imageView = [UIImageView new];
        imageView.tag = 1001;
        [backView addSubview:imageView];
    }
    
    // 判断图片存在并计算大小
    UIImage * image = [UIImage imageNamed:imageName];
    if (image) {
        imageView.image = image;
        
        CGFloat width = 0;
        CGFloat height = 0;
        if (image.size.width > 100) {
            width = 100;
            height = width / image.size.width * image.size.height;
        } else if (image.size.height > 100) {
            height = 100;
            width = 100 * image.size.width / image.size.height;
        } else {
            width = image.size.width;
            height = image.size.height;
        }
        CGRect frame = imageView.frame;
        frame.size = CGSizeMake(width, height);
        frame.origin.y = textLabel.bounds.origin.y - 10 - frame.size.height;
        
        CGPoint center = imageView.center;
        center.x = backView.bounds.size.width / 2.0;
        imageView.frame = frame;
        imageView.center = center;
    } else {
        imageView.image = nil;
    }
}

#pragma mark - 手势
- (void)tapAction {
    if (self.touchBlock) {
        self.touchBlock();
    }
}

#pragma mark - 动态生成属性
static char touchBlockKey;
@dynamic touchBlock;

- (void)setTouchBlock:(TouchBlock)touchBlock {
    objc_setAssociatedObject(self, &touchBlockKey, touchBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TouchBlock)touchBlock {
    return objc_getAssociatedObject(self, &touchBlockKey);
}


@end
