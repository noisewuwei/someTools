//
//  YM_PhotoManager.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/3.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PhotoManager.h"
#import "YM_CustomAssetModel.h"
#import "YM_PhotoModel.h"
#import "YM_PhotoDateModel.h"

@interface YM_PhotoManager ()

@property (strong, nonatomic) NSMutableArray *allPhotos;
@property (strong, nonatomic) NSMutableArray *allVideos;
@property (strong, nonatomic) NSMutableArray *allObjs;
//@property (assign, nonatomic) BOOL hasLivePhoto;
//------// 当要删除的已选中的图片或者视频的时候需要在对应的end数组里面删除
// 例如: 如果删除的是通过相机拍的照片需要在 endCameraList 和 endCameraPhotos 数组删除对应的图片模型
@property (strong, nonatomic) NSMutableArray *selectedList;
@property (strong, nonatomic) NSMutableArray *selectedPhotos;
@property (strong, nonatomic) NSMutableArray *selectedVideos;
@property (strong, nonatomic) NSMutableArray *cameraList;
@property (strong, nonatomic) NSMutableArray *cameraPhotos;
@property (strong, nonatomic) NSMutableArray *cameraVideos;
@property (strong, nonatomic) NSMutableArray *endCameraList;
@property (strong, nonatomic) NSMutableArray *endCameraPhotos;
@property (strong, nonatomic) NSMutableArray *endCameraVideos;
@property (strong, nonatomic) NSMutableArray *selectedCameraList;
@property (strong, nonatomic) NSMutableArray *selectedCameraPhotos;
@property (strong, nonatomic) NSMutableArray *selectedCameraVideos;
@property (strong, nonatomic) NSMutableArray *endSelectedCameraList;
@property (strong, nonatomic) NSMutableArray *endSelectedCameraPhotos;
@property (strong, nonatomic) NSMutableArray *endSelectedCameraVideos;
@property (strong, nonatomic) NSMutableArray *endSelectedList;
@property (strong, nonatomic) NSMutableArray *endSelectedPhotos;
@property (strong, nonatomic) NSMutableArray *endSelectedVideos;
//------//
@property (assign, nonatomic) BOOL isOriginal;
@property (assign, nonatomic) BOOL endIsOriginal;
@property (copy, nonatomic) NSString *photosTotalBtyes;
@property (copy, nonatomic) NSString *endPhotosTotalBtyes;
@property (strong, nonatomic) NSMutableArray *iCloudUploadArray;
@property (strong, nonatomic) NSMutableArray *albums;

@end

@implementation YM_PhotoManager

