//
//  YMTableView.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/21.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "YMTableView.h"

#pragma mark - YMCustomTableView
@class YMCustomTableView;
@protocol YMCustomTableViewDelegate <NSObject>
@optional
- (NSMenu *)ymCustomTableView:(YMCustomTableView *)outlineView row:(NSInteger)row col:(NSInteger)col;
- (BOOL)ymCustomTableView:(YMCustomTableView *)outlineView didSelectedRow:(NSInteger)row col:(NSInteger)col;

@end

@interface YMCustomTableView : NSTableView

@property (assign, nonatomic) id <YMCustomTableViewDelegate> ymDelegate;

@end

@interface YMCustomTableView ()

@end

@implementation YMCustomTableView

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger row = [self rowAtPoint:point];
    NSInteger col = [self columnAtPoint:point];
    if (row < 0) {
        return [super menuForEvent:event];
    }
    return [self.ymDelegate ymCustomTableView:self row:row col:col];
}

/// 为了拦截TableView被选中
- (void)mouseDown:(NSEvent *)theEvent {
    BOOL result = [self.ymDelegate ymCustomTableView:self didSelectedRow:-1 col:-1];
    if (result) {
        
    } else {
        [super mouseDown:theEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    NSInteger clickedRow = [self rowAtPoint:localLocation];
    NSInteger clickedCol = [self columnAtPoint:localLocation];
    
    [super mouseUp:theEvent];
    
    if (clickedRow != -1 && [self.ymDelegate respondsToSelector:@selector(ymCustomTableView:didSelectedRow:col:)]) {
        [self.ymDelegate ymCustomTableView:self didSelectedRow:clickedRow col:clickedCol];
    }
}

@end

#pragma mark - YMTableView
@interface YMTableView () <YMCustomTableViewDelegate>

@property (strong, nonatomic) YMCustomTableView * tableView;
@property (strong, nonatomic) NSScrollView * scrollView;

@end

@implementation YMTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self layoutView];
    }
    return self;
}

- (void)layout {
    [super layout];
    _scrollView.frame = self.bounds;
    
    if (self.borderColor) {
        self.layer.borderColor = self.borderColor.CGColor;
        self.layer.borderWidth = self.borderWidth;
    }
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    self.focusRingType = NSFocusRingTypeNone;
    [self addSubview:self.scrollView];
}

- (void)reloadData {
    [_tableView reloadData];
}

#pragma mark public
/// 删除某一行
/// @param row 行
/// @param animation 动画类型
- (void)removeWithRow:(NSInteger)row animation:(NSTableViewAnimationOptions)animation {
    NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndex:row];
    [_tableView removeRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationEffectNone];
}

/// 选中某一行数据
/// @param indexes 索引
/// @param extend  通过扩展选择
- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)exten {
    [_tableView selectRowIndexes:indexes byExtendingSelection:exten];
}

/// 通过行列获取项
/// @param column 列
/// @param row 行
/// @param makeIfNecessary 是否必要
- (nullable __kindof NSView *)viewAtColumn:(NSInteger)column row:(NSInteger)row makeIfNecessary:(BOOL)makeIfNecessary {
    return [_tableView viewAtColumn:column row:row makeIfNecessary:makeIfNecessary];
}

#pragma mark getter
- (NSInteger)selectedRow {
    return _tableView.selectedRow;
}

- (NSInteger)selectedColumn {
    return _tableView.selectedColumn;
}

#pragma mark setter
- (void)setDelegate:(id<NSTableViewDelegate>)delegate {
    _delegate = delegate;
    _tableView.delegate = delegate;
}

- (void)setDataSource:(id<NSTableViewDataSource>)dataSource {
    _dataSource = dataSource;
    _tableView.dataSource = dataSource;
}

- (void)setHeaderView:(NSTableHeaderView *)headerView {
    _tableView.headerView = headerView;
}

#pragma mark YMCustomOutlineViewDelegate
- (NSMenu *)ymCustomTableView:(YMCustomTableView *)outlineView row:(NSInteger)row col:(NSInteger)col {
    if ([self.ymDelegate respondsToSelector:@selector(ymTableView:row:col:)]) {
        return [self.ymDelegate ymTableView:self row:row col:col];
    }
    return nil;
}

- (BOOL)ymCustomTableView:(YMCustomTableView *)outlineView didSelectedRow:(NSInteger)row col:(NSInteger)col {
    if (row == -1 && col == -1) {
        return [self.ymDelegate respondsToSelector:@selector(ymTableView:didSelectedRow:col:)];
    }
    
    if ([self.ymDelegate respondsToSelector:@selector(ymTableView:didSelectedRow:col:)]) {
        [self.ymDelegate ymTableView:self didSelectedRow:row col:col];
    }
    
    return YES;
}

#pragma mark 懒加载
- (NSScrollView *)scrollView {
    if (!_scrollView) {
        NSScrollView * scrollView = [NSScrollView new];
        scrollView.backgroundColor = [NSColor redColor];
        scrollView.drawsBackground = NO;
        scrollView.hasHorizontalScroller = YES;
        scrollView.hasVerticalScroller = YES;
        scrollView.autohidesScrollers = YES;
        scrollView.documentView = self.tableView;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (YMCustomTableView *)tableView {
    if (!_tableView) {
        YMCustomTableView * tableView = [YMCustomTableView new];
        tableView.focusRingType = NSFocusRingTypeNone;
        tableView.autoresizesSubviews = YES;
        tableView.headerView = nil;
        
        NSTableColumn * column1 = [[NSTableColumn alloc] initWithIdentifier:@"TextCell"];
        column1.title = @"";
        [tableView addTableColumn:column1];
        
        tableView.dataSource = _dataSource;
        tableView.delegate = _delegate;
        tableView.ymDelegate = self;
        
        _tableView = tableView;
    }
    return _tableView;
}

@end
