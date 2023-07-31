//
//  YM_PhotoView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PhotoView.h"
#import "YM_PhotoSubViewCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#import "UIView+YM_Extension.h"
#import "UIImage+YM_Extension.h"
#import "YM_AlbumListViewController.h"
#import "YM_DatePhotoPreviewViewController.h"
#import "YM_CustomNavigationController.h"
#import "YM_CustomCameraViewController.h"
#import "YM_DatePhotoToolManager.h"

#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

#define Spacing 3 // 每个item的间距  !! 这个宏已经没用了, 请用HXPhotoView 的 spacing 这个属性来控制

#define LineNum 3 // 每行个数  !! 这个宏已经没用了, 请用HXPhotoView 的 lineCount 这个属性来控制

static NSString *YM_PhotoSubViewCellId = @"photoSubViewCellId";

@interface YM_PhotoView () <YM_CollectionViewDataSource,YM_CollectionViewDelegate,YM_PhotoSubViewCellDelegate,UIActionSheetDelegate,UIAlertViewDelegate,YM_AlbumListViewControllerDelegate,YM_CustomCameraViewControllerDelegate,YM_DatePhotoPreviewViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray *videos;
@property (strong, nonatomic) YM_PhotoModel *addModel;
@property (assign, nonatomic) BOOL isAddModel;
@property (assign, nonatomic) BOOL original;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (assign, nonatomic) NSInteger numOfLinesOld;
@property (assign, nonatomic) BOOL downLoadComplete;
@property (strong, nonatomic) UIImage *tempCameraImage;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (strong, nonatomic) YM_PhotoSubViewCell *addCell;
@property (assign, nonatomic) BOOL tempShowAddCell;
@property (strong, nonatomic) YM_DatePhotoToolManager *toolManager;

@end

@implementation YM_PhotoView
- (NSMutableArray *)imageList {
    if (!_imageList) {
        _imageList = [NSMutableArray array];
    }
    return _imageList;
}
- (YM_DatePhotoToolManager *)toolManager {
    if (!_toolManager) {
        _toolManager = [[YM_DatePhotoToolManager alloc] init];
    }
    return _toolManager;
}
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _flowLayout;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}
- (YM_PhotoSubViewCell *)addCell {
    if (!_addCell) {
        _addCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"addCell" forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        _addCell.model = self.addModel;
    }
    return _addCell;
}
- (YM_PhotoModel *)addModel {
    if (!_addModel) {
        _addModel = [[YM_PhotoModel alloc] init];
        _addModel.type = YM_PhotoModelMediaType_Camera;
        //        if (self.manager.UIManager.photoViewAddImageName) {
        //            _addModel.thumbPhoto = [YM_PhotoTools hx_imageNamed:self.manager.UIManager.photoViewAddImageName];
        //        }else {
        _addModel.thumbPhoto = [YM_PhotoTools ym_imageNamed:@"compose_pic_add@2x.png"];
        //        }
    }
    return _addModel;
}

+ (instancetype)photoManager:(YM_PhotoManager *)manager {
    return [[self alloc] initWithManager:manager];
}
- (instancetype)initWithFrame:(CGRect)frame manager:(YM_PhotoManager *)manager {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.manager = manager;
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame WithManager:(YM_PhotoManager *)manager {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.manager = manager;
    }
    return self;
}

- (instancetype)initWithManager:(YM_PhotoManager *)manager {
    self = [super init];
    if (self) {
        [self setup];
        self.manager = manager;
    }
    return self;
}
- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.spacing = 3;
    self.lineCount = 3;
    self.numOfLinesOld = 0;
    [self setup];
    self.manager = [[YM_PhotoManager alloc] init];
}

