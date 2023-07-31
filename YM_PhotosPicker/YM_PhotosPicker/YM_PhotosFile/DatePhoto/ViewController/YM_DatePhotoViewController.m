//
//  YM_DatePhotoViewController.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoViewController.h"

/** viewController */
#import "YM_DatePhotoPreviewViewController.h"
#import "YM_CustomCameraViewController.h"
#import "YM_DatePhotoEditViewController.h"
#import "YM_CustomNavigationController.h"
#import "YM_Photo3DTouchViewController.h"

/** view */
#import "YM_DatePhotoViewFlowLayout.h"
#import "YM_DatePhotoViewSectionFooterView.h"
#import "YM_DatePhotoCameraViewCell.h"
#import "YM_DatePhotoViewSectionHeaderView.h"
#import "YM_DatePhotoViewCell.h"
#import "YM_DatePhotoBottomView.h"

/** model */
#import "YM_PhotoDateModel.h"

/** category */
#import "UIViewController+YM_Extension.h"

@interface YM_DatePhotoViewController ()<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIViewControllerPreviewingDelegate,
YM_DatePhotoViewCellDelegate,
YM_DatePhotoBottomViewDelegate,
YM_DatePhotoPreviewViewControllerDelegate,
YM_CustomCameraViewControllerDelegate,
YM_DatePhotoEditViewControllerDelegate
>

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) YM_DatePhotoViewFlowLayout *customLayout;

@property (strong, nonatomic) NSMutableArray *allArray;
@property (strong, nonatomic) NSMutableArray *previewArray;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (strong, nonatomic) NSMutableArray *videoArray;
@property (strong, nonatomic) NSMutableArray *dateArray;

@property (assign, nonatomic) NSInteger currentSectionIndex;
@property (weak, nonatomic) id<UIViewControllerPreviewing> previewingContext;

@property (assign, nonatomic) BOOL orientationDidChange;
@property (assign, nonatomic) BOOL needChangeViewFrame;
@property (strong, nonatomic) NSIndexPath *beforeOrientationIndexPath;

@property (weak, nonatomic) YM_DatePhotoViewSectionFooterView *footerView;

@end