#pragma mark - < 初始化 >
- (instancetype)initWithType:(YM_PhotoManagerType)type {
    if (self = [super init]) {
        self.type = type;
        [self setup];
    }
    return self;
}
- (instancetype)init {
    if ([super init]) {
        self.type = YM_PhotoManagerType_Photo;
        [self setup];
    }
    return self;
}
- (void)setup {
    self.albums = [NSMutableArray array];
    self.selectedList = [NSMutableArray array];
    self.selectedPhotos = [NSMutableArray array];
    self.selectedVideos = [NSMutableArray array];
    self.endSelectedList = [NSMutableArray array];
    self.endSelectedPhotos = [NSMutableArray array];
    self.endSelectedVideos = [NSMutableArray array];
    self.cameraList = [NSMutableArray array];
    self.cameraPhotos = [NSMutableArray array];
    self.cameraVideos = [NSMutableArray array];
    self.endCameraList = [NSMutableArray array];
    self.endCameraPhotos = [NSMutableArray array];
    self.endCameraVideos = [NSMutableArray array];
    self.selectedCameraList = [NSMutableArray array];
    self.selectedCameraPhotos = [NSMutableArray array];
    self.selectedCameraVideos = [NSMutableArray array];
    self.endSelectedCameraList = [NSMutableArray array];
    self.endSelectedCameraPhotos = [NSMutableArray array];
    self.endSelectedCameraVideos = [NSMutableArray array];
    self.iCloudUploadArray = [NSMutableArray array];
    //    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}
- (YM_PhotoConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [[YM_PhotoConfiguration alloc] init];
    }
    return _configuration;
}
- (void)setLocalImageList:(NSArray *)localImageList {
    _localImageList = localImageList;
    if (!localImageList.count) return;
    if (![localImageList.firstObject isKindOfClass:[UIImage class]]) {
        if (showLog) NSSLog(@"请传入装着UIImage对象的数组");
        return;
    }
    for (UIImage *image in localImageList) {
        YM_PhotoModel *photoModel = [YM_PhotoModel photoModelWithImage:image];
        photoModel.selected = YES;
        [self.endCameraPhotos addObject:photoModel];
        [self.endSelectedCameraPhotos addObject:photoModel];
        [self.endCameraList addObject:photoModel];
        [self.endSelectedCameraList addObject:photoModel];
        [self.endSelectedPhotos addObject:photoModel];
        [self.endSelectedList addObject:photoModel];
    }
}
- (void)addCustomAssetModel:(NSArray<YM_CustomAssetModel *> *)assetArray {
    if (!assetArray.count) return;
    if (![assetArray.firstObject isKindOfClass:[YM_CustomAssetModel class]]) {
        if (showLog) NSSLog(@"请传入装着YM_CustomAssetModel对象的数组");
        return;
    }
    self.configuration.deleteTemporaryPhoto = NO;
    NSInteger photoMaxCount = self.configuration.photoMaxNum;
    NSInteger videoMaxCount = self.configuration.videoMaxNum;
    NSInteger photoCount = 0;
    NSInteger videoCount = 0;
    BOOL canAddPhoto;
    BOOL canAddVideo;
    BOOL selectTogether = self.configuration.selectTogether;
    YM_PhotoModel *firstModel;
    for (YM_CustomAssetModel *model in assetArray) {
        canAddPhoto = !(photoCount >= photoMaxCount);
        canAddVideo = !(videoCount >= videoMaxCount);
        if (!selectTogether && firstModel) {
            if (firstModel.subType == YM_PhotoModelMediaSubType_Photo) {
                canAddVideo = NO;
            }else if (firstModel.subType == YM_PhotoModelMediaSubType_Video) {
                canAddPhoto = NO;
            }
        }
        if (model.type == YM_CustomAssetModelType_LocalImage && model.localImage) {
            if (self.type == YM_PhotoModelMediaSubType_Video) {
                continue;
            }
            YM_PhotoModel *photoModel = [YM_PhotoModel photoModelWithImage:model.localImage];
            photoModel.selected = canAddPhoto ? model.selected : NO;
            if (model.selected && canAddPhoto) {
                [self.endCameraPhotos addObject:photoModel];
                [self.endSelectedCameraPhotos addObject:photoModel];
                [self.endCameraList addObject:photoModel];
                [self.endSelectedCameraList addObject:photoModel];
                [self.endSelectedPhotos addObject:photoModel];
                [self.endSelectedList addObject:photoModel];
                firstModel = photoModel;
                photoCount++;
            }else {
                [self.endCameraPhotos addObject:photoModel];
                [self.endCameraList addObject:photoModel];
            }
        }else if (model.type == YM_CustomAssetModelType_NetWorkImage && model.networkImageURL) {
            if (self.type == YM_PhotoModelMediaSubType_Video) {
                continue;
            }
            YM_PhotoModel *photoModel = [YM_PhotoModel photoModelWithImageURL:model.networkImageURL];
            photoModel.selected = canAddPhoto ? model.selected : NO;
            if (model.selected && canAddPhoto) {
                [self.endCameraPhotos addObject:photoModel];
                [self.endSelectedCameraPhotos addObject:photoModel];
                [self.endCameraList addObject:photoModel];
                [self.endSelectedCameraList addObject:photoModel];
                [self.endSelectedPhotos addObject:photoModel];
                [self.endSelectedList addObject:photoModel];
                firstModel = photoModel;
                photoCount++;
            }else {
                [self.endCameraPhotos addObject:photoModel];
                [self.endCameraList addObject:photoModel];
            }
        }else if (model.type == YM_CustomAssetModelType_LocalVideo) {
            if (self.type == YM_PhotoModelMediaSubType_Photo) {
                continue;
            }
            // 本地视频
            YM_PhotoModel *photoModel = [YM_PhotoModel photoModelWithVideoURL:model.localVideoURL];
            photoModel.selected = canAddVideo ? model.selected : NO;
            if (model.selected && canAddVideo) {
                [self.endCameraVideos addObject:photoModel];
                [self.endSelectedCameraVideos addObject:photoModel];
                [self.endCameraList addObject:photoModel];
                [self.endSelectedCameraList addObject:photoModel];
                [self.endSelectedVideos addObject:photoModel];
                [self.endSelectedList addObject:photoModel];
                firstModel = photoModel;
                videoCount++;
            }else {
                [self.endCameraVideos addObject:photoModel];
                [self.endCameraList addObject:photoModel];
            }
        }
    }
}
- (void)addNetworkingImageToAlbum:(NSArray<NSString *> *)imageUrls selected:(BOOL)selected {
    if (!imageUrls.count) return;
    if (![imageUrls.firstObject isKindOfClass:[NSString class]]) {
        if (showLog) NSSLog(@"请传入装着NSString对象的数组");
        return;
    }
    self.configuration.deleteTemporaryPhoto = NO;
    for (NSString *imageUrlStr in imageUrls) {
        YM_PhotoModel *photoModel = [YM_PhotoModel photoModelWithImageURL:[NSURL URLWithString:imageUrlStr]];
        photoModel.selected = selected;
        if (selected) {
            [self.endCameraPhotos addObject:photoModel];
            [self.endSelectedCameraPhotos addObject:photoModel];
            [self.endCameraList addObject:photoModel];
            [self.endSelectedCameraList addObject:photoModel];
            [self.endSelectedPhotos addObject:photoModel];
            [self.endSelectedList addObject:photoModel];
        }else {
            [self.endCameraPhotos addObject:photoModel];
            [self.endCameraList addObject:photoModel];
        }
    }
}
- (void)setNetworkPhotoUrls:(NSArray<NSString *> *)networkPhotoUrls {
    _networkPhotoUrls = networkPhotoUrls;
    if (!networkPhotoUrls.count) return;
    if (![networkPhotoUrls.firstObject isKindOfClass:[NSString class]]) {
        if (showLog) NSSLog(@"请传入装着NSString对象的数组");
        return;
    }
    self.configuration.deleteTemporaryPhoto = NO;
    for (NSString *imageUrlStr in networkPhotoUrls) {
        YM_PhotoModel *photoModel = [YM_PhotoModel photoModelWithImageURL:[NSURL URLWithString:imageUrlStr]];
        photoModel.selected = NO;
        [self.endCameraPhotos addObject:photoModel];
        [self.endCameraList addObject:photoModel];
    }
}
- (void)addModelArray:(NSArray<YM_PhotoModel *> *)modelArray {
    if (!modelArray.count) return;
    if (![modelArray.firstObject isKindOfClass:[YM_PhotoModel class]]) {
        if (showLog) NSSLog(@"请传入装着YM_PhotoModel对象的数组");
        return;
    }
    for (YM_PhotoModel *photoModel in modelArray) {
        if (photoModel.subType == YM_PhotoModelMediaSubType_Photo) {
            [self.endSelectedPhotos addObject:photoModel];
        }else {
            [self.endSelectedVideos addObject:photoModel];
        }
        if (photoModel.type == YM_PhotoModelMediaType_CameraPhoto) {
            [self.endCameraPhotos addObject:photoModel];
            [self.endSelectedCameraPhotos addObject:photoModel];
            [self.endCameraList addObject:photoModel];
            [self.endSelectedCameraList addObject:photoModel];
        }else if (photoModel.type == YM_PhotoModelMediaType_CameraVideo) {
            [self.endCameraVideos addObject:photoModel];
            [self.endSelectedCameraVideos addObject:photoModel];
            [self.endCameraList addObject:photoModel];
            [self.endSelectedCameraList addObject:photoModel];
        }
        [self.endSelectedList addObject:photoModel];
    }
}
- (void)addLocalVideo:(NSArray<NSURL *> *)urlArray selected:(BOOL)selected {
    if (!urlArray.count) return;
    if (![urlArray.firstObject isKindOfClass:[NSURL class]]) {
        if (showLog) NSSLog(@"请传入装着NSURL对象的数组");
        return;
    }
    self.configuration.deleteTemporaryPhoto = NO;
    for (NSURL *url in urlArray) {
        YM_PhotoModel *model = [YM_PhotoModel photoModelWithVideoURL:url];
        model.selected = selected;
        if (selected) {
            [self.endCameraVideos addObject:model];
            [self.endSelectedCameraVideos addObject:model];
            [self.endCameraList addObject:model];
            [self.endSelectedCameraList addObject:model];
            [self.endSelectedVideos addObject:model];
            [self.endSelectedList addObject:model];
        }else {
            [self.endCameraVideos addObject:model];
            [self.endCameraList addObject:model];
        }
    }
}
- (void)addLocalImage:(NSArray *)images selected:(BOOL)selected {
    if (!images.count) return;
    if (![images.firstObject isKindOfClass:[UIImage class]]) {
        if (showLog) NSSLog(@"请传入装着UIImage对象的数组");
        return;
    }
    self.configuration.deleteTemporaryPhoto = NO;
    for (UIImage *image in images) {
        YM_PhotoModel *photoModel = [YM_PhotoModel photoModelWithImage:image];
        photoModel.selected = selected;
        if (selected) {
            [self.endCameraPhotos addObject:photoModel];
            [self.endSelectedCameraPhotos addObject:photoModel];
            [self.endCameraList addObject:photoModel];
            [self.endSelectedCameraList addObject:photoModel];
            [self.endSelectedPhotos addObject:photoModel];
            [self.endSelectedList addObject:photoModel];
        }else {
            [self.endCameraPhotos addObject:photoModel];
            [self.endCameraList addObject:photoModel];
        }
    }
}
- (void)addLocalImageToAlbumWithImages:(NSArray *)images {
    if (!images.count) return;
    if (![images.firstObject isKindOfClass:[UIImage class]]) {
        if (showLog) NSSLog(@"请传入装着UIImage对象的数组");
        return;
    }
    self.configuration.deleteTemporaryPhoto = NO;
    for (UIImage *image in images) {
        YM_PhotoModel *photoModel = [YM_PhotoModel photoModelWithImage:image];
        [self.endCameraPhotos addObject:photoModel];
        [self.endCameraList addObject:photoModel];
    }
}
/**
 获取系统所有相册
 @param albums 相册集合
 */