- (void)setup {
    self.spacing = 3;
    self.lineCount = 3;
    self.numOfLinesOld = 0;
    self.tag = 9999;
    self.showAddCell = YES;
    
    self.flowLayout.minimumLineSpacing = self.spacing;
    self.flowLayout.minimumInteritemSpacing = self.spacing;
    self.collectionView = [[YM_CollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.tag = 8888;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = self.backgroundColor;
    [self.collectionView registerClass:[YM_PhotoSubViewCell class] forCellWithReuseIdentifier:YM_PhotoSubViewCellId];
    [self.collectionView registerClass:[YM_PhotoSubViewCell class] forCellWithReuseIdentifier:@"addCell"];
    [self addSubview:self.collectionView];
    if (self.manager.afterSelectedArray.count > 0) {
        self.imageList = [NSMutableArray array];
        for (YM_PhotoModel *photoModel in self.manager.afterSelectedArray) {
            [self.imageList addObject:photoModel.thumbPhoto];
        }
        [self photoViewControllerDidNext:self.manager.afterSelectedArray.mutableCopy Photos:self.manager.afterSelectedPhotoArray.mutableCopy Videos:self.manager.afterSelectedVideoArray.mutableCopy Original:self.manager.afterOriginal];
    }
}

- (void)setEditEnabled:(BOOL)editEnabled {
    _editEnabled = editEnabled;
    self.collectionView.editEnabled = editEnabled;
}

- (void)setManager:(YM_PhotoManager *)manager {
    _manager = manager;
    manager.configuration.specialModeNeedHideVideoSelectBtn = YES;
    if (self.manager.afterSelectedArray.count > 0) {
        self.imageList = [NSMutableArray array];
        for (YM_PhotoModel *photoModel in self.manager.afterSelectedArray) {
            [self.imageList addObject:photoModel.thumbPhoto];
        }
        [self photoViewControllerDidNext:self.manager.afterSelectedArray.mutableCopy Photos:self.manager.afterSelectedPhotoArray.mutableCopy Videos:self.manager.afterSelectedVideoArray.mutableCopy Original:self.manager.afterOriginal];
    }
}

- (void)setHideDeleteButton:(BOOL)hideDeleteButton {
    _hideDeleteButton = hideDeleteButton;
    [self.collectionView reloadData];
}
- (void)setShowAddCell:(BOOL)showAddCell {
    _showAddCell = showAddCell;
    self.tempShowAddCell = showAddCell;
    if (self.manager.afterSelectedArray.count > 0) {
        [self photoViewControllerDidNext:self.manager.afterSelectedArray.mutableCopy Photos:self.manager.afterSelectedPhotoArray.mutableCopy Videos:self.manager.afterSelectedVideoArray.mutableCopy Original:self.manager.afterOriginal];
    }
}
/**
 刷新视图
 */
- (void)refreshView {
    [self photoViewControllerDidNext:self.manager.afterSelectedArray.mutableCopy Photos:self.manager.afterSelectedPhotoArray.mutableCopy Videos:self.manager.afterSelectedVideoArray.mutableCopy Original:self.manager.afterOriginal];
}
- (NSString *)videoOutFutFileName {
    NSString *fileName = @"";
    NSDate *nowDate = [NSDate date];
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
    NSString *numStr = [NSString stringWithFormat:@"%d",arc4random()%10000];
    fileName = [fileName stringByAppendingString:dateStr];
    fileName = [fileName stringByAppendingString:numStr];
    return fileName;
}

#pragma mark - 相册事件
/**  跳转相册 如果需要选择相机/相册时 还是需要选择  */
- (void)goPhotoViewController {
    if (self.outerCamera) {
        //        self.manager.openCamera = NO;
        if (self.manager.type == YM_PhotoManagerType_Photo) {
            self.manager.configuration.maxNum = self.manager.configuration.photoMaxNum;
        }else if (self.manager.type == YM_PhotoManagerType_Video) {
            self.manager.configuration.maxNum = self.manager.configuration.videoMaxNum;
        }else {
            // 防错
            if (self.manager.configuration.videoMaxNum + self.manager.configuration.photoMaxNum != self.manager.configuration.maxNum) {
                self.manager.configuration.maxNum = self.manager.configuration.videoMaxNum + self.manager.configuration.photoMaxNum;
            }
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"相机"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self goCameraViewController];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"相册"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self directGoPhotoViewController];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"取消"] style:UIAlertActionStyleCancel handler:nil]];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
        //        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[NSBundle ym_localizedStringForKey:@"取消"] destructiveButtonTitle:nil otherButtonTitles:[NSBundle ym_localizedStringForKey:@"相机"],[NSBundle ym_localizedStringForKey:@"相册"], nil];
        //
        //        [sheet showInView:self];
        return;
    }
    [self directGoPhotoViewController];
}