@implementation YM_DatePhotoViewController 


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self changeSubviewFrame];
    [self.view showLoadingHUDText:nil];
    [self getPhotoList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.needChangeViewFrame) {
        self.needChangeViewFrame = NO;
    }
    
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.orientationDidChange) {
        [self changeSubviewFrame];
        self.orientationDidChange = NO;
    }
}
- (void)deviceOrientationChanged:(NSNotification *)notify {
    self.beforeOrientationIndexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    self.orientationDidChange = YES;
    if (self.navigationController.topViewController != self) {
        self.needChangeViewFrame = YES;
    }
}
- (void)changeSubviewFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat navBarHeight = kNavigationBarHeight;
    NSInteger lineCount = self.manager.configuration.rowCount;
    if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
        navBarHeight = kNavigationBarHeight;
        lineCount = self.manager.configuration.rowCount;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        if ([UIApplication sharedApplication].statusBarHidden) {
            navBarHeight = self.navigationController.navigationBar.hx_h;
        }else {
            navBarHeight = self.navigationController.navigationBar.hx_h + 20;
        }
        lineCount = self.manager.configuration.horizontalRowCount;
    }
    CGFloat bottomMargin = kBottomMargin;
    CGFloat leftMargin = 0;
    CGFloat rightMargin = 0;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (!CGRectEqualToRect(self.view.bounds, [UIScreen mainScreen].bounds)) {
        self.view.frame = CGRectMake(0, 0, viewWidth, height);
    }
    if (kDevice_Is_iPhoneX && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
        bottomMargin = 21;
        leftMargin = 35;
        rightMargin = 35;
        width = [UIScreen mainScreen].bounds.size.width - 70;
    }
    CGFloat itemWidth = (width - (lineCount - 1)) / lineCount;
    CGFloat itemHeight = itemWidth;
    if (self.manager.configuration.showDateSectionHeader) {
        self.customLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
    }else {
        self.flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
    }
    CGFloat bottomViewY = height - 50 - bottomMargin;
    
    self.collectionView.contentInset = UIEdgeInsetsMake(navBarHeight, leftMargin, bottomMargin, rightMargin);
    if (!self.manager.configuration.singleSelected) {
        self.collectionView.contentInset = UIEdgeInsetsMake(navBarHeight, leftMargin, 50 + bottomMargin, rightMargin);
    } else {
        self.collectionView.contentInset = UIEdgeInsetsMake(navBarHeight, leftMargin, bottomMargin, rightMargin);
    }
    self.collectionView.scrollIndicatorInsets = _collectionView.contentInset;
    
    if (self.orientationDidChange) {
        [self.collectionView scrollToItemAtIndexPath:self.beforeOrientationIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    
    self.bottomView.frame = CGRectMake(0, bottomViewY, viewWidth, 50 + bottomMargin);
    
    if (self.manager.configuration.photoListCollectionView) {
        self.manager.configuration.photoListCollectionView(self.collectionView);
    }
}
- (void)setupUI {
    self.currentSectionIndex = 0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle ym_localizedStringForKey:@"取消"] style:UIBarButtonItemStyleDone target:self action:@selector(didCancelClick)];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    if (!self.manager.configuration.singleSelected) {
        [self.view addSubview:self.bottomView];
        self.bottomView.selectCount = self.manager.selectedArray.count;
        if (self.manager.configuration.photoListBottomView) {
            self.manager.configuration.photoListBottomView(self.bottomView);
        }
    }
}
- (void)didCancelClick {
    if ([self.delegate respondsToSelector:@selector(datePhotoViewControllerDidCancel:)]) {
        [self.delegate datePhotoViewControllerDidCancel:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (YM_DatePhotoViewCell *)currentPreviewCell:(YM_PhotoModel *)model {
    if (!model || ![self.allArray containsObject:model]) {
        return nil;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self dateItem:model] inSection:model.dateSection];
    return (YM_DatePhotoViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}
- (BOOL)scrollToModel:(YM_PhotoModel *)model {
    if ([self.allArray containsObject:model]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self dateItem:model] inSection:model.dateSection] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self dateItem:model] inSection:model.dateSection]]];
    }
    return [self.allArray containsObject:model];
}
- (NSInteger)dateItem:(YM_PhotoModel *)model {
    NSInteger dateItem = model.dateItem;
    if (self.manager.configuration.showDateSectionHeader && self.manager.configuration.reverseDate && model.dateSection != 0) {
        dateItem = model.dateItem;
    }else if (self.manager.configuration.showDateSectionHeader && !self.manager.configuration.reverseDate && model.dateSection != self.dateArray.count - 1) {
        dateItem = model.dateItem;
    }else {
        if (model.type == YM_PhotoModelMediaType_CameraPhoto || model.type == YM_PhotoModelMediaType_CameraVideo) {
            if (self.manager.configuration.showDateSectionHeader) {
                if (self.manager.configuration.reverseDate) {
                    YM_PhotoDateModel *dateModel = self.dateArray.firstObject;
                    dateItem = [dateModel.photoModelArray indexOfObject:model];
                    //                    dateItem = cameraIndex + [self.manager.cameraList indexOfObject:model];
                    //                    model.dateItem = dateItem;
                }else {
                    YM_PhotoDateModel *dateModel = self.dateArray.lastObject;
                    dateItem = [dateModel.photoModelArray indexOfObject:model];
                }
            }else {
                dateItem = [self.allArray indexOfObject:model];
            }
        }else {
            if (self.manager.configuration.showDateSectionHeader) {
                if (self.manager.configuration.reverseDate) {
                    YM_PhotoDateModel *dateModel = self.dateArray.firstObject;
                    dateItem = [dateModel.photoModelArray indexOfObject:model];
                    //                    dateItem = model.dateItem + cameraIndex + cameraCount;
                }else {
                    //                    dateItem = model.dateItem;
                    YM_PhotoDateModel *dateModel = self.dateArray.lastObject;
                    dateItem = [dateModel.photoModelArray indexOfObject:model];
                }
            }else {
                dateItem = [self.allArray indexOfObject:model];
            }
        }
    }
    return dateItem;
}
- (void)scrollToPoint:(YM_DatePhotoViewCell *)cell rect:(CGRect)rect {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat navBarHeight = kNavigationBarHeight;
    if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
        navBarHeight = kNavigationBarHeight;
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        if ([UIApplication sharedApplication].statusBarHidden) {
            navBarHeight = self.navigationController.navigationBar.hx_h;
        }else {
            navBarHeight = self.navigationController.navigationBar.hx_h + 20;
        }
    }
    if (self.manager.configuration.showDateSectionHeader) {
        navBarHeight += 50;
    }
    if (rect.origin.y < navBarHeight) {
        [self.collectionView setContentOffset:CGPointMake(0, cell.frame.origin.y - navBarHeight)];
    }else if (rect.origin.y + rect.size.height > self.view.hx_h - 50.5 - kBottomMargin) {
        [self.collectionView setContentOffset:CGPointMake(0, cell.frame.origin.y - self.view.hx_h + 50.5 + kBottomMargin + rect.size.height)];
    }
}
- (void)getPhotoList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        kWeakSelf
        [self.manager getPhotoListWithAlbumModel:self.albumModel complete:^(NSArray *allList, NSArray *previewList, NSArray *photoList, NSArray *videoList, NSArray *dateList, YM_PhotoModel *firstSelectModel) {
            kStrongSelf
            self.dateArray = [NSMutableArray arrayWithArray:dateList];
            self.photoArray = [NSMutableArray arrayWithArray:photoList];
            self.videoArray = [NSMutableArray arrayWithArray:videoList];
            self.allArray = [NSMutableArray arrayWithArray:allList];
            self.previewArray = [NSMutableArray arrayWithArray:previewList];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view handleLoading];
                CATransition *transition = [CATransition animation];
                transition.type = kCATransitionPush;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.fillMode = kCAFillModeForwards;
                transition.duration = 0.1;
                transition.subtype = kCATransitionFade;
                [[self.collectionView layer] addAnimation:transition forKey:@""];
                [self.collectionView reloadData];
                if (!self.manager.configuration.reverseDate) {
                    if (self.manager.configuration.showDateSectionHeader && self.dateArray.count > 0) {
                        YM_PhotoDateModel *dateModel = self.dateArray.lastObject;
                        if (dateModel.photoModelArray.count > 0) {
                            if (firstSelectModel) {
                                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self dateItem:firstSelectModel] inSection:firstSelectModel.dateSection] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                            }else {
                                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:dateModel.photoModelArray.count - 1 inSection:self.dateArray.count - 1] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                            }
                        }
                    }else {
                        if (self.allArray.count > 0) {
                            if (firstSelectModel) {
                                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.allArray indexOfObject:firstSelectModel] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                            }else {
                                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.allArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                            }
                        }
                    }
                }else {
                    if (firstSelectModel) {
                        if (self.manager.configuration.showDateSectionHeader) {
                            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self dateItem:firstSelectModel] inSection:firstSelectModel.dateSection] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                        }else {
                            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.allArray indexOfObject:firstSelectModel] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                        }
                    }
                }
            });
        }];
    });
}
#pragma mark - < YM_CustomCameraViewControllerDelegate >
- (void)customCameraViewController:(YM_CustomCameraViewController *)viewController didDone:(YM_PhotoModel *)model {
    if (self.manager.configuration.singleSelected) {
        if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
            YM_DatePhotoEditViewController *vc = [[YM_DatePhotoEditViewController alloc] init];
            vc.delegate = self;
            vc.manager = self.manager;
            vc.model = model;
            [self.navigationController pushViewController:vc animated:NO];
        }else {
            YM_DatePhotoPreviewViewController *previewVC = [[YM_DatePhotoPreviewViewController alloc] init];
            previewVC.delegate = self;
            previewVC.modelArray = [NSMutableArray arrayWithObjects:model, nil];
            previewVC.manager = self.manager;
            previewVC.currentModelIndex = 0;
            self.navigationController.delegate = previewVC;
            [self.navigationController pushViewController:previewVC animated:YES];
        }
        return;
    }
    model.currentAlbumIndex = self.albumModel.index;
    [self.manager beforeListAddCameraTakePicturesModel:model];
    
    // 判断类型
    if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
        if (self.manager.configuration.reverseDate) {
            [self.photoArray insertObject:model atIndex:0];
        }else {
            [self.photoArray addObject:model];
        }
    }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
        if (self.manager.configuration.reverseDate) {
            [self.videoArray insertObject:model atIndex:0];
        }else {
            [self.videoArray addObject:model];
        }
    }
    NSInteger cameraIndex = self.manager.configuration.openCamera ? 1 : 0;
    if (self.manager.configuration.reverseDate) {
        [self.allArray insertObject:model atIndex:cameraIndex];
        [self.previewArray insertObject:model atIndex:0];
    }else {
        NSInteger count = self.allArray.count - cameraIndex;
        [self.allArray insertObject:model atIndex:count];
        [self.previewArray addObject:model];
    }
    if (self.manager.configuration.showDateSectionHeader) {
        if (self.manager.configuration.reverseDate) {
            model.dateSection = 0;
            YM_PhotoDateModel *dateModel = self.dateArray.firstObject;
            NSMutableArray *array = [NSMutableArray arrayWithArray:dateModel.photoModelArray];
            [array insertObject:model atIndex:cameraIndex];
            dateModel.photoModelArray = array;
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:cameraIndex inSection:0]]];
        }else {
            model.dateSection = self.dateArray.count - 1;
            YM_PhotoDateModel *dateModel = self.dateArray.lastObject;
            NSMutableArray *array = [NSMutableArray arrayWithArray:dateModel.photoModelArray];
            NSInteger count = array.count - cameraIndex;
            [array insertObject:model atIndex:count];
            dateModel.photoModelArray = array;
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:count inSection:self.dateArray.count - 1]]];
        }
    }else {
        if (self.manager.configuration.reverseDate) {
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:cameraIndex inSection:0]]];
        }else {
            NSInteger count = self.allArray.count - 1;
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:count - cameraIndex inSection:0]]];
        }
    }
    self.footerView.photoCount = self.photoArray.count;
    self.footerView.videoCount = self.videoArray.count;
    self.bottomView.selectCount = [self.manager selectedCount];
}
#pragma mark - < UICollectionViewDataSource >
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.manager.configuration.showDateSectionHeader) {
        return [self.dateArray count];
    }
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.manager.configuration.showDateSectionHeader) {
        YM_PhotoDateModel *dateModel = [self.dateArray objectAtIndex:section];
        return [dateModel.photoModelArray count];
    }
    return self.allArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YM_PhotoModel *model;
    if (self.manager.configuration.showDateSectionHeader) {
        YM_PhotoDateModel *dateModel = [self.dateArray objectAtIndex:indexPath.section];
        model = dateModel.photoModelArray[indexPath.item];
    }else {
        model = self.allArray[indexPath.item];
    }
    model.rowCount = self.manager.configuration.rowCount;
    //    model.dateSection = indexPath.section;
    //    model.dateItem = indexPath.item;
    model.dateCellIsVisible = YES;
    if (model.type == YM_PhotoModelMediaType_Camera) {
        YM_DatePhotoCameraViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DateCameraCellId" forIndexPath:indexPath];
        cell.model = model;
        if (self.manager.configuration.cameraCellShowPreview) {
            [cell starRunning];
        }
        return cell;
    }else {
        if (self.manager.configuration.specialModeNeedHideVideoSelectBtn) {
            if (self.manager.videoSelectedType == YM_PhotoManagerVideoSelectedType_Single && !self.manager.videoCanSelected && model.subType == YM_PhotoModelMediaSubType_Video) {
                model.videoUnableSelect = YES;
            }else {
                model.videoUnableSelect = NO;
            }
        }
        YM_DatePhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DateCellId" forIndexPath:indexPath];
        cell.delegate = self;
        if (self.manager.configuration.cellSelectedTitleColor) {
            cell.selectedTitleColor = self.manager.configuration.cellSelectedTitleColor;
        }else if (self.manager.configuration.selectedTitleColor) {
            cell.selectedTitleColor = self.manager.configuration.selectedTitleColor;
        }
        if (self.manager.configuration.cellSelectedBgColor) {
            cell.selectBgColor = self.manager.configuration.cellSelectedBgColor;
        }else {
            cell.selectBgColor = self.manager.configuration.themeColor;
        }
        //        cell.section = indexPath.section;
        //        cell.item = indexPath.item;
        cell.model = model;
        cell.singleSelected = self.manager.configuration.singleSelected;
        return cell;
    }
}
#pragma mark - < UICollectionViewDelegate >
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.navigationController.topViewController != self) {
        return;
    }
    YM_PhotoModel *model;
    if (self.manager.configuration.showDateSectionHeader) {
        YM_PhotoDateModel *dateModel = [self.dateArray objectAtIndex:indexPath.section];
        model = dateModel.photoModelArray[indexPath.item];
    }else {
        model = self.allArray[indexPath.item];
    }
    if (model.type == YM_PhotoModelMediaType_Camera) {
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"无法使用相机!"]];
            return;
        }
        kWeakSelf
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            kStrongSelf
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    if (self.manager.configuration.replaceCameraViewController) {
                        YM_PhotoConfigurationCameraType cameraType;
                        if (self.manager.type == YM_PhotoManagerType_Photo) {
                            cameraType = YM_PhotoConfigurationCameraType_Photo;
                        }else if (self.manager.type == YM_PhotoManagerType_Video) {
                            cameraType = YM_PhotoConfigurationCameraType_Video;
                        }else {
                            if (!self.manager.configuration.selectTogether) {
                                if (self.manager.selectedPhotoArray.count > 0) {
                                    cameraType = YM_PhotoConfigurationCameraType_Photo;
                                }else if (self.manager.selectedVideoArray.count > 0) {
                                    cameraType = YM_PhotoConfigurationCameraType_Video;
                                }else {
                                    cameraType = YM_PhotoConfigurationCameraType_PhotoAndVideo;
                                }
                            }else {
                                cameraType = YM_PhotoConfigurationCameraType_PhotoAndVideo;
                            }
                        }
                        if (self.manager.configuration.shouldUseCamera) {
                            self.manager.configuration.shouldUseCamera(weakSelf, cameraType, self.manager);
                        }
                        self.manager.configuration.useCameraComplete = ^(YM_PhotoModel *model) {
                            kStrongSelf
                            if (model.videoDuration > self.manager.configuration.videoMaxDuration) {
                                [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"视频过大,无法选择"]];
                            }
                            [self customCameraViewController:nil didDone:model];
                        };
                        return;
                    }
                    YM_CustomCameraViewController *vc = [[YM_CustomCameraViewController alloc] init];
                    vc.delegate = weakSelf;
                    vc.manager = self.manager;
                    YM_CustomNavigationController *nav = [[YM_CustomNavigationController alloc] initWithRootViewController:vc];
                    nav.isCamera = YES;
                    nav.supportRotation = self.manager.configuration.supportRotation;
                    [self presentViewController:nav animated:YES completion:nil];
                }else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle ym_localizedStringForKey:@"无法使用相机"] message:[NSBundle ym_localizedStringForKey:@"请在设置-隐私-相机中允许访问相机"] preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"取消"] style:UIAlertActionStyleDefault handler:nil]];
                    [alert addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"设置"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }];
    }else {
        YM_DatePhotoViewCell *cell = (YM_DatePhotoViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell.model.isICloud) {
            if (self.manager.configuration.downloadICloudAsset) {
                if (!cell.model.iCloudDownloading) {
                    [cell startRequestICloudAsset];
                }
            }else {
                [self.view showImageHUDText:[NSBundle ym_localizedStringForKey:@"尚未从iCloud上下载，请至系统相册下载完毕后选择"]];
            }
            return;
        }
        if (!self.manager.configuration.singleSelected) {
            NSInteger currentIndex = [self.previewArray indexOfObject:cell.model];
            YM_DatePhotoPreviewViewController *previewVC = [[YM_DatePhotoPreviewViewController alloc] init];
            previewVC.delegate = self;
            previewVC.modelArray = self.previewArray;
            previewVC.manager = self.manager;
            previewVC.currentModelIndex = currentIndex;
            self.navigationController.delegate = previewVC;
            [self.navigationController pushViewController:previewVC animated:YES];
        }else {
            if (!self.manager.configuration.singleJumpEdit) {
                NSInteger currentIndex = [self.previewArray indexOfObject:cell.model];
                YM_DatePhotoPreviewViewController *previewVC = [[YM_DatePhotoPreviewViewController alloc] init];
                previewVC.delegate = self;
                previewVC.modelArray = self.previewArray;
                previewVC.manager = self.manager;
                previewVC.currentModelIndex = currentIndex;
                self.navigationController.delegate = previewVC;
                [self.navigationController pushViewController:previewVC animated:YES];
            }else {
                if (cell.model.subType == YM_PhotoModelMediaSubType_Photo) {
                    YM_DatePhotoEditViewController *vc = [[YM_DatePhotoEditViewController alloc] init];
                    vc.model = cell.model;
                    vc.delegate = self;
                    vc.manager = self.manager;
                    [self.navigationController pushViewController:vc animated:NO];
                }else {
                    YM_DatePhotoPreviewViewController *previewVC = [[YM_DatePhotoPreviewViewController alloc] init];
                    previewVC.delegate = self;
                    previewVC.modelArray = [NSMutableArray arrayWithObjects:cell.model, nil];
                    previewVC.manager = self.manager;
                    previewVC.currentModelIndex = 0;
                    self.navigationController.delegate = previewVC;
                    [self.navigationController pushViewController:previewVC animated:YES];
                }
            }
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    YM_PhotoModel *model;
    if (self.manager.configuration.showDateSectionHeader) {
        YM_PhotoDateModel *dateModel = [self.dateArray objectAtIndex:indexPath.section];
        model = dateModel.photoModelArray[indexPath.item];
    }else {
        model = self.allArray[indexPath.item];
    }
    if (model.type != YM_PhotoModelMediaType_Camera) {
        //        model.dateCellIsVisible = NO;
        //        NSSLog(@"cell消失");
        [(YM_DatePhotoViewCell *)cell cancelRequest];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        //        NSSLog(@"headerSection消失");
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && self.manager.configuration.showDateSectionHeader) {
        YM_DatePhotoViewSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sectionHeaderId" forIndexPath:indexPath];
        headerView.translucent = self.manager.configuration.sectionHeaderTranslucent;
        headerView.suspensionBgColor = self.manager.configuration.sectionHeaderSuspensionBgColor;
        headerView.suspensionTitleColor = self.manager.configuration.sectionHeaderSuspensionTitleColor;
        headerView.model = self.dateArray[indexPath.section];
        return headerView;
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        if (self.manager.configuration.showBottomPhotoDetail) {
            YM_DatePhotoViewSectionFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sectionFooterId" forIndexPath:indexPath];
            footerView.photoCount = self.photoArray.count;
            footerView.videoCount = self.videoArray.count;
            self.footerView = footerView;
            return footerView;
        }
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.manager.configuration.showDateSectionHeader) {
        return CGSizeMake(self.view.hx_w, 50);
    }
    return CGSizeZero;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (self.manager.configuration.showDateSectionHeader) {
        if (section == self.dateArray.count - 1) {
            return self.manager.configuration.showBottomPhotoDetail ? CGSizeMake(self.view.hx_w, 50) : CGSizeZero;
        }else {
            return CGSizeZero;
        }
    }else {
        return self.manager.configuration.showBottomPhotoDetail ? CGSizeMake(self.view.hx_w, 50) : CGSizeZero;
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (!indexPath) {
        return nil;
    }
    if (![[self.collectionView cellForItemAtIndexPath:indexPath] isKindOfClass:[YM_DatePhotoViewCell class]]) {
        return nil;
    }
    YM_DatePhotoViewCell *cell = (YM_DatePhotoViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (!cell || cell.model.type == YM_PhotoModelMediaType_Camera || cell.model.isICloud) {
        return nil;
    }
    if (cell.model.networkPhotoUrl) {
        if (cell.model.downloadError) {
            return nil;
        }
        if (!cell.model.downloadComplete) {
            return nil;
        }
    }
    //设置突出区域
    previewingContext.sourceRect = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    YM_PhotoModel *model = cell.model;
    YM_Photo3DTouchViewController *vc = [[YM_Photo3DTouchViewController alloc] init];
    vc.model = model;
    vc.indexPath = indexPath;
    vc.image = cell.imageView.image;
    vc.preferredContentSize = model.previewViewSize;
    return vc;
}
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    YM_Photo3DTouchViewController *vc = (YM_Photo3DTouchViewController *)viewControllerToCommit;
    YM_DatePhotoViewCell *cell = (YM_DatePhotoViewCell *)[self.collectionView cellForItemAtIndexPath:vc.indexPath];
    if (!self.manager.configuration.singleSelected) {
        YM_DatePhotoPreviewViewController *previewVC = [[YM_DatePhotoPreviewViewController alloc] init];
        previewVC.delegate = self;
        previewVC.modelArray = self.previewArray;
        previewVC.manager = self.manager;
        cell.model.tempImage = vc.imageView.image;
        NSInteger currentIndex = [self.previewArray indexOfObject:cell.model];
        previewVC.currentModelIndex = currentIndex;
        self.navigationController.delegate = previewVC;
        [self.navigationController pushViewController:previewVC animated:YES];
    }else {
        if (vc.model.subType == YM_PhotoModelMediaSubType_Photo) {
            YM_DatePhotoEditViewController *vc = [[YM_DatePhotoEditViewController alloc] init];
            vc.model = cell.model;
            vc.delegate = self;
            vc.manager = self.manager;
            [self.navigationController pushViewController:vc animated:NO];
        }else {
            YM_DatePhotoPreviewViewController *previewVC = [[YM_DatePhotoPreviewViewController alloc] init];
            previewVC.delegate = self;
            previewVC.modelArray = [NSMutableArray arrayWithObjects:cell.model, nil];
            previewVC.manager = self.manager;
            cell.model.tempImage = vc.imageView.image;
            previewVC.currentModelIndex = 0;
            self.navigationController.delegate = previewVC;
            [self.navigationController pushViewController:previewVC animated:YES];
        }
    }
}
#pragma mark - < YM_DatePhotoViewCellDelegate >
- (void)datePhotoViewCellRequestICloudAssetComplete:(YM_DatePhotoViewCell *)cell {
    if (cell.model.dateCellIsVisible) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self dateItem:cell.model] inSection:cell.model.dateSection];
        if (indexPath) {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
        [self.manager addICloudModel:cell.model];
    }
}
- (void)datePhotoViewCell:(YM_DatePhotoViewCell *)cell didSelectBtn:(UIButton *)selectBtn {
    if (selectBtn.selected) {
        if (cell.model.type != YM_PhotoModelMediaType_CameraVideo && cell.model.type != YM_PhotoModelMediaType_CameraPhoto) {
            cell.model.thumbPhoto = nil;
            cell.model.previewPhoto = nil;
        }
        [self.manager beforeSelectedListdeletePhotoModel:cell.model];
        cell.model.selectIndexStr = @"";
        cell.selectMaskLayer.hidden = YES;
        selectBtn.selected = NO;
    }else {
        NSString *str = [self.manager maximumOfJudgment:cell.model];
        if (str) {
            [self.view showImageHUDText:str];
            return;
        }
        if (cell.model.type != YM_PhotoModelMediaType_CameraVideo && cell.model.type != YM_PhotoModelMediaType_CameraPhoto) {
            cell.model.thumbPhoto = cell.imageView.image;
        }
        [self.manager beforeSelectedListAddPhotoModel:cell.model];
        cell.selectMaskLayer.hidden = NO;
        selectBtn.selected = YES;
        [selectBtn setTitle:cell.model.selectIndexStr forState:UIControlStateSelected];
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        anim.duration = 0.25;
        anim.values = @[@(1.2),@(0.8),@(1.1),@(0.9),@(1.0)];
        [selectBtn.layer addAnimation:anim forKey:@""];
    }
    UIColor *bgColor;
    if (self.manager.configuration.cellSelectedBgColor) {
        bgColor = self.manager.configuration.cellSelectedBgColor;
    }else {
        bgColor = self.manager.configuration.themeColor;
    }
    selectBtn.backgroundColor = selectBtn.selected ? bgColor : nil;
    
    NSMutableArray *indexPathList = [NSMutableArray array];
    if (!selectBtn.selected) {
        NSInteger index = 0;
        for (YM_PhotoModel *model in [self.manager selectedArray]) {
            model.selectIndexStr = [NSString stringWithFormat:@"%ld",index + 1];
            if (model.currentAlbumIndex == self.albumModel.index) {
                if (model.dateCellIsVisible) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self dateItem:model] inSection:model.dateSection];
                    [indexPathList addObject:indexPath];
                }
            }
            index++;
        }
        //        if (indexPathList.count > 0) {
        //            [self.collectionView reloadItemsAtIndexPaths:indexPathList];
        //        }
    }
    
    if (self.manager.videoSelectedType == YM_PhotoManagerVideoSelectedType_Single) {
        for (UICollectionViewCell *tempCell in self.collectionView.visibleCells) {
            if ([tempCell isKindOfClass:[YM_DatePhotoViewCell class]]) {
                if ([(YM_DatePhotoViewCell *)tempCell model].subType == YM_PhotoModelMediaSubType_Video) {
                    [indexPathList addObject:[self.collectionView indexPathForCell:tempCell]];
                }
            }
        }
        if (indexPathList.count) {
            [self.collectionView reloadItemsAtIndexPaths:indexPathList];
        }
    }else {
        if (!selectBtn.selected) {
            if (indexPathList.count) {
                [self.collectionView reloadItemsAtIndexPaths:indexPathList];
            }
        }
    }
    
    self.bottomView.selectCount = [self.manager selectedCount];
    if ([self.delegate respondsToSelector:@selector(datePhotoViewControllerDidChangeSelect:selected:)]) {
        [self.delegate datePhotoViewControllerDidChangeSelect:cell.model selected:selectBtn.selected];
    }
}
#pragma mark - < YM_DatePhotoPreviewViewControllerDelegate >
- (void)datePhotoPreviewDownLoadICloudAssetComplete:(YM_DatePhotoPreviewViewController *)previewController model:(YM_PhotoModel *)model {
    if (model.iCloudRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:model.iCloudRequestID];
    }
    if (model.dateCellIsVisible) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self dateItem:model] inSection:model.dateSection];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        [self.manager addICloudModel:model];
    }
}
- (void)datePhotoPreviewControllerDidSelect:(YM_DatePhotoPreviewViewController *)previewController model:(YM_PhotoModel *)model {
    NSMutableArray *indexPathList = [NSMutableArray array];
    if (model.currentAlbumIndex == self.albumModel.index) {
        [indexPathList addObject:[NSIndexPath indexPathForItem:[self dateItem:model] inSection:model.dateSection]];
    }
    if (!model.selected) {
        NSInteger index = 0;
        for (YM_PhotoModel *subModel in [self.manager selectedArray]) {
            subModel.selectIndexStr = [NSString stringWithFormat:@"%ld",index + 1];
            if (subModel.currentAlbumIndex == self.albumModel.index && subModel.dateCellIsVisible) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self dateItem:subModel] inSection:subModel.dateSection];
                [indexPathList addObject:indexPath];
            }
            index++;
        }
    }
    
    if (self.manager.videoSelectedType == YM_PhotoManagerVideoSelectedType_Single) {
        for (UICollectionViewCell *tempCell in self.collectionView.visibleCells) {
            if ([tempCell isKindOfClass:[YM_DatePhotoViewCell class]]) {
                if ([(YM_DatePhotoViewCell *)tempCell model].subType == YM_PhotoModelMediaSubType_Video) {
                    [indexPathList addObject:[self.collectionView indexPathForCell:tempCell]];
                }
            }
        }
    }
    if (indexPathList.count) {
        [self.collectionView reloadItemsAtIndexPaths:indexPathList];
    }
    
    self.bottomView.selectCount = [self.manager selectedCount];
    if ([self.delegate respondsToSelector:@selector(datePhotoViewControllerDidChangeSelect:selected:)]) {
        [self.delegate datePhotoViewControllerDidChangeSelect:model selected:model.selected];
    }
}
- (void)datePhotoPreviewControllerDidDone:(YM_DatePhotoPreviewViewController *)previewController {
    [self datePhotoBottomViewDidDoneBtn];
}
- (void)datePhotoPreviewDidEditClick:(YM_DatePhotoPreviewViewController *)previewController {
    [self datePhotoBottomViewDidDoneBtn];
}
- (void)datePhotoPreviewSingleSelectedClick:(YM_DatePhotoPreviewViewController *)previewController model:(YM_PhotoModel *)model {
    [self.manager beforeSelectedListAddPhotoModel:model];
    [self datePhotoBottomViewDidDoneBtn];
}
#pragma mark - < YM_DatePhotoEditViewControllerDelegate >
- (void)datePhotoEditViewControllerDidClipClick:(YM_DatePhotoEditViewController *)datePhotoEditViewController beforeModel:(YM_PhotoModel *)beforeModel afterModel:(YM_PhotoModel *)afterModel {
    if (self.manager.configuration.singleSelected) {
        [self.manager beforeSelectedListAddPhotoModel:afterModel];
        [self datePhotoBottomViewDidDoneBtn];
        return;
    }
    [self.manager beforeSelectedListdeletePhotoModel:beforeModel];
    
    [self datePhotoPreviewControllerDidSelect:nil model:beforeModel];
    [self customCameraViewController:nil didDone:afterModel];
}
#pragma mark - < YM_DatePhotoBottomViewDelegate >
- (void)datePhotoBottomViewDidPreviewBtn {
    if (self.navigationController.topViewController != self || [self.manager selectedCount] == 0) {
        return;
    }
    YM_DatePhotoPreviewViewController *previewVC = [[YM_DatePhotoPreviewViewController alloc] init];
    previewVC.delegate = self;
    previewVC.modelArray = [NSMutableArray arrayWithArray:[self.manager selectedArray]];
    previewVC.manager = self.manager;
    previewVC.currentModelIndex = 0;
    previewVC.selectPreview = YES;
    self.navigationController.delegate = previewVC;
    [self.navigationController pushViewController:previewVC animated:YES];
}
- (void)datePhotoBottomViewDidDoneBtn {
    [self cleanSelectedList];
    if (!self.manager.configuration.requestImageAfterFinishingSelection) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)datePhotoBottomViewDidEditBtn {
    YM_PhotoModel *model = self.manager.selectedArray.firstObject;
    if (model.subType == YM_PhotoModelMediaSubType_Photo) {
        YM_DatePhotoEditViewController *vc = [[YM_DatePhotoEditViewController alloc] init];
        vc.model = self.manager.selectedPhotoArray.firstObject;
        vc.delegate = self;
        vc.manager = self.manager;
        [self.navigationController pushViewController:vc animated:NO];
    }else if (model.subType == YM_PhotoModelMediaSubType_Video) {
        if (self.manager.configuration.replaceVideoEditViewController) {
#pragma mark - < 替换视频编辑 >
            if (self.manager.configuration.shouldUseVideoEdit) {
                self.manager.configuration.shouldUseVideoEdit(self, self.manager, model);
            }
            kWeakSelf
            self.manager.configuration.useVideoEditComplete = ^(YM_PhotoModel *beforeModel, YM_PhotoModel *afterModel) {
                kStrongSelf
                [self datePhotoEditViewControllerDidClipClick:nil beforeModel:beforeModel afterModel:afterModel];
            };
        }else {
            
        }
    }
}

