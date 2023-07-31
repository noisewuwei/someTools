//
//  YMOutlineView.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/4.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "YMOutlineView.h"

#pragma mark - YMCustomOutlineView
@class YMCustomOutlineView;
@protocol YMCustomOutlineViewDelegate <NSObject>
@optional

- (NSMenu *)ymCustomOutlineView:(YMCustomOutlineView *)outlineView menuForItem:(id)item;
- (BOOL)ymCustomOutlineView:(YMCustomOutlineView *)outlineView didSelectedRow:(NSInteger)row col:(NSInteger)col event:(NSEvent *)event;

@end

@interface YMCustomOutlineView : NSOutlineView

@property (assign, nonatomic) id <YMCustomOutlineViewDelegate> ymDelegate;

@end

@interface YMCustomOutlineView ()

@end

@implementation YMCustomOutlineView

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger row = [self rowAtPoint:point];
    if (row < 0) {
        return [super menuForEvent:event];
    }
    return [self.ymDelegate ymCustomOutlineView:self menuForItem:[self itemAtRow:row]];
}

/// 为了拦截TableView被选中
- (void)mouseDown:(NSEvent *)theEvent {
    BOOL result = [self.ymDelegate ymCustomOutlineView:self didSelectedRow:-1 col:-1 event:theEvent];
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
    
    if (clickedRow != -1 && [self.ymDelegate respondsToSelector:@selector(ymCustomOutlineView:didSelectedRow:col:event:)]) {
        [self.ymDelegate ymCustomOutlineView:self didSelectedRow:clickedRow col:clickedCol event:theEvent];
    }
}

@end



#pragma mark - YMOutlineView
@interface YMOutlineView () <YMCustomOutlineViewDelegate>
{
    
}

@property (strong, nonatomic) YMCustomOutlineView * outlineView;
@property (strong, nonatomic) NSScrollView * scrollView;

@end

@implementation YMOutlineView

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
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    self.focusRingType = NSFocusRingTypeNone;
    [self addSubview:self.scrollView];
}

- (void)reloadData {
    [_outlineView reloadData];
}

#pragma mark setter
- (void)setDelegate:(id<NSOutlineViewDelegate>)delegate {
    _delegate = delegate;
    _outlineView.delegate = delegate;
}

- (void)setDataSource:(id<NSOutlineViewDataSource>)dataSource {
    _dataSource = dataSource;
    _outlineView.dataSource = dataSource;
}

#pragma mark public
- (nullable id)itemAtRow:(NSInteger)row {
    return [_outlineView itemAtRow:row];
}
- (NSInteger)rowForItem:(nullable id)item {
    return [_outlineView rowForItem:item];
}

#pragma mark YMCustomOutlineViewDelegate
- (NSMenu *)ymCustomOutlineView:(YMCustomOutlineView *)outlineView menuForItem:(id)item {
    if ([self.ymDelegate respondsToSelector:@selector(ymOutlineView:menuForItem:)]) {
        return [self.ymDelegate ymOutlineView:self menuForItem:item];
    }
    return nil;
}

- (BOOL)ymCustomOutlineView:(YMCustomOutlineView *)outlineView didSelectedRow:(NSInteger)row col:(NSInteger)col event:(NSEvent *)event {
    if (row == -1 && col == -1) {
        if ([self.ymDelegate respondsToSelector:@selector(ymOutlineView:didSelectedRow:col:event:)]) {
            return [self.ymDelegate ymOutlineView:self didSelectedRow:-1 col:-1 event:event];
        }
        return NO;
    }
       
    if ([self.ymDelegate respondsToSelector:@selector(ymOutlineView:didSelectedRow:col:event:)]) {
        return [self.ymDelegate ymOutlineView:self didSelectedRow:row col:col event:event];
    }
    
    return NO;
}



#pragma mark 懒加载
- (NSScrollView *)scrollView {
    if (!_scrollView) {
        NSScrollView * scrollView = [NSScrollView new];
        scrollView.drawsBackground = NO;
        scrollView.hasHorizontalScroller = YES;
        scrollView.hasVerticalScroller = YES;
        scrollView.autohidesScrollers = YES;
        scrollView.documentView = self.outlineView;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (YMCustomOutlineView *)outlineView {
    if (!_outlineView) {
        YMCustomOutlineView * outlineView = [YMCustomOutlineView new];
        outlineView.floatsGroupRows = NO;
        outlineView.allowsColumnResizing = YES;
        outlineView.headerView = nil;
        outlineView.indentationPerLevel = 0;
        outlineView.delegate = _delegate;
        outlineView.dataSource = _dataSource;
        outlineView.ymDelegate = self;
        
        NSTableColumn * colum = [[NSTableColumn alloc] initWithIdentifier:@"TextCell"];
        [outlineView addTableColumn:colum];
        outlineView.outlineTableColumn = colum;
        
        _outlineView = outlineView;
    }
    return _outlineView;
}

@end