/** 打开相片、视屏详情 */
- (void)goPhoneDetailViewWithModel:(YM_PhotoModel *)photoModel {
    YM_DatePhotoPreviewViewController *vc = [[YM_DatePhotoPreviewViewController alloc] init];
    vc.outside = YES;
    vc.manager = self.manager;
    vc.delegate = self;
    vc.modelArray = [NSMutableArray arrayWithArray:self.manager.afterSelectedArray];
    vc.currentModelIndex = [self.manager.afterSelectedArray indexOfObject:photoModel];
    vc.previewShowDeleteButton = self.previewShowDeleteButton;
    vc.photoView = self;
    [[self viewController] presentViewController:vc animated:YES completion:nil];
}

#pragma mark - <YM_CollectionViewDataSource,YM_CollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tempShowAddCell ? self.dataList.count + 1 : self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tempShowAddCell) {
        if (indexPath.item == self.dataList.count) {
            return self.addCell;
        }
    }
    YM_PhotoSubViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YM_PhotoSubViewCellId forIndexPath:indexPath];
    cell.delegate = self;
    cell.model = self.dataList[indexPath.item];
    cell.showDeleteNetworkPhotoAlert = self.manager.configuration.showDeleteNetworkPhotoAlert;
    cell.hideDeleteButton = self.hideDeleteButton;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tempShowAddCell) {
        if (indexPath.item == self.dataList.count) {
            [self goPhotoViewController];
            return;
        }
    }
    self.currentIndexPath = indexPath;
    YM_PhotoModel *model = self.dataList[indexPath.item];
    if (model.networkPhotoUrl) {
        if (model.downloadError) {
            YM_PhotoSubViewCell *cell = (YM_PhotoSubViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell againDownload];
            return;
        }
    }
    if (model.type == YM_PhotoModelMediaType_Camera) {
        [self goPhotoViewController];
    }else {
        [self goPhoneDetailViewWithModel:model];
    }
}

#pragma mark - < YM_DatePhotoPreviewViewControllerDelegate >
- (void)datePhotoPreviewDidDeleteClick:(YM_DatePhotoPreviewViewController *)previewController deleteModel:(YM_PhotoModel *)model deleteIndex:(NSInteger)index {
    [self deleteModelWithIndex:index];
}

- (void)datePhotoPreviewSelectLaterDidEditClick:(YM_DatePhotoPreviewViewController *)previewController beforeModel:(YM_PhotoModel *)beforeModel afterModel:(YM_PhotoModel *)afterModel {
    [self.manager afterSelectedArrayReplaceModelAtModel:beforeModel withModel:afterModel];
    [self.manager afterSelectedListAddEditPhotoModel:afterModel];
    
    [self.photos removeAllObjects];
    [self.videos removeAllObjects];
    NSInteger i = 0;
    for (YM_PhotoModel *model in self.manager.afterSelectedArray) {
        model.selectIndexStr = [NSString stringWithFormat:@"%ld",i + 1];
        if (model.subType == YM_PhotoModelMediaSubType_Photo) {
            [self.photos addObject:model];
        }else if (model.subType == YM_PhotoModelMediaSubType_Video) {
            [self.videos addObject:model];
        }
        i++;
    }
    [self.manager setAfterSelectedPhotoArray:self.photos];
    [self.manager setAfterSelectedVideoArray:self.videos];
    [self.dataList replaceObjectAtIndex:[self.dataList indexOfObject:beforeModel] withObject:afterModel];
    [self.collectionView reloadData];
    [self dragCellCollectionViewCellEndMoving:self.collectionView];
}


