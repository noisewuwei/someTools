//
//  YM_BaseTabBar.h
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

/** tabbar */
@interface YM_BaseTabBar : UITabBar

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray <NSString *> *)titles
                norImageNames:(NSArray <NSString *> *)norImageNames
                preImageNames:(NSArray <NSString *> *)preImageNames;

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray <NSString *> *)titles
                norImageNames:(NSArray <NSString *> *)norImageNames
                preImageNames:(NSArray <NSString *> *)preImageNames
                 normalColors:(NSArray <UIColor *> *)normalColors
                    selColors:(NSArray <UIColor *> *)selColors;

@property (nonatomic, copy) void(^selectIndexBlock)(NSInteger);

/* 外部执行调用 */
- (void)setSelectedIndex:(NSInteger)index;
- (NSInteger)selectedIndex;

@end
