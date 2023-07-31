//
//  UITableView+YMCategory.h
//  youqu
//
//  Created by 黄玉洲 on 2019/5/8.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UITableView (YMCategory)

/**
 获取侧滑按钮
 需要在 - (void)tableView:willBeginEditingRowAtIndexPath:代理中调用控制器的setNeedsLayout方法
 ios11以下还需要延迟0.01秒调用该方法
 */
- (NSArray <UIButton *> *)getSwipeWithIndexPath:(NSIndexPath *)indexPath;

@end


