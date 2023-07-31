//
//  YM_DateVideoEditBottomView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DateVideoEditBottomView.h"
#import "NSBundle+YM_PhotoPicker.h"
#import "YM_DataVideoEditBottomViewCell.h"

#define hxItemHeight ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) ? 40 : 50
#define hxItemWidth hxItemHeight/16*9


@interface YM_DateVideoEditBottomView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) UIButton *cancelBtn;

@property (strong, nonatomic) UIButton *doneBtn;

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) YM_PhotoManager *manager;

@end

@implementation YM_DateVideoEditBottomView


- (instancetype)initWithManager:(YM_PhotoManager *)manager {
    self = [super init];
    if (self) {
        self.manager = manager;
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.cancelBtn];
    [self addSubview:self.doneBtn];
    [self addSubview:self.collectionView];
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    [self.collectionView reloadData];
    [self layoutSubviews];
}

- (void)didCancelBtnClick {
    if ([self.delegate respondsToSelector:@selector(videoEditBottomViewDidCancelClick:)]) {
        [self.delegate videoEditBottomViewDidCancelClick:self];
    }
}
#pragma mark - < UICollectionViewDataSource >
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YM_DataVideoEditBottomViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
    cell.imageView.image = self.dataArray[indexPath.item];
    return cell;
}

- (void)layoutSubviews {
    self.cancelBtn.hx_x = 12;
    self.cancelBtn.hx_h = hxItemHeight;
    self.cancelBtn.hx_w = hxItemHeight;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat collectionViewX = 0.0;
    CGFloat collectionViewY = 5;
    CGFloat itemH = hxItemHeight;
    CGFloat itemW = hxItemWidth;
    CGFloat collectionViewW = 0;
    if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
        collectionViewY = 10;
        self.cancelBtn.hx_y = self.hx_h - self.cancelBtn.hx_h - kBottomMargin;
        collectionViewX = 5;
        collectionViewW = self.hx_w - collectionViewX * 2;
    }else {
        collectionViewX = CGRectGetMaxX(self.cancelBtn.frame);
        collectionViewW = self.hx_w - collectionViewX * 2;
        self.cancelBtn.hx_y = self.hx_h - self.cancelBtn.hx_h - kBottomMargin + 5;
    }
    if (self.dataArray.count) {
        itemW = collectionViewW / self.dataArray.count;
    }
    self.flowLayout.itemSize = CGSizeMake(itemW, itemH);
    self.collectionView.frame = CGRectMake(collectionViewX, collectionViewY, collectionViewW, hxItemHeight);
}

#pragma mark - < 懒加载 >
- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cancelBtn setTitle:[NSBundle ym_localizedStringForKey:@"取消"] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelBtn addTarget:self action:@selector(didCancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
    }
    return _doneBtn;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[YM_DataVideoEditBottomViewCell class] forCellWithReuseIdentifier:@"CellId"];
    }
    return _collectionView;
}


@end
