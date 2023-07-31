//
//  YM_DatePhotoToolManager.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoToolManager.h"
#import <Photos/Photos.h>
#import "UIImage+YM_Extension.h"
#import "YM_PhotoDefine.h"
#import "YM_PhotoTools.h"


#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/UIView+WebCache.h>
#elif __has_include("UIImageView+WebCache.h")
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "UIView+WebCache.h"
#endif

@interface YM_DatePhotoToolManager ()

@property (copy, nonatomic) YM_DatePhotoToolManagerSuccessHandler successHandler;
@property (copy, nonatomic) YM_DatePhotoToolManagerFailedHandler failedHandler;

@property (assign, nonatomic) BOOL writing;
@property (strong, nonatomic) NSMutableArray *allURL;
@property (strong, nonatomic) NSMutableArray *photoURL;
@property (strong, nonatomic) NSMutableArray *videoURL;
@property (strong, nonatomic) NSMutableArray *writeArray;
@property (strong, nonatomic) NSMutableArray *waitArray;
@property (strong, nonatomic) NSMutableArray *allArray;

@property (strong, nonatomic) NSMutableArray *downloadTokenArray;


@property (copy, nonatomic) YM_DatePhotoToolManagerGetImageListSuccessHandler imageSuccessHandler;
@property (copy, nonatomic) YM_DatePhotoToolManagerGetImageListFailedHandler imageFailedHandler;
@property (assign, nonatomic) BOOL gettingImage;
@property (assign, nonatomic) BOOL cancelGetImage;
@property (assign, nonatomic) PHImageRequestID currentImageRequestID;
@property (strong, nonatomic) NSMutableArray *allImageModelArray;
@property (strong, nonatomic) NSMutableArray *waitImageModelArray;
@property (strong, nonatomic) NSMutableArray *currentImageModelArray;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (assign, nonatomic) YM_DatePhotoToolManagerRequestType requestType;


@property (copy, nonatomic) YM_DatePhotoToolManagerGetImageDataListSuccessHandler imageDataSuccessHandler;
@property (copy, nonatomic) YM_DatePhotoToolManagerGetImageDataListFailedHandler imageDataFailedHandler;
@property (assign, nonatomic) BOOL gettingImageData;
@property (assign, nonatomic) BOOL cancelGetImageData;
@property (assign, nonatomic) PHImageRequestID currentImageDataRequestID;
@property (strong, nonatomic) NSMutableArray *allImageDataModelArray;
@property (strong, nonatomic) NSMutableArray *waitImageDataModelArray;
@property (strong, nonatomic) NSMutableArray *currentImageDataModelArray;
@property (strong, nonatomic) NSMutableArray *imageDataArray;

@end

@implementation YM_DatePhotoToolManager

- (instancetype)init {
    if (self = [super init]) {
        self.requestType = YM_DatePhotoToolManagerRequestTypeHD;
    }
    return self;
}

- (void)writeSelectModelListToTempPathWithList:(NSArray<YM_PhotoModel *> *)modelList requestType:(YM_DatePhotoToolManagerRequestType)requestType success:(YM_DatePhotoToolManagerSuccessHandler)success failed:(YM_DatePhotoToolManagerFailedHandler)failed {
    if (self.writing) {
        if (showLog) NSSLog(@"已有写入任务,请等待");
        return;
    }
    self.requestType = requestType;
    self.writing = YES;
    self.successHandler = success;
    self.failedHandler = failed;
    
    [self.allURL removeAllObjects];
    [self.photoURL removeAllObjects];
    [self.videoURL removeAllObjects];
    
    self.allArray = [NSMutableArray array];
    for (YM_PhotoModel *model in modelList) {
        [self.allArray insertObject:model atIndex:0];
    }
    self.waitArray = [NSMutableArray arrayWithArray:self.allArray];
    [self writeModelToTempPath];
}