- (void)directGoPhotoViewController {
    YM_AlbumListViewController *vc = [[YM_AlbumListViewController alloc] init];
    vc.manager = self.manager;
    vc.delegate = self;
    YM_CustomNavigationController *nav = [[YM_CustomNavigationController alloc] initWithRootViewController:vc];
    nav.supportRotation = self.manager.configuration.supportRotation;
    [[self viewController] presentViewController:nav animated:YES completion:nil];
}

/**
 前往相机
 */
- (void)goCameraViewController {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[self viewController].view showImageHUDText:[NSBundle ym_localizedStringForKey:@"无法使用相机!"]];
        return;
    }
    kWeakSelf
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            kStrongSelf
            if (granted) {
                if (self.manager.configuration.replaceCameraViewController) {
                    YM_PhotoConfigurationCameraType cameraType;
                    if (self.manager.type == YM_PhotoManagerType_Photo) {
                        cameraType = YM_PhotoConfigurationCameraType_Photo;
                    }else if (self.manager.type == YM_PhotoManagerType_Video) {
                        cameraType = YM_PhotoConfigurationCameraType_Video;
                    }else {
                        if (!self.manager.configuration.selectTogether) {
                            if (self.manager.afterSelectedPhotoArray.count > 0) {
                                cameraType = YM_PhotoConfigurationCameraType_Photo;
                            }else if (self.manager.afterSelectedVideoArray.count > 0) {
                                cameraType = YM_PhotoConfigurationCameraType_Video;
                            }else {
                                cameraType = YM_PhotoConfigurationCameraType_PhotoAndVideo;
                            }
                        }else {
                            cameraType = YM_PhotoConfigurationCameraType_PhotoAndVideo;
                        }
                    }
                    self.manager.configuration.shouldUseCamera([self viewController], cameraType, self.manager);
                    self.manager.configuration.useCameraComplete = ^(YM_PhotoModel *model) {
                        kStrongSelf
                        [self customCameraViewController:nil didDone:model];
                    };
                    return;
                }
                YM_CustomCameraViewController *vc = [[YM_CustomCameraViewController alloc] init];
                vc.delegate = weakSelf;
                vc.manager = self.manager;
                vc.isOutside = YES;
                YM_CustomNavigationController *nav = [[YM_CustomNavigationController alloc] initWithRootViewController:vc];
                nav.isCamera = YES;
                nav.supportRotation = self.manager.configuration.supportRotation;
                [[self viewController] presentViewController:nav animated:YES completion:nil];
            }else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle ym_localizedStringForKey:@"无法使用相机"] message:[NSBundle ym_localizedStringForKey:@"请在设置-隐私-相机中允许访问相机"] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"取消"] style:UIAlertActionStyleDefault handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:@"设置"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }]];
                [[self viewController] presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self goCameraViewController];
    }else if (buttonIndex == 1){
        [self directGoPhotoViewController];
    }
}

/**
 前往设置开启权限
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
- (void)customCameraViewController:(YM_CustomCameraViewController *)viewController didDone:(YM_PhotoModel *)model {
    [self cameraDidNextClick:model];
}
/**
 相机拍完之后的代理
 
 @param model 照片模型
 */
