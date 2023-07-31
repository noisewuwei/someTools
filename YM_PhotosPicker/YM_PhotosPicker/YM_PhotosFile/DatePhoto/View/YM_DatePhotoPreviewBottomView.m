//
//  YM_DatePhotoPreviewBottomView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoPreviewBottomView.h"
#import "YM_PhotoManager.h"
#import "UIImageView+YM_Extension.h"
#import "YM_DatePhotoPreviewBottomViewCell.h"
@interface YM_DatePhotoPreviewBottomView () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) UIButton *doneBtn;
@property (strong, nonatomic) UIButton *editBtn;
@property (strong, nonatomic) YM_PhotoManager *manager;


@end

@implementation YM_DatePhotoPreviewBottomView

- (instancetype)initWithFrame:(CGRect)frame modelArray:(NSArray *)modelArray manager:(YM_PhotoManager *)manager {
    self = [super initWithFrame:frame];
    if (self) {
        self.manager = manager;
        self.modelArray = [NSMutableArray arrayWithArray:modelArray];
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    self.currentIndex = -1;
    [self addSubview:self.bgView];
    [self addSubview:self.collectionView];
    [self addSubview:self.doneBtn];
    [self addSubview:self.editBtn];
    [self changeDoneBtnFrame];
}
- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.editBtn.enabled = enabled;
}
- (void)setHideEditBtn:(BOOL)hideEditBtn {
    _hideEditBtn = hideEditBtn;
    if (hideEditBtn) {
        [self.editBtn removeFromSuperview];
        [self layoutSubviews];
    }else {
        [self addSubview:self.editBtn];
    }
}
- (void)setOutside:(BOOL)outside {
    _outside = outside;
    if (outside) {
        self.doneBtn.hidden = YES;
    }
}
- (void)setShowTipView:(BOOL)showTipView {
    _showTipView = showTipView;
    self.tipView.hidden = !showTipView;
}
- (void)setTipStr:(NSString *)tipStr {
    _tipStr = tipStr;
    self.tipLb.text = tipStr;
}
- (void)insertModel:(YM_PhotoModel *)model {
    [self.modelArray addObject:model];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.modelArray.count - 1 inSection:0]]];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.modelArray.count - 1 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}
- (void)deleteModel:(YM_PhotoModel *)model {
    if ([self.modelArray containsObject:model]) {
        NSInteger index = [self.modelArray indexOfObject:model];
        [self.modelArray removeObject:model];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    }
}
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    if (currentIndex < 0 || currentIndex > self.modelArray.count - 1) {
        return;
    }
    self.currentIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
    //    [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self.collectionView selectItemAtIndexPath:self.currentIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}
- (void)setSelectCount:(NSInteger)selectCount {
    _selectCount = selectCount;
    if (selectCount <= 0) {
        [self.doneBtn setTitle:[NSBundle ym_localizedStringForKey:@"完成"] forState:UIControlStateNormal];
    }else {
        if (self.manager.configuration.doneBtnShowDetail) {
            if (!self.manager.configuration.selectTogether) {
                if (self.manager.selectedPhotoCount > 0) {
                    [self.doneBtn setTitle:[NSString stringWithFormat:@"%@(%ld/%ld)",[NSBundle ym_localizedStringForKey:@"完成"],selectCount,self.manager.configuration.photoMaxNum] forState:UIControlStateNormal];
                }else {
                    [self.doneBtn setTitle:[NSString stringWithFormat:@"%@(%ld/%ld)",[NSBundle ym_localizedStringForKey:@"完成"],selectCount,self.manager.configuration.videoMaxNum] forState:UIControlStateNormal];
                }
            }else {
                [self.doneBtn setTitle:[NSString stringWithFormat:@"%@(%ld/%ld)",[NSBundle ym_localizedStringForKey:@"完成"],selectCount,self.manager.configuration.maxNum] forState:UIControlStateNormal];
            }
        }else {
            [self.doneBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",[NSBundle ym_localizedStringForKey:@"完成"],selectCount] forState:UIControlStateNormal];
        }
    }
    [self changeDoneBtnFrame];
}
#pragma mark - < UICollectionViewDataSource >
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.modelArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YM_DatePhotoPreviewBottomViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DatePreviewBottomViewCellId" forIndexPath:indexPath];
    cell.selectColor = self.manager.configuration.themeColor;
    YM_PhotoModel *model = self.modelArray[indexPath.item];
    cell.model = model;
    return cell;
}
#pragma mark - < UICollectionViewDelegate >
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delagate respondsToSelector:@selector(datePhotoPreviewBottomViewDidItem:currentIndex:beforeIndex:)]) {
        [self.delagate datePhotoPreviewBottomViewDidItem:self.modelArray[indexPath.item] currentIndex:indexPath.item beforeIndex:self.currentIndex];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(YM_DatePhotoPreviewBottomViewCell *)cell cancelRequest];
}
- (void)deselectedWithIndex:(NSInteger)index {
    if (index < 0 || index > self.modelArray.count - 1) {
        return;
    }
    [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:NO];
}

- (void)deselected {
    if (self.currentIndex < 0 || self.currentIndex > self.modelArray.count - 1) {
        return;
    }
    [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] animated:NO];
}

