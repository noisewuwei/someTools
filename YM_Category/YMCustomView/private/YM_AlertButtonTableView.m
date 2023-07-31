//
//  YM_AlertButtonTableView.m
//  YM_AlertView
//
//  Created by 黄玉洲 on 2021/5/22.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import "YM_AlertButtonTableView.h"
#import "YM_AlertViewItem.h"

#pragma mark - YM_AlertButtonCell
@interface YM_AlertButtonCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (void)setItem:(YM_AlertViewItem *)item;
- (void)setSeparator:(BOOL)separator;

@property (strong, nonatomic) UILabel * titleLab;

@property (strong, nonatomic) UIView * separatorLine;

@end

@implementation YM_AlertButtonCell


+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString  * identifer = @"YM_AlertButtonCellID";
    YM_AlertButtonCell * cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil) {
        cell = [[YM_AlertButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    return cell;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self layoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor whiteColor];
    _titleLab.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    _separatorLine.frame = CGRectMake(0, self.contentView.bounds.size.height - 0.5, self.contentView.bounds.size.width, 0.5);
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.separatorLine];
}

#pragma mark setter
- (void)setItem:(YM_AlertViewItem *)item {
    if (item) {
        _titleLab.text = item.text;
        _titleLab.textColor = item.textColor;
        _titleLab.font = item.textFont;
    }
}

- (void)setSeparator:(BOOL)separator {
    _separatorLine.hidden = !separator;
}

#pragma mark 懒加载
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [UIView new];
        _separatorLine.backgroundColor = [UIColor grayColor];
    }
    return _separatorLine;
}

@end

#pragma mark - YM_AlertButtonTableView
@interface YM_AlertButtonTableView () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray<YM_AlertViewItem *> * items;

@end

@implementation YM_AlertButtonTableView

- (instancetype)initWithItems:(NSArray<YM_AlertViewItem *> *)items {
    if (self = [super init]) {
        _items = items;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSections {
    return 0;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YM_AlertButtonCell * cell = [YM_AlertButtonCell cellWithTableView:tableView];
    if (indexPath.row < (_items.count-1)) {
        [cell setItem:_items[indexPath.row+1]];
        [cell setSeparator:YES];
    } else {
        [cell setItem:_items[0]];
        [cell setSeparator:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_didSelectedBlock) {
        if (indexPath.row < (_items.count-1)) {
            _didSelectedBlock(indexPath.row+1);
        } else {
            _didSelectedBlock(0);
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kAlertBtnHeight;
}

#pragma mark 懒加载

@end

