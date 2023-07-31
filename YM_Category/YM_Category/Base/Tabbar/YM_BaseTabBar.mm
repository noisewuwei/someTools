//
//  YM_BaseTabBar.m
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import "YM_BaseTabBar.h"
#import "YM_BaseTabBarItem.h"
#import "YM_BaseTool.h"
#import "YYModel.h"
#import "YM_TabbarInfo.h"
@interface YM_BaseTabBar () {
    NSMutableArray * _items; // item组
    NSInteger _index;
}

@end

@implementation YM_BaseTabBar

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray <NSString *> *)titles
                norImageNames:(NSArray <NSString *> *)norImageNames
                preImageNames:(NSArray <NSString *> *)preImageNames {
    return [self initWithFrame:frame
                        titles:titles
                 norImageNames:norImageNames
                 preImageNames:preImageNames
                  normalColors:nil
                     selColors:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray <NSString *> *)titles
                 norImageNames:(NSArray <NSString *> *)norImageNames
                 preImageNames:(NSArray <NSString *> *)preImageNames
                 normalColors:(NSArray <UIColor *> *)normalColors
                    selColors:(NSArray <UIColor *> *)selColors {
    if (self = [super initWithFrame:frame]) {
        [self layoutViewWithTitles:titles
                     norImageNames:norImageNames
                     preImageNames:preImageNames
                      normalColors:normalColors
                         selColors:selColors];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    // 防止原生的按钮挡住当前自定义的按钮
    Class class5 = NSClassFromString(@"UITabBarButton");
    for (UIView *btn in self.subviews) {
        if ([btn isKindOfClass:class5]) {
            btn.hidden = YES;
        }
    }
}

#pragma mark - 初始化
- (void)layoutViewWithTitles:(NSArray <NSString *> *)titles
               norImageNames:(NSArray <NSString *> *)norImageNames
               preImageNames:(NSArray <NSString *> *)preImageNames
                normalColors:(NSArray <UIColor *> *)normalColors
                   selColors:(NSArray <UIColor *> *)selColors {
    
    _items = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    CGFloat width = ymScreenWidth / [titles count];
    CGFloat height = self.bounds.size.height;
    for (NSInteger i = 0; i < [titles count]; i++) {
        YM_BaseTabBarItem * tabbarItem = [[YM_BaseTabBarItem alloc] initWithNormal:norImageNames[i]
                                                                        hightLight:preImageNames[i]
                                                                             title:titles[i]
                                                                             index:i];
       [tabbarItem setTitleColor:normalColors.count > i ? normalColors[i] : nil
                        selColor:selColors.count > i ? selColors[i] : nil];
        tabbarItem.frame = CGRectMake(width * i, 0, width, height);
        [self addSubview:tabbarItem];
        tabbarItem.selectedBlock = ^(NSInteger index) {
            [weakSelf refreshPage:index];
        };
        [_items addObject:tabbarItem];
    }
}

- (void)refreshPage:(NSInteger)index {
    // 改变tabbar的状态
    for (int i = 0; i < _items.count; i++) {
        YM_BaseTabBarItem * item = (YM_BaseTabBarItem *)_items[i];
        if (i == index) {
            item.isSelected = YES;
        } else {
            item.isSelected = NO;
        }
    }
    
    // 事件回调
    if (self.selectIndexBlock) {
        self.selectIndexBlock(index);
    }
}

/* 外部执行调用 */
- (void)setSelectedIndex:(NSInteger)index {
    _index = index;
    [self refreshPage:index];
}

- (NSInteger)selectedIndex {
    return _index;
}

@end
