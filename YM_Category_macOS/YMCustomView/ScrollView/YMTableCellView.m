//
//  YMTableCellView.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/5.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "YMTableCellView.h"

@interface YMTableCellView ()

@end

@implementation YMTableCellView

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

+ (id)cellWithTable:(NSTableView *)tableView {
    id cell = [tableView makeViewWithIdentifier:[self identifier] owner:self];
    if (!cell) {
        cell = [[self class] new];
    }
    return cell;
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

#pragma mark 懒加载

@end
