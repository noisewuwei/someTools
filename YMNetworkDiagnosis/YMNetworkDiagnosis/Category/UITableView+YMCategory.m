//
//  UITableView+YMCategory.m
//  youqu
//
//  Created by 黄玉洲 on 2019/5/8.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import "UITableView+YMCategory.h"

@implementation UITableView (YMCategory)

#pragma mark - 设置侧滑
/** 设置侧滑按钮 */
- (NSArray <UIButton *> *)getSwipeWithIndexPath:(NSIndexPath *)indexPath {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f) {
        return [self iOS11Last_GetSwipe];
    } else {
        return [self iOS11Befor_GetSwipeWithIndexPath:indexPath];
    }
}

/** iOS11之后调用 */
- (NSArray <UIButton *> *)iOS11Last_GetSwipe {
    NSMutableArray * swipeBtns = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] &&
            [subview.subviews count]) {
            subview.backgroundColor = [UIColor clearColor];
            for (UIButton * button in subview.subviews) {
                // 默认透明色
                if ([button isKindOfClass:[UIButton class]]) {
                    UIView * backView = [button.subviews firstObject];
                    backView.backgroundColor = [UIColor clearColor];
                    [swipeBtns addObject:button];
                }
            }
            break;
        }
    }
    return swipeBtns;
}

/** iOS11之前调用 */
- (NSArray <UIButton *> *)iOS11Befor_GetSwipeWithIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray * swipeBtns = [NSMutableArray array];
    UITableViewCell *tableCell = [self cellForRowAtIndexPath:indexPath];
    for (UIView *subview in tableCell.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")] && [subview.subviews count]) {
            subview.backgroundColor = [UIColor clearColor];
            for (UIButton * button in subview.subviews) {
                // 默认透明色
                if ([button isKindOfClass:[UIButton class]]) {
                    button.backgroundColor = [UIColor clearColor];
                    [swipeBtns addObject:button];
                }
            }
            break;
        }
    }
    return swipeBtns;
}

@end