- (void)getAllPhotoAlbums:(void(^)(YM_AlbumModel *firstAlbumModel))firstModel
                   albums:(void(^)(NSArray *albums))albums
                  isFirst:(BOOL)isFirst {
    if (self.albums.count > 0) [self.albums removeAllObjects];
    [self.iCloudUploadArray removeAllObjects];
    // 获取系统智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 正向遍历搜索结果中的相册
    [smartAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isFirst) {
            if ([[YM_PhotoTools transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"相机胶卷"] ||
                [[YM_PhotoTools transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"所有照片"]) {
                
                // 是否按创建时间排序
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                if (self.type == YM_PhotoManagerType_Photo) {
                    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                }else if (self.type == YM_PhotoManagerType_Video) {
                    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                }
                // 获取照片集合
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection
                                                                      options:option];
                
                YM_AlbumModel *albumModel = [[YM_AlbumModel alloc] init];
                albumModel.count = result.count;
                albumModel.albumName = collection.localizedTitle;
                albumModel.result = result;
                albumModel.index = 0;
                if (firstModel) {
                    firstModel(albumModel);
                }
                *stop = YES;
            }
        }else {
            // 是否按创建时间排序
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            if (self.type == YM_PhotoManagerType_Photo) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            }else if (self.type == YM_PhotoManagerType_Video) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            // 获取相册集合
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            
            // 过滤掉空相册
            if (result.count > 0 &&
                ![[YM_PhotoTools transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"最近删除"]) {
                YM_AlbumModel *albumModel = [[YM_AlbumModel alloc] init];
                albumModel.count = result.count;
                albumModel.albumName = collection.localizedTitle;
                albumModel.result = result;
                if ([[YM_PhotoTools transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"相机胶卷"] ||
                    [[YM_PhotoTools transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"所有照片"]) {
                    [self.albums insertObject:albumModel atIndex:0];
                }else {
                    [self.albums addObject:albumModel];
                }
            }
        }
    }];
    if (isFirst) {
        return;
    }
    // 获取用户相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        // 是否按创建时间排序
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        if (self.type == YM_PhotoManagerType_Photo) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }else if (self.type == YM_PhotoManagerType_Video) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        // 获取照片集合
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        
        // 过滤掉空相册
        if (result.count > 0) {
            YM_AlbumModel *albumModel = [[YM_AlbumModel alloc] init];
            albumModel.count = result.count;
            albumModel.albumName = [YM_PhotoTools transFormPhotoTitle:collection.localizedTitle];
            albumModel.result = result;
            [self.albums addObject:albumModel];
        }
    }];
    for (int i = 0 ; i < self.albums.count; i++) {
        YM_AlbumModel *model = self.albums[i];
        model.index = i;
        //        NSPredicate *pred = [NSPredicate predicateWithFormat:@"currentAlbumIndex = %d", i];
        //        NSArray *newArray = [self.selectedList filteredArrayUsingPredicate:pred];
        //        model.selectedCount = newArray.count;
    }
    if (albums) {
        albums(self.albums);
    }
}

/**
 *  是否为同一天
 */
- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}
- (void)getPhotoListWithAlbumModel:(YM_AlbumModel *)albumModel complete:(void (^)(NSArray *allList , NSArray *previewList,NSArray *photoList ,NSArray *videoList ,NSArray *dateList , YM_PhotoModel *firstSelectModel))complete {
    NSMutableArray *allArray = [NSMutableArray array];
    NSMutableArray *previewArray = [NSMutableArray array];
    NSMutableArray *videoArray = [NSMutableArray array];
    NSMutableArray *photoArray = [NSMutableArray array];
    NSMutableArray *dateArray = [NSMutableArray array];
    
    __block NSDate *currentIndexDate;
    __block NSMutableArray *sameDayArray;
    __block YM_PhotoDateModel *dateModel;
    __block YM_PhotoModel *firstSelectModel;
    __block BOOL already = NO;
    NSMutableArray *selectList = [NSMutableArray arrayWithArray:self.selectedList];
    if (self.configuration.reverseDate) {
        [albumModel.result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            YM_PhotoModel *photoModel = [[YM_PhotoModel alloc] init];
            photoModel.clarityScale = self.configuration.clarityScale;
            photoModel.asset = asset;
            if ([[asset valueForKey:@"isCloudPlaceholder"] boolValue]) {
                if (self.iCloudUploadArray.count) {
                    NSString *property = @"asset";
                    //                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", property, asset];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"localIdentifier = %@", asset.localIdentifier];
                    NSArray *newArray = [self.iCloudUploadArray filteredArrayUsingPredicate:pred];
                    if (!newArray.count) {
                        photoModel.isICloud = YES;
                    }
                }else {
                    photoModel.isICloud = YES;
                }
            }
            if (selectList.count > 0) {
                NSString *property = @"asset";
                //                NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", property, asset];
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"localIdentifier = %@", asset.localIdentifier];
                NSArray *newArray = [selectList filteredArrayUsingPredicate:pred];
                if (newArray.count > 0) {
                    YM_PhotoModel *model = newArray.firstObject;
                    [selectList removeObject:model];
                    photoModel.selected = YES;
                    if ((model.type == YM_PhotoModelMediaType_Photo || model.type == YM_PhotoModelMediaType_PhotoGif) || (model.type == YM_PhotoModelMediaType_LivePhoto || model.type == YM_PhotoModelMediaType_CameraPhoto)) {
                        if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
                            [self.selectedCameraPhotos replaceObjectAtIndex:[self.selectedCameraPhotos indexOfObject:model] withObject:photoModel];
                        }else {
                            [self.selectedPhotos replaceObjectAtIndex:[self.selectedPhotos indexOfObject:model] withObject:photoModel];
                        }
                    }else {
                        if (model.type == YM_PhotoModelMediaType_CameraVideo) {
                            [self.selectedCameraVideos replaceObjectAtIndex:[self.selectedCameraVideos indexOfObject:model] withObject:photoModel];
                        }else {
                            [self.selectedVideos replaceObjectAtIndex:[self.selectedVideos indexOfObject:model] withObject:photoModel];
                        }
                    }
                    [self.selectedList replaceObjectAtIndex:[self.selectedList indexOfObject:model] withObject:photoModel];
                    photoModel.thumbPhoto = model.thumbPhoto;
                    photoModel.previewPhoto = model.previewPhoto;
                    photoModel.selectIndexStr = model.selectIndexStr;
                    if (!firstSelectModel) {
                        firstSelectModel = photoModel;
                    }
                }
            }
            if (asset.mediaType == PHAssetMediaTypeImage) {
                photoModel.subType = YM_PhotoModelMediaSubType_Photo;
                if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                    if (self.configuration.singleSelected) {
                        photoModel.type = YM_PhotoModelMediaType_Photo;
                    }else {
                        photoModel.type = self.configuration.lookGifPhoto ? YM_PhotoModelMediaType_PhotoGif : YM_PhotoModelMediaType_Photo;
                    }
                }else if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive){
                    if (iOS9Later) {
                        if (!self.configuration.singleSelected) {
                            photoModel.type = self.configuration.lookLivePhoto ? YM_PhotoModelMediaType_LivePhoto : YM_PhotoModelMediaType_Photo;
                        }else {
                            photoModel.type = YM_PhotoModelMediaType_Photo;
                        }
                    }else {
                        photoModel.type = YM_PhotoModelMediaType_Photo;
                    }
                }else {
                    photoModel.type = YM_PhotoModelMediaType_Photo;
                }
                //                if (!photoModel.isICloud) {
                [photoArray addObject:photoModel];
                //                }
            }else if (asset.mediaType == PHAssetMediaTypeVideo) {
                photoModel.subType = YM_PhotoModelMediaSubType_Video;
                photoModel.type = YM_PhotoModelMediaType_Video;
                //                if (!photoModel.isICloud) {
                [videoArray addObject:photoModel];
                //                }
                // 默认视频都是可选的
                [self changeModelVideoState:photoModel];
            }
            photoModel.currentAlbumIndex = albumModel.index;
            
            BOOL canAddPhoto = YES;
            if (self.configuration.filtrationICloudAsset) {
                if (!photoModel.isICloud) {
                    [allArray addObject:photoModel];
                    [previewArray addObject:photoModel];
                }else {
                    canAddPhoto = NO;
                }
            }else {
                [allArray addObject:photoModel];
                if (photoModel.isICloud) {
                    if (self.configuration.downloadICloudAsset) {
                        [previewArray addObject:photoModel];
                    }
                }else {
                    [previewArray addObject:photoModel];
                }
            }
            
            if (self.configuration.showDateSectionHeader && canAddPhoto) {
                NSDate *photoDate = photoModel.creationDate;
                if (!currentIndexDate) {
                    dateModel = [[YM_PhotoDateModel alloc] init];
                    dateModel.date = photoDate;
                    sameDayArray = [NSMutableArray array];
                    [sameDayArray addObject:photoModel];
                    [dateArray addObject:dateModel];
                    photoModel.dateItem = sameDayArray.count - 1;
                    photoModel.dateSection = dateArray.count - 1;
                }else {
                    if ([self isSameDay:photoDate date2:currentIndexDate]) {
                        [sameDayArray addObject:photoModel];
                        photoModel.dateItem = sameDayArray.count - 1;
                        photoModel.dateSection = dateArray.count - 1;
                    }else {
                        dateModel.photoModelArray = sameDayArray;
                        sameDayArray = [NSMutableArray array];
                        dateModel = [[YM_PhotoDateModel alloc] init];
                        dateModel.date = photoDate;
                        [sameDayArray addObject:photoModel];
                        [dateArray addObject:dateModel];
                        photoModel.dateItem = sameDayArray.count - 1;
                        photoModel.dateSection = dateArray.count - 1;
                    }
                }
                if (firstSelectModel && !already) {
                    firstSelectModel.dateSection = dateArray.count - 1;
                    firstSelectModel.dateItem = sameDayArray.count - 1;
                    already = YES;
                }
                if (idx == 0) {
                    dateModel.photoModelArray = sameDayArray;
                }
                if (!dateModel.location && self.configuration.sectionHeaderShowPhotoLocation) {
                    if (photoModel.asset.location) {
                        dateModel.location = photoModel.asset.location;
                    }
                }
                currentIndexDate = photoDate;
            }else {
                photoModel.dateItem = allArray.count - 1;
                photoModel.dateSection = 0;
            }
        }];
    }else {
        NSInteger index = 0;
        for (PHAsset *asset in albumModel.result) {
            YM_PhotoModel *photoModel = [[YM_PhotoModel alloc] init];
            photoModel.asset = asset;
            photoModel.clarityScale = self.configuration.clarityScale;
            if ([[asset valueForKey:@"isCloudPlaceholder"] boolValue]) {
                if (self.iCloudUploadArray.count) {
                    NSString *property = @"asset";
                    //                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", property, asset];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"localIdentifier = %@", asset.localIdentifier];
                    NSArray *newArray = [self.iCloudUploadArray filteredArrayUsingPredicate:pred];
                    if (!newArray.count) {
                        photoModel.isICloud = YES;
                    }
                }else {
                    photoModel.isICloud = YES;
                }
            }
            if (selectList.count > 0) {
                NSString *property = @"asset";
                //                NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", property, asset];
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"localIdentifier = %@", asset.localIdentifier];
                NSArray *newArray = [selectList filteredArrayUsingPredicate:pred];
                if (newArray.count > 0) {
                    YM_PhotoModel *model = newArray.firstObject;
                    [selectList removeObject:model];
                    photoModel.selected = YES;
                    if ((model.type == YM_PhotoModelMediaType_Photo || model.type == YM_PhotoModelMediaType_PhotoGif) || (model.type == YM_PhotoModelMediaType_LivePhoto || model.type == YM_PhotoModelMediaType_CameraPhoto)) {
                        if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
                            [self.selectedCameraPhotos replaceObjectAtIndex:[self.selectedCameraPhotos indexOfObject:model] withObject:photoModel];
                        }else {
                            [self.selectedPhotos replaceObjectAtIndex:[self.selectedPhotos indexOfObject:model] withObject:photoModel];
                        }
                    }else {
                        if (model.type == YM_PhotoModelMediaType_CameraVideo) {
                            [self.selectedCameraVideos replaceObjectAtIndex:[self.selectedCameraVideos indexOfObject:model] withObject:photoModel];
                        }else {
                            [self.selectedVideos replaceObjectAtIndex:[self.selectedVideos indexOfObject:model] withObject:photoModel];
                        }
                    }
                    [self.selectedList replaceObjectAtIndex:[self.selectedList indexOfObject:model] withObject:photoModel];
                    photoModel.thumbPhoto = model.thumbPhoto;
                    photoModel.previewPhoto = model.previewPhoto;
                    photoModel.selectIndexStr = model.selectIndexStr;
                    if (!firstSelectModel) {
                        firstSelectModel = photoModel;
                    }
                }
            }
            if (asset.mediaType == PHAssetMediaTypeImage) {
                photoModel.subType = YM_PhotoModelMediaSubType_Photo;
                if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                    if (self.configuration.singleSelected) {
                        photoModel.type = YM_PhotoModelMediaType_Photo;
                    }else {
                        photoModel.type = self.configuration.lookGifPhoto ? YM_PhotoModelMediaType_PhotoGif : YM_PhotoModelMediaType_Photo;
                    }
                }else if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive){
                    if (iOS9Later) {
                        if (!self.configuration.singleSelected) {
                            photoModel.type = self.configuration.lookLivePhoto ? YM_PhotoModelMediaType_LivePhoto : YM_PhotoModelMediaType_Photo;
                        }else {
                            photoModel.type = YM_PhotoModelMediaType_Photo;
                        }
                    }else {
                        photoModel.type = YM_PhotoModelMediaType_Photo;
                    }
                }else {
                    photoModel.type = YM_PhotoModelMediaType_Photo;
                }
                //                if (!photoModel.isICloud) {
                [photoArray addObject:photoModel];
                //                }
            }else if (asset.mediaType == PHAssetMediaTypeVideo) {
                photoModel.subType = YM_PhotoModelMediaSubType_Video;
                photoModel.type = YM_PhotoModelMediaType_Video;
                //                if (!photoModel.isICloud) {
                [videoArray addObject:photoModel];
                //                }
                // 默认视频都是可选的
                [self changeModelVideoState:photoModel];
            }
            photoModel.currentAlbumIndex = albumModel.index;
            BOOL canAddPhoto = YES;
            if (self.configuration.filtrationICloudAsset) {
                if (!photoModel.isICloud) {
                    [allArray addObject:photoModel];
                    [previewArray addObject:photoModel];
                }else {
                    canAddPhoto = NO;
                }
            }else {
                [allArray addObject:photoModel];
                if (photoModel.isICloud) {
                    if (self.configuration.downloadICloudAsset) {
                        [previewArray addObject:photoModel];
                    }
                }else {
                    [previewArray addObject:photoModel];
                }
            }
            if (self.configuration.showDateSectionHeader && canAddPhoto) {
                NSDate *photoDate = photoModel.creationDate;
                //        CLLocation *photoLocation = photoModel.location;
                if (!currentIndexDate) {
                    dateModel = [[YM_PhotoDateModel alloc] init];
                    dateModel.date = photoDate;
                    sameDayArray = [NSMutableArray array];
                    [sameDayArray addObject:photoModel];
                    [dateArray addObject:dateModel];
                    photoModel.dateItem = sameDayArray.count - 1;
                    photoModel.dateSection = dateArray.count - 1;
                }else {
                    if ([self isSameDay:photoDate date2:currentIndexDate]) {
                        [sameDayArray addObject:photoModel];
                        photoModel.dateItem = sameDayArray.count - 1;
                        photoModel.dateSection = dateArray.count - 1;
                    }else {
                        dateModel.photoModelArray = sameDayArray;
                        sameDayArray = [NSMutableArray array];
                        dateModel = [[YM_PhotoDateModel alloc] init];
                        dateModel.date = photoDate;
                        [sameDayArray addObject:photoModel];
                        [dateArray addObject:dateModel];
                        photoModel.dateItem = sameDayArray.count - 1;
                        photoModel.dateSection = dateArray.count - 1;
                    }
                }
                if (firstSelectModel && !already) {
                    firstSelectModel.dateSection = dateArray.count - 1;
                    firstSelectModel.dateItem = sameDayArray.count - 1;
                    already = YES;
                }
                if (index == albumModel.result.count - 1) {
                    dateModel.photoModelArray = sameDayArray;
                }
                if (!dateModel.location && self.configuration.sectionHeaderShowPhotoLocation) {
                    if (photoModel.asset.location) {
                        dateModel.location = photoModel.asset.location;
                    }
                }
                currentIndexDate = photoDate;
            }else {
                photoModel.dateItem = allArray.count - 1;
                photoModel.dateSection = 0;
            }
            index++;
        }
    }
    NSInteger cameraIndex = self.configuration.openCamera ? 1 : 0;
    if (self.configuration.openCamera) {
        YM_PhotoModel *model = [[YM_PhotoModel alloc] init];
        model.type = YM_PhotoModelMediaType_Camera;
        if (photoArray.count == 0 && videoArray.count != 0) {
            model.thumbPhoto = [YM_PhotoTools ym_imageNamed:@"compose_photo_video@2x.png"];
            model.previewPhoto = [YM_PhotoTools ym_imageNamed:@"takePhoto@2x.png"];
        }else if (photoArray.count == 0) {
            model.thumbPhoto = [YM_PhotoTools ym_imageNamed:@"compose_photo_photograph@2x.png"];
            model.previewPhoto = [YM_PhotoTools ym_imageNamed:@"takePhoto@2x.png"];
        }else {
            model.thumbPhoto = [YM_PhotoTools ym_imageNamed:@"compose_photo_photograph@2x.png"];
            model.previewPhoto = [YM_PhotoTools ym_imageNamed:@"takePhoto@2x.png"];
        }
        if (!self.configuration.reverseDate) {
            if (self.configuration.showDateSectionHeader) {
                model.dateSection = dateArray.count;
                YM_PhotoDateModel *dateModel = dateArray.lastObject;
                model.dateItem = dateModel.photoModelArray.count;
                NSMutableArray *array = [NSMutableArray arrayWithArray:dateModel.photoModelArray];
                [array addObject:model];
                dateModel.photoModelArray = array;
            }else {
                model.dateSection = 0;
                model.dateItem = allArray.count;
                [allArray addObject:model];
            }
        }else {
            model.dateSection = 0;
            model.dateItem = 0;
            if (self.configuration.showDateSectionHeader) {
                YM_PhotoDateModel *dateModel = dateArray.firstObject;
                NSMutableArray *array = [NSMutableArray arrayWithArray:dateModel.photoModelArray];
                [array insertObject:model atIndex:0];
                dateModel.photoModelArray = array;
            }else {
                [allArray insertObject:model atIndex:0];
            }
        }
    }
    if (self.cameraList.count > 0) {
        NSInteger index = 0;
        NSInteger photoIndex = 0;
        NSInteger videoIndex = 0;
        for (YM_PhotoModel *model in self.cameraList) {
            if ([self.selectedCameraList containsObject:model]) {
                model.selected = YES;
                model.selectedIndex = [self.selectedList indexOfObject:model];
                model.selectIndexStr = [NSString stringWithFormat:@"%ld",model.selectedIndex + 1];
            }else {
                model.selected = NO;
                model.selectIndexStr = @"";
                model.selectedIndex = 0;
            }
            model.currentAlbumIndex = albumModel.index;
            if (self.configuration.reverseDate) {
                [allArray insertObject:model atIndex:cameraIndex + index];
                [previewArray insertObject:model atIndex:index];
                if (model.subType == YM_PhotoModelMediaSubType_Photo) {
                    [photoArray insertObject:model atIndex:photoIndex];
                    photoIndex++;
                }else {
                    [videoArray insertObject:model atIndex:videoIndex];
                    videoIndex++;
                }
            }else {
                NSInteger count = allArray.count;
                [allArray insertObject:model atIndex:count - cameraIndex];
                [previewArray addObject:model];
                if (model.subType == YM_PhotoModelMediaSubType_Photo) {
                    [photoArray addObject:model];
                }else {
                    [videoArray addObject:model];
                }
            }
            if (self.configuration.showDateSectionHeader) {
                if (self.configuration.reverseDate) {
                    model.dateSection = 0;
                    YM_PhotoDateModel *dateModel = dateArray.firstObject;
                    NSMutableArray *array = [NSMutableArray arrayWithArray:dateModel.photoModelArray];
                    [array insertObject:model atIndex:cameraIndex + index];
                    dateModel.photoModelArray = array;
                }else {
                    model.dateSection = dateArray.count - 1;
                    YM_PhotoDateModel *dateModel = dateArray.lastObject;
                    NSMutableArray *array = [NSMutableArray arrayWithArray:dateModel.photoModelArray];
                    NSInteger count = array.count;
                    [array insertObject:model atIndex:count - cameraIndex];
                    dateModel.photoModelArray = array;
                }
            }else {
                model.dateSection = 0;
            }
            index++;
        }
    }
    if (complete) {
        complete(allArray,previewArray,photoArray,videoArray,dateArray,firstSelectModel);
    }
}
- (void)addICloudModel:(YM_PhotoModel *)model {
    if (![self.iCloudUploadArray containsObject:model]) {
        [self.iCloudUploadArray addObject:model];
    }
}
- (NSString *)maximumOfJudgment:(YM_PhotoModel *)model {
    if ([self beforeSelectCountIsMaximum]) {
        // 已经达到最大选择数 [NSString stringWithFormat:@"最多只能选择%ld个",manager.maxNum]
        return [NSString stringWithFormat:[NSBundle ym_localizedStringForKey:@"最多只能选择%ld个"],self.configuration.maxNum];
    }
    if (self.type == YM_PhotoManagerType_All) {
        if ((model.type == YM_PhotoModelMediaType_Photo || model.type == YM_PhotoModelMediaType_PhotoGif) || (model.type == YM_PhotoModelMediaType_CameraPhoto || model.type == YM_PhotoModelMediaType_LivePhoto)) {
            if (self.configuration.videoMaxNum > 0) {
                if (!self.configuration.selectTogether) { // 是否支持图片视频同时选择
                    if (self.selectedVideos.count > 0 ) {
                        // 已经选择了视频,不能再选图片
                        return [NSBundle ym_localizedStringForKey:@"图片不能和视频同时选择"];
                    }
                }
            }
            if (self.selectedPhotos.count == self.configuration.photoMaxNum) {
                // 已经达到图片最大选择数
                
                return [NSString stringWithFormat:[NSBundle ym_localizedStringForKey:@"最多只能选择%ld张图片"],self.configuration.photoMaxNum];
            }
        }else if (model.type == YM_PhotoModelMediaType_Video || model.type == YM_PhotoModelMediaType_CameraVideo) {
            if (self.configuration.photoMaxNum > 0) {
                if (!self.configuration.selectTogether) { // 是否支持图片视频同时选择
                    if (self.selectedPhotos.count > 0 ) {
                        // 已经选择了图片,不能再选视频
                        return [NSBundle ym_localizedStringForKey:@"视频不能和图片同时选择"];
                    }
                }
            }
            if ([self beforeSelectVideoCountIsMaximum]) {
                // 已经达到视频最大选择数
                
                return [NSString stringWithFormat:[NSBundle ym_localizedStringForKey:@"最多只能选择%ld个视频"],self.configuration.videoMaxNum];
            }
        }
    }else if (self.type == YM_PhotoManagerType_Photo) {
        if ([self beforeSelectPhotoCountIsMaximum]) {
            // 已经达到图片最大选择数
            return [NSString stringWithFormat:[NSBundle ym_localizedStringForKey:@"最多只能选择%ld张图片"],self.configuration.photoMaxNum];
        }
    }else if (self.type == YM_PhotoManagerType_Video) {
        if ([self beforeSelectVideoCountIsMaximum]) {
            // 已经达到视频最大选择数
            return [NSString stringWithFormat:[NSBundle ym_localizedStringForKey:@"最多只能选择%ld个视频"],self.configuration.videoMaxNum];
        }
    }
    if (model.type == YM_PhotoModelMediaType_Video) {
        if (model.asset.duration < 3) {
            return [NSBundle ym_localizedStringForKey:@"视频少于3秒,无法选择"];
        }else if (model.asset.duration >= self.configuration.videoMaxDuration + 1) {
            return [NSBundle ym_localizedStringForKey:@"视频过大,无法选择"];
        }
    }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
        if (model.videoDuration < 3) {
            return [NSBundle ym_localizedStringForKey:@"视频少于3秒,无法选择"];
        }else if (model.videoDuration >= self.configuration.videoMaxDuration + 1) {
            return [NSBundle ym_localizedStringForKey:@"视频过大,无法选择"];
        }
    }
    return nil;
}
#pragma mark - < 改变模型的视频状态 >
- (void)changeModelVideoState:(YM_PhotoModel *)model {
    if (self.configuration.specialModeNeedHideVideoSelectBtn) {
        if (self.videoSelectedType == YM_PhotoManagerVideoSelectedType_Single && model.subType == YM_PhotoModelMediaSubType_Video) {
            model.needHideSelectBtn = YES;
        }
    }
    if (model.subType == YM_PhotoModelMediaSubType_Video) {
        if (model.type == YM_PhotoModelMediaType_Video) {
            if (model.asset.duration < 3) {
                model.videoState = YM_PhotoModelVideoStateUndersize;
            }else if (model.asset.duration >= self.configuration.videoMaxDuration + 1) {
                model.videoState = YM_PhotoModelVideoStateOversize;
            }
        }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
            if (model.videoDuration < 3) {
                model.videoState = YM_PhotoModelVideoStateUndersize;
            }else if (model.videoDuration >= self.configuration.videoMaxDuration + 1) {
                model.videoState = YM_PhotoModelVideoStateOversize;
            }
        }
    }
}
- (YM_PhotoManagerVideoSelectedType)videoSelectedType {
    if (self.type == YM_PhotoManagerType_All && self.configuration.videoMaxNum == 1 && !self.configuration.selectTogether) {
        return YM_PhotoManagerVideoSelectedType_Single;
    }
    return YM_PhotoManagerVideoSelectedType_Normal;
}
- (BOOL)videoCanSelected {
    if (self.videoSelectedType == YM_PhotoManagerVideoSelectedType_Single) {
        if (self.selectedPhotos.count) {
            return NO;
        }
    }
    return YES;
}
#pragma mark - < 关于选择完成之前的一些方法 >
- (NSInteger)selectedCount {
    return self.selectedList.count;
}
- (NSInteger)selectedPhotoCount {
    return self.selectedPhotos.count;
}
- (NSInteger)selectedVideoCount {
    return self.selectedVideos.count;
}
- (NSArray *)selectedArray {
    return self.selectedList;
}
- (NSArray *)selectedPhotoArray {
    return self.selectedPhotos;
}
- (NSArray *)selectedVideoArray {
    return self.selectedVideos;
}
- (BOOL)original {
    return self.isOriginal;
}
- (void)setOriginal:(BOOL)original {
    self.isOriginal = original;
}
- (BOOL)beforeSelectCountIsMaximum {
    if (self.selectedList.count >= self.configuration.maxNum) {
        return YES;
    }
    return NO;
}
- (BOOL)beforeSelectPhotoCountIsMaximum {
    if (self.selectedPhotos.count >= self.configuration.photoMaxNum) {
        return YES;
    }
    return NO;
}
- (BOOL)beforeSelectVideoCountIsMaximum {
    if (self.selectedVideos.count >= self.configuration.videoMaxNum) {
        return YES;
    }
    return NO;
}
- (void)beforeSelectedListdeletePhotoModel:(YM_PhotoModel *)model {
    model.selected = NO;
    model.selectIndexStr = @"";
    if (model.subType == YM_PhotoModelMediaSubType_Photo) {
        [self.selectedPhotos removeObject:model];
        if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
            // 为相机拍的照片时
            [self.selectedCameraPhotos removeObject:model];
            [self.selectedCameraList removeObject:model];
        }else {
            model.thumbPhoto = nil;
            model.previewPhoto = nil;
        }
    }else if (model.subType == YM_PhotoModelMediaSubType_Video) {
        [self.selectedVideos removeObject:model];
        if (model.type == YM_PhotoModelMediaType_CameraVideo) {
            // 为相机录的视频时
            [self.selectedCameraVideos removeObject:model];
            [self.selectedCameraList removeObject:model];
        }else {
            model.thumbPhoto = nil;
            model.previewPhoto = nil;
        }
    }
    [self.selectedList removeObject:model];
}
- (void)beforeSelectedListAddPhotoModel:(YM_PhotoModel *)model {
    if (model.subType == YM_PhotoModelMediaSubType_Photo) {
        [self.selectedPhotos addObject:model];
        if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
            // 为相机拍的照片时
            [self.selectedCameraPhotos addObject:model];
            [self.selectedCameraList addObject:model];
        }
    }else if (model.subType == YM_PhotoModelMediaSubType_Video) {
        [self.selectedVideos addObject:model];
        if (model.type == YM_PhotoModelMediaType_CameraVideo) {
            // 为相机录的视频时
            [self.selectedCameraVideos addObject:model];
            [self.selectedCameraList addObject:model];
        }
    }
    [self.selectedList addObject:model];
    model.selected = YES;
    model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.selectedList indexOfObject:model] + 1];
}
- (void)beforeSelectedListAddEditPhotoModel:(YM_PhotoModel *)model {
    [self beforeSelectedListAddPhotoModel:model];
    // 默认视频都是可选的
    [self changeModelVideoState:model];
    
    if (model.subType == YM_PhotoModelMediaSubType_Photo) {
        if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
            [self.cameraPhotos addObject:model];
            [self.cameraList addObject:model];
        }
    }else {
        if (model.type == YM_PhotoModelMediaType_CameraVideo) {
            [self.cameraVideos addObject:model];
            [self.cameraList addObject:model];
        }
    }
}
- (void)beforeListAddCameraTakePicturesModel:(YM_PhotoModel *)model {
    // 默认视频都是可选的
    [self changeModelVideoState:model];
    
    model.dateCellIsVisible = YES;
    if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
        [self.cameraPhotos addObject:model];
        if (![self beforeSelectPhotoCountIsMaximum]) {
            if (!self.configuration.selectTogether) {
                if (self.selectedList.count > 0) {
                    YM_PhotoModel *phMd = self.selectedList.firstObject;
                    if (phMd.subType == YM_PhotoModelMediaSubType_Photo) {
                        [self.selectedCameraPhotos insertObject:model atIndex:0];
                        [self.selectedPhotos addObject:model];
                        [self.selectedList addObject:model];
                        [self.selectedCameraList addObject:model];
                        model.selected = YES;
                        model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.selectedList indexOfObject:model] + 1];
                    }
                }else {
                    [self.selectedCameraPhotos insertObject:model atIndex:0];
                    [self.selectedPhotos addObject:model];
                    [self.selectedList addObject:model];
                    [self.selectedCameraList addObject:model];
                    model.selected = YES;
                    model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.selectedList indexOfObject:model] + 1];
                }
            }else {
                [self.selectedCameraPhotos insertObject:model atIndex:0];
                [self.selectedPhotos addObject:model];
                [self.selectedList addObject:model];
                [self.selectedCameraList addObject:model];
                model.selected = YES;
                model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.selectedList indexOfObject:model] + 1];
            }
        }
    }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
        [self.cameraVideos addObject:model];
        // 当选中视频个数没有达到最大个数时就添加到选中数组中
        if (![self beforeSelectVideoCountIsMaximum] && model.videoDuration <= self.configuration.videoMaxDuration) {
            if (!self.configuration.selectTogether) {
                if (self.selectedList.count > 0) {
                    YM_PhotoModel *phMd = self.selectedList.firstObject;
                    if (phMd.subType == YM_PhotoModelMediaSubType_Video) {
                        [self.selectedCameraVideos insertObject:model atIndex:0];
                        [self.selectedVideos addObject:model];
                        [self.selectedList addObject:model];
                        [self.selectedCameraList addObject:model];
                        model.selected = YES;
                        model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.selectedList indexOfObject:model] + 1];
                    }
                }else {
                    if (!model.needHideSelectBtn) {
                        [self.selectedCameraVideos insertObject:model atIndex:0];
                        [self.selectedVideos addObject:model];
                        [self.selectedList addObject:model];
                        [self.selectedCameraList addObject:model];
                        model.selected = YES;
                        model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.selectedList indexOfObject:model] + 1];
                    }
                }
            }else {
                [self.selectedCameraVideos insertObject:model atIndex:0];
                [self.selectedVideos addObject:model];
                [self.selectedList addObject:model];
                [self.selectedCameraList addObject:model];
                model.selected = YES;
                model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.selectedList indexOfObject:model] + 1];
            }
        }
    }
    //    NSInteger cameraIndex = self.configuration.openCamera ? 1 : 0;
    if (self.configuration.reverseDate) {
        [self.cameraList insertObject:model atIndex:0];
    }else {
        [self.cameraList addObject:model];
    }
}
#pragma mark - < 关于选择完成之后的一些方法 >
- (BOOL)afterSelectCountIsMaximum {
    if (self.endSelectedList.count >= self.configuration.maxNum) {
        return YES;
    }
    return NO;
}

