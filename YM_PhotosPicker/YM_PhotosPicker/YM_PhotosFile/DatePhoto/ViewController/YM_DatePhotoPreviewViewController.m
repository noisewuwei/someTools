//
//  YM_DatePhotoPreviewViewController.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoPreviewViewController.h"

/** other */
#import "YM_DatePhotoViewTransition.h"
#import "YM_DatePhotoViewPresentTransition.h"

/** category */
#import "UIButton+YM_Extension.h"

/** viewController */
#import "YM_DatePhotoEditViewController.h"
#import "YM_DateVideoEditViewController.h"
#import "YM_DatePhotoInteractiveTransition.h"

/** view */
#import "YM_PhotoCustomNavigationBar.h"
#import "YM_DatePhotoPreviewBottomView.h"
#import "YM_DatePhotoPreviewViewCell.h"
@interface YM_DatePhotoPreviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate, YM_DatePhotoPreviewBottomViewDelegate, YM_DatePhotoEditViewControllerDelegate, YM_DateVideoEditViewControllerDelegate>

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) YM_PhotoModel *currentModel;
@property (strong, nonatomic) UIView *customTitleView;
@property (strong, nonatomic) UILabel *titleLb;
@property (strong, nonatomic) UILabel *subTitleLb;
@property (strong, nonatomic) YM_DatePhotoPreviewViewCell *tempCell;
@property (strong, nonatomic) UIButton *selectBtn;
@property (assign, nonatomic) BOOL orientationDidChange;
@property (assign, nonatomic) NSInteger beforeOrientationIndex;
@property (strong, nonatomic) YM_DatePhotoInteractiveTransition *interactiveTransition;
@property (strong, nonatomic) YM_PhotoCustomNavigationBar *navBar;
@property (strong, nonatomic) UINavigationItem *navItem;
@property (assign, nonatomic) BOOL isAddInteractiveTransition;

@end

@implementation YM_DatePhotoPreviewViewController


- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.currentModelIndex = 0;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:self.manager.configuration.statusBarStyle];
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPush) {
        return [YM_DatePhotoViewTransition transitionWithType:YM_DatePhotoViewTransitionType_Push];
    }else {
        if (![fromVC isKindOfClass:[self class]]) {
            return nil;
        }
        return [YM_DatePhotoViewTransition transitionWithType:YM_DatePhotoViewTransitionType_Pop];
    }
}
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    return self.interactiveTransition.interation ? self.interactiveTransition : nil;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [YM_DatePhotoViewPresentTransition transitionWithTransitionType:YM_DatePhotoViewPresentTransitionType_Present photoView:self.photoView];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [YM_DatePhotoViewPresentTransition transitionWithTransitionType:YM_DatePhotoViewPresentTransitionType_Dismiss photoView:self.photoView];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.orientationDidChange) {
        self.orientationDidChange = NO;
        [self changeSubviewFrame];
    }
}
- (void)deviceOrientationChanged:(NSNotification *)notify {
    self.orientationDidChange = YES;
}
- (void)deviceOrientationWillChanged:(NSNotification *)notify {
    self.beforeOrientationIndex = self.currentModelIndex;
}
- (YM_DatePhotoPreviewViewCell *)currentPreviewCell:(YM_PhotoModel *)model {
    if (!model) {
        return nil;
    }
    return (YM_DatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
}
- (void)changeSubviewFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    YM_PhotoModel *model = self.modelArray[self.currentModelIndex];
    if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.titleLb.hidden = NO;
        self.customTitleView.frame = CGRectMake(0, 0, 150, 44);
        self.titleLb.frame = CGRectMake(0, 9, 150, 14);
        self.subTitleLb.frame = CGRectMake(0, CGRectGetMaxY(self.titleLb.frame) + 4, 150, 12);
        self.titleLb.text = model.barTitle;
        self.subTitleLb.text = model.barSubTitle;
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.customTitleView.frame = CGRectMake(0, 0, 200, 30);
        self.titleLb.hidden = YES;
        self.subTitleLb.frame = CGRectMake(0, 0, 200, 30);
        self.subTitleLb.text = [NSString stringWithFormat:@"%@  %@",model.barTitle,model.barSubTitle];
    }
    CGFloat bottomMargin = kBottomMargin;
    //    CGFloat leftMargin = 0;
    //    CGFloat rightMargin = 0;
    CGFloat width = self.view.hx_w;
    CGFloat itemMargin = 20;
    if (kDevice_Is_iPhoneX && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
        bottomMargin = 21;
        //        leftMargin = 35;
        //        rightMargin = 35;
        //        width = self.view.hx_w - 70;
    }
    self.flowLayout.itemSize = CGSizeMake(width, self.view.hx_h - kTopMargin - bottomMargin);
    self.flowLayout.minimumLineSpacing = itemMargin;
    
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    //    self.collectionView.contentInset = UIEdgeInsetsMake(0, leftMargin, 0, rightMargin);
    if (self.outside) {
        self.navBar.frame = CGRectMake(0, 0, self.view.hx_w, kNavigationBarHeight);
    }
    self.collectionView.frame = CGRectMake(-(itemMargin / 2), kTopMargin,self.view.hx_w + itemMargin, self.view.hx_h - kTopMargin - bottomMargin);
    self.collectionView.contentSize = CGSizeMake(self.modelArray.count * (self.view.hx_w + itemMargin), 0);
    
    [self.collectionView setContentOffset:CGPointMake(self.beforeOrientationIndex * (self.view.hx_w + itemMargin), 0)];
    
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.beforeOrientationIndex inSection:0]]];
    }];
    
    CGFloat bottomViewHeight = self.view.hx_h - 50 - bottomMargin;
    self.bottomView.frame = CGRectMake(0, bottomViewHeight, self.view.hx_w, 50 + bottomMargin);
    if (self.manager.configuration.previewCollectionView) {
        self.manager.configuration.previewCollectionView(self.collectionView);
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    YM_PhotoModel *model = self.modelArray[self.currentModelIndex];
    self.currentModel = model;
    YM_DatePhotoPreviewViewCell *cell = (YM_DatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
    if (!cell) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            YM_DatePhotoPreviewViewCell *tempCell = (YM_DatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
            self.tempCell = tempCell;
            [tempCell requestHDImage];
        });
    }else {
        self.tempCell = cell;
        [cell requestHDImage];
    }
    if (!self.isAddInteractiveTransition) {
        if (!self.outside) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //初始化手势过渡的代理
                self.interactiveTransition = [[YM_DatePhotoInteractiveTransition alloc] init];
                //给当前控制器的视图添加手势
                [self.interactiveTransition addPanGestureForViewController:self];
            });
        }
        self.isAddInteractiveTransition = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    YM_DatePhotoPreviewViewCell *cell = (YM_DatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
    cell.stopCancel = self.stopCancel;
    [cell cancelRequest];
    self.stopCancel = NO;
}
- (void)setupUI {
    self.navigationItem.titleView = self.customTitleView;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    self.beforeOrientationIndex = self.currentModelIndex;
    [self changeSubviewFrame];
    YM_PhotoModel *model = self.modelArray[self.currentModelIndex];
    self.bottomView.outside = self.outside;
    
    if (self.manager.type == YM_PhotoManagerType_Video && !self.manager.configuration.videoCanEdit) {
        self.bottomView.hideEditBtn = YES;
    }else if (self.manager.type == YM_PhotoManagerType_Photo && !self.manager.configuration.photoCanEdit) {
        self.bottomView.hideEditBtn = YES;
    }else {
        if (!self.manager.configuration.videoCanEdit && !self.manager.configuration.photoCanEdit) {
            self.bottomView.hideEditBtn = YES;
        }
    }
    
    if (!self.outside) {
        if (self.manager.configuration.navigationTitleSynchColor) {
            self.titleLb.textColor = self.manager.configuration.themeColor;
            self.subTitleLb.textColor = self.manager.configuration.themeColor;
        }else {
            UIColor *titleColor = [self.navigationController.navigationBar.titleTextAttributes objectForKey:NSForegroundColorAttributeName];
            if (titleColor) {
                self.titleLb.textColor = titleColor;
                self.subTitleLb.textColor = titleColor;
            }
            if (self.manager.configuration.navigationTitleColor) {
                self.titleLb.textColor = self.manager.configuration.navigationTitleColor;
                self.subTitleLb.textColor = self.manager.configuration.navigationTitleColor;
            }
        }
        if (model.subType == YM_PhotoModelMediaSubType_Video) {
            self.bottomView.enabled = self.manager.configuration.videoCanEdit;
        } else {
            if (!self.manager.configuration.selectTogether) {
                if (self.manager.selectedVideoArray.count > 0) {
                    self.bottomView.enabled = NO;
                }else {
                    if ([self.manager beforeSelectPhotoCountIsMaximum] && !model.selected) {
                        self.bottomView.enabled = NO;
                    }else {
                        self.bottomView.enabled = self.manager.configuration.photoCanEdit;
                    }
                }
            }else {
                if ([self.manager beforeSelectPhotoCountIsMaximum] && !model.selected) {
                    self.bottomView.enabled = NO;
                }else {
                    self.bottomView.enabled = self.manager.configuration.photoCanEdit;
                }
            }
        }
        self.bottomView.selectCount = [self.manager selectedCount];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
        self.selectBtn.selected = model.selected;
        [self.selectBtn setTitle:model.selectIndexStr forState:UIControlStateSelected];
        self.selectBtn.backgroundColor = self.selectBtn.selected ? self.manager.configuration.themeColor : nil;
        if ([self.manager.selectedArray containsObject:model]) {
            self.bottomView.currentIndex = [[self.manager selectedArray] indexOfObject:model];
        }else {
            [self.bottomView deselected];
        }
        if (self.manager.configuration.singleSelected) {
            self.selectBtn.hidden = YES;
            self.bottomView.hideEditBtn = self.manager.configuration.singleJumpEdit;
        }else {
#pragma mark - < 单选视频时隐藏选择按钮 >
            if (model.needHideSelectBtn) {
                self.selectBtn.hidden = YES;
                self.selectBtn.userInteractionEnabled = NO;
            }
        }
    }else {
        self.bottomView.selectCount = [self.manager afterSelectedCount];
        if ([self.manager.afterSelectedArray containsObject:model]) {
            self.bottomView.currentIndex = [[self.manager afterSelectedArray] indexOfObject:model];
        }else {
            [self.bottomView deselected];
        }
        if (model.subType == YM_PhotoModelMediaSubType_Video) {
            self.bottomView.enabled = self.manager.configuration.videoCanEdit;
        } else {
            self.bottomView.enabled = self.manager.configuration.photoCanEdit;
        }
        [self.view addSubview:self.navBar];
        [self.navBar setTintColor:self.manager.configuration.themeColor];
        if (self.manager.configuration.navBarBackgroudColor) {
            self.navBar.barTintColor = self.manager.configuration.navBarBackgroudColor;
        }
        if (self.manager.configuration.navigationBar) {
            self.manager.configuration.navigationBar(self.navBar);
        }
        if (self.manager.configuration.navigationTitleSynchColor) {
            self.titleLb.textColor = self.manager.configuration.themeColor;
            self.subTitleLb.textColor = self.manager.configuration.themeColor;
        }else {
            UIColor *titleColor = [self.navBar.titleTextAttributes objectForKey:NSForegroundColorAttributeName];
            if (titleColor) {
                self.titleLb.textColor = titleColor;
                self.subTitleLb.textColor = titleColor;
            }
            if (self.manager.configuration.navigationTitleColor) {
                self.titleLb.textColor = self.manager.configuration.navigationTitleColor;
                self.subTitleLb.textColor = self.manager.configuration.navigationTitleColor;
            }
        }
    }
    if (self.manager.configuration.previewBottomView) {
        self.manager.configuration.previewBottomView(self.bottomView);
    }
}
- (void)didSelectClick:(UIButton *)button {
    if (self.modelArray.count <= 0 || self.outside) {
        [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"没有照片可选!"]];
        return;
    }
    YM_PhotoModel *model = self.modelArray[self.currentModelIndex];
    if (model.isICloud) {
        YM_DatePhotoPreviewViewCell *cell = (YM_DatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
        [cell cancelRequest];
        [cell requestHDImage];
        [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"正在下载iCloud上的资源"]];
        return;
    }
    if (button.selected) {
        button.selected = NO;
        [self.manager beforeSelectedListdeletePhotoModel:model];
    }else {
        NSString *str = [self.manager maximumOfJudgment:model];
        if (str) {
            [self.view showImageHUDText:str];
            return;
        }
        YM_DatePhotoPreviewViewCell *cell = (YM_DatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
        if (model.type == YM_PhotoModelMediaType_PhotoGif) {
            if (cell.imageView.image.images.count > 0) {
                model.thumbPhoto = cell.imageView.image.images.firstObject;
                model.previewPhoto = cell.imageView.image.images.firstObject;
            }else {
                model.thumbPhoto = cell.imageView.image;
                model.previewPhoto = cell.imageView.image;
            }
        }else {
            model.thumbPhoto = cell.imageView.image;
            model.previewPhoto = cell.imageView.image;
        }
        [self.manager beforeSelectedListAddPhotoModel:model];
        button.selected = YES;
        [button setTitle:model.selectIndexStr forState:UIControlStateSelected];
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        anim.duration = 0.25;
        anim.values = @[@(1.2),@(0.8),@(1.1),@(0.9),@(1.0)];
        [button.layer addAnimation:anim forKey:@""];
    }
    button.backgroundColor = button.selected ? self.manager.configuration.themeColor : nil;
    if ([self.delegate respondsToSelector:@selector(datePhotoPreviewControllerDidSelect:model:)]) {
        [self.delegate datePhotoPreviewControllerDidSelect:self model:model];
    }
    self.bottomView.selectCount = [self.manager selectedCount];
    if (button.selected) {
        [self.bottomView insertModel:model];
    }else {
        [self.bottomView deleteModel:model];
    }
}
#pragma mark - < UICollectionViewDataSource >
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.modelArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YM_DatePhotoPreviewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DatePreviewCellId" forIndexPath:indexPath];
    YM_PhotoModel *model = self.modelArray[indexPath.item];
    cell.model = model;
    kWeakSelf
    [cell setCellDidPlayVideoBtn:^(BOOL play) {
        kStrongSelf
        if (play) {
            if (self.bottomView.userInteractionEnabled) {
                [self setSubviewAlphaAnimate:YES];
            }
        }else {
            if (!self.bottomView.userInteractionEnabled) {
                [self setSubviewAlphaAnimate:YES];
            }
        }
    }];
    [cell setCellDownloadICloudAssetComplete:^(YM_DatePhotoPreviewViewCell *myCell) {
        kStrongSelf
        if ([self.delegate respondsToSelector:@selector(datePhotoPreviewDownLoadICloudAssetComplete:model:)]) {
            [self.delegate datePhotoPreviewDownLoadICloudAssetComplete:self model:myCell.model];
        }
    }];
    [cell setCellTapClick:^{
        kStrongSelf
        [self setSubviewAlphaAnimate:YES];
    }];
    return cell;
}
- (void)setSubviewAlphaAnimate:(BOOL)animete duration:(NSTimeInterval)duration {
    BOOL hide = NO;
    if (self.bottomView.alpha == 1) {
        hide = YES;
    }
    if (!hide) {
        [self.navigationController setNavigationBarHidden:hide animated:NO];
    }
    self.bottomView.userInteractionEnabled = !hide;
    if (animete) {
        [[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:UIStatusBarAnimationFade];
        [UIView animateWithDuration:duration animations:^{
            self.navigationController.navigationBar.alpha = hide ? 0 : 1;
            if (self.outside) {
                self.navBar.alpha = hide ? 0 : 1;
            }
            self.view.backgroundColor = hide ? [UIColor blackColor] : [UIColor whiteColor];
            self.collectionView.backgroundColor = hide ? [UIColor blackColor] : [UIColor whiteColor];
            self.bottomView.alpha = hide ? 0 : 1;
        } completion:^(BOOL finished) {
            if (hide) {
                [self.navigationController setNavigationBarHidden:hide animated:NO];
            }
        }];
    }else {
        [[UIApplication sharedApplication] setStatusBarHidden:hide];
        self.navigationController.navigationBar.alpha = hide ? 0 : 1;
        if (self.outside) {
            self.navBar.alpha = hide ? 0 : 1;
        }
        self.view.backgroundColor = hide ? [UIColor blackColor] : [UIColor whiteColor];
        self.collectionView.backgroundColor = hide ? [UIColor blackColor] : [UIColor whiteColor];
        self.bottomView.alpha = hide ? 0 : 1;
        if (hide) {
            [self.navigationController setNavigationBarHidden:hide];
        }
    }
}
- (void)setSubviewAlphaAnimate:(BOOL)animete {
    [self setSubviewAlphaAnimate:animete duration:0.15];
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(YM_DatePhotoPreviewViewCell *)cell resetScale];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(YM_DatePhotoPreviewViewCell *)cell cancelRequest];
}
#pragma mark - < UICollectionViewDelegate >
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat offsetx = self.collectionView.contentOffset.x;
    NSInteger currentIndex = (offsetx + (width + 20) * 0.5) / (width + 20);
    if (currentIndex > self.modelArray.count - 1) {
        currentIndex = self.modelArray.count - 1;
    }
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    if (self.modelArray.count > 0) {
        YM_PhotoModel *model = self.modelArray[currentIndex];
        if (model.subType == YM_PhotoModelMediaSubType_Video) {
            // 为视频时
            //            self.bottomView.enabled = self.manager.configuration.videoCanEdit;
            self.bottomView.hideEditBtn = !self.manager.configuration.videoCanEdit;
        }else {
            self.bottomView.hideEditBtn = !self.manager.configuration.photoCanEdit;
            if (!self.manager.configuration.selectTogether) {
                // 照片,视频不能同时选择时
                if (self.manager.selectedVideoArray.count > 0) {
                    // 如果有选择视频那么照片就不能编辑
                    self.bottomView.enabled = NO;
                }else {
                    // 没有选择视频时
                    if ([self.manager beforeSelectPhotoCountIsMaximum] && !model.selected) {
                        // 当选择照片数达到最大数且当前照片没选中时就不能编辑
                        self.bottomView.enabled = NO;
                    }else {
                        // 反之就能
                        self.bottomView.enabled = self.manager.configuration.photoCanEdit;
                    }
                }
            }else {
                // 能同时选择时
                if ([self.manager beforeSelectPhotoCountIsMaximum] && !model.selected) {
                    // 当选择照片数达到最大数且当前照片没选中时就不能编辑
                    self.bottomView.enabled = NO;
                }else {
                    // 反之就能
                    self.bottomView.enabled = self.manager.configuration.photoCanEdit;
                }
            }
        }
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
            self.titleLb.text = model.barTitle;
            self.subTitleLb.text = model.barSubTitle;
        }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
            self.subTitleLb.text = [NSString stringWithFormat:@"%@  %@",model.barTitle,model.barSubTitle];
        }
        self.selectBtn.selected = model.selected;
        [self.selectBtn setTitle:model.selectIndexStr forState:UIControlStateSelected];
        self.selectBtn.backgroundColor = self.selectBtn.selected ? self.manager.configuration.themeColor : nil;
        if (self.outside) {
            /*
             if ([[self.manager afterSelectedArray] containsObject:model]) {
             self.bottomView.currentIndex = [[self.manager afterSelectedArray] indexOfObject:model];
             }else {
             [self.bottomView deselected];
             }
             */
            if ([self.modelArray containsObject:model]) {
                self.bottomView.currentIndex = [self.modelArray indexOfObject:model];
            }else {
                [self.bottomView deselected];
            }
        }else {
#pragma mark - < 单选视频时隐藏选择按钮 >
            if (model.needHideSelectBtn) {
                self.selectBtn.hidden = YES;
                self.selectBtn.userInteractionEnabled = NO;
            }else {
                self.selectBtn.hidden = NO;
                self.selectBtn.userInteractionEnabled = YES;
            }
            if ([[self.manager selectedArray] containsObject:model]) {
                self.bottomView.currentIndex = [[self.manager selectedArray] indexOfObject:model];
            }else {
                [self.bottomView deselected];
            }
        }
    }
    self.currentModelIndex = currentIndex;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.modelArray.count > 0) {
        YM_DatePhotoPreviewViewCell *cell = (YM_DatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
        YM_PhotoModel *model = self.modelArray[self.currentModelIndex];
        self.currentModel = model;
        [cell requestHDImage];
    }
}
- (void)datePhotoPreviewBottomViewDidItem:(YM_PhotoModel *)model currentIndex:(NSInteger)currentIndex beforeIndex:(NSInteger)beforeIndex {
    if ([self.modelArray containsObject:model]) {
        NSInteger index = [self.modelArray indexOfObject:model];
        if (self.currentModelIndex == index) {
            return;
        }
        self.currentModelIndex = index;
        [self.collectionView setContentOffset:CGPointMake(self.currentModelIndex * (self.view.hx_w + 20), 0) animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollViewDidEndDecelerating:self.collectionView];
        });
    }else {
        if (beforeIndex == -1) {
            [self.bottomView deselectedWithIndex:currentIndex];
        }
        self.bottomView.currentIndex = beforeIndex;
    }
}
- (void)datePhotoPreviewBottomViewDidEdit:(YM_DatePhotoPreviewBottomView *)bottomView {
    if (!self.modelArray.count) {
        [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"当前没有可编辑的资源"]];
        return;
    }
    if (self.currentModel.networkPhotoUrl) {
        if (self.currentModel.downloadError) {
            [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"下载失败"]];
            return;
        }
        if (!self.currentModel.downloadComplete) {
            [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"照片正在下载"]];
            return;
        }
    }
    if (self.currentModel.subType == YM_PhotoModelMediaSubType_Photo) {
        YM_DatePhotoEditViewController *vc = [[YM_DatePhotoEditViewController alloc] init];
        vc.model = [self.modelArray objectAtIndex:self.currentModelIndex];
        vc.delegate = self;
        vc.manager = self.manager;
        if (self.outside) {
            vc.outside = YES;
            [self presentViewController:vc animated:NO completion:nil];
        }else {
            [self.navigationController pushViewController:vc animated:NO];
        }
    }else {
        if (self.manager.configuration.replaceVideoEditViewController) {
#pragma mark - < 替换视频编辑 >
            if (self.manager.configuration.shouldUseVideoEdit) {
                self.manager.configuration.shouldUseVideoEdit(self, self.manager, [self.modelArray objectAtIndex:self.currentModelIndex]);
            }
            kWeakSelf
            self.manager.configuration.useVideoEditComplete = ^(YM_PhotoModel *beforeModel, YM_PhotoModel *afterModel) {
                kStrongSelf
                [self datePhotoEditViewControllerDidClipClick:nil beforeModel:beforeModel afterModel:afterModel];
            };
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"要使用视频编辑功能，请先替换视频编辑界面" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [alert show];
            //            HXDateVideoEditViewController *vc = [[HXDateVideoEditViewController alloc] init];
            //            vc.model = [self.modelArray objectAtIndex:self.currentModelIndex];
            //            vc.delegate = self;
            //            vc.manager = self.manager;
            //            if (self.outside) {
            //                vc.outside = YES;
            //                [self presentViewController:vc animated:NO completion:nil];
            //            }else {
            //                [self.navigationController pushViewController:vc animated:NO];
            //            }
        }
    }
}
- (void)datePhotoPreviewBottomViewDidDone:(YM_DatePhotoPreviewBottomView *)bottomView {
    if (self.outside) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if (self.modelArray.count == 0) {
        [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"没有照片可选!"]];
        return;
    }
    YM_PhotoModel *model = self.modelArray[self.currentModelIndex];
    if (self.manager.configuration.singleSelected) {
        if (model.type == YM_PhotoModelMediaType_Video ) {
            if (model.asset.duration > self.manager.configuration.videoMaxDuration) {
                [self.view showImageHUDText: [NSBundle ym_localizedStringForKey:@"视频过大,无法选择"]];
                return;
            }else if (model.asset.duration < 3.f) {
                [self.view showImageHUDText: [NSBundle ym_localizedStringForKey:@"视频少于3秒,无法选择"]];
                return;
            }
        }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
            if (model.videoDuration > self.manager.configuration.videoMaxDuration) {
                [self.view showImageHUDText: [NSBundle ym_localizedStringForKey:@"视频过大,无法选择"]];
                return;
            }else if (model.videoDuration < 3.f) {
                [self.view showImageHUDText: [NSBundle ym_localizedStringForKey:@"视频少于3秒,无法选择"]];
                return;
            }
        }
        if ([self.delegate respondsToSelector:@selector(datePhotoPreviewSingleSelectedClick:model:)]) {
            [self.delegate datePhotoPreviewSingleSelectedClick:self model:model];
        }
        return;
    }
    BOOL max = NO;
    if ([self.manager selectedCount] == self.manager.configuration.maxNum) {
        // 已经达到最大选择数
        max = YES;
    }
    if (self.manager.type == YM_PhotoManagerType_All) {
        if ((model.type == YM_PhotoModelMediaType_Photo || model.type == YM_PhotoModelMediaType_PhotoGif) || (model.type == YM_PhotoModelMediaType_CameraPhoto || model.type == YM_PhotoModelMediaType_LivePhoto)) {
            if (self.manager.configuration.videoMaxNum > 0) {
                if (!self.manager.configuration.selectTogether) { // 是否支持图片视频同时选择
                    if (self.manager.selectedVideoArray.count > 0 ) {
                        // 已经选择了视频,不能再选图片
                        max = YES;
                    }
                }
            }
            if ([self.manager beforeSelectPhotoCountIsMaximum]) {
                max = YES;
                // 已经达到图片最大选择数
            }
        }
    }else if (self.manager.type == YM_PhotoManagerType_Photo) {
        if ([self.manager beforeSelectPhotoCountIsMaximum]) {
            // 已经达到图片最大选择数
            max = YES;
        }
    }
    if ([self.manager selectedCount] == 0) {
        if (model.type == YM_PhotoModelMediaType_Video ) {
            if (model.asset.duration > self.manager.configuration.videoMaxDuration) {
                [self.view showImageHUDText: [NSBundle ym_localizedStringForKey:@"视频过大,无法选择"]];
                return;
            }else if (model.asset.duration < 3.f) {
                [self.view showImageHUDText: [NSBundle ym_localizedStringForKey:@"视频少于3秒,无法选择"]];
                return;
            }
        }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
            if (model.videoDuration > self.manager.configuration.videoMaxDuration) {
                [self.view showImageHUDText: [NSBundle ym_localizedStringForKey:@"视频过大,无法选择"]];
                return;
            }else if (model.videoDuration < 3.f) {
                [self.view showImageHUDText: [NSBundle ym_localizedStringForKey:@"视频少于3秒,无法选择"]];
                return;
            }
        }
        if (!self.selectBtn.selected && !max && self.modelArray.count > 0) {
            //            model.selected = YES;
            YM_DatePhotoPreviewViewCell *cell = (YM_DatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
            if (model.type == YM_PhotoModelMediaType_PhotoGif) {
                if (cell.imageView.image.images.count > 0) {
                    model.thumbPhoto = cell.imageView.image.images.firstObject;
                    model.previewPhoto = cell.imageView.image.images.firstObject;
                }else {
                    model.thumbPhoto = cell.imageView.image;
                    model.previewPhoto = cell.imageView.image;
                }
            }else {
                model.thumbPhoto = cell.imageView.image;
                model.previewPhoto = cell.imageView.image;
            }
            [self.manager beforeSelectedListAddPhotoModel:model];
            
            //            if (model.type == YM_PhotoModelMediaType_Photo || (model.type == YM_PhotoModelMediaType_PhotoGif || model.type == YM_PhotoModelMediaType_LivePhoto)) { // 为图片时
            //                [self.manager.selectedPhotos addObject:model];
            //            }else if (model.type == YM_PhotoModelMediaType_Video) { // 为视频时
            //                [self.manager.selectedVideos addObject:model];
            //            }else if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
            //                // 为相机拍的照片时
            //                [self.manager.selectedPhotos addObject:model];
            //                [self.manager.selectedCameraPhotos addObject:model];
            //                [self.manager.selectedCameraList addObject:model];
            //            }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
            //                // 为相机录的视频时
            //                [self.manager.selectedVideos addObject:model];
            //                [self.manager.selectedCameraVideos addObject:model];
            //                [self.manager.selectedCameraList addObject:model];
            //            }
            //            [self.manager.selectedList addObject:model];
            //            model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.manager.selectedList indexOfObject:model] + 1];
        }
    }
    if ([self.delegate respondsToSelector:@selector(datePhotoPreviewControllerDidDone:)]) {
        [self.delegate datePhotoPreviewControllerDidDone:self];
    }
}
#pragma mark - < YM_DatePhotoEditViewControllerDelegate >
- (void)datePhotoEditViewControllerDidClipClick:(YM_DatePhotoEditViewController *)datePhotoEditViewController beforeModel:(YM_PhotoModel *)beforeModel afterModel:(YM_PhotoModel *)afterModel {
    if (self.outside) {
        [self.modelArray replaceObjectAtIndex:[self.modelArray indexOfObject:beforeModel] withObject:afterModel];
        if ([self.delegate respondsToSelector:@selector(datePhotoPreviewSelectLaterDidEditClick:beforeModel:afterModel:)]) {
            [self.delegate datePhotoPreviewSelectLaterDidEditClick:self beforeModel:beforeModel afterModel:afterModel];
        }
        [self dismissClick];
        return;
    }
    //    if (self.manager.configuration.saveSystemAblum) {
    //        [YM_PhotoTools savePhotoToCustomAlbumWithName:self.manager.customAlbumName photo:afterModel.thumbPhoto];
    //    }
    if (beforeModel.selected) {
        [self.manager beforeSelectedListdeletePhotoModel:beforeModel];
        
        //        beforeModel.selected = NO;
        //        beforeModel.selectIndexStr = @"";
        //        if (beforeModel.type == YM_PhotoModelMediaType_CameraPhoto) {
        //            [self.manager.selectedCameraList removeObject:beforeModel];
        //            [self.manager.selectedCameraPhotos removeObject:beforeModel];
        //        }else {
        //            beforeModel.thumbPhoto = nil;
        //            beforeModel.previewPhoto = nil;
        //        }
        //        [self.manager.selectedList removeObject:beforeModel];
        //        [self.manager.selectedPhotos removeObject:beforeModel];
    }
    [self.manager beforeSelectedListAddEditPhotoModel:afterModel];
    
    //    [self.manager.cameraPhotos addObject:afterModel];
    //    [self.manager.cameraList addObject:afterModel];
    //    [self.manager.selectedCameraPhotos addObject:afterModel];
    //    [self.manager.selectedCameraList addObject:afterModel];
    //    [self.manager.selectedPhotos addObject:afterModel];
    //    [self.manager.selectedList addObject:afterModel];
    //    afterModel.selected = YES;
    //    afterModel.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.manager.selectedList indexOfObject:afterModel] + 1];
    if ([self.delegate respondsToSelector:@selector(datePhotoPreviewDidEditClick:)]) {
        [self.delegate datePhotoPreviewDidEditClick:self];
    }
}
- (void)dismissClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)deleteClick {
    if (!self.modelArray.count) {
        [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"当前没有可删除的资源"]];
        return;
    }
    NSString *message;
    if (self.currentModel.subType == YM_PhotoModelMediaSubType_Photo) {
        message = [NSBundle ym_localizedStringForKey:@"确定删除这张照片吗?"];
    }else {
        message = [NSBundle ym_localizedStringForKey:@"确定删除这个视频吗?"];
    }
    kWeakSelf
    hx_showAlert(self, message, nil, [NSBundle ym_localizedStringForKey:@"取消"], [NSBundle ym_localizedStringForKey:@"删除"], ^{
        
    }, ^{
        kStrongSelf
        YM_PhotoModel *tempModel = self.currentModel;
        NSInteger tempIndex = self.currentModelIndex;
        
        [self.modelArray removeObject:self.currentModel];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]]];
        [self.bottomView deleteModel:self.currentModel];
        if ([self.delegate respondsToSelector:@selector(datePhotoPreviewDidDeleteClick:deleteModel:deleteIndex:)]) {
            [self.delegate datePhotoPreviewDidDeleteClick:self deleteModel:tempModel deleteIndex:tempIndex];
        }
        [self scrollViewDidScroll:self.collectionView];
        [self scrollViewDidEndDecelerating:self.collectionView];
        if (!self.modelArray.count) {
            [self dismissClick];
        }
    });
}



