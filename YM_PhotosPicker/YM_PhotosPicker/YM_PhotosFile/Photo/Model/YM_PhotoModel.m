//
//  YM_PhotoModel.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/3.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PhotoModel.h"
#import "YM_PhotoTools.h"
#import "YM_PhotoManager.h"
#import "UIImage+YM_Extension.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation YM_PhotoModel

- (NSURL *)fileURL {
    if (self.type == YM_PhotoModelMediaType_CameraVideo && !_fileURL) {
        _fileURL = self.videoURL;
    }
    if (self.type != YM_PhotoModelMediaType_CameraPhoto) {
        if (self.asset && !_fileURL) {
            _fileURL = [self.asset valueForKey:@"mainFileURL"];
        }
    }
    return _fileURL;
}

- (NSDate *)creationDate {
    if (self.type == YM_PhotoModelMediaType_CameraPhoto || self.type == YM_PhotoModelMediaType_CameraVideo) {
        return [NSDate date];
    }
    if (!_creationDate) {
        _creationDate = [self.asset valueForKey:@"creationDate"];
    }
    return _creationDate;
}

- (NSDate *)modificationDate {
    if (self.type == YM_PhotoModelMediaType_CameraPhoto || self.type == YM_PhotoModelMediaType_CameraVideo) {
        if (!_modificationDate) {
            _modificationDate = [NSDate date];
        }
    }
    if (!_modificationDate) {
        _modificationDate = [self.asset valueForKey:@"modificationDate"];
    }
    return _modificationDate;
}

- (NSData *)locationData {
    if (!_locationData) {
        _locationData = [self.asset valueForKey:@"locationData"];
    }
    return _locationData;
}

- (CLLocation *)location {
    if (!_location) {
        _location = [self.asset valueForKey:@"location"];
    }
    return _location;
}

- (NSString *)localIdentifier {
    if (self.asset) {
        return self.asset.localIdentifier;
    }
    return _localIdentifier;
}

+ (instancetype)photoModelWithPHAsset:(PHAsset *)asset {
    return [[self alloc] initWithPHAsset:asset];
}

+ (instancetype)photoModelWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

+ (instancetype)photoModelWithImageURL:(NSURL *)imageURL {
    return [[self alloc] initWithImageURL:imageURL];
}

+ (instancetype)photoModelWithVideoURL:(NSURL *)videoURL videoTime:(NSTimeInterval)videoTime {
    return [[self alloc] initWithVideoURL:videoURL videoTime:videoTime];
}

+ (instancetype)photoModelWithVideoURL:(NSURL *)videoURL {
    return [[self alloc] initWithVideoURL:videoURL];
}

- (instancetype)initWithImageURL:(NSURL *)imageURL {
    if (self = [super init]) {
        self.type = YM_PhotoModelMediaType_CameraPhoto;
        self.subType = YM_PhotoModelMediaSubType_Photo;
        self.thumbPhoto = [YM_PhotoTools ym_imageNamed:@"qz_photolist_picture_fail@2x.png"];
        self.previewPhoto = self.thumbPhoto;
        self.imageSize = self.thumbPhoto.size;
        self.networkPhotoUrl = imageURL;
    }
    return self;
}

- (instancetype)initWithPHAsset:(PHAsset *)asset{
    if (self = [super init]) {
        self.asset = asset;
        self.type = YM_PhotoModelMediaType_Photo;
        self.subType = YM_PhotoModelMediaSubType_Photo;
    }
    return self;
}