- (void)cameraDidNextClick:(YM_PhotoModel *)model {
    // 判断类型
    if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
        // 当选择图片个数没有达到最大个数时就添加到选中数组中
        if ([self.manager afterSelectPhotoCountIsMaximum]) {
            [[self viewController].view showImageHUDText:[NSString stringWithFormat:[NSBundle ym_localizedStringForKey:@"最多只能选择%ld张图片"],self.manager.configuration.photoMaxNum]];
            return;
        }
    }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
        // 当选中视频个数没有达到最大个数时就添加到选中数组中
        if (model.videoDuration < 3) {
            [[self viewController].view showImageHUDText:[NSBundle ym_localizedStringForKey:@"视频少于3秒,无法选择"]];
            return;
        }else if (model.videoDuration > self.manager.configuration.videoMaxDuration) {
            [[self viewController].view showImageHUDText:[NSBundle ym_localizedStringForKey:@"视频过大,无法选择"]];
            return;
        }else if ([self.manager afterSelectVideoCountIsMaximum]) {
            [[self viewController].view showImageHUDText:[NSString stringWithFormat:[NSBundle ym_localizedStringForKey:@"最多只能选择%ld个视频"],self.manager.configuration.videoMaxNum]];
            return;
        }
    }
    [self.manager afterListAddCameraTakePicturesModel:model];
    if (self.manager.configuration.requestImageAfterFinishingSelection) {
        [self.imageList addObject:model.thumbPhoto];
        if ([self.delegate respondsToSelector:@selector(photoView:imageChangeComplete:)]) {
            [self.delegate photoView:self imageChangeComplete:self.imageList];
        }
    }
    [self photoViewControllerDidNext:self.manager.afterSelectedArray.mutableCopy Photos:self.manager.afterSelectedPhotoArray.mutableCopy Videos:self.manager.afterSelectedVideoArray.mutableCopy Original:self.manager.afterOriginal];
}

- (void)deleteModelWithIndex:(NSInteger)index {
    if (index < 0) {
        index = 0;
    }
    if (index > self.manager.afterSelectedArray.count - 1) {
        index = self.manager.afterSelectedArray.count - 1;
    }
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (cell) {
        [self cellDidDeleteClcik:cell];
    }else {
        if (showLog) NSSLog(@"删除失败 - cell为空");
    }
}
/**
 cell删除按钮的代理
 
 @param cell 被删的cell
 */
- (void)cellDidDeleteClcik:(UICollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    if (self.manager.configuration.requestImageAfterFinishingSelection) {
        if (indexPath.item < self.imageList.count) {
            [self.imageList removeObjectAtIndex:indexPath.item];
        }
        if ([self.delegate respondsToSelector:@selector(photoView:imageChangeComplete:)]) {
            [self.delegate photoView:self imageChangeComplete:self.imageList];
        }
    }
    YM_PhotoModel *model = self.dataList[indexPath.item];
    [self.manager afterSelectedListdeletePhotoModel:model];
    if ((model.type == YM_PhotoModelMediaType_Photo || model.type == YM_PhotoModelMediaType_PhotoGif) || (model.type == YM_PhotoModelMediaType_CameraPhoto || model.type == YM_PhotoModelMediaType_LivePhoto)) {
        [self.photos removeObject:model];
    }else if (model.type == YM_PhotoModelMediaType_Video || model.type == YM_PhotoModelMediaType_CameraVideo) {
        [self.videos removeObject:model];
    }
    
    UIView *mirrorView = [cell snapshotViewAfterScreenUpdates:NO];
    mirrorView.frame = cell.frame;
    [self.collectionView insertSubview:mirrorView atIndex:0];
    cell.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        mirrorView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        YM_PhotoSubViewCell *myCell = (YM_PhotoSubViewCell *)cell;
        myCell.imageView.image = nil;
        [mirrorView removeFromSuperview];
    }];
    [self.dataList removeObjectAtIndex:indexPath.item];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self changeSelectedListModelIndex];
    if (self.showAddCell) {
        if (!self.tempShowAddCell) {
            self.tempShowAddCell = YES;
            [self.collectionView reloadData];
        }
    }
    if ([self.delegate respondsToSelector:@selector(photoView:changeComplete:photos:videos:original:)]) {
        [self.delegate photoView:self changeComplete:self.dataList photos:self.photos videos:self.videos original:self.original];
    }
    if ([self.delegate respondsToSelector:@selector(photoView:currentDeleteModel:currentIndex:)]) {
        [self.delegate photoView:self currentDeleteModel:model currentIndex:indexPath.item];
    }
    if (model.type != YM_PhotoModelMediaType_CameraPhoto &&
        model.type != YM_PhotoModelMediaType_CameraVideo) {
        model.thumbPhoto = nil;
        model.previewPhoto = nil;
        model = nil;
    }
    [self setupNewFrame];
}

