//
//  YMOutlineView.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/4.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YMOutlineViewDelegate;
@interface YMOutlineView : NSView

@property (assign, nonatomic) id <NSOutlineViewDelegate> delegate;
@property (assign, nonatomic) id <NSOutlineViewDataSource> dataSource;
@property (assign, nonatomic) id <YMOutlineViewDelegate> ymDelegate;
- (void)reloadData;

#pragma mark public
- (nullable id)itemAtRow:(NSInteger)row;

- (NSInteger)rowForItem:(nullable id)item;

@end

@protocol YMOutlineViewDelegate <NSObject>

@optional
- (NSMenu *)ymOutlineView:(YMOutlineView *)outlineView menuForItem:(id)item;

/// cell被点击
/// @param outlineView YMOutlineView
/// @param row 行
/// @param col 列
/// @param event 事件
/// @return 是否要绕过系统事件
- (BOOL)ymOutlineView:(YMOutlineView *)outlineView didSelectedRow:(NSInteger)row col:(NSInteger)col event:(NSEvent *)event;
@end

NS_ASSUME_NONNULL_END
