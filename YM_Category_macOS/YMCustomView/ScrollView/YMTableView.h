//
//  YMTableView.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/21.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YMTableViewDelegate;
@interface YMTableView : NSView

@property (assign, nonatomic) id <NSTableViewDelegate> delegate;
@property (assign, nonatomic) id <NSTableViewDataSource> dataSource;
@property (assign, nonatomic) id <YMTableViewDelegate> ymDelegate;
@property (strong, nonatomic) NSTableHeaderView * headerView;

@property (readonly) NSInteger selectedRow;
@property (readonly) NSInteger selectedColumn;

/// 边框颜色
@property (strong, nonatomic) NSColor * borderColor;

/// 边框宽度
@property (assign, nonatomic) CGFloat   borderWidth;

- (void)reloadData;

/// 删除某一行
/// @param row 行
/// @param animation 动画类型
- (void)removeWithRow:(NSInteger)row animation:(NSTableViewAnimationOptions)animation;

/// 选中某一行数据
/// @param indexes 索引
/// @param extend  通过扩展选择
- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extend;

/// 通过行列获取项
/// @param column 列
/// @param row 行
/// @param makeIfNecessary 是否必要
- (nullable __kindof NSView *)viewAtColumn:(NSInteger)column row:(NSInteger)row makeIfNecessary:(BOOL)makeIfNecessary;

@end

@protocol YMTableViewDelegate <NSObject>

@optional
- (NSMenu *)ymTableView:(YMTableView *)tableView row:(NSInteger)row col:(NSInteger)col;
- (void)ymTableView:(YMTableView *)tableView didSelectedRow:(NSInteger)row col:(NSInteger)col;
@end

NS_ASSUME_NONNULL_END