- (void)changeSelectedListModelIndex {
    int i = 0;
    for (YM_PhotoModel *model in self.dataList) {
        model.selectIndexStr = [NSString stringWithFormat:@"%d",i + 1];
        i++;
    }
}
#pragma mark - < YM_AlbumListViewControllerDelegate >
- (void)albumListViewController:(YM_AlbumListViewController *)albumListViewController didDoneAllImage:(NSArray<UIImage *> *)imageList {
    self.imageList = [NSMutableArray arrayWithArray:imageList];
    if ([self.delegate respondsToSelector:@selector(photoView:imageChangeComplete:)]) {
        [self.delegate photoView:self imageChangeComplete:imageList];
    }
}
- (void)albumListViewController:(YM_AlbumListViewController *)albumListViewController didDoneAllList:(NSArray<YM_PhotoModel *> *)allList photos:(NSArray<YM_PhotoModel *> *)photoList videos:(NSArray<YM_PhotoModel *> *)videoList original:(BOOL)original {
    [self photoViewControllerDidNext:allList Photos:photoList Videos:videoList Original:original];
}
- (void)photoViewControllerDidNext:(NSArray<YM_PhotoModel *> *)allList Photos:(NSArray<YM_PhotoModel *> *)photos Videos:(NSArray<YM_PhotoModel *> *)videos Original:(BOOL)original {
    self.original = original;
    NSMutableArray *tempAllArray = [NSMutableArray array];
    NSMutableArray *tempPhotoArray = [NSMutableArray array];
    [tempAllArray addObjectsFromArray:allList];
    [tempPhotoArray addObjectsFromArray:photos];
    allList = tempAllArray;
    photos = tempPhotoArray;
    
    self.photos = [NSMutableArray arrayWithArray:photos];
    self.videos = [NSMutableArray arrayWithArray:videos];
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:allList];
    if (self.showAddCell) {
        self.tempShowAddCell = YES;
        if (self.manager.configuration.selectTogether) {
            if (self.manager.configuration.maxNum == allList.count) {
                self.tempShowAddCell = NO;
            }
        }else {
            if (photos.count > 0) {
                if (photos.count == self.manager.configuration.photoMaxNum) {
                    if (self.manager.configuration.photoMaxNum > 0) {
                        self.tempShowAddCell = NO;
                    }
                }
            }else if (videos.count > 0) {
                if (videos.count == self.manager.configuration.videoMaxNum) {
                    if (self.manager.configuration.videoMaxNum > 0) {
                        self.tempShowAddCell = NO;
                    }
                }
            }
        }
    }
    [self changeSelectedListModelIndex];
    [self.collectionView reloadData];
    if ([self.delegate respondsToSelector:@selector(photoView:changeComplete:photos:videos:original:)]) {
        [self.delegate photoView:self changeComplete:allList.copy photos:photos.copy videos:videos.copy original:original];
    }
    [self setupNewFrame];
}

- (void)photoViewControllerDidCancel {
    if ([self.delegate respondsToSelector:@selector(photoViewDidCancel:)]) {
        [self.delegate photoViewDidCancel:self];
    }
}

- (NSArray *)dataSourceArrayOfCollectionView:(YM_CollectionView *)collectionView {
    return self.dataList;
}

