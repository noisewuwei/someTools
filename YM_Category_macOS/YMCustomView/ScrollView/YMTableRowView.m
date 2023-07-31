//
//  YMTableRowView.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/31.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "YMTableRowView.h"

@interface YMTableRowView ()

@end

@implementation YMTableRowView

+ (NSString *)identifier {
    return @"YMTableRowView";
}

+ (YMTableRowView *)viewWithTableView:(NSTableView *)tableView {
    return [self viewWithTableView:tableView
                       normalColor:[NSColor whiteColor]
                       selectColor:[NSColor grayColor]];
}

+ (YMTableRowView *)viewWithTableView:(NSTableView *)tableView
                          normalColor:(NSColor *)normalColor
                          selectColor:(NSColor *)selectColor {
    YMTableRowView * rowView = [tableView makeViewWithIdentifier:[self identifier] owner:self];
    if (!rowView) {
        rowView = [YMTableRowView new];
        rowView.identifier = [self identifier];
        rowView.normalColor = normalColor;
        rowView.selectionColor = selectColor;
    } else {
        rowView.normalColor = normalColor;
        rowView.selectionColor = selectColor;
    }
    return rowView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutView];
    }
    return self;
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    
}

#pragma mark 重写
- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle == NSTableViewSelectionHighlightStyleNone) {
        return;
    }
    
    [_selectionColor setFill];
    NSBezierPath * path = [NSBezierPath bezierPathWithRect:dirtyRect];
    [path fill];
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect {
    [_normalColor setFill];
    NSBezierPath * path = [NSBezierPath bezierPathWithRect:dirtyRect];
    [path fill];
}


#pragma mark 懒加载

@end
