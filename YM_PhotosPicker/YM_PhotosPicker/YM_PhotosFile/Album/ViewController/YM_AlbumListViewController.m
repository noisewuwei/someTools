//
//  YM_AlbumListViewController.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_AlbumListViewController.h"
#import "YM_DatePhotoViewController.h"

/** category */
#import "UIViewController+YM_Extension.h"

/** manage */
#import "YM_DatePhotoToolManager.h"

/** view */
#import "YM_AlbumListSingleViewCell.h"
#import "YM_AlbumListQuadrateViewCell.h"

/** model */
#import "YM_AlbumModel.h"
#import "YM_AlbumModel.h"

@interface YM_AlbumListViewController () <
UICollectionViewDataSource,
UICollectionViewDelegate,
UIViewControllerPreviewingDelegate,
UITableViewDataSource,
UITableViewDelegate,
YM_DatePhotoViewControllerDelegate
>

/** 多选模式下（configuration.singleSelected = NO） 相片列表 */
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) UICollectionView *collectionView;

/** 单选模式下（configuration.singleSelected = YES） 相册列表 */
@property (strong, nonatomic) UITableView *tableView;

/** 相册模型数组 */
@property (strong, nonatomic) NSMutableArray <YM_AlbumModel *> *albumModelArray;

@property (weak, nonatomic) id<UIViewControllerPreviewing> previewingContext;

@property (assign, nonatomic) BOOL orientationDidChange;
@property (strong, nonatomic) NSIndexPath *beforeOrientationIndexPath;
@property (strong, nonatomic) YM_DatePhotoToolManager *toolManager;

@end

@implementation YM_AlbumListViewController

- (void)dealloc {
    if (showLog) NSSLog(@"dealloc");
    if (self.manager.configuration.open3DTouchPreview) {
        if (self.previewingContext) {
            [self unregisterForPreviewingWithContext:self.previewingContext];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getAlbumModelList:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:self.manager.configuration.statusBarStyle];
    [UINavigationBar appearance].translucent = YES;
    self.navigationController.popoverPresentationController.delegate = (id)self;
    
    [self registerNotification];
    [self setPhotoManager];
    [self setNavigation];
    [self layoutView];
    
    // 获取当前应用对照片的访问授权状态
    kWeakSelf
    [self.view showLoadingHUDText:nil];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            kStrongSelf
            if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
                [self.view handleLoading];
                [self showAuthorizationWithtType:YM_AuthorizationType_Photo];
            }else {
                [self getAlbumModelList:YES];
            }
        });
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.orientationDidChange) {
        [self changeSubviewFrame];
        self.orientationDidChange = NO;
    }
}

#pragma mark - 数据
/**
 获取相册模型列表
 @param isFirst 是否第一次获取
 */
- (void)getAlbumModelList:(BOOL)isFirst {
//    // 是否有相册 && 拍摄的 照片/视频 是否保存到系统相册 && 是否为单选模式
//    if (self.manager.configuration.saveSystemAblum &&
//        !self.manager.configuration.singleSelected) {
//        [self.view handleLoading];
//        self.albumModelArray = [NSMutableArray arrayWithArray:self.manager.albums];
//        YM_AlbumModel *model = self.albumModelArray.firstObject;
//        if (isFirst) {
//            YM_DatePhotoViewController *vc = [[YM_DatePhotoViewController alloc] init];
//            vc.manager = self.manager;
//            vc.title = model.albumName;
//            vc.albumModel = model;
//            vc.delegate = self;
//            [self.navigationController pushViewController:vc animated:NO];
//        }
//        if (self.manager.configuration.singleSelected) {
//            [self.tableView reloadData];
//        }else {
//            [self.collectionView reloadData];
//        }
//    }
    if (!isFirst) {
        [self.view showLoadingHUDText:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        kWeakSelf
        [self.manager getAllPhotoAlbums:^(YM_AlbumModel *firstAlbumModel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                kStrongSelf
                [self.view handleLoading];
                YM_AlbumModel *model = firstAlbumModel;
                if (isFirst) {
                    YM_DatePhotoViewController *vc = [[YM_DatePhotoViewController alloc] init];
                    vc.manager = self.manager;
                    vc.title = model.albumName;
                    vc.albumModel = model;
                    vc.delegate = weakSelf;
                    [self.navigationController pushViewController:vc animated:NO];
                }
                if (self.manager.configuration.saveSystemAblum && !self.manager.configuration.singleSelected) {
                    if (self.albumModelArray.count == 0) {
                        [self getAlbumModelList:NO];
                    }
                }
            });
        } albums:^(NSArray *albums) {
            self.albumModelArray = [NSMutableArray arrayWithArray:albums];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.manager.configuration.singleSelected) {
                    [self.tableView reloadData];
                }else {
                    [self.collectionView reloadData];
                }
                [self.view handleLoading];
            });
        } isFirst:isFirst];
    });
}