- (void)dragCellCollectionView:(YM_CollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray {
    self.dataList = [NSMutableArray arrayWithArray:newDataArray];
}

- (void)dragCellCollectionView:(YM_CollectionView *)collectionView moveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    YM_PhotoModel *fromModel = self.dataList[fromIndexPath.item];
    YM_PhotoModel *toModel = self.dataList[toIndexPath.item];
    [self.manager afterSelectedArraySwapPlacesWithFromModel:fromModel fromIndex:fromIndexPath.item toModel:toModel toIndex:toIndexPath.item];
    if (self.manager.configuration.requestImageAfterFinishingSelection) {
        UIImage *fromImage = self.imageList[fromIndexPath.item];
        UIImage *toImage = self.imageList[toIndexPath.item];
        [self.imageList replaceObjectAtIndex:toIndexPath.item withObject:fromImage];
        [self.imageList replaceObjectAtIndex:fromIndexPath.item withObject:toImage];
    }
    //    [self.manager.endSelectedList removeObject:toModel];
    //    [self.manager.endSelectedList insertObject:toModel atIndex:toIndexPath.item];
    //    [self.manager.endSelectedList removeObject:fromModel];
    //    [self.manager.endSelectedList insertObject:fromModel atIndex:fromIndexPath.item];
    [self.photos removeAllObjects];
    [self.videos removeAllObjects];
    NSInteger i = 0;
    for (YM_PhotoModel *model in self.manager.afterSelectedArray) {
        model.selectIndexStr = [NSString stringWithFormat:@"%ld",i + 1];
        if (model.subType == YM_PhotoModelMediaSubType_Photo) {
            [self.photos addObject:model];
        }else if (model.subType == YM_PhotoModelMediaSubType_Video) {
            [self.videos addObject:model];
        }
        i++;
    }
    [self.manager setAfterSelectedPhotoArray:self.photos];
    [self.manager setAfterSelectedVideoArray:self.videos];
    //    int i = 0, j = 0, k = 0;
    //    for (YM_PhotoModel *model in self.manager.endSelectedList) {
    //        model.selectIndexStr = [NSString stringWithFormat:@"%d",k + 1];
    //        if ((model.type == YM_PhotoModelMediaType_Photo || model.type == YM_PhotoModelMediaType_PhotoGif) || (model.type == YM_PhotoModelMediaType_CameraPhoto || model.type == YM_PhotoModelMediaType_LivePhoto)) {
    //            model.endIndex = i++;
    //            [self.photos addObject:model];
    //        }else if (model.type == YM_PhotoModelMediaType_Video || model.type == YM_PhotoModelMediaType_CameraVideo) {
    //            model.endIndex = j++;
    //            [self.videos addObject:model];
    //        }
    //        model.endCollectionIndex = k++;
    //    }
    //    self.manager.endSelectedPhotos = [NSMutableArray arrayWithArray:self.photos];
    //    self.manager.endSelectedVideos = [NSMutableArray arrayWithArray:self.videos];
}