#pragma mark - < 懒加载 >
- (YM_PhotoCustomNavigationBar *)navBar {
    if (!_navBar) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _navBar = [[YM_PhotoCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, width, kNavigationBarHeight)];
        _navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_navBar pushNavigationItem:self.navItem animated:NO];
        [_navBar setTintColor:self.manager.configuration.themeColor];
    }
    return _navBar;
}
- (UINavigationItem *)navItem {
    if (!_navItem) {
        _navItem = [[UINavigationItem alloc] init];
        if (self.previewShowDeleteButton) {
            _navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle ym_localizedStringForKey:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissClick)];
            _navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle ym_localizedStringForKey:@"删除"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteClick)];
        }else {
            _navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle ym_localizedStringForKey:@"取消"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissClick)];
        }
        _navItem.titleView = self.customTitleView;
    }
    return _navItem;
}
- (UIView *)customTitleView {
    if (!_customTitleView) {
        _customTitleView = [[UIView alloc] init];
        [_customTitleView addSubview:self.titleLb];
        [_customTitleView addSubview:self.subTitleLb];
    }
    return _customTitleView;
}
- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        if (iOS8_2Later) {
            _titleLb.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        }else {
            _titleLb.font = [UIFont systemFontOfSize:14];
        }
        _titleLb.textColor = [UIColor blackColor];
    }
    return _titleLb;
}
- (UILabel *)subTitleLb {
    if (!_subTitleLb) {
        _subTitleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLb.frame) + 4, 150, 12)];
        _subTitleLb.textAlignment = NSTextAlignmentCenter;
        if (iOS8_2Later) {
            _subTitleLb.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
        }else {
            _subTitleLb.font = [UIFont systemFontOfSize:11];
        }
        _subTitleLb.textColor = [UIColor blackColor];
    }
    return _subTitleLb;
}
- (YM_DatePhotoPreviewBottomView *)bottomView {
    if (!_bottomView) {
        if (self.outside) {
            _bottomView = [[YM_DatePhotoPreviewBottomView alloc] initWithFrame:CGRectMake(0, self.view.hx_h - 50 - kBottomMargin, self.view.hx_w, 50 + kBottomMargin) modelArray:self.manager.afterSelectedArray manager:self.manager];
        }else {
            _bottomView = [[YM_DatePhotoPreviewBottomView alloc] initWithFrame:CGRectMake(0, self.view.hx_h - 50 - kBottomMargin, self.view.hx_w, 50 + kBottomMargin) modelArray:self.manager.selectedArray manager:self.manager];
        }
        _bottomView.delagate = self;
    }
    return _bottomView;
}
- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setBackgroundImage:[YM_PhotoTools ym_imageNamed:@"compose_guide_check_box_default111@2x.png"] forState:UIControlStateNormal];
        [_selectBtn setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateSelected];
        if ([self.manager.configuration.themeColor isEqual:[UIColor whiteColor]]) {
            [_selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        }else {
            [_selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        }
        if (self.manager.configuration.selectedTitleColor) {
            [_selectBtn setTitleColor:self.manager.configuration.selectedTitleColor forState:UIControlStateSelected];
        }
        _selectBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _selectBtn.adjustsImageWhenDisabled = YES;
        [_selectBtn addTarget:self action:@selector(didSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn.hx_size = CGSizeMake(24, 24);
        [_selectBtn setEnlargeEdgeWithTop:0 right:0 bottom:20 left:20];
        _selectBtn.layer.cornerRadius = 12;
    }
    return _selectBtn;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, kTopMargin,self.view.hx_w + 20, self.view.hx_h - kTopMargin - kBottomMargin) collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[YM_DatePhotoPreviewViewCell class] forCellWithReuseIdentifier:@"DatePreviewCellId"];
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
#else
            if ((NO)) {
#endif
            } else {
                self.automaticallyAdjustsScrollViewInsets = NO;
            }
        }
        return _collectionView;
    }
    - (UICollectionViewFlowLayout *)flowLayout {
        if (!_flowLayout) {
            _flowLayout = [[UICollectionViewFlowLayout alloc] init];
            _flowLayout.minimumInteritemSpacing = 0;
            _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            
            if (self.outside) {
                _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
            }else {
#ifdef __IPHONE_11_0
                if (@available(iOS 11.0, *)) {
#else
                    if ((NO)) {
#endif
                        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
                    }else {
                        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
                    }
                }
            }
            return _flowLayout;
        }
        - (NSMutableArray *)modelArray {
            if (!_modelArray) {
                _modelArray = [NSMutableArray array];
            }
            return _modelArray;
        }
        - (void)dealloc {
            YM_DatePhotoPreviewViewCell *cell = (YM_DatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
            [cell cancelRequest];
            if ([UIApplication sharedApplication].statusBarHidden) {
                [self.navigationController setNavigationBarHidden:NO animated:NO];
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
            if (showLog) NSSLog(@"dealloc");
        }

@end