- (BOOL)afterSelectPhotoCountIsMaximum {
    if (self.endSelectedPhotos.count >= self.configuration.photoMaxNum) {
        return YES;
    }
    return NO;
}

- (BOOL)afterSelectVideoCountIsMaximum {
    if (self.endSelectedVideos.count >= self.configuration.videoMaxNum) {
        return YES;
    }
    return NO;
}
- (NSInteger)afterSelectedCount {
    return self.endSelectedList.count;
}
- (NSArray *)afterSelectedArray {
    return self.endSelectedList;
}
- (NSArray *)afterSelectedPhotoArray {
    return self.endSelectedPhotos;
}
- (NSArray *)afterSelectedVideoArray {
    return self.endSelectedVideos;
}
- (void)setAfterSelectedPhotoArray:(NSArray *)array {
    self.endSelectedPhotos = [NSMutableArray arrayWithArray:array];
}
- (void)setAfterSelectedVideoArray:(NSArray *)array {
    self.endSelectedVideos = [NSMutableArray arrayWithArray:array];
}
- (BOOL)afterOriginal {
    return self.endIsOriginal;
}
- (void)afterSelectedArraySwapPlacesWithFromModel:(YM_PhotoModel *)fromModel fromIndex:(NSInteger)fromIndex toModel:(YM_PhotoModel *)toModel toIndex:(NSInteger)toIndex {
    [self.endSelectedList removeObject:toModel];
    [self.endSelectedList insertObject:toModel atIndex:toIndex];
    [self.endSelectedList removeObject:fromModel];
    [self.endSelectedList insertObject:fromModel atIndex:fromIndex];
}
- (void)afterSelectedArrayReplaceModelAtModel:(YM_PhotoModel *)atModel withModel:(YM_PhotoModel *)model {
    atModel.selected = NO;
    model.selected = YES;
    
    // 默认视频都是可选的
    [self changeModelVideoState:model];
    
    [self.endSelectedList replaceObjectAtIndex:[self.endSelectedList indexOfObject:atModel] withObject:model];
    if (atModel.type == YM_PhotoModelMediaType_CameraPhoto) {
        [self.endSelectedCameraPhotos removeObject:atModel];
        [self.endSelectedCameraList removeObject:atModel];
        [self.endCameraList removeObject:atModel];
        [self.endCameraPhotos removeObject:atModel];
    }else if (atModel.type == YM_PhotoModelMediaType_CameraVideo) {
        [self.endSelectedCameraVideos removeObject:atModel];
        [self.endSelectedCameraList removeObject:atModel];
        [self.endCameraList removeObject:atModel];
        [self.endCameraVideos removeObject:atModel];
    }
}
- (void)afterSelectedListAddEditPhotoModel:(YM_PhotoModel *)model {
    // 默认视频都是可选的
    [self changeModelVideoState:model];
    
    if (model.subType == YM_PhotoModelMediaSubType_Photo) {
        if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
            [self.endCameraPhotos addObject:model];
            [self.endCameraList addObject:model];
            [self.endSelectedCameraList addObject:model];
            [self.endSelectedCameraPhotos addObject:model];
        }
    }else {
        if (model.type == YM_PhotoModelMediaType_CameraVideo) {
            [self.endCameraVideos addObject:model];
            [self.endCameraList addObject:model];
            [self.endSelectedCameraList addObject:model];
            [self.endSelectedCameraVideos addObject:model];
        }
    }
}
- (void)afterListAddCameraTakePicturesModel:(YM_PhotoModel *)model {
    // 默认视频都是可选的
    [self changeModelVideoState:model];
    
    if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
        [self.endCameraPhotos addObject:model];
        // 当选择图片个数没有达到最大个数时就添加到选中数组中
        if (![self afterSelectPhotoCountIsMaximum]) {
            if (!self.configuration.selectTogether) {
                if (self.endSelectedList.count > 0) {
                    YM_PhotoModel *phMd = self.endSelectedList.firstObject;
                    if ((phMd.type == YM_PhotoModelMediaType_Photo || phMd.type == YM_PhotoModelMediaType_LivePhoto) || (phMd.type == YM_PhotoModelMediaType_PhotoGif || phMd.type == YM_PhotoModelMediaType_CameraPhoto)) {
                        [self.endSelectedCameraPhotos insertObject:model atIndex:0];
                        [self.endSelectedPhotos addObject:model];
                        [self.endSelectedList addObject:model];
                        [self.endSelectedCameraList addObject:model];
                        model.selected = YES;
                        model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.endSelectedList indexOfObject:model] + 1];
                    }
                }else {
                    [self.endSelectedCameraPhotos insertObject:model atIndex:0];
                    [self.endSelectedPhotos addObject:model];
                    [self.endSelectedList addObject:model];
                    [self.endSelectedCameraList addObject:model];
                    model.selected = YES;
                    model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.endSelectedList indexOfObject:model] + 1];
                }
            }else {
                [self.endSelectedCameraPhotos insertObject:model atIndex:0];
                [self.endSelectedPhotos addObject:model];
                [self.endSelectedList addObject:model];
                [self.endSelectedCameraList addObject:model];
                model.selected = YES;
                model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.endSelectedList indexOfObject:model] + 1];
            }
        }
    }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
        [self.endCameraVideos addObject:model];
        // 当选中视频个数没有达到最大个数时就添加到选中数组中
        if (![self afterSelectVideoCountIsMaximum] && model.videoDuration <= self.configuration.videoMaxDuration) {
            if (!self.configuration.selectTogether) {
                if (self.endSelectedList.count > 0) {
                    YM_PhotoModel *phMd = self.endSelectedList.firstObject;
                    if (phMd.type == YM_PhotoModelMediaType_Video || phMd.type == YM_PhotoModelMediaType_CameraVideo) {
                        [self.endSelectedCameraVideos insertObject:model atIndex:0];
                        [self.endSelectedVideos addObject:model];
                        [self.endSelectedList addObject:model];
                        [self.endSelectedCameraList addObject:model];
                        model.selected = YES;
                        model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.endSelectedList indexOfObject:model] + 1];
                    }
                }else {
                    [self.endSelectedCameraVideos insertObject:model atIndex:0];
                    [self.endSelectedVideos addObject:model];
                    [self.endSelectedList addObject:model];
                    [self.endSelectedCameraList addObject:model];
                    model.selected = YES;
                    model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.endSelectedList indexOfObject:model] + 1];
                }
            }else {
                [self.endSelectedCameraVideos insertObject:model atIndex:0];
                [self.endSelectedVideos addObject:model];
                [self.endSelectedList addObject:model];
                [self.endSelectedCameraList addObject:model];
                model.selected = YES;
                model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.endSelectedList indexOfObject:model] + 1];
            }
        }
    }
    [self.endCameraList addObject:model];
}
- (void)afterSelectedListdeletePhotoModel:(YM_PhotoModel *)model {
    if (model.subType == YM_PhotoModelMediaSubType_Photo) {
        if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
            if (self.configuration.deleteTemporaryPhoto) {
                [self.endCameraPhotos removeObject:model];
                [self.endCameraList removeObject:model];
            }
            [self.endSelectedCameraPhotos removeObject:model];
            [self.endSelectedCameraList removeObject:model];
        }
        [self.endSelectedPhotos removeObject:model];
    }else if (model.subType == YM_PhotoModelMediaSubType_Video) {
        if (model.type == YM_PhotoModelMediaType_CameraVideo) {
            if (self.configuration.deleteTemporaryPhoto) {
                [self.endCameraVideos removeObject:model];
                [self.endCameraList removeObject:model];
            }
            [self.endSelectedCameraVideos removeObject:model];
            [self.endSelectedCameraList removeObject:model];
        }
        [self.endSelectedVideos removeObject:model];
    }
    [self.endSelectedList removeObject:model];
    
    int i = 0;
    for (YM_PhotoModel *model in self.selectedList) {
        model.selectIndexStr = [NSString stringWithFormat:@"%d",i + 1];
        i++;
    }
}
- (void)afterSelectedListAddPhotoModel:(YM_PhotoModel *)model {
    
}
#pragma mark - < others >
- (void)selectedListTransformBefore {
    if (self.type == YM_PhotoManagerType_Photo) {
        self.configuration.maxNum = self.configuration.photoMaxNum;
        if (self.endCameraVideos.count > 0) {
            [self.endCameraList removeObjectsInArray:self.endCameraVideos];
            [self.endCameraVideos removeAllObjects];
        }
    }else if (self.type == YM_PhotoManagerType_Video) {
        self.configuration.maxNum = self.configuration.videoMaxNum;
        if (self.endCameraPhotos.count > 0) {
            [self.endCameraList removeObjectsInArray:self.endCameraPhotos];
            [self.endCameraPhotos removeAllObjects];
        }
    }else {
        if (self.configuration.videoMaxNum + self.configuration.photoMaxNum != self.configuration.maxNum) {
            self.configuration.maxNum = self.configuration.videoMaxNum + self.configuration.photoMaxNum;
        }
    }
    // 上次选择的所有记录
    self.selectedList = [NSMutableArray arrayWithArray:self.endSelectedList];
    self.selectedPhotos = [NSMutableArray arrayWithArray:self.endSelectedPhotos];
    self.selectedVideos = [NSMutableArray arrayWithArray:self.endSelectedVideos];
    self.cameraList = [NSMutableArray arrayWithArray:self.endCameraList];
    self.cameraPhotos = [NSMutableArray arrayWithArray:self.endCameraPhotos];
    self.cameraVideos = [NSMutableArray arrayWithArray:self.endCameraVideos];
    self.selectedCameraList = [NSMutableArray arrayWithArray:self.endSelectedCameraList];
    self.selectedCameraPhotos = [NSMutableArray arrayWithArray:self.endSelectedCameraPhotos];
    self.selectedCameraVideos = [NSMutableArray arrayWithArray:self.endSelectedCameraVideos];
    self.isOriginal = self.endIsOriginal;
    self.photosTotalBtyes = self.endPhotosTotalBtyes;
}
- (void)selectedListTransformAfter {
    // 如果通过相机拍的数组为空 则清空所有关于相机的数组
    if (self.configuration.deleteTemporaryPhoto) {
        if (self.selectedCameraList.count == 0) {
            [self.cameraList removeAllObjects];
            [self.cameraVideos removeAllObjects];
            [self.cameraPhotos removeAllObjects];
        }
    }
    if (!self.configuration.singleSelected) {
        // 记录这次操作的数据
        self.endSelectedList = [NSMutableArray arrayWithArray:self.selectedList];
        self.endSelectedPhotos = [NSMutableArray arrayWithArray:self.selectedPhotos];
        self.endSelectedVideos = [NSMutableArray arrayWithArray:self.selectedVideos];
        self.endCameraList = [NSMutableArray arrayWithArray:self.cameraList];
        self.endCameraPhotos = [NSMutableArray arrayWithArray:self.cameraPhotos];
        self.endCameraVideos = [NSMutableArray arrayWithArray:self.cameraVideos];
        self.endSelectedCameraList = [NSMutableArray arrayWithArray:self.selectedCameraList];
        self.endSelectedCameraPhotos = [NSMutableArray arrayWithArray:self.selectedCameraPhotos];
        self.endSelectedCameraVideos = [NSMutableArray arrayWithArray:self.selectedCameraVideos];
        self.endIsOriginal = self.isOriginal;
        self.endPhotosTotalBtyes = self.photosTotalBtyes;
    }
}
- (void)cancelBeforeSelectedList {
    [self.selectedList removeAllObjects];
    [self.selectedPhotos removeAllObjects];
    [self.selectedVideos removeAllObjects];
    self.isOriginal = NO;
    self.photosTotalBtyes = nil;
    [self.selectedCameraList removeAllObjects];
    [self.selectedCameraVideos removeAllObjects];
    [self.selectedCameraPhotos removeAllObjects];
    [self.cameraPhotos removeAllObjects];
    [self.cameraList removeAllObjects];
    [self.cameraVideos removeAllObjects];
}
- (void)clearSelectedList {
    [self.endSelectedList removeAllObjects];
    [self.endCameraPhotos removeAllObjects];
    [self.endSelectedCameraPhotos removeAllObjects];
    [self.endCameraList removeAllObjects];
    [self.endSelectedCameraList removeAllObjects];
    [self.endSelectedPhotos removeAllObjects];
    [self.endCameraVideos removeAllObjects];
    [self.endSelectedCameraVideos removeAllObjects];
    [self.endCameraList removeAllObjects];
    [self.endSelectedCameraList removeAllObjects];
    [self.endSelectedVideos removeAllObjects];
    [self.endSelectedPhotos removeAllObjects];
    [self.endSelectedVideos removeAllObjects];
    self.endIsOriginal = NO;
    self.endPhotosTotalBtyes = nil;
    
    [self.selectedList removeAllObjects];
    [self.cameraPhotos removeAllObjects];
    [self.selectedCameraPhotos removeAllObjects];
    [self.cameraList removeAllObjects];
    [self.selectedCameraList removeAllObjects];
    [self.selectedPhotos removeAllObjects];
    [self.cameraVideos removeAllObjects];
    [self.selectedCameraVideos removeAllObjects];
    [self.cameraList removeAllObjects];
    [self.selectedCameraList removeAllObjects];
    [self.selectedVideos removeAllObjects];
    [self.selectedPhotos removeAllObjects];
    [self.selectedVideos removeAllObjects];
    self.isOriginal = NO;
    self.photosTotalBtyes = nil;
    
    [self.albums removeAllObjects];
    [self.iCloudUploadArray removeAllObjects];
}