- (void)gifModelAssignmentData:(NSArray<YM_PhotoModel *> *)gifModelArray
                       success:(void (^)(void))success
                        failed:(void (^)(void))failed {
    __block NSInteger count = 0;
    __block NSInteger modelCount = gifModelArray.count;
    for (YM_PhotoModel *model in gifModelArray) {
        [YM_PhotoTools getImageDataWithModel:model startRequestIcloud:^(PHImageRequestID cloudRequestId, YM_PhotoModel *model) {
            
        } progressHandler:^(YM_PhotoModel *model, double progress) {
            
        } completion:^(YM_PhotoModel *model, NSData *imageData, UIImageOrientation orientation) {
            model.gifImageData = imageData;
            count++;
            if (count == modelCount) {
                if (success) {
                    success();
                }
            }
        } failed:^(YM_PhotoModel *model, NSDictionary *info) {
            if (failed) {
                failed();
            }
        }];
    }
}

- (void)writeSelectModelListToTempPathWithList:(NSArray<YM_PhotoModel *> *)modelList success:(YM_DatePhotoToolManagerSuccessHandler)success failed:(YM_DatePhotoToolManagerFailedHandler)failed {
    if (self.writing) {
        if (showLog) NSSLog(@"已有写入任务,请等待");
        return;
    }
    self.writing = YES;
    self.successHandler = success;
    self.failedHandler = failed;
    
    [self.allURL removeAllObjects];
    [self.photoURL removeAllObjects];
    [self.videoURL removeAllObjects];
    
    self.allArray = [NSMutableArray array];
    for (YM_PhotoModel *model in modelList) {
        [self.allArray insertObject:model atIndex:0];
    }
    self.waitArray = [NSMutableArray arrayWithArray:self.allArray];
    [self writeModelToTempPath];
}
- (void)cleanWriteList {
    self.writing = NO;
    self.successHandler = nil;
    self.failedHandler = nil;
    
    [self.allURL removeAllObjects];
    [self.photoURL removeAllObjects];
    [self.videoURL removeAllObjects];
    [self.allArray removeAllObjects];
}
- (void)writeModelToTempPath {
    if (self.waitArray.count == 0) {
        if (showLog) NSSLog(@"全部压缩成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.writing = NO;
            if (self.successHandler) {
                self.successHandler(self.allURL, self.photoURL, self.videoURL);
            }
        });
        return;
    }
    self.writeArray = [NSMutableArray arrayWithObjects:self.waitArray.lastObject, nil];
    [self.waitArray removeLastObject];
    YM_PhotoModel *model = self.writeArray.firstObject;
    kWeakSelf
    if (model.type == YM_PhotoModelMediaType_Video) {
        NSString *presetName;
        if (self.requestType == YM_DatePhotoToolManagerRequestTypeOriginal) {
            presetName = AVAssetExportPresetHighestQuality;
        }else {
            presetName = AVAssetExportPresetMediumQuality;
        }
        if (model.asset) {
            [YM_PhotoTools getExportSessionWithPHAsset:model.asset deliveryMode:PHVideoRequestOptionsDeliveryModeAutomatic presetName:presetName startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                
            } progressHandler:^(double progress) {
                
            } completion:^(AVAssetExportSession *exportSession, NSDictionary *info) {
                kStrongSelf
                NSString *fileName = [[self uploadFileName] stringByAppendingString:@".mp4"];
                NSString *fullPathToFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                NSURL *videoURL = [NSURL fileURLWithPath:fullPathToFile];
                exportSession.outputURL = videoURL;
                exportSession.outputFileType = AVFileTypeMPEG4;
                exportSession.shouldOptimizeForNetworkUse = YES;
                
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                            [self.allArray removeObject:self.writeArray.firstObject];
                            [self.allURL addObject:videoURL];
                            [self.videoURL addObject:videoURL];
                            [self writeModelToTempPath];
                        }else if ([exportSession status] == AVAssetExportSessionStatusFailed){
                            if (self.failedHandler) {
                                self.failedHandler();
                            }
                            [self cleanWriteList];
                        }else if ([exportSession status] == AVAssetExportSessionStatusCancelled) {
                            if (self.failedHandler) {
                                self.failedHandler();
                            }
                            [self cleanWriteList];
                        }
                    });
                }];
            } failed:^(NSDictionary *info) {
                if (self.failedHandler) {
                    self.failedHandler();
                }
                [self cleanWriteList];
            }];
        }else {
            [self compressedVideoWithMediumQualityWriteToTemp:model.fileURL progress:^(float progress) {
                
            } success:^(NSURL *url) {
                [self.allArray removeObject:self.writeArray.firstObject];
                [self.allURL addObject:url];
                [self.videoURL addObject:url];
                [self writeModelToTempPath];
            } failure:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.failedHandler) {
                        self.failedHandler();
                    }
                    [self cleanWriteList];
                });
            }];
            
        }
        /*
         [YM_PhotoTools getAVAssetWithPHAsset:model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
         
         } progressHandler:^(double progress) {
         
         } completion:^(AVAsset *asset) {
         [self compressedVideoWithMediumQualityWriteToTemp:asset progress:^(float progress) {
         
         } success:^(NSURL *url) {
         [self.allArray removeObject:self.writeArray.firstObject];
         [self.allURL addObject:url];
         [self.videoURL addObject:url];
         [self writeModelToTempPath];
         } failure:^{
         if (self.failedHandler) {
         self.failedHandler();
         }
         [self cleanWriteList];
         }];
         } failed:^(NSDictionary *info) {
         dispatch_async(dispatch_get_main_queue(), ^{
         if (self.failedHandler) {
         self.failedHandler();
         }
         [self cleanWriteList];
         });
         }];
         */
    }else if (model.type == YM_PhotoModelMediaType_CameraVideo) {
        
        [self.allArray removeObject:self.writeArray.firstObject];
        [self.allURL addObject:model.videoURL];
        [self.videoURL addObject:model.videoURL];
        [self writeModelToTempPath];
        //        [self compressedVideoWithMediumQualityWriteToTemp:model.videoURL progress:^(float progress) {
        //
        //        } success:^(NSURL *url) {
        //            [self.allArray removeObject:self.writeArray.firstObject];
        //            [self.allURL addObject:url];
        //            [self.videoURL addObject:url];
        //            [self writeModelToTempPath];
        //        } failure:^{
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                if (self.failedHandler) {
        //                    self.failedHandler();
        //                }
        //                [self cleanWriteList];
        //            });
        //        }];
    }else if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
        if (model.networkPhotoUrl) {
            // 为网络图片时,直接使用图片地址
            [self.allArray removeObject:self.writeArray.firstObject];
            [self.allURL addObject:model.networkPhotoUrl];
            [self.photoURL addObject:model.networkPhotoUrl];
            [self writeModelToTempPath];
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CGFloat scale;
            if (self.requestType == YM_DatePhotoToolManagerRequestTypeHD) {
                scale = 0.8f;
            }else {
                scale = 1.0f;
            }
            NSData *imageData = UIImageJPEGRepresentation(model.thumbPhoto, scale);
            NSString *fileName = [[self uploadFileName] stringByAppendingString:[NSString stringWithFormat:@".jpeg"]];
            
            NSString *fullPathToFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            
            if ([imageData writeToFile:fullPathToFile atomically:YES]) {
                [self.allArray removeObject:self.writeArray.firstObject];
                [self.allURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                [self.photoURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                [self writeModelToTempPath];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.failedHandler) {
                        self.failedHandler();
                    }
                    [self cleanWriteList];
                });
            }
        });
    }else if (model.type == YM_PhotoModelMediaType_PhotoGif) {
        if (model.asset) {
            [YM_PhotoTools getImageData:model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                
            } progressHandler:^(double progress) {
                
            } completion:^(NSData *imageData, UIImageOrientation orientation) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *fileName = [[self uploadFileName] stringByAppendingString:[NSString stringWithFormat:@".gif"]];
                    
                    NSString *fullPathToFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                    
                    if ([imageData writeToFile:fullPathToFile atomically:YES]) {
                        [self.allArray removeObject:self.writeArray.firstObject];
                        [self.allURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                        [self.photoURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                        [self writeModelToTempPath];
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.failedHandler) {
                                self.failedHandler();
                            }
                            [self cleanWriteList];
                        });
                    }
                });
            } failed:^(NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.failedHandler) {
                        self.failedHandler();
                        [self cleanWriteList];
                    }
                });
            }];
        }else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fileName = [[self uploadFileName] stringByAppendingString:[NSString stringWithFormat:@".gif"]];
                
                NSString *fullPathToFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                
                if ([model.gifImageData writeToFile:fullPathToFile atomically:YES]) {
                    [self.allArray removeObject:self.writeArray.firstObject];
                    [self.allURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                    [self.photoURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                    [self writeModelToTempPath];
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.failedHandler) {
                            self.failedHandler();
                        }
                        [self cleanWriteList];
                    });
                }
            });
        }
    }else {
        if (model.asset) {
            CGSize size = CGSizeZero;
            if (self.requestType == YM_DatePhotoToolManagerRequestTypeHD) {
                CGFloat width = [UIScreen mainScreen].bounds.size.width;
                CGFloat height = [UIScreen mainScreen].bounds.size.height;
                CGFloat imgWidth = model.imageSize.width;
                CGFloat imgHeight = model.imageSize.height;
                if (imgHeight > imgWidth / 9 * 17) {
                    size = CGSizeMake(width, height);
                }else {
                    size = CGSizeMake(model.endImageSize.width * 1.5, model.endImageSize.height * 1.5);
                }
            }else {
                size = PHImageManagerMaximumSize;
            }
            [YM_PhotoTools getHighQualityFormatPhoto:model.asset size:size startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                
            } progressHandler:^(double progress) {
                
            } completion:^(UIImage *image) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *tempImage = image;
                    if (tempImage.imageOrientation != UIImageOrientationUp) {
                        tempImage = [tempImage normalizedImage];
                    }
                    NSData *imageData;
                    NSString *suffix;
                    if (UIImagePNGRepresentation(tempImage)) {
                        //返回为png图像。
                        imageData = UIImagePNGRepresentation(tempImage);
                        suffix = @"png";
                    }else {
                        //返回为JPEG图像。
                        imageData = UIImageJPEGRepresentation(tempImage, 0.8);
                        suffix = @"jpeg";
                    }
                    
                    NSString *fileName = [[self uploadFileName] stringByAppendingString:[NSString stringWithFormat:@".%@",suffix]];
                    
                    NSString *fullPathToFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                    
                    if ([imageData writeToFile:fullPathToFile atomically:YES]) {
                        [self.allArray removeObject:self.writeArray.firstObject];
                        [self.allURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                        [self.photoURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                        [self writeModelToTempPath];
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.failedHandler) {
                                self.failedHandler();
                            }
                            [self cleanWriteList];
                        });
                    }
                });
            } failed:^(NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.failedHandler) {
                        self.failedHandler();
                    }
                    [self cleanWriteList];
                });
            }];
        }else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                CGFloat scale;
                if (self.requestType == YM_DatePhotoToolManagerRequestTypeHD) {
                    scale = 0.8f;
                }else {
                    scale = 1.0f;
                }
                NSData *imageData = UIImageJPEGRepresentation(model.thumbPhoto, scale);
                NSString *fileName = [[self uploadFileName] stringByAppendingString:[NSString stringWithFormat:@".jpeg"]];
                
                NSString *fullPathToFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                
                if ([imageData writeToFile:fullPathToFile atomically:YES]) {
                    [self.allArray removeObject:self.writeArray.firstObject];
                    [self.allURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                    [self.photoURL addObject:[NSURL fileURLWithPath:fullPathToFile]];
                    [self writeModelToTempPath];
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.failedHandler) {
                            self.failedHandler();
                        }
                        [self cleanWriteList];
                    });
                }
            });
        }
    }
}