#pragma mark - 界面
/** 设置导航栏 */
- (void)setNavigation {
    // 导航栏主题颜色
    [self.navigationController.navigationBar setTintColor:self.manager.configuration.themeColor];
    
    // 导航栏背景颜色
    if (self.manager.configuration.navBarBackgroudColor) {
        [self.navigationController.navigationBar setBackgroundColor:nil];
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.barTintColor = self.manager.configuration.navBarBackgroudColor;
    }
    
    // 设置导航栏
    if (self.manager.configuration.navigationBar) {
        self.manager.configuration.navigationBar(self.navigationController.navigationBar);
    }
    
    // 导航栏标题颜色是否与主题色同步，如果是，同步导航栏颜色
    if (self.manager.configuration.navigationTitleSynchColor) {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : self.manager.configuration.themeColor};
    } else {
        if (self.manager.configuration.navigationTitleColor) {
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : self.manager.configuration.navigationTitleColor};
        }
    }
    
    // 设置导航栏按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle ym_localizedStringForKey:@"取消"] style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonAction:)];
}

/** 布局 */
- (void)layoutView {
    self.title = [NSBundle ym_localizedStringForKey:@"相册"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.manager.configuration.singleSelected) {
        [self.view addSubview:self.tableView];
    }else {
        [self.view addSubview:self.collectionView];
    }
    [self changeSubviewFrame];
}

/** 改变视图坐标、大小 */
- (void)changeSubviewFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat navBarHeight = kNavigationBarHeight;
    NSInteger lineCount = 2;
    if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
        navBarHeight = kNavigationBarHeight;
        lineCount = 2;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        if ([UIApplication sharedApplication].statusBarHidden) {
            navBarHeight = self.navigationController.navigationBar.hx_h;
        }else {
            navBarHeight = self.navigationController.navigationBar.hx_h + 20;
        }
        lineCount = 3;
    }
    CGFloat leftMargin = 0;
    CGFloat rightMargin = 0;
    CGFloat width = self.view.hx_w;
    if (kDevice_Is_iPhoneX && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
        leftMargin = 35;
        rightMargin = 35;
        width = self.view.hx_w - 70;
    }
    if (self.manager.configuration.singleSelected) {
        self.tableView.contentInset = UIEdgeInsetsMake(navBarHeight, leftMargin, 0, rightMargin);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(navBarHeight, leftMargin, 0, rightMargin);
        if (self.manager.configuration.albumListTableView) {
            self.manager.configuration.albumListTableView(self.tableView);
        }
    } else {
        CGFloat itemWidth = (width - (lineCount + 1) * 15) / lineCount;
        CGFloat itemHeight = itemWidth + 6 + 14 + 4 + 14;
        self.flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        
        self.collectionView.contentInset = UIEdgeInsetsMake(navBarHeight, leftMargin, 0, rightMargin);
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(navBarHeight, leftMargin, 0, rightMargin);
        if (self.orientationDidChange) {
            [self.collectionView scrollToItemAtIndexPath:self.beforeOrientationIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
        if (self.manager.configuration.albumListCollectionView) {
            self.manager.configuration.albumListCollectionView(self.collectionView);
        }
    }
}

- (void)setPhotoManager {
    [self.manager selectedListTransformBefore];
}

#pragma mark - 通知
/** 注册通知 */
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

/** 设备方向发生改变 */
- (void)deviceOrientationChanged:(NSNotification *)notify {
    if (!self.manager.configuration.singleSelected) {
        self.beforeOrientationIndexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    }
    self.orientationDidChange = YES;
}

#pragma mark - <YM_DatePhotoViewControllerDelegate>
/**
 点击完成按钮
 @param datePhotoViewController self
 @param allList 已选的所有列表(包含照片、视频)
 @param photoList 已选的照片列表
 @param videoList 已选的视频列表
 @param original 是否原图
 */
- (void)datePhotoViewController:(YM_DatePhotoViewController *)datePhotoViewController didDoneAllList:(NSArray<YM_PhotoModel *> *)allList photos:(NSArray<YM_PhotoModel *> *)photoList videos:(NSArray<YM_PhotoModel *> *)videoList original:(BOOL)original {
    if ([self.delegate respondsToSelector:@selector(albumListViewController:didDoneAllList:photos:videos:original:)]) {
        [self.delegate albumListViewController:self didDoneAllList:allList photos:photoList videos:videoList original:original];
        
    }
    if (self.manager.configuration.requestImageAfterFinishingSelection) {
        [self.navigationController.viewControllers.lastObject.view showLoadingHUDText:nil];
        kWeakSelf
        YM_DatePhotoToolManagerRequestType requestType;
        if (original) {
            requestType = YM_DatePhotoToolManagerRequestTypeOriginal;
        }else {
            requestType = YM_DatePhotoToolManagerRequestTypeHD;
        }
        [self.toolManager getSelectedImageList:allList requestType:requestType success:^(NSArray<UIImage *> *imageList) {
            kStrongSelf
            int i = 0;
            for (YM_PhotoModel *subModel in self.manager.afterSelectedArray) {
                if (i < imageList.count) {
                    subModel.thumbPhoto = imageList[i];
                    subModel.previewPhoto = imageList[i];
                }
                i++;
            }
            if ([self.delegate respondsToSelector:@selector(albumListViewController:didDoneAllImage:)]) {
                [self.delegate albumListViewController:self didDoneAllImage:imageList];
            }
            if (self.doneBlock) {
                self.doneBlock(allList, photoList, videoList, imageList, original, self);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } failed:^{
            kStrongSelf
            [self.navigationController.viewControllers.lastObject.view handleLoading];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }else {
        if (self.doneBlock) {
            self.doneBlock(allList, photoList, videoList, nil, original, self);
        }
    }
}

/**
 点击取消
 @param datePhotoViewController self
 */
- (void)datePhotoViewControllerDidCancel:(YM_DatePhotoViewController *)datePhotoViewController {
    [self rightButtonAction:nil];
}

/**
 改变了选择
 @param model 改的模型
 @param selected 是否选中
 */
- (void)datePhotoViewControllerDidChangeSelect:(YM_PhotoModel *)model selected:(BOOL)selected {
    if (self.albumModelArray.count > 0) {
        //        YM_AlbumModel *albumModel = self.albumModelArray[model.currentAlbumIndex];
        //        if (selected) {
        //            albumModel.selectedCount++;
        //        }else {
        //            albumModel.selectedCount--;
        //        }
        //        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:model.currentAlbumIndex inSection:0]]];
    }
}


#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.albumModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YM_AlbumListQuadrateViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YM_AlbumListQuadrateViewCellID forIndexPath:indexPath];
    cell.model = self.albumModelArray[indexPath.item];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.navigationController.topViewController != self) {
        return;
    }
    YM_AlbumModel *model = self.albumModelArray[indexPath.item];
    YM_DatePhotoViewController *vc = [[YM_DatePhotoViewController alloc] init];
    vc.manager = self.manager;
    vc.title = model.albumName;
    vc.albumModel = model;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(YM_AlbumListQuadrateViewCell *)cell cancelRequest];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YM_AlbumListSingleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YM_AlbumListSingleViewCellID];
    cell.model = self.albumModelArray[indexPath.row];
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.navigationController.topViewController != self) {
        return;
    }
    YM_AlbumModel *model = self.albumModelArray[indexPath.row];
    YM_DatePhotoViewController *vc = [[YM_DatePhotoViewController alloc] init];
    vc.manager = self.manager;
    vc.title = model.albumName;
    vc.albumModel = model;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [(YM_AlbumListSingleViewCell *)cell cancelRequest];
}