- (void)dragCellCollectionViewCellEndMoving:(YM_CollectionView *)collectionView {
    if (self.manager.configuration.requestImageAfterFinishingSelection) {
        if ([self.delegate respondsToSelector:@selector(photoView:imageChangeComplete:)]) {
            [self.delegate photoView:self imageChangeComplete:self.imageList];
        }
    }
    if ([self.delegate respondsToSelector:@selector(photoView:changeComplete:photos:videos:original:)]) {
        [self.delegate photoView:self changeComplete:self.dataList.mutableCopy photos:self.photos.mutableCopy videos:self.videos.mutableCopy original:self.original];
    }
}
- (BOOL)collectionViewShouldDeleteCurrentMoveItem:(UICollectionView *)collectionView {
    if ([self.delegate respondsToSelector:@selector(photoViewShouldDeleteCurrentMoveItem:)]) {
        return [self.delegate photoViewShouldDeleteCurrentMoveItem:self];
    }
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView gestureRecognizerBegan:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        if ([self.delegate respondsToSelector:@selector(photoView:gestureRecognizerBegan:indexPath:)]) {
            [self.delegate photoView:self gestureRecognizerBegan:longPgr indexPath:indexPath];
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView gestureRecognizerChange:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        YM_PhotoSubViewCell *cell = (YM_PhotoSubViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell.model.type == YM_PhotoModelMediaType_Camera) {
            return;
        }
        if ([self.delegate respondsToSelector:@selector(photoView:gestureRecognizerChange:indexPath:)]) {
            [self.delegate photoView:self gestureRecognizerChange:longPgr indexPath:indexPath];
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView gestureRecognizerEnded:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        if ([self.delegate respondsToSelector:@selector(photoView:gestureRecognizerEnded:indexPath:)]) {
            [self.delegate photoView:self gestureRecognizerEnded:longPgr indexPath:indexPath];
        }
    }
}

- (NSIndexPath *)currentModelIndexPath:(YM_PhotoModel *)model {
    if ([self.dataList containsObject:model]) {
        return [NSIndexPath indexPathForItem:[self.dataList indexOfObject:model] inSection:0];
    }
    return [NSIndexPath indexPathForItem:0 inSection:0];
}
/**
 更新高度
 */
- (void)setupNewFrame {
    double x = self.frame.origin.x;
    double y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    
    CGFloat itemW = (width - self.spacing * (self.lineCount - 1)) / self.lineCount;
    if (itemW > 0) {
        self.flowLayout.itemSize = CGSizeMake(itemW, itemW);
    }
    
    NSInteger dataCount = self.tempShowAddCell ? self.dataList.count + 1 : self.dataList.count;
    NSInteger numOfLinesNew = 0;
    if (self.lineCount != 0) {
        numOfLinesNew = (dataCount / self.lineCount) + 1;
    }
    
    if (dataCount % self.lineCount == 0) {
        numOfLinesNew -= 1;
    }
    self.flowLayout.minimumLineSpacing = self.spacing;
    
    if (numOfLinesNew != self.numOfLinesOld) {
        CGFloat newHeight = numOfLinesNew * itemW + self.spacing * (numOfLinesNew - 1);
        if (newHeight < 0) {
            newHeight = 0;
        }
        self.frame = CGRectMake(x, y, width, newHeight);
        self.numOfLinesOld = numOfLinesNew;
        if (newHeight <= 0) {
            self.numOfLinesOld = 0;
        }
        if ([self.delegate respondsToSelector:@selector(photoView:updateFrame:)]) {
            [self.delegate photoView:self updateFrame:self.frame];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger dataCount = self.tempShowAddCell ? self.dataList.count + 1 : self.dataList.count;
    NSInteger numOfLinesNew = (dataCount / self.lineCount) + 1;
    
    [self setupNewFrame];
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (dataCount == 1) {
        CGFloat itemW = (width - self.spacing * (self.lineCount - 1)) / self.lineCount;
        if ((int)height != (int)itemW) {
            self.frame = CGRectMake(x, y, width, itemW);
        }
    }
    if (dataCount % self.lineCount == 0) {
        numOfLinesNew -= 1;
    }
    CGFloat cWidth = self.frame.size.width;
    CGFloat cHeight = self.frame.size.height;
    self.collectionView.frame = CGRectMake(0, 0, cWidth, cHeight);
    if (cHeight <= 0) {
        self.numOfLinesOld = 0;
        [self setupNewFrame];
        CGFloat cWidth = self.frame.size.width;
        CGFloat cHeight = self.frame.size.height;
        self.collectionView.frame = CGRectMake(0, 0, cWidth, cHeight);
    }
}
- (void)dealloc {
    if (showLog) NSSLog(@"dealloc");
}
@end