- (AVAssetExportSession *)compressedVideoWithMediumQualityWriteToTemp:(id)obj
                                                             progress:(void (^)(float progress))progress
                                                              success:(void (^)(NSURL *url))success
                                                              failure:(void (^)(void))failure {
    AVAsset *avAsset;
    if ([obj isKindOfClass:[AVAsset class]]) {
        avAsset = obj;
    }else {
        avAsset = [AVURLAsset URLAssetWithURL:obj options:nil];
    }
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        NSString *fileName = [[self uploadFileName] stringByAppendingString:@".mp4"];
        NSString *fullPathToFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        NSURL *videoURL = [NSURL fileURLWithPath:fullPathToFile];
        exportSession.outputURL = videoURL;
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                if (success) {
                    success(videoURL);
                }
            }else if ([exportSession status] == AVAssetExportSessionStatusFailed){
                if (failure) {
                    failure();
                }
            }else if ([exportSession status] == AVAssetExportSessionStatusCancelled) {
                if (failure) {
                    failure();
                }
            }
        }];
        return exportSession;
    }else {
        if (failure) {
            failure();
        }
        return nil;
    }
}
- (NSString *)uploadFileName {
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *uuidStr = [[uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *name = [NSString stringWithFormat:@"%@",uuidStr];
    
    NSString *fileName = @"";
    NSDate *nowDate = [NSDate date];
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
    NSString *numStr = [NSString stringWithFormat:@"%d",arc4random()%10000];
    fileName = [fileName stringByAppendingString:@"hx"];
    fileName = [fileName stringByAppendingString:dateStr];
    fileName = [fileName stringByAppendingString:numStr];
    
    return [NSString stringWithFormat:@"%@%@",name,fileName];
}
- (void)getSelectedImageDataList:(NSArray<YM_PhotoModel *> *)modelList success:(YM_DatePhotoToolManagerGetImageDataListSuccessHandler)success failed:(YM_DatePhotoToolManagerGetImageDataListFailedHandler)failed {
    if (self.gettingImageData) {
        if (showLog) NSSLog(@"已有任务,请等待");
        return;
    }
    [self cancelGetImageList];
    
    self.cancelGetImageData = NO;
    self.gettingImageData = YES;
    self.imageDataSuccessHandler = success;
    self.imageDataFailedHandler = failed;
    
    [self.imageDataArray removeAllObjects];
    [self.currentImageDataModelArray removeAllObjects];
    
    self.allImageDataModelArray = [NSMutableArray array];
    for (YM_PhotoModel *model in modelList) {
        [self.allImageDataModelArray insertObject:model atIndex:0];
    }
    self.waitImageDataModelArray = [NSMutableArray arrayWithArray:self.allImageDataModelArray];
    [self getCurrentModelImageData];
}
- (void)getCurrentModelImageData {
    if (self.cancelGetImageData) {
        self.cancelGetImageData = NO;
        self.gettingImageData = NO;
        [self.downloadTokenArray removeAllObjects];
        if (showLog) NSSLog(@"取消了");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.imageDataFailedHandler) {
                self.imageDataFailedHandler();
            }
        });
        return;
    }
    if (self.waitImageDataModelArray.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloadTokenArray removeAllObjects];
            self.gettingImageData = NO;
            self.cancelGetImageData = NO;
            if (self.imageDataSuccessHandler) {
                self.imageDataSuccessHandler(self.imageDataArray);
            }
        });
        return;
    }
    self.currentImageDataModelArray = [NSMutableArray arrayWithObjects:self.waitImageDataModelArray.lastObject, nil];
    [self.waitImageDataModelArray removeLastObject];
    YM_PhotoModel *model = self.currentImageDataModelArray.firstObject;
    if (model.asset) {
        kWeakSelf
        self.currentImageDataRequestID = [YM_PhotoTools getImageData:model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
            self.currentImageDataRequestID = cloudRequestId;
        } progressHandler:^(double progress) {
            
        } completion:^(NSData *imageData, UIImageOrientation orientation) {
            kStrongSelf
            [self.imageDataArray addObject:imageData];
            [self.allImageDataModelArray removeObject:self.currentImageDataModelArray.firstObject];
            [self getCurrentModelImageData];
        } failed:^(NSDictionary *info) {
            kStrongSelf
            if ([[info objectForKey:PHImageCancelledKey] boolValue]) {
                self.gettingImageData = NO;
                self.cancelGetImageData = NO;
                if (showLog) NSSLog(@"取消了请求了");
                if (self.imageDataFailedHandler) {
                    self.imageDataFailedHandler();
                }
                return;
            }
            YM_PhotoModel *model = self.currentImageDataModelArray.firstObject;
            if (model.gifImageData) {
                [self.imageDataArray addObject:model.gifImageData];
                [self.allImageDataModelArray removeObject:self.currentImageDataModelArray.firstObject];
                [self getCurrentModelImageData];
            }else {
                self.gettingImageData = NO;
                if (self.imageDataFailedHandler) {
                    self.imageDataFailedHandler();
                }
            }
        }];
    }else {
        if (model.networkPhotoUrl) {
            kWeakSelf
            if (model.downloadError) {
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
                SDWebImageDownloadToken *token = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:model.networkPhotoUrl options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    kStrongSelf
                    if (!error && data) {
                        model.thumbPhoto = image;
                        model.previewPhoto = image;
                        model.gifImageData = data;
                        [self.imageDataArray addObject:data];
                        [self.allImageDataModelArray removeObject:self.currentImageDataModelArray.firstObject];
                        [self getCurrentModelImageData];
                    }else {
                        [self.downloadTokenArray removeAllObjects];
                        self.gettingImageData = NO;
                        if (self.imageDataFailedHandler) {
                            self.imageDataFailedHandler();
                        }
                    }
                }];
                [self.downloadTokenArray addObject:token];
#endif
                return;
            }
            if (!model.downloadComplete) {
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
                SDWebImageDownloadToken *token = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:model.networkPhotoUrl options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    kStrongSelf
                    if (!error && image) {
                        model.thumbPhoto = image;
                        model.previewPhoto = image;
                        model.gifImageData = data;
                        [self.imageDataArray addObject:data];
                        [self.allImageDataModelArray removeObject:self.currentImageDataModelArray.firstObject];
                        [self getCurrentModelImageData];
                    }else {
                        [self.downloadTokenArray removeAllObjects];
                        self.gettingImageData = NO;
                        if (self.imageDataFailedHandler) {
                            self.imageDataFailedHandler();
                        }
                    }
                }];
                [self.downloadTokenArray addObject:token];
