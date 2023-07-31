//
//  YM_BaseTabBarItem.h
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

/** tabbar部件 */
@interface YM_BaseTabBarItem : UIView

/**
 初始化
 @param normal 默认图片
 @param hightLight 高亮图片
 @param title 标题
 @param index 索引
 @return YM_BaseTabBarItem
 */
- (instancetype)initWithNormal:(NSString *)normal
                    hightLight:(NSString *)hightLight
                         title:(NSString *)title
                         index:(NSInteger)index;

- (void)setTitleColor:(UIColor *)normalColor
             selColor:(UIColor *)selColor;

// 是否选中
@property (nonatomic, assign) BOOL isSelected;

@property (copy, nonatomic) void(^selectedBlock)(NSInteger index);

@end
