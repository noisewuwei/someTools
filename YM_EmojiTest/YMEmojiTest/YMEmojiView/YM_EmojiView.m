//
//  YM_EmojiView.m
//  YMEmojiTest
//
//  Created by 黄玉洲 on 16/10/27.
//  Copyright © 2016年 黄玉洲. All rights reserved.
//

#import "YM_EmojiView.h"
#import "YM_EmojiModel.h"

#import "YM_FaceTypeCell.h"
@interface YM_EmojiView ()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSArray                 * _ymEmojis;   // 表情容器对象数组
    NSArray                 * _emojis;     // 表情数组
    NSMutableArray          * _offSets;    // 每一类类型所在的偏移位置
    BOOL                      _isTouchBtn; // 是否点击了按钮
    
    NSInteger _selectedCellIndex; // 选中的cell
    
}

/** 表情列表 */
@property (strong, nonatomic) UIScrollView * faceScrollView;  

/** 表情类型列表 */
@property (strong, nonatomic) UICollectionView * faceTypeCollectionView;

@end

#define FACE_COUNT_ALL  [_emojis count] // 表情总数
#define FACE_COUNT_ROW  4       // 行数
#define FACE_ICON_SIZE  44      // 表情大小
#define FACE_ICON_EDGE  5
#define MIDX(v) CGRectGetMidX(v)
#define MIDY(v) CGRectGetMidY(v)
#define MAXX(v) CGRectGetMaxX(v)
#define MAXY(v) CGRectGetMaxY(v)
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define COLOR(R,G,B) [UIColor colorWithRed:R green:G blue:B alpha:0]
@implementation YM_EmojiView

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = COLOR(242, 242, 242);
        _offSets = [NSMutableArray array];
        _ymEmojis = [YM_EmojiModel allEmojis];
        _selectedCellIndex = 0;
        [self layoutView];
    }
    return self;
}

#pragma mark - 布局
- (void)layoutView
{
    self.frame = CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 230);
    [self addSubview:self.faceTypeCollectionView];
    [self addSubview:self.faceScrollView];
    _emojis = [[_ymEmojis firstObject] emojis];
    [self layoutEmoji];
    
    [_faceTypeCollectionView reloadData];
}

/**
 布局表情
 */