#endif
                return;
            }
        }
        if (model.gifImageData) {
            [self.imageDataArray addObject:model.gifImageData];
            [self.allImageDataModelArray removeObject:self.currentImageDataModelArray.firstObject];
            [self getCurrentModelImageData];
        }else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imageData = UIImageJPEGRepresentation(model.thumbPhoto, 1.0f);
                model.gifImageData = imageData;
                [self.imageDataArray addObject:imageData];
                [self.allImageDataModelArray removeObject:self.currentImageDataModelArray.firstObject];
                [self getCurrentModelImageData];
            });
        }
    }
}

- (void)getSelectedImageList:(NSArray<YM_PhotoModel *> *)modelList requestType:(YM_DatePhotoToolManagerRequestType)requestType success:(YM_DatePhotoToolManagerGetImageListSuccessHandler)success failed:(YM_DatePhotoToolManagerGetImageListFailedHandler)failed {
    if (self.gettingImage) {
        if (showLog) NSSLog(@"已有任务,请等待");
        return;
    }
    [self cancelGetImageDataList];
    self.requestType = requestType;
    self.cancelGetImage = NO;
    self.gettingImage = YES;
    self.imageSuccessHandler = success;
    self.imageFailedHandler = failed;
    
    [self.imageArray removeAllObjects];
    [self.currentImageModelArray removeAllObjects];
    
    self.allImageModelArray = [NSMutableArray array];
    for (YM_PhotoModel *model in modelList) {
        [self.allImageModelArray insertObject:model atIndex:0];
    }
    self.waitImageModelArray = [NSMutableArray arrayWithArray:self.allImageModelArray];
    [self getCurrentModelImage];
}
- (void)getSelectedImageList:(NSArray<YM_PhotoModel *> *)modelList success:(YM_DatePhotoToolManagerGetImageListSuccessHandler)success failed:(YM_DatePhotoToolManagerGetImageListFailedHandler)failed {
    if (self.gettingImage) {
        if (showLog) NSSLog(@"已有任务,请等待");
        return;
    }
    [self cancelGetImageDataList];
    self.cancelGetImage = NO;
    self.gettingImage = YES;
    self.imageSuccessHandler = success;
    self.imageFailedHandler = failed;
    
    [self.imageArray removeAllObjects];
    [self.currentImageModelArray removeAllObjects];
    
    self.allImageModelArray = [NSMutableArray array];
    for (YM_PhotoModel *model in modelList) {
        [self.allImageModelArray insertObject:model atIndex:0];
    }
    self.waitImageModelArray = [NSMutableArray arrayWithArray:self.allImageModelArray];
    [self getCurrentModelImage];
}
- (void)getCurrentModelImage {
    if (self.cancelGetImage) {
        self.cancelGetImage = NO;
        self.gettingImage = NO;
        [self.downloadTokenArray removeAllObjects];
        if (showLog) NSSLog(@"取消了");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.imageFailedHandler) {
                self.imageFailedHandler();
            }
        });
        return;
    }
    if (self.waitImageModelArray.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downloadTokenArray removeAllObjects];
            self.gettingImage = NO;
            self.cancelGetImage = NO;
            if (self.imageSuccessHandler) {
                self.imageSuccessHandler(self.imageArray);
            }
        });
        return;
    }
    self.currentImageModelArray = [NSMutableArray arrayWithObjects:self.waitImageModelArray.lastObject, nil];
    [self.waitImageModelArray removeLastObject];
    YM_PhotoModel *model = self.currentImageModelArray.firstObject;
    if (model.asset) {
        kWeakSelf
        CGFloat imgWidth = model.imageSize.width;
        CGFloat imgHeight = model.imageSize.height;
        CGSize size;
        if (self.requestType == YM_DatePhotoToolManagerRequestTypeHD) {
            if (imgHeight > imgWidth / 9 * 17) {
                size = [UIScreen mainScreen].bounds.size;
            }else {
                size = CGSizeMake(model.endImageSize.width * 2.0, model.endImageSize.height * 2.0);
            }
        }else {
            size = PHImageManagerMaximumSize;
        }
        self.currentImageRequestID = [YM_PhotoTools getHighQualityFormatPhoto:model.asset size:size startRequestIcloud:^(PHImageRequestID cloudRequestId) {
            self.currentImageRequestID = cloudRequestId;
        } progressHandler:^(double progress) {
            
        } completion:^(UIImage *image) {
            kStrongSelf
            [self.imageArray addObject:image];
            [self.allImageModelArray removeObject:self.currentImageModelArray.firstObject];
            [self getCurrentModelImage];
        } failed:^(NSDictionary *info) {
            if ([[info objectForKey:PHImageCancelledKey] boolValue]) {
                self.gettingImage = NO;
                self.cancelGetImage = NO;
                if (showLog) NSSLog(@"取消了请求了");
                if (self.imageFailedHandler) {
                    self.imageFailedHandler();
                }
                return;
            }
            YM_PhotoModel *model = self.currentImageModelArray.firstObject;
            if (model.thumbPhoto) {
                [self.imageArray addObject:model.thumbPhoto];
                [self.allImageModelArray removeObject:self.currentImageModelArray.firstObject];
                [self getCurrentModelImage];
            }else {
                self.gettingImage = NO;
                if (self.imageFailedHandler) {
                    self.imageFailedHandler();
                }
            }
        }];
    }else {
        if (model.networkPhotoUrl) {
            kWeakSelf
            if (model.downloadError) {
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
                SDWebImageDownloadToken *token = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:model.networkPhotoUrl options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    kStrongSelf
                    if (!error && image) {
                        model.thumbPhoto = image;
                        model.previewPhoto = image;
                        [self.imageArray addObject:model.thumbPhoto];
                        [self.allImageModelArray removeObject:self.currentImageModelArray.firstObject];
                        [self getCurrentModelImage];
                    }else {
                        [self.downloadTokenArray removeAllObjects];
                        self.gettingImage = NO;
                        if (self.imageFailedHandler) {
                            self.imageFailedHandler();
                        }
                    }
                }];
                [self.downloadTokenArray addObject:token];
#endif
                return;
            }
            if (!model.downloadComplete) {
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
                SDWebImageDownloadToken *token = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:model.networkPhotoUrl options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    kStrongSelf
                    if (!error && image) {
                        model.thumbPhoto = image;
                        model.previewPhoto = image;
                        [self.imageArray addObject:model.thumbPhoto];
                        [self.allImageModelArray removeObject:self.currentImageModelArray.firstObject];
                        [self getCurrentModelImage];
                    }else {
                        [self.downloadTokenArray removeAllObjects];
                        self.gettingImage = NO;
                        if (self.imageFailedHandler) {
                            self.imageFailedHandler();
                        }
                    }
                }];
                [self.downloadTokenArray addObject:token];