- (void)didDoneBtnClick {
    if ([self.delagate respondsToSelector:@selector(datePhotoPreviewBottomViewDidDone:)]) {
        [self.delagate datePhotoPreviewBottomViewDidDone:self];
    }
}
- (void)didEditBtnClick {
    if ([self.delagate respondsToSelector:@selector(datePhotoPreviewBottomViewDidEdit:)]) {
        [self.delagate datePhotoPreviewBottomViewDidEdit:self];
    }
}
- (void)changeDoneBtnFrame {
    if (self.outside) {
        if (self.manager.afterSelectedPhotoArray.count && self.manager.afterSelectedVideoArray.count) {
            if (self.manager.configuration.videoCanEdit && self.manager.configuration.photoCanEdit) {
                self.collectionView.hx_w = self.hx_w - 12;
            }else {
                self.editBtn.hx_x = self.hx_w - 12 - self.editBtn.hx_w;
                self.collectionView.hx_w = self.editBtn.hx_x;
            }
        }else {
            if (self.hideEditBtn) {
                self.collectionView.hx_w = self.hx_w - 12;
            }else {
                self.editBtn.hx_x = self.hx_w - 12 - self.editBtn.hx_w;
                self.collectionView.hx_w = self.editBtn.hx_x;
            }
        }
    }else {
        CGFloat width = [YM_PhotoTools getTextWidth:self.doneBtn.currentTitle height:30 fontSize:14];
        self.doneBtn.hx_w = width + 20;
        if (self.doneBtn.hx_w < 50) {
            self.doneBtn.hx_w = 50;
        }
        self.doneBtn.hx_x = self.hx_w - 12 - self.doneBtn.hx_w;
        self.editBtn.hx_x = self.doneBtn.hx_x - self.editBtn.hx_w;
        if (self.manager.type == YM_PhotoManagerType_Photo || self.manager.type == YM_PhotoManagerType_Video) {
            if (!self.hideEditBtn) {
                self.collectionView.hx_w = self.editBtn.hx_x;
            }else {
                self.collectionView.hx_w = self.doneBtn.hx_x - 12;
            }
        }else {
            if (!self.manager.configuration.videoCanEdit && !self.manager.configuration.photoCanEdit) {
                self.collectionView.hx_w = self.doneBtn.hx_x - 12;
            }else {
                self.collectionView.hx_w = self.editBtn.hx_x;
            }
        }
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgView.frame = self.bounds;
    self.collectionView.frame = CGRectMake(0, 0,self.hx_w - 12 - 50, 50);
    self.doneBtn.frame = CGRectMake(0, 0, 50, 30);
    self.doneBtn.center = CGPointMake(self.doneBtn.center.x, 25);
    
    self.tipView.frame = CGRectMake(0, -40, self.hx_w, 40);
    self.tipLb.frame = CGRectMake(12, 0, self.hx_w - 24, 40);
    
    [self changeDoneBtnFrame];
}
#pragma mark - < 懒加载 >
- (UIToolbar *)bgView {
    if (!_bgView) {
        _bgView = [[UIToolbar alloc] init];
    }
    return _bgView;
}
- (UIToolbar *)tipView {
    if (!_tipView) {
        _tipView = [[UIToolbar alloc] init];
        _tipView.hidden = YES;
        [_tipView addSubview:self.tipLb];
    }
    return _tipView;
}
- (UILabel *)tipLb {
    if (!_tipLb) {
        _tipLb = [[UILabel alloc] init];
        _tipLb.text = [NSBundle ym_localizedStringForKey:@"选择照片时不能选择视频"];
        _tipLb.textColor = self.manager.configuration.themeColor;
        _tipLb.font = [UIFont systemFontOfSize:14];
    }
    return _tipLb;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,self.hx_w - 12 - 50, 50) collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[YM_DatePhotoPreviewBottomViewCell class] forCellWithReuseIdentifier:@"DatePreviewBottomViewCellId"];
    }
    return _collectionView;
}
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = 40;
        _flowLayout.itemSize = CGSizeMake(itemWidth, 48);
        _flowLayout.sectionInset = UIEdgeInsetsMake(1, 12, 1, 0);
        _flowLayout.minimumInteritemSpacing = 1;
        _flowLayout.minimumLineSpacing = 1;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}
- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneBtn setTitle:[NSBundle ym_localizedStringForKey:@"完成"] forState:UIControlStateNormal];
        if ([self.manager.configuration.themeColor isEqual:[UIColor whiteColor]]) {
            [_doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_doneBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        }else {
            [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_doneBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        }
        if (self.manager.configuration.selectedTitleColor) {
            [_doneBtn setTitleColor:self.manager.configuration.selectedTitleColor forState:UIControlStateNormal];
            [_doneBtn setTitleColor:[self.manager.configuration.selectedTitleColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        }
        _doneBtn.titleLabel.font = [UIFont ym_pingFangFontOfSize:14];
        _doneBtn.layer.cornerRadius = 3;
        _doneBtn.backgroundColor = self.manager.configuration.themeColor;
        [_doneBtn addTarget:self action:@selector(didDoneBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}
- (UIButton *)editBtn {
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editBtn setTitle:[NSBundle ym_localizedStringForKey:@"编辑"] forState:UIControlStateNormal];
        [_editBtn setTitleColor:self.manager.configuration.themeColor forState:UIControlStateNormal];
        [_editBtn setTitleColor:[self.manager.configuration.themeColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_editBtn addTarget:self action:@selector(didEditBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _editBtn.hx_size = CGSizeMake(50, 50);
    }
    return _editBtn;
}

@end
