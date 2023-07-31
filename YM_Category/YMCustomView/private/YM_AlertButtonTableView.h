//
//  YM_AlertButtonTableView.h
//  YM_AlertView
//
//  Created by 黄玉洲 on 2021/5/22.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YM_AlertViewItem;
NS_ASSUME_NONNULL_BEGIN

static NSInteger kAlertBtnHeight = 40.0f;
@interface YM_AlertButtonTableView : UITableView

- (instancetype)initWithItems:(NSArray <YM_AlertViewItem *> *)items;

@property (copy, nonatomic) void (^didSelectedBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