#endif
                return;
            }
            [self.imageArray addObject:model.thumbPhoto];
            [self.allImageModelArray removeObject:self.currentImageModelArray.firstObject];
            [self getCurrentModelImage];
        }else {
            [self.imageArray addObject:model.thumbPhoto];
            [self.allImageModelArray removeObject:self.currentImageModelArray.firstObject];
            [self getCurrentModelImage];
        }
    }
}
- (void)cancelGetImageList {
    self.cancelGetImage = YES;
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
    for (SDWebImageDownloadToken *token in self.downloadTokenArray) {
        [token cancel];
    }
#endif
    [self.downloadTokenArray removeAllObjects];
    if (self.currentImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.currentImageRequestID];
        self.currentImageRequestID = 0;
    }
}
- (void)cancelGetImageDataList {
    self.cancelGetImageData = YES;
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
    for (SDWebImageDownloadToken *token in self.downloadTokenArray) {
        [token cancel];
    }
#endif
    [self.downloadTokenArray removeAllObjects];
    if (self.currentImageDataRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.currentImageDataRequestID];
        self.currentImageDataRequestID = 0;
    }
}
- (NSMutableArray *)allURL {
    if (!_allURL) {
        _allURL = [NSMutableArray array];
    }
    return _allURL;
}
- (NSMutableArray *)photoURL {
    if (!_photoURL) {
        _photoURL = [NSMutableArray array];
    }
    return _photoURL;
}
- (NSMutableArray *)videoURL {
    if (!_videoURL) {
        _videoURL = [NSMutableArray array];
    }
    return _videoURL;
}
- (NSMutableArray *)writeArray {
    if (!_writeArray) {
        _writeArray = [NSMutableArray array];
    }
    return _writeArray;
}
- (NSMutableArray *)waitArray {
    if (!_waitArray) {
        _waitArray = [NSMutableArray array];
    }
    return _waitArray;
}
- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}
- (NSMutableArray *)currentImageModelArray {
    if (!_currentImageModelArray) {
        _currentImageModelArray = [NSMutableArray array];
    }
    return _currentImageModelArray;
}
- (NSMutableArray *)waitImageModelArray {
    if (!_waitImageModelArray) {
        _waitImageModelArray = [NSMutableArray array];
    }
    return _waitImageModelArray;
}
- (NSMutableArray *)allImageModelArray {
    if (!_allImageModelArray) {
        _allImageModelArray = [NSMutableArray array];
    }
    return _allImageModelArray;
}
- (NSMutableArray *)downloadTokenArray {
    if (!_downloadTokenArray) {
        _downloadTokenArray = [NSMutableArray array];
    }
    return _downloadTokenArray;
}
- (NSMutableArray *)allImageDataModelArray {
    if (!_allImageDataModelArray) {
        _allImageDataModelArray = [NSMutableArray array];
    }
    return _allImageDataModelArray;
}
- (NSMutableArray *)waitImageDataModelArray {
    if (!_waitImageDataModelArray) {
        _waitImageDataModelArray = [NSMutableArray array];
    }
    return _waitImageDataModelArray;
}
- (NSMutableArray *)currentImageDataModelArray {
    if (!_currentImageDataModelArray) {
        _currentImageDataModelArray = [NSMutableArray array];
    }
    return _currentImageDataModelArray;
}
- (NSMutableArray *)imageDataArray {
    if (!_imageDataArray) {
        _imageDataArray = [NSMutableArray array];
    }
    return _imageDataArray;
}

- (void)dealloc {
    if (showLog) NSSLog(@"dealloc");
}


@end
