//
//  YM_TabControl.m
//  YM_TabViewTest
//
//  Created by 黄玉洲 on 2018/6/11.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_TabControl.h"
#import "YM_TabControlCell.h"
static NSString * cellID = @"itemCell";
@interface YM_TabControl () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, YM_TabControlCellDelegate>
{
    NSInteger _currentIndex;
}
/** 项滚动条 */
@property (strong, nonatomic) UICollectionView * tabCollectionView;

@end

@implementation YM_TabControl

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _currentIndex = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutView];
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    [self addSubview:self.tabCollectionView];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
/** item数量 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(ym_tabItemCount:)]) {
        return [self.delegate ym_tabItemCount:self];
    }
    return 0;
}

/** 选项卡cell */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YM_TabControlCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:YM_TabControlCellID forIndexPath:indexPath];
    cell.cellDelegate = self;
    cell.index = indexPath.row;
    
    if ([self.delegate respondsToSelector:@selector(ym_customerTabItem:itemIndex:)]) {
        for (UIView * view in cell.contentView.subviews) {
            if (![view isEqual:cell.indicatorView]) {
                [view removeFromSuperview];
            }
        }
        
        UIView * view = [self.delegate ym_customerTabItem:self itemIndex:indexPath.row];
        [cell.contentView addSubview:view];
        view.frame = CGRectMake(0, 0, [self widthWithView:cell], [self heightWithView:cell]);
    }
    
    // 是否显示指示标
    if ([self showTabItemIndicatorView]) {
        if (_currentIndex == indexPath.row) {
            cell.isShowLine = YES;
        } else {
            cell.isShowLine = NO;
        }
    }
    
    return cell;
}

/** 选项元素大小 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([self tabItemWidthWithIndex:indexPath.row], [self heightWithView:self]);
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_allowDuplicateTouch && indexPath.row == _currentIndex) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(ym_tabItemDidSelect:index:)]) {
        // 如果允许点击
        if ([self.delegate ym_tabItemDidSelect:self index:indexPath.row]) {
            _currentIndex = indexPath.row;
            [_tabCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            [self reloadData];
        }
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - <YM_TabControlCellDelegate>
/** 指示标高度 */
- (CGFloat)ym_lineHeightWithIndex:(NSInteger)index {
    if ([self.indicatorDelegate respondsToSelector:@selector(ym_indicatorViewHeight:)]) {
        return [self.indicatorDelegate ym_indicatorViewHeight:self];
    }
    return 1;
}

/** 指示标颜色 */
- (UIColor *)ym_lineColorWithIndex:(NSInteger)index {
    if ([self.indicatorDelegate respondsToSelector:@selector(ym_indicatorViewColor:index:)]) {
        return [self.indicatorDelegate ym_indicatorViewColor:self index:index];
    }
    return [UIColor whiteColor];
}

#pragma mark - 懒加载
- (UICollectionView *)tabCollectionView {
    if (!_tabCollectionView) {
        UICollectionViewFlowLayout * flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        // 初始化
        _tabCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [self widthWithView:self], [self heightWithView:self]) collectionViewLayout:flowLayout];
        _tabCollectionView.delegate = self;
        _tabCollectionView.dataSource = self;
        _tabCollectionView.backgroundColor = self.backgroundColor;
        _tabCollectionView.showsHorizontalScrollIndicator = NO;
        _tabCollectionView.showsVerticalScrollIndicator = NO;
        
        // cell注册
        [_tabCollectionView registerClass:[YM_TabControlCell class]
               forCellWithReuseIdentifier:YM_TabControlCellID];
        
    }
    return _tabCollectionView;
}

#pragma mark - 数据获取
/** 获取视图宽度 */
- (CGFloat)widthWithView:(UIView *)view {
    return CGRectGetWidth(view.bounds);
}

/** 获取视图高度 */
- (CGFloat)heightWithView:(UIView *)view {
    return CGRectGetHeight(view.bounds);
}

/** 默认的选项卡宽度 */
- (CGFloat)tabItemWidthWithIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(ym_tabItemWidth:index:)]) {
        return [self.delegate ym_tabItemWidth:self index:index];
    } else {
        return 60;
    }
}

#pragma mark - 指示标
/** 是否显示指示标 */
- (BOOL)showTabItemIndicatorView {
    if ([self.indicatorDelegate respondsToSelector:@selector(ym_showIndicatorView:)]) {
        return [self.indicatorDelegate ym_showIndicatorView:self];
    } else {
        return NO;
    }
}

/** 指示标数据 */
- (UIColor *)tabItemIndicatorViewColor {
    if ([self.indicatorDelegate respondsToSelector:@selector(ym_indicatorViewColor:index:)]) {
        return [self.indicatorDelegate ym_indicatorViewColor:self index:_currentIndex];
    } else {
        return [UIColor redColor];
    }
}

/** 指示标高度 */
- (CGFloat)tabItemIndicatorViewHeight {
    if ([self.indicatorDelegate respondsToSelector:@selector(ym_indicatorViewHeight:)]) {
        return [self.indicatorDelegate ym_indicatorViewHeight:self];
    } else {
        return 1;
    }
}

/** 移动到指定的位置 */
- (void)scrollToIndex:(NSInteger)index animation:(BOOL)isAnimation{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSIndexPath * oldIndexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
    _currentIndex = index;
    
    [_tabCollectionView scrollToItemAtIndexPath:indexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                       animated:isAnimation];
    
    [_tabCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    [_tabCollectionView reloadItemsAtIndexPaths:@[oldIndexPath]];
}


#pragma mark - public
- (void)reloadData {
    [_tabCollectionView reloadData];
}

/** 当前指定下标是否处于选中状态 */
- (BOOL)isSelectedWithIndex:(NSInteger)index {
    if (index == _currentIndex) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setCurrentIndex:(NSInteger)index {
    _currentIndex = index;
    [self reloadData];
}

- (NSInteger)currentIndex {
    return _currentIndex;
}

@end