#pragma mark - < PHPhotoLibraryChangeObserver >
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     NSMutableArray *array = [NSMutableArray arrayWithArray:self.albums];
     for (YM_AlbumModel *albumModel in array) {
     PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:albumModel.result];
     if ([collectionChanges hasIncrementalChanges]) {
     if (self.configuration.saveSystemAblum) {
     //                if (!self.cameraList.count) {
     //                    self.albums = nil;
     //                }
     }
     return;
     }
     }
     */
}
- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)changeAfterCameraArray:(NSArray *)array {
    self.endCameraList = array.mutableCopy;
}
- (void)changeAfterCameraPhotoArray:(NSArray *)array {
    self.endCameraPhotos = array.mutableCopy;
}
- (void)changeAfterCameraVideoArray:(NSArray *)array {
    self.endCameraVideos = array.mutableCopy;
}
- (void)changeAfterSelectedCameraArray:(NSArray *)array {
    self.endSelectedCameraList = array.mutableCopy;
}
- (void)changeAfterSelectedCameraPhotoArray:(NSArray *)array {
    self.endSelectedCameraPhotos = array.mutableCopy;
}
- (void)changeAfterSelectedCameraVideoArray:(NSArray *)array {
    self.endSelectedCameraVideos = array.mutableCopy;
}
- (void)changeAfterSelectedArray:(NSArray *)array {
    self.endSelectedList = array.mutableCopy;
}
- (void)changeAfterSelectedPhotoArray:(NSArray *)array {
    self.endSelectedPhotos = array.mutableCopy;
}
- (void)changeAfterSelectedVideoArray:(NSArray *)array {
    self.endSelectedVideos = array.mutableCopy;
}
- (void)changeICloudUploadArray:(NSArray *)array {
    self.iCloudUploadArray = array.mutableCopy;
}
- (NSArray *)afterCameraArray {
    return self.endCameraList;
}
- (NSArray *)afterCameraPhotoArray {
    return self.endCameraPhotos;
}
- (NSArray *)afterCameraVideoArray {
    return self.endCameraVideos;
}
- (NSArray *)afterSelectedCameraArray {
    return self.endSelectedCameraList;
}
- (NSArray *)afterSelectedCameraPhotoArray {
    return self.endSelectedCameraPhotos;
}
- (NSArray *)afterSelectedCameraVideoArray {
    return self.endSelectedCameraVideos;
}
- (NSArray *)afterICloudUploadArray {
    return self.iCloudUploadArray;
}
- (NSString *)version {
    return @"2.2.0";
}


@end