- (void)layoutEmoji
{
    // 一列表表情的列数
    NSInteger col_number = SCREEN_WIDTH / (FACE_ICON_SIZE + FACE_ICON_EDGE);
    // 一列表情所占宽度
    CGFloat   col_width = col_number * (FACE_ICON_SIZE + FACE_ICON_EDGE) + FACE_ICON_EDGE;
    // 左边距
    CGFloat   edge = (SCREEN_WIDTH - col_width) / 2.0;
    // 每页表情总数
    NSInteger pageTotalNumber = col_number * FACE_COUNT_ROW;
    
    // 基础X坐标
    CGFloat baseX = 0;
    // 当前页
    NSInteger currentPage = 0;
    
    // 循环加载所有表情
    for (int i = 0; i < [_ymEmojis count]; i++) {
        _emojis = [_ymEmojis[i] emojis];
        for (int j = 0; j < FACE_COUNT_ALL; j++) {
            UIButton * faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.tag = j;
            [faceButton addTarget:self action:@selector(emojiBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            // 表情在第几页
            NSInteger page = j / pageTotalNumber;
            // 当前页的第几个表情
            NSInteger index = (j % pageTotalNumber);
            // 当前表情在第几列
            NSInteger col = index % col_number;
            // 当前表情在第几行
            NSInteger row = (index - col) / col_number;
            
            // 计算每一个表情的坐标和在哪一屏
            CGFloat x = baseX + edge + (col * (FACE_ICON_SIZE + FACE_ICON_EDGE)) + page * SCREEN_WIDTH;
            CGFloat y = edge + (row * (FACE_ICON_SIZE + FACE_ICON_EDGE));
            faceButton.frame = CGRectMake(x, y, FACE_ICON_SIZE, FACE_ICON_SIZE);
            [faceButton.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
            [faceButton setTitle:[_emojis objectAtIndex:j] forState:UIControlStateNormal];
            [_faceScrollView addSubview:faceButton];
            
            // 设置表情滚动页面范围
            currentPage = page;
        }
        [_offSets addObject:@(baseX)];
        baseX = baseX + (currentPage + 1) * CGRectGetWidth(_faceScrollView.frame);
        _faceScrollView.contentSize = CGSizeMake(baseX,190);
        currentPage = 0;
    }
    // 添加表情
    [self addSubview:_faceScrollView];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 当前是点击按钮进行偏移还是拖动scrollView进行偏移
    if (_isTouchBtn) {
        return;
    }
    
    if (scrollView != _faceScrollView) {
        return;
    }
    
    NSInteger page = 0;
    
    // 当前偏移量
    CGFloat current_offset_x = scrollView.contentOffset.x;
    NSLog(@"%lf", current_offset_x);
    
    for (NSInteger i = 1; i < [_offSets count]; i++) {
        CGFloat min_midX = [_offSets[i - 1] floatValue] - scrollView.bounds.size.width / 2.0;
        CGFloat max_midX = [_offSets[i] floatValue] - scrollView.bounds.size.width / 2.0;
        if (current_offset_x >= min_midX && current_offset_x < max_midX) {
            page = i - 1;
            break;
        } else if (current_offset_x >= max_midX) {
            page = i;
        }
    }
    if (page != _selectedCellIndex) {
        _selectedCellIndex = page;
        [self.faceTypeCollectionView reloadData];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:page inSection:0];
        [_faceTypeCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    NSLog(@"页码：%ld", page);
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _faceTypeCollectionView) {
        return [_ymEmojis count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _faceTypeCollectionView) {
        YM_FaceTypeCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:YM_FaceTypeCellID forIndexPath:indexPath];
        if (indexPath.row == _selectedCellIndex) {
            cell.isSelected = YES;
        } else {
            cell.isSelected = NO;
        }
        
        YM_EmojiModel *emoji = _ymEmojis[indexPath.row];
        cell.emojiType = emoji.title;
        
        return cell;
    }
    return nil;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _faceTypeCollectionView) {
        _selectedCellIndex = indexPath.row;
        [_faceTypeCollectionView reloadData];
    }
}


#pragma mark - <UICollectionViewDelegateFlowLayout>
/** cell大小 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _faceTypeCollectionView) {
        
        return CGSizeMake(collectionView.bounds.size.width / 5.0, collectionView.bounds.size.height);
    }
    return CGSizeMake(0, 0);
}

/** 行间距 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == _faceTypeCollectionView) {
        return 0;
    }
    return 0;
}

/** 列间距 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == _faceTypeCollectionView) {
        return 0;
    }
    return 0;
}

#pragma mark - 事件
- (void)emojiBtnAction:(UIButton *)sender {
    // 获取点击的表情
    NSString * faceString = [sender currentTitle];
    // 调用代理方法
    if ([self.delegate respondsToSelector:@selector(emojiView:emojiStr:)]) {
        [self.delegate emojiView:self emojiStr:faceString];
    }
}

- (void)typeBtnAction:(UIButton *)sender {
    _isTouchBtn = YES;
    [UIView animateWithDuration:0.5 animations:^{
        [_faceScrollView setContentOffset:CGPointMake([_offSets[_selectedCellIndex] floatValue], 0)];
    } completion:^(BOOL finished) {
        _isTouchBtn = NO;
    }];
}

#pragma mark - property
- (UICollectionView *)faceTypeCollectionView {
    if (!_faceTypeCollectionView) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _faceTypeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:flowLayout];
        _faceTypeCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20);
        _faceTypeCollectionView.showsHorizontalScrollIndicator = NO;
        _faceTypeCollectionView.delegate  = self;
        _faceTypeCollectionView.dataSource = self;
        _faceTypeCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_faceTypeCollectionView registerClass:[YM_FaceTypeCell class] forCellWithReuseIdentifier:YM_FaceTypeCellID];
    }
    return _faceTypeCollectionView;
}

- (UIScrollView *)faceScrollView {
    if (!_faceScrollView) {
        _faceScrollView = [[UIScrollView alloc] init];
        _faceScrollView.frame = CGRectMake(0, 20, SCREEN_WIDTH,200);
        _faceScrollView.pagingEnabled = YES;
        _faceScrollView.showsHorizontalScrollIndicator = NO;
        _faceScrollView.delegate = self;
    }
    return _faceScrollView;
}

@end