- (void)setPhotoManager:(YM_PhotoManager *)photoManager {
    _photoManager = photoManager;
    if (self.asset.mediaType == PHAssetMediaTypeImage) {
        self.subType = YM_PhotoModelMediaSubType_Photo;
        if ([[self.asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            if (photoManager.configuration.singleSelected) {
                self.type = YM_PhotoModelMediaType_Photo;
            }else {
                self.type = photoManager.configuration.lookGifPhoto ? YM_PhotoModelMediaType_PhotoGif : YM_PhotoModelMediaType_Photo;
            }
        }else if (self.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive){
            if (iOS9Later) {
                if (!photoManager.configuration.singleSelected) {
                    self.type = photoManager.configuration.lookLivePhoto ? YM_PhotoModelMediaType_LivePhoto : YM_PhotoModelMediaType_Photo;
                }else {
                    self.type = YM_PhotoModelMediaType_Photo;
                }
            }else {
                self.type = YM_PhotoModelMediaType_Photo;
            }
        }else {
            self.type = YM_PhotoModelMediaType_Photo;
        }
    }else if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        self.type = YM_PhotoModelMediaType_Video;
        self.subType = YM_PhotoModelMediaSubType_Video;
    }
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL {
    if (self = [super init]) {
        self.type = YM_PhotoModelMediaType_CameraVideo;
        self.subType = YM_PhotoModelMediaSubType_Video;
        self.videoURL = videoURL;
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL] ;
        player.shouldAutoplay = NO;
        UIImage  *image = [player thumbnailImageAtTime:0.1 timeOption:MPMovieTimeOptionNearestKeyFrame];
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
        float second = 0;
        second = urlAsset.duration.value/urlAsset.duration.timescale;
        
        NSString *time = [YM_PhotoTools getNewTimeFromDurationSecond:second];
        self.videoDuration = second;
        self.videoURL = videoURL;
        self.videoTime = time;
        self.thumbPhoto = image;
        self.previewPhoto = image;
        self.imageSize = self.thumbPhoto.size;
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL videoTime:(NSTimeInterval)videoTime {
    if (self = [super init]) {
        self.type = YM_PhotoModelMediaType_CameraVideo;
        self.subType = YM_PhotoModelMediaSubType_Video;
        self.videoURL = videoURL;
        if (videoTime <= 0) {
            videoTime = 1;
        }
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL] ;
        player.shouldAutoplay = NO;
        UIImage  *image = [player thumbnailImageAtTime:0.1 timeOption:MPMovieTimeOptionNearestKeyFrame];
        NSString *time = [YM_PhotoTools getNewTimeFromDurationSecond:videoTime];
        self.videoDuration = videoTime;
        self.videoURL = videoURL;
        self.videoTime = time;
        self.thumbPhoto = image;
        self.previewPhoto = image;
        self.imageSize = self.thumbPhoto.size;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.type = YM_PhotoModelMediaType_CameraPhoto;
        self.subType = YM_PhotoModelMediaSubType_Photo;
        if (image.imageOrientation != UIImageOrientationUp) {
            image = [image normalizedImage];
        }
        self.thumbPhoto = image;
        self.previewPhoto = image;
        self.imageSize = image.size;
    }
    return self;
}

- (CGSize)imageSize
{
    if (_imageSize.width == 0 || _imageSize.height == 0) {
        if (self.asset) {
            if (self.asset.pixelWidth == 0 || self.asset.pixelHeight == 0) {
                _imageSize = CGSizeMake(200, 200);
            }else {
                _imageSize = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
            }
        }else {
            _imageSize = self.thumbPhoto.size;
        }
    }
    return _imageSize;
}
- (NSString *)videoTime {
    if (!_videoTime) {
        NSString *timeLength = [NSString stringWithFormat:@"%0.0f",self.asset.duration];
        _videoTime = [YM_PhotoTools getNewTimeFromDurationSecond:timeLength.integerValue];
    }
    return _videoTime;
}
- (CGSize)endImageSize
{
    if (_endImageSize.width == 0 || _endImageSize.height == 0) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height - kNavigationBarHeight;
        CGFloat imgWidth = self.imageSize.width;
        CGFloat imgHeight = self.imageSize.height;
        CGFloat w;
        CGFloat h;
        imgHeight = width / imgWidth * imgHeight;
        if (imgHeight > height) {
            w = height / self.imageSize.height * imgWidth;
            h = height;
        }else {
            w = width;
            h = imgHeight;
        }
        _endImageSize = CGSizeMake(w, h);
    }
    return _endImageSize;
}
- (CGSize)previewViewSize {
    if (_previewViewSize.width == 0 || _previewViewSize.height == 0) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGFloat imgWidth = self.imageSize.width;
        CGFloat imgHeight = self.imageSize.height;
        CGFloat w;
        CGFloat h;
        
        if (imgWidth > width) {
            h = width / self.imageSize.width * imgHeight;
            w = width;
        }else {
            w = width;
            h = width / imgWidth * imgHeight;
        }
        if (h > height + 20) {
            h = height;
        }
        _previewViewSize = CGSizeMake(w, h);
    }
    return _previewViewSize;
}
- (CGSize)endDateImageSize {
    if (_endDateImageSize.width == 0 || _endDateImageSize.height == 0) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height - kTopMargin - kBottomMargin;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
            if (kDevice_Is_iPhoneX) {
                height = [UIScreen mainScreen].bounds.size.height - kTopMargin - 21;
            }
        }
        CGFloat imgWidth = self.imageSize.width;
        CGFloat imgHeight = self.imageSize.height;
        CGFloat w;
        CGFloat h;
        imgHeight = width / imgWidth * imgHeight;
        if (imgHeight > height) {
            w = height / self.imageSize.height * imgWidth;
            h = height;
        }else {
            w = width;
            h = imgHeight;
        }
        _endDateImageSize = CGSizeMake(w, h);
    }
    return _endDateImageSize;
}
- (CGSize)requestSize {
    if (_requestSize.width == 0 || _requestSize.height == 0) {
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 1 * self.rowCount - 1 ) / self.rowCount;
        CGSize size = CGSizeMake(width * self.clarityScale, width * self.clarityScale);
        _requestSize = size;
    }
    return _requestSize;
}
- (CGSize)dateBottomImageSize {
    if (_dateBottomImageSize.width == 0 || _dateBottomImageSize.height == 0) {
        CGFloat width = 0;
        CGFloat height = 50;
        CGFloat imgWidth = self.imageSize.width;
        CGFloat imgHeight = self.imageSize.height;
        if (imgHeight > height) {
            width = imgWidth * (height / imgHeight);
        }else {
            width = imgWidth * (imgHeight / height);
        }
        if (width < 50 / 16 * 9) {
            width = 50 / 16 * 9;
        }
        _dateBottomImageSize = CGSizeMake(width, height);
    }
    return _dateBottomImageSize;
}
- (NSString *)barTitle {
    if (!_barTitle) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([self.creationDate isToday]) {
            _barTitle = [NSBundle ym_localizedStringForKey:@"今天"];
        }else if ([self.creationDate isYesterday]) {
            _barTitle = [NSBundle ym_localizedStringForKey:@"昨天"];
        }else if ([self.creationDate isSameWeek]) {
            _barTitle = [self.creationDate getNowWeekday];
        }else if ([self.creationDate isThisYear]) {
            if ([language hasPrefix:@"en"]) {
                // 英文
                _barTitle = [NSString stringWithFormat:@"%@ %@",[self.creationDate dateStringWithFormat:@"MMM dd"],[self.creationDate getNowWeekday]];
            } else if ([language hasPrefix:@"zh"]) {
                // 中文
                _barTitle = [NSString stringWithFormat:@"%@ %@",[self.creationDate dateStringWithFormat:@"MM月dd日"],[self.creationDate getNowWeekday]];
                
            }else if ([language hasPrefix:@"ko"]) {
                // 韩语
                _barTitle = [NSString stringWithFormat:@"%@ %@",[self.creationDate dateStringWithFormat:@"MM월dd일"],[self.creationDate getNowWeekday]];
            }else if ([language hasPrefix:@"ja"]) {
                // 日语
                _barTitle = [NSString stringWithFormat:@"%@ %@",[self.creationDate dateStringWithFormat:@"MM月dd日"],[self.creationDate getNowWeekday]];
            }else {
                // 英文
                _barTitle = [NSString stringWithFormat:@"%@ %@",[self.creationDate dateStringWithFormat:@"MMM dd"],[self.creationDate getNowWeekday]];
            }
        }else {
            if ([language hasPrefix:@"en"]) {
                // 英文
                _barTitle = [self.creationDate dateStringWithFormat:@"MMM dd, yyyy"];
            } else if ([language hasPrefix:@"zh"]) {
                // 中文
                _barTitle = [self.creationDate dateStringWithFormat:@"yyyy年MM月dd日"];
                
            }else if ([language hasPrefix:@"ko"]) {
                // 韩语
                _barTitle = [self.creationDate dateStringWithFormat:@"yyyy년MM월dd일"];
            }else if ([language hasPrefix:@"ja"]) {
                // 日语
                _barTitle = [self.creationDate dateStringWithFormat:@"yyyy年MM月dd日"];
            }else {
                // 其他
                _barTitle = [self.creationDate dateStringWithFormat:@"MMM dd, yyyy"];
            }
        }
    }
    return _barTitle;
}
- (NSString *)barSubTitle {
    if (!_barSubTitle) {
        _barSubTitle = [self.creationDate dateStringWithFormat:@"HH:mm"];
    }
    return _barSubTitle;
}
- (void)dealloc {
    if (self.iCloudRequestID) {
        if (self.iCloudDownloading) {
            [[PHImageManager defaultManager] cancelImageRequest:self.iCloudRequestID];
        }
    }
    //    [self cancelImageRequest];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.thumbPhoto = [aDecoder decodeObjectForKey:@"thumbPhoto"];
        self.previewPhoto = [aDecoder decodeObjectForKey:@"previewPhoto"];
        self.localIdentifier = [aDecoder decodeObjectForKey:@"localIdentifier"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.subType = [aDecoder decodeIntegerForKey:@"subType"];
        self.videoDuration = [aDecoder decodeFloatForKey:@"videoDuration"];
        self.selected = [aDecoder decodeBoolForKey:@"selected"];
        self.videoURL = [aDecoder decodeObjectForKey:@"videoURL"];
        self.networkPhotoUrl = [aDecoder decodeObjectForKey:@"networkPhotoUrl"];
        self.creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
        self.modificationDate = [aDecoder decodeObjectForKey:@"modificationDate"];
        self.locationData = [aDecoder decodeObjectForKey:@"locationData"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.videoTime = [aDecoder decodeObjectForKey:@"videoTime"];
        self.selectIndexStr = [aDecoder decodeObjectForKey:@"videoTime"];
        self.cameraIdentifier = [aDecoder decodeObjectForKey:@"cameraIdentifier"];
        self.fileURL = [aDecoder decodeObjectForKey:@"fileURL"];
        self.gifImageData = [aDecoder decodeObjectForKey:@"gifImageData"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.thumbPhoto forKey:@"thumbPhoto"];
    [aCoder encodeObject:self.previewPhoto forKey:@"previewPhoto"];
    [aCoder encodeObject:self.localIdentifier forKey:@"localIdentifier"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeInteger:self.subType forKey:@"subType"];
    [aCoder encodeFloat:self.videoDuration forKey:@"videoDuration"];
    [aCoder encodeBool:self.selected forKey:@"selected"];
    [aCoder encodeObject:self.videoURL forKey:@"videoURL"];
    [aCoder encodeObject:self.networkPhotoUrl forKey:@"networkPhotoUrl"];
    [aCoder encodeObject:self.creationDate forKey:@"creationDate"];
    [aCoder encodeObject:self.modificationDate forKey:@"modificationDate"];
    [aCoder encodeObject:self.locationData forKey:@"locationData"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.videoTime forKey:@"videoTime"];
    [aCoder encodeObject:self.selectIndexStr forKey:@"selectIndexStr"];
    [aCoder encodeObject:self.cameraIdentifier forKey:@"cameraIdentifier"];
    [aCoder encodeObject:self.fileURL forKey:@"fileURL"];
    [aCoder encodeObject:self.gifImageData forKey:@"gifImageData"];
}

@end