#pragma mark - <UIViewControllerPreviewing> 3DTouch事件
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (!indexPath) {
        return nil;
    }
    YM_AlbumListQuadrateViewCell *cell = (YM_AlbumListQuadrateViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    // 设置突出区域
    CGRect frame = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    previewingContext.sourceRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width);
    
    // 要打开的控制器
    YM_DatePhotoViewController *vc = [[YM_DatePhotoViewController alloc] init];
    vc.manager = self.manager;
    vc.title = cell.model.albumName;
    vc.albumModel = cell.model;
    vc.delegate = self;
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

#pragma mark - 按钮事件
/** 点击取消后的事件 */
- (void)rightButtonAction:(UIButton *)sender {
    [self.manager cancelBeforeSelectedList];
    if (self.cancelBlock) {
        self.cancelBlock(self);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

#pragma mark - 懒加载
- (YM_DatePhotoToolManager *)toolManager {
    if (!_toolManager) {
        _toolManager = [[YM_DatePhotoToolManager alloc] init];
    }
    return _toolManager;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.hx_w, self.view.hx_h) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[YM_AlbumListSingleViewCell class]
           forCellReuseIdentifier:YM_AlbumListSingleViewCellID];
        
        if (@available(iOS 11.0, *)) {
            if ([self navigationBarWhetherSetupBackground]) {
                self.navigationController.navigationBar.translucent = NO;
            }else {
                _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        } else {
            if ([self navigationBarWhetherSetupBackground]) {
                self.navigationController.navigationBar.translucent = NO;
            }else {
                self.automaticallyAdjustsScrollViewInsets = NO;
            }
        }
    }
    return _tableView;
}
    
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.hx_w, self.view.hx_h) collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[YM_AlbumListQuadrateViewCell class] forCellWithReuseIdentifier:YM_AlbumListQuadrateViewCellID];
        
        if (@available(iOS 11.0, *)) {
            if ([self navigationBarWhetherSetupBackground]) {
                self.navigationController.navigationBar.translucent = YES;
            }
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            if ([self navigationBarWhetherSetupBackground]) {
                self.navigationController.navigationBar.translucent = YES;
            }
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        // 添加3DTouch交互
        if (self.manager.configuration.open3DTouchPreview) {
            // http://www.cocoachina.com/industry/20140729/9269.html
            if ([self respondsToSelector:@selector(traitCollection)]) {
                if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
                    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:_collectionView];
                    }
                }
            }
        }
    }
    return _collectionView;
}
    
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //        CGFloat itemWidth = (self.view.hx_w - 45) / 2;
        //        CGFloat itemHeight = itemWidth + 6 + 14 + 4 + 14;
        //        _flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        _flowLayout.minimumLineSpacing = 15;
        _flowLayout.minimumInteritemSpacing = 15;
        _flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    }
    return _flowLayout;
}

@end