- (void)cleanSelectedList {
    [self.manager selectedListTransformAfter];
    if (!self.manager.configuration.singleSelected) {
        if ([self.delegate respondsToSelector:@selector(datePhotoViewController:didDoneAllList:photos:videos:original:)]) {
            [self.delegate datePhotoViewController:self didDoneAllList:self.manager.afterSelectedArray.mutableCopy photos:self.manager.afterSelectedPhotoArray.mutableCopy videos:self.manager.afterSelectedVideoArray.mutableCopy original:self.manager.afterOriginal];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(datePhotoViewController:didDoneAllList:photos:videos:original:)]) {
            [self.delegate datePhotoViewController:self didDoneAllList:self.manager.selectedArray.mutableCopy photos:self.manager.selectedPhotoArray.mutableCopy videos:self.manager.selectedVideoArray.mutableCopy original:self.manager.original];
        }
    }
}
#pragma mark - < 懒加载 >
- (YM_DatePhotoBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[YM_DatePhotoBottomView alloc] initWithFrame:CGRectMake(0, self.view.hx_h - 50 - kBottomMargin, self.view.hx_w, 50 + kBottomMargin)];
        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _bottomView.manager = self.manager;
        _bottomView.delegate = self;
    }
    return _bottomView;
}
- (YM_DatePhotoViewFlowLayout *)customLayout {
    if (!_customLayout) {
        _customLayout = [[YM_DatePhotoViewFlowLayout alloc] init];
        _customLayout.minimumLineSpacing = 1;
        _customLayout.minimumInteritemSpacing = 1;
        _customLayout.sectionInset = UIEdgeInsetsMake(0.5, 0, 0.5, 0);
        //        if (iOS9_Later) {
        //            _customLayout.sectionHeadersPinToVisibleBounds = YES;
        //        }
    }
    return _customLayout;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat collectionHeight = self.view.hx_h;
        if (self.manager.configuration.showDateSectionHeader) {
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.hx_w, collectionHeight) collectionViewLayout:self.customLayout];
        }else {
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.hx_w, collectionHeight) collectionViewLayout:self.flowLayout];
        }
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[YM_DatePhotoViewCell class] forCellWithReuseIdentifier:@"DateCellId"];
        [_collectionView registerClass:[YM_DatePhotoCameraViewCell class] forCellWithReuseIdentifier:@"DateCameraCellId"];
        [_collectionView registerClass:[YM_DatePhotoViewSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeaderId"];
        [_collectionView registerClass:[YM_DatePhotoViewSectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"sectionFooterId"];
        
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            if ([self navigationBarWhetherSetupBackground]) {
                self.navigationController.navigationBar.translucent = YES;
            }
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
#else
            if ((NO)) {
#endif
            } else {
                if ([self navigationBarWhetherSetupBackground]) {
                    self.navigationController.navigationBar.translucent = YES;
                }
                self.automaticallyAdjustsScrollViewInsets = NO;
            }
            if (self.manager.configuration.open3DTouchPreview) {
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
            _flowLayout.minimumLineSpacing = 1;
            _flowLayout.minimumInteritemSpacing = 1;
            _flowLayout.sectionInset = UIEdgeInsetsMake(0.5, 0, 0.5, 0);
            //        if (iOS9_Later) {
            //            _flowLayout.sectionHeadersPinToVisibleBounds = YES;
            //        }
        }
        return _flowLayout;
    }
    - (NSMutableArray *)allArray {
        if (!_allArray) {
            _allArray = [NSMutableArray array];
        }
        return _allArray;
    }
    - (NSMutableArray *)photoArray {
        if (!_photoArray) {
            _photoArray = [NSMutableArray array];
        }
        return _photoArray;
    }
    - (NSMutableArray *)videoArray {
        if (!_videoArray) {
            _videoArray = [NSMutableArray array];
        }
        return _videoArray;
    }
    - (NSMutableArray *)previewArray {
        if (!_previewArray) {
            _previewArray = [NSMutableArray array];
        }
        return _previewArray;
    }
    - (NSMutableArray *)dateArray {
        if (!_dateArray) {
            _dateArray = [NSMutableArray array];
        }
        return _dateArray;
    }
    - (void)dealloc {
        if (showLog) NSSLog(@"dealloc");
        [self.collectionView.layer removeAllAnimations];
        if (self.manager.configuration.open3DTouchPreview) {
            if (self.previewingContext) {
                [self unregisterForPreviewingWithContext:self.previewingContext];
            }
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
@end
