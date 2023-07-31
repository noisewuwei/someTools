//
//  YM_PhotoTools.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PhotoTools.h"
#import <sys/utsname.h>
#import <MobileCoreServices/MobileCoreServices.h>

/** category */
#import "UIImage+YM_Extension.h"

/** manage */
#import "YM_PhotoManager.h"
#import "YM_DatePhotoToolManager.h"

/** model */
#import "YM_PhotoModel.h"
#import "YM_PhotoDateModel.h"

@implementation YM_PhotoTools


/**
 获取bundle文件中的图片
 @param imageName 图片名
 @return UIImage图片
 */
+ (UIImage *)ym_imageNamed:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    if (image) {
        return image;
    }
    NSString *path = [NSString stringWithFormat:@"YM_PhotoPicker.bundle/%@",imageName];
    image = [UIImage imageNamed:path];
    if (image) {
        return image;
    } else {
        NSString *path = [NSString stringWithFormat:@"Frameworks/YM_PhotosFile.framework/YM_PhotoPicker.bundle/%@",imageName];
        image = [UIImage imageNamed:path];
        if (!image) {
            image = [UIImage imageNamed:imageName];
        }
        return image;
    }
}

/**
 保存模型数组到本地
 @param manager 照片管理者
 @param success 成功
 @param failed  失败
 */
+ (void)saveSelectModelArrayWithManager:(YM_PhotoManager *)manager
                                success:(void (^)(void))success
                                 failed:(void (^)(void))failed {
    if (!manager.afterSelectedArray.count) {
        if (failed) {
            failed();
            return;
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *gifModel = [NSMutableArray array];
        // 遍历选择后的图片模型 获取gif图片模型
        for (YM_PhotoModel *model in manager.afterSelectedArray) {
            if (model.type == YM_PhotoModelMediaType_PhotoGif &&
                !model.gifImageData) {
                [gifModel addObject:model];
            }
        }
        // 如果存在gif图片
        if (gifModel.count) {
            kWeakSelf
            [[[YM_DatePhotoToolManager alloc] init] gifModelAssignmentData:gifModel success:^{
                kStrongSelf
                BOOL su = [self saveSelectModelArray:manager.afterSelectedArray fileName:manager.configuration.localFileName];
                if (!su) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (failed) {
                            failed();
                        }
                        if (showLog) NSSLog(@"保存草稿失败啦!");
                    });
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            success();
                        }
                    });
                }
            } failed:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed();
                    }
                    if (showLog) NSSLog(@"保存草稿失败啦!");
                });
            }];
        }else {
            BOOL su = [self saveSelectModelArray:manager.afterSelectedArray fileName:manager.configuration.localFileName];
            if (!su) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed();
                    }
                    if (showLog) NSSLog(@"保存草稿失败啦!");
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success();
                    }
                });
            }
        }
    });
}

/**
 删除本地保存的模型数组
 @param manager 照片管理者
 @return 删除结果
 */
+ (BOOL)deleteLocalSelectModelArrayWithManager:(YM_PhotoManager *)manager {
    return [self deleteSelectModelArrayWithFileName:manager.configuration.localFileName];
}

/**
 获取本地保存的模型数组
 @param manager   相片管理者
 @param complete  成功回调
 */
+ (void)getSelectedModelArrayWithManager:(YM_PhotoManager *)manager
                                complete:(Complete_Block1)complete  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *modelArray = [self getSelectedModelArrayWithFileName:manager.configuration.localFileName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(modelArray);
            }
        });
    });
}

/**
 保存模型数组到本地
 @param modelArray 要保存的模型数组
 @param fileName   文件名
 @return 保存结果
 */
+ (BOOL)saveSelectModelArray:(NSArray<YM_PhotoModel *> *)modelArray
                    fileName:(NSString *)fileName {
    NSMutableData *data = [[NSMutableData alloc] init];
    //创建归档辅助类
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //编码
    [archiver encodeObject:modelArray forKey:encodeKey];
    //结束编码
    [archiver finishEncoding];
    //写入到沙盒
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *toFileName = [array.firstObject stringByAppendingPathComponent:fileName];
    
    if([data writeToFile:toFileName atomically:YES]){
        if (showLog) NSSLog(@"归档成功");
        return YES;
    }
    return NO;
}

/**
 获取保存在本地的模型数组
 @param fileName 文件名
 @return 模型数组
 */
+ (NSArray<YM_PhotoModel *> *)getSelectedModelArrayWithFileName:(NSString *)fileName {
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *toFileName = [array.firstObject stringByAppendingPathComponent:fileName];
    //解档
    NSData *undata = [[NSData alloc] initWithContentsOfFile:toFileName];
    //解档辅助类
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:undata];
    //解码并解档出model
    NSArray *tempArray = [unarchiver decodeObjectForKey:encodeKey];
    //关闭解档
    [unarchiver finishDecoding];
    return tempArray.copy;
}

/**
 删除保存在本地的模型数组
 @param fileName 文件名
 @return 模型数组
 */
+ (BOOL)deleteSelectModelArrayWithFileName:(NSString *)fileName {
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *toFileName = [array.firstObject stringByAppendingPathComponent:fileName];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:toFileName error:&error];
    if (error) {
        if (showLog) NSSLog(@"删除失败");
        return NO;
    }
    return YES;
}

/**
 保存本地视频到系统相册和自定义相册
 @param albumName 自定义相册名称
 @param videoURL  本地视频地址
 */
+ (void)saveVideoToCustomAlbumWithName:(NSString *)albumName
                              videoURL:(NSURL *)videoURL {
    if (!videoURL) {
        return;
    }
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!iOS9_Later) {
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([videoURL path])) {
                    //保存相册核心代码
                    UISaveVideoAtPathToSavedPhotosAlbum([videoURL path], nil, nil, nil);
                }
                return;
            }
            NSError *error = nil;
            // 保存相片到相机胶卷
            __block PHObjectPlaceholder *createdAsset = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                createdAsset = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoURL].placeholderForCreatedAsset;
            } error:&error];
            
            if (error) {
                if (showLog) NSSLog(@"保存失败");
                return;
            }
            
            // 拿到自定义的相册对象
            PHAssetCollection *collection = [self createCollection:albumName];
            if (collection == nil) {
                if (showLog) NSSLog(@"保存自定义相册失败");
                return;
            }
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:&error];
            
            if (error) {
                if (showLog) NSSLog(@"保存自定义相册失败");
            } else {
                if (showLog)  NSSLog(@"保存成功");
            }
        });
    }];
}

/**
 保存图片到系统相册和自定义相册
 @param albumName 自定义相册名称
 @param photo uiimage
 */
+ (void)savePhotoToCustomAlbumWithName:(NSString *)albumName
                                 photo:(UIImage *)photo {
    if (!photo) {
        return;
    }
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!iOS9_Later) {
                UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
                return;
            }
            NSError *error = nil;
            // 保存相片到相机胶卷
            __block PHObjectPlaceholder *createdAsset = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:photo].placeholderForCreatedAsset;
            } error:&error];
            
            if (error) {
                if (showLog) NSSLog(@"保存失败");
                return;
            }
            
            // 拿到自定义的相册对象
            PHAssetCollection *collection = [self createCollection:albumName];
            if (collection == nil) {
                if (showLog) NSSLog(@"保存自定义相册失败");
                return;
            }
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:&error];
            
            if (error) {
                if (showLog) NSSLog(@"保存自定义相册失败");
            } else {
                if (showLog) NSSLog(@"保存成功");
            }
        });
    }];
}

/**
 获取相片中的反地理编码
 @param model       相片模型
 @param completion  成功回调
 @return 反地理编码
 */
+ (CLGeocoder *)getDateLocationDetailInformationWithModel:(YM_PhotoDateModel *)model
                                               completion:(Complete_Block3)completion {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:model.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0 && !error) {
            CLPlacemark *placemark = placemarks.firstObject;
            if (completion) {
                completion(placemark,model);
            }
        }
    }];
    return geoCoder;
}

/**
 根据PHAsset对象获取照片信息（此方法会回调多次）
 @param asset      指定相片
 @param size       指定相片的尺寸（option.resizeMode = PHImageRequestOptionsResizeModeFast时有效）
 @param completion 完成回调
 @return PHImageRequestID
 */
+ (PHImageRequestID)getPhotoForPHAsset:(PHAsset *)asset
                                  size:(CGSize)size
                            completion:(Complete_Block4)completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    return [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        
        if (downloadFinined && completion && result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result,info);
            });
        }
    }];
}

/**
 根据PHAsset对象获取照片信息，此方法只会回调一次
 @param asset      指定相片
 @param size       指定相片的尺寸（option.resizeMode = PHImageRequestOptionsResizeModeFast时有效）
 @param completion 完成回调
 @param error      错误回调
 @return PHImageRequestID
 */
+ (PHImageRequestID)getHighQualityFormatPhotoForPHAsset:(PHAsset *)asset
                                                   size:(CGSize)size
                                             completion:(Complete_Block4)completion
                                                  error:(void(^)(NSDictionary *info))error {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = NO;
    
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(result,info);
                }
            });
        }else {
            //            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
            //                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
            //                option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            //                option.resizeMode = PHImageRequestOptionsResizeModeFast;
            //                option.networkAccessAllowed = YES;
            //                option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            //                    NSSLog(@"%f",progress);
            //                };
            //                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            //                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            //                    if (downloadFinined && result) {
            //                        dispatch_async(dispatch_get_main_queue(), ^{
            //                            if (completion) {
            //                                completion(result,info);
            //                            }
            //                        });
            //                    }else {
            //
            //                    }
            //                }];
            //            }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    error(info);
                }
            });
            //            }
        }
    }];
    return requestID;
}

/**
 根据模型获取指定大小的image(成功回调可能会执行多次)
 @param model       相片模型
 @param size        相片大小
 @param completion  完成后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getImageWithAlbumModel:(YM_AlbumModel *)model
                                      size:(CGSize)size
                                completion:(Complete_Block6)completion {
    // 图片请求选项
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    // 快速调整模式(传入的size好像只有在PHImageRequestOptionsResizeModeExact下有效果)
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 获取标识符和图片
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] &&
                                ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(result,model);
            });
        }
    }];
    return requestID;
}

/**
 根据相册模型、PHAsset获取指定大小的image
 @param model 相册模型
 @param asset 照片对象
 @param size  指定大小
 @param completion 完成后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getImageWithAlbumModel:(YM_AlbumModel *)model
                                     asset:(PHAsset *)asset
                                      size:(CGSize)size
                                completion:(Complete_Block6)completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    return [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(result,model);
            });
        }
    }];
}

/**
 根据PHAsset对象获取AVPlayerItem（如果为iCloud上的会自动下载）
 @param asset               PHAsset
 @param startRequestIcloud  开始请求iCloud上的资源
 @param progressHandler     iCloud下载进度
 @param completion          完成后的block
 @param failed              失败后的block
 @return 请求id
 */
+ (PHImageRequestID)getPlayerItemWithPHAsset:(PHAsset *)asset
                          startRequestIcloud:(Start_Request_iCloud_Block1)startRequestIcloud
                             progressHandler:(void (^)(double progress))progressHandler
                                  completion:(void(^)(AVPlayerItem *playerItem))completion
                                      failed:(void(^)(NSDictionary *info))failed {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
    options.networkAccessAllowed = NO;
    return [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && playerItem) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(playerItem);
                }
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                PHImageRequestID cloudRequestId = 0;
                PHVideoRequestOptions *cloudOptions = [[PHVideoRequestOptions alloc] init];
                cloudOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
                cloudOptions.networkAccessAllowed = YES;
                cloudOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress);
                        }
                    });
                };
                cloudRequestId = [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:cloudOptions resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && playerItem) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(playerItem);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failed) {
                                failed(info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (startRequestIcloud) {
                        startRequestIcloud(cloudRequestId);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed(info);
                    }
                });
            }
        }
    }];
}

/**
 根据PHAsset对象获取AVAsset（如果为iCloud上的会自动下载）
 @param phAsset            PHAsset
 @param startRequestIcloud 开始请求iCloud上的资源
 @param progressHandler    iCloud下载进度
 @param completion         完成后的block
 @param failed             失败后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getAVAssetWithPHAsset:(PHAsset *)phAsset
                       startRequestIcloud:(Start_Request_iCloud_Block1)startRequestIcloud
                          progressHandler:(void (^)(double progress))progressHandler
                               completion:(void(^)(AVAsset *asset))completion
                                   failed:(void(^)(NSDictionary *info))failed {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
    options.networkAccessAllowed = NO;
    return [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(asset);
                }
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                PHImageRequestID cloudRequestId = 0;
                PHVideoRequestOptions *cloudOptions = [[PHVideoRequestOptions alloc] init];
                cloudOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
                cloudOptions.networkAccessAllowed = YES;
                cloudOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress);
                        }
                    });
                };
                cloudRequestId = [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:cloudOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && asset) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(asset);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failed) {
                                failed(info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (startRequestIcloud) {
                        startRequestIcloud(cloudRequestId);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed(info);
                    }
                });
            }
        }
    }];
}

/**
 获取AVAssetExportSession
 @param phAsset            PHAsset对象
 @param deliveryMode       PHVideoRequestOptionsDeliveryMode
 @param presetName         质量
 @param startRequestIcloud 开始请求iCloud上的资源
 @param progressHandler    iCloud下载进度
 @param completion         完成后的block
 @param failed             失败后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getExportSessionWithPHAsset:(PHAsset *)phAsset
                                   deliveryMode:(PHVideoRequestOptionsDeliveryMode)deliveryMode
                                     presetName:(NSString *)presetName
                             startRequestIcloud:(Start_Request_iCloud_Block1)startRequestIcloud
                                progressHandler:(void (^)(double progress))progressHandler
                                     completion:(Complete_Block7)completion
                                         failed:(void(^)(NSDictionary *info))failed {
    //    AVAssetExportPresetHighestQuality
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = deliveryMode;
    options.networkAccessAllowed = NO;
    
    return [[PHImageManager defaultManager] requestExportSessionForVideo:phAsset options:options exportPreset:presetName resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        // 是否成功
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && exportSession) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(exportSession, info);
                }
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                PHImageRequestID iRequestId = 0;
                PHVideoRequestOptions *iOption = [[PHVideoRequestOptions alloc] init];
                iOption.deliveryMode = deliveryMode;
                iOption.networkAccessAllowed = YES;
                iOption.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress);
                        }
                    });
                };
                iRequestId = [[PHImageManager defaultManager] requestExportSessionForVideo:phAsset options:iOption exportPreset:presetName resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && exportSession) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(exportSession, info);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failed) {
                                failed(info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (startRequestIcloud) {
                        startRequestIcloud(iRequestId);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed(info);
                    }
                });
            }
        }
    }];
}

/**
 根据PHAsset获取中等质量的视频AVAsset对象
 @param phAsset            PHAsset
 @param startRequestIcloud 开始请求iCloud上的资源回调
 @param progressHandler    下载进度回调
 @param completion         完成回调
 @param failed             错误回调
 @return PHImageRequestID
 */
+ (PHImageRequestID)getMediumQualityAVAssetWithPHAsset:(PHAsset *)phAsset
                                    startRequestIcloud:(Start_Request_iCloud_Block1)startRequestIcloud
                                       progressHandler:(void (^)(double progress))progressHandler
                                            completion:(void(^)(AVAsset *asset))completion
                                                failed:(void(^)(NSDictionary *info))failed {
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
    options.networkAccessAllowed = NO;
    return [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(asset);
                }
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                PHImageRequestID cloudRequestId = 0;
                PHVideoRequestOptions *cloudOptions = [[PHVideoRequestOptions alloc] init];
                cloudOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
                cloudOptions.networkAccessAllowed = YES;
                cloudOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress);
                        }
                    });
                };
                cloudRequestId = [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:cloudOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && asset) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(asset);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failed) {
                                failed(info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (startRequestIcloud) {
                        startRequestIcloud(cloudRequestId);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed(info);
                    }
                });
            }
        }
    }];
    
}

/**
 根据模型获取image
 @param model      相片模型
 @param completion 完成后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getImageWithModel:(YM_PhotoModel *)model
                           completion:(Complete_Block5)completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    return [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:model.requestSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        //        if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
        //            NSSLog(@"icloud上的资源!!!");
        //        }
        if (downloadFinined && result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(result,model);
            });
        }
    }];
}

+ (PHImageRequestID)FetchLivePhotoForPHAsset:(PHAsset *)asset Size:(CGSize)size Completion:(void (^)(PHLivePhoto *, NSDictionary *))completion
{
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.networkAccessAllowed = NO;
    
    return [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey]);
        if (downloadFinined && completion && livePhoto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(livePhoto,info);
            });
        }
    }];
}








+ (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}



// 创建自己要创建的自定义相册
+ (PHAssetCollection * )createCollection:(NSString *)albumName {
    NSString * title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    PHFetchResult<PHAssetCollection *> *collections =  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHAssetCollection * createCollection = nil;
    for (PHAssetCollection * collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            createCollection = collection;
            break;
        }
    }
    if (createCollection == nil) {
        
        NSError * error1 = nil;
        __block NSString * createCollectionID = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            NSString * title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
            createCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
        } error:&error1];
        
        if (error1) {
            if (showLog) NSSLog(@"创建相册失败...");
            return nil;
        }
        // 创建相册之后我们还要获取此相册  因为我们要往进存储相片
        createCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createCollectionID] options:nil].firstObject;
    }
    
    return createCollection;
}





/**
 根据PHAsset获取高等质量的视频AVAsset对象
 @param phAsset             phAsset
 @param startRequestIcloud  开始请求iCloud上的资源回调
 @param progressHandler     下载进度回调
 @param completion          完成回调
 @param failed              错误回调
 @return PHImageRequestID
 */
+ (PHImageRequestID)getHighQualityAVAssetWithPHAsset:(PHAsset *)phAsset
                                  startRequestIcloud:(Start_Request_iCloud_Block1)startRequestIcloud
                                     progressHandler:(void (^)(double progress))progressHandler
                                          completion:(void(^)(AVAsset *asset))completion
                                              failed:(void(^)(NSDictionary *info))failed {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = NO;
    return [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(asset);
                }
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                PHImageRequestID cloudRequestId = 0;
                PHVideoRequestOptions *cloudOptions = [[PHVideoRequestOptions alloc] init];
                cloudOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
                cloudOptions.networkAccessAllowed = YES;
                cloudOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress);
                        }
                    });
                };
                cloudRequestId = [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:cloudOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && asset) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(asset);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failed) {
                                failed(info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (startRequestIcloud) {
                        startRequestIcloud(cloudRequestId);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed(info);
                    }
                });
            }
        }
    }];
}

/**
 根据PHAsset对象获取指定大小的图片（成功回调只会执行一次）
 @param asset       PHAsset
 @param size        指定大小
 @param succeed     成功后的回调
 @param failed      失败后的回调
 @return PHImageRequestID
 */
+ (PHImageRequestID)getHighQualityFormatPhoto:(PHAsset *)asset
                                         size:(CGSize)size
                                      succeed:(void (^)(UIImage *image))succeed
                                       failed:(void(^)(void))failed {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = NO;
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && result) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (succeed) {
                    succeed(result);
                }
            });
        }else {
            if (failed) {
                failed();
            }
        }
    }];
    return requestID;
}

/**
 根据PHAsset对象获取指定大小的图片（成功回调只会执行一次）
 @param asset               PHAsset对象
 @param size                大小
 @param startRequestIcloud  开始请求iCloud上的资源
 @param progressHandler     iCloud下载进度
 @param completion          完成后的block
 @param failed              失败后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getHighQualityFormatPhoto:(PHAsset *)asset
                                         size:(CGSize)size
                           startRequestIcloud:(Start_Request_iCloud_Block1)startRequestIcloud
                              progressHandler:(void (^)(double progress))progressHandler
                                   completion:(void(^)(UIImage *image))completion
                                       failed:(void(^)(NSDictionary *info))failed {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = NO;
    
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(result);
                }
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && ![[info objectForKey:PHImageCancelledKey] boolValue]) {
                PHImageRequestID cloudRequestId = 0;
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                option.networkAccessAllowed = YES;
                option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress);
                        }
                    });
                };
                cloudRequestId = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && result) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(result);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failed) {
                                failed(info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (startRequestIcloud) {
                        startRequestIcloud(cloudRequestId);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed(info);
                    }
                });
            }
        }
    }];
    return requestID;
}


/**
 根据PHAsset获取指定大小的LivePhoto图片
 @param asset               PHAsset
 @param size                大小
 @param startRequestICloud  开始请求iCloud上的资源
 @param progressHandler     iCloud下载进度
 @param completion          完成后的block
 @param failed              失败后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getLivePhotoForAsset:(PHAsset *)asset
                                    size:(CGSize)size
                      startRequestICloud:(void (^)(PHImageRequestID iCloudRequestId))startRequestICloud
                         progressHandler:(void (^)(double progress))progressHandler
                              completion:(void(^)(PHLivePhoto *livePhoto))completion
                                  failed:(void(^)(void))failed {
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.networkAccessAllowed = NO;
    
    return [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && completion && livePhoto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(livePhoto);
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]) {
                PHImageRequestID iCloudRequestId = 0;
                PHLivePhotoRequestOptions *iCloudOption = [[PHLivePhotoRequestOptions alloc] init];
                iCloudOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                iCloudOption.networkAccessAllowed = YES;
                iCloudOption.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress);
                        }
                    });
                };
                iCloudRequestId = [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:iCloudOption resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && livePhoto) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(livePhoto);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failed) {
                                failed();
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (startRequestICloud) {
                        startRequestICloud(iCloudRequestId);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed();
                    }
                });
            }
        }
    }];
}

/**
 根据PHAsset获取imageData
 @param asset               PHAsset
 @param startRequestIcloud  开始请求iCloud上的资源
 @param progressHandler     iCloud下载进度
 @param completion          完成后的block
 @param failed              失败后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getImageData:(PHAsset *)asset
              startRequestIcloud:(void (^)(PHImageRequestID
                                           cloudRequestId))startRequestIcloud
                 progressHandler:(void (^)(double progress))progressHandler
                      completion:(Complete_Block8)completion
                          failed:(void(^)(NSDictionary *info))failed {
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = NO;
    option.synchronous = NO;
    option.version = PHImageRequestOptionsVersionOriginal;
    
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && imageData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(imageData, orientation);
                }
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && ![[info objectForKey:PHImageCancelledKey] boolValue]) {
                PHImageRequestID cloudRequestId = 0;
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                option.networkAccessAllowed = YES;
                option.version = PHImageRequestOptionsVersionOriginal;
                option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress);
                        }
                    });
                };
                cloudRequestId = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && imageData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(imageData, orientation);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failed) {
                                failed(info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (startRequestIcloud) {
                        startRequestIcloud(cloudRequestId);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failed) {
                        failed(info);
                    }
                });
            }
        }
    }];
    return requestID;
}

/**
 通过模型去获取AVAsset
 @param model               相片模型
 @param startRequestIcloud  开始请求iCloud上的资源
 @param progressHandler     iCloud下载进度
 @param completion          完成后的block
 @param failed              失败后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getAVAssetWithModel:(YM_PhotoModel *)model
                     startRequestIcloud:(Start_Request_iCloud_Block2)startRequestIcloud
                        progressHandler:(Progress_Handler_Block)progressHandler
                             completion:(Complete_Block9)completion
                                 failed:(Failed_Block1)failed {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
    options.networkAccessAllowed = NO;
    PHImageRequestID requestId = 0;
    model.iCloudDownloading = YES;
    requestId = [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                model.iCloudDownloading = NO;
                model.isICloud = NO;
                if (completion) {
                    completion(model,asset);
                }
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]) {
                PHImageRequestID cloudRequestId = 0;
                PHVideoRequestOptions *cloudOptions = [[PHVideoRequestOptions alloc] init];
                cloudOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
                cloudOptions.networkAccessAllowed = YES;
                cloudOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        model.iCloudProgress = progress;
                        if (progressHandler) {
                            progressHandler(model,progress);
                        }
                    });
                };
                cloudRequestId = [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:cloudOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && asset) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            model.iCloudDownloading = NO;
                            model.isICloud = NO;
                            if (completion) {
                                completion(model,asset);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (![[info objectForKey:PHImageCancelledKey] boolValue]) {
                                model.iCloudDownloading = NO;
                            }
                            if (failed) {
                                failed(model,info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.iCloudRequestID = cloudRequestId;
                    if (startRequestIcloud) {
                        startRequestIcloud(cloudRequestId, model);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![[info objectForKey:PHImageCancelledKey] boolValue]) {
                        model.iCloudDownloading = NO;
                    }
                    if (failed) {
                        failed(model,info);
                    }
                });
            }
        }
    }];
    model.iCloudRequestID = requestId;
    return requestId;
}

/**
 通过模型去获取PHLivePhoto
 @param model               相片模型
 @param size                指定相片大小
 @param startRequestICloud  开始请求iCloud上的资源
 @param progressHandler     iCloud下载进度
 @param completion          完成后的block
 @param failed              失败后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getLivePhotoWithModel:(YM_PhotoModel *)model
                                     size:(CGSize)size
                       startRequestICloud:(Start_Request_iCloud_Block3)startRequestICloud
                          progressHandler:(Progress_Handler_Block)progressHandler
                               completion:(Complete_Block10)completion
                                   failed:(Failed_Block1)failed {
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.networkAccessAllowed = NO;
    PHImageRequestID requestId = 0;
    model.iCloudDownloading = YES;
    requestId = [[PHImageManager defaultManager] requestLivePhotoForAsset:model.asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && completion && livePhoto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                model.isICloud = NO;
                model.iCloudDownloading = NO;
                completion(model,livePhoto);
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]) {
                PHImageRequestID iCloudRequestId = 0;
                PHLivePhotoRequestOptions *iCloudOption = [[PHLivePhotoRequestOptions alloc] init];
                iCloudOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                iCloudOption.networkAccessAllowed = YES;
                iCloudOption.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        model.iCloudProgress = progress;
                        if (progressHandler) {
                            progressHandler(model,progress);
                        }
                    });
                };
                iCloudRequestId = [[PHImageManager defaultManager] requestLivePhotoForAsset:model.asset targetSize:size contentMode:PHImageContentModeAspectFill options:iCloudOption resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && livePhoto) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            model.isICloud = NO;
                            model.iCloudDownloading = NO;
                            if (completion) {
                                completion(model,livePhoto);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (![[info objectForKey:PHImageCancelledKey] boolValue]) {
                                model.iCloudDownloading = NO;
                            }
                            if (failed) {
                                failed(model,info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.iCloudRequestID = requestId;
                    if (startRequestICloud) {
                        startRequestICloud(model,iCloudRequestId);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![[info objectForKey:PHImageCancelledKey] boolValue]) {
                        model.iCloudDownloading = NO;
                    }
                    if (failed) {
                        failed(model,info);
                    }
                });
            }
        }
    }];
    model.iCloudRequestID = requestId;
    return requestId;
}

/**
 通过模型去获取imageData
 @param model 相片模型
 @param startRequestIcloud 请求iCloud回调
 @param progressHandler    进度回调
 @param completion         完成回调
 @param failed             错误回调
 @return PHImageRequestID  标识符
 */
+ (PHImageRequestID)getImageDataWithModel:(YM_PhotoModel *)model
                       startRequestIcloud:(Start_Request_iCloud_Block2)startRequestIcloud
                          progressHandler:(Progress_Handler_Block)progressHandler
                               completion:(Complete_Block2)completion
                                   failed:(Failed_Block1)failed {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = NO;
    option.synchronous = NO;
    if (model.type == YM_PhotoModelMediaType_PhotoGif) {
        option.version = PHImageRequestOptionsVersionOriginal;
    }
    model.iCloudDownloading = YES;
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        if (downloadFinined && imageData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                model.iCloudDownloading = NO;
                model.isICloud = NO;
                if (completion) {
                    completion(model,imageData, orientation);
                }
            });
        }else {
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]) {
                PHImageRequestID cloudRequestId = 0;
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                option.networkAccessAllowed = YES;
                option.version = PHImageRequestOptionsVersionOriginal;
                option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        model.iCloudProgress = progress;
                        if (progressHandler) {
                            progressHandler(model,progress);
                        }
                    });
                };
                cloudRequestId = [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadFinined && imageData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            model.iCloudDownloading = NO;
                            model.isICloud = NO;
                            if (completion) {
                                completion(model,imageData, orientation);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (![[info objectForKey:PHImageCancelledKey] boolValue]) {
                                model.iCloudDownloading = NO;
                            }
                            if (failed) {
                                failed(model,info);
                            }
                        });
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.iCloudRequestID = cloudRequestId;
                    if (startRequestIcloud) {
                        startRequestIcloud(cloudRequestId, model);
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![[info objectForKey:PHImageCancelledKey] boolValue]) {
                        model.iCloudDownloading = NO;
                    }
                    if (failed) {
                        failed(model,info);
                    }
                });
            }
        }
    }];
    model.iCloudRequestID = requestID;
    return requestID;
}

/**
 根据AVAsset对象获取指定数量和大小的图片(会根据视频时长平分)
 @param asset       AVAsset
 @param total       总数
 @param size        图片大小
 @param complete    完成后的block
 */
+ (void)getVideoEachFrameWithAsset:(AVAsset *)asset
                             total:(NSInteger)total
                              size:(CGSize)size
                          complete:(Complete_Block11)complete {
    long duration = round(asset.duration.value) / asset.duration.timescale;
    
    NSTimeInterval average = (CGFloat)duration / (CGFloat)total;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.maximumSize = size;
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 1; i <= total; i++) {
        CMTime time = CMTimeMake((i * average) * asset.duration.timescale, asset.duration.timescale);
        NSValue *value = [NSValue valueWithCMTime:time];
        [arr addObject:value];
    }
    NSMutableArray *arrImages = [NSMutableArray array];
    __block long count = 0;
    [generator generateCGImagesAsynchronouslyForTimes:arr completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        switch (result) {
            case AVAssetImageGeneratorSucceeded:
                [arrImages addObject:[UIImage imageWithCGImage:image]];
                break;
            case AVAssetImageGeneratorFailed:
                
                break;
            case AVAssetImageGeneratorCancelled:
                
                break;
        }
        count++;
        if (count == arr.count && complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(asset, arrImages);
            });
        }
    }];
}

/********************分割线*********************/
+ (NSString *)uploadFileName {
    NSString *fileName = @"";
    NSDate *nowDate = [NSDate date];
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
    
    NSString *numStr = [NSString stringWithFormat:@"%d",arc4random()%10000];
    
    fileName = [fileName stringByAppendingString:@"hx"];
    fileName = [fileName stringByAppendingString:dateStr];
    fileName = [fileName stringByAppendingString:numStr];
    return fileName;
}


+ (void)writeOriginalImageToTempWith:(YM_PhotoModel *)model
                           requestId:(void (^)(PHImageRequestID requestId))requestId iCloudRequestId:(void (^)(PHImageRequestID requestId))iCloudRequestId
                             success:(void (^)(void))success
                             failure:(void (^)(void))failure {
    if (model.asset) { // asset有值说明是系统相册里的照片
        if (model.type == YM_PhotoModelMediaType_PhotoGif) {
            // 根据asset获取imageData
            PHImageRequestID request_Id = [self getImageData:model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                if (showLog) NSSLog(@"正在请求下载iCloud");
                if (iCloudRequestId) {
                    iCloudRequestId(cloudRequestId);
                }
            } progressHandler:^(double progress) {
                if (showLog) NSSLog(@"iCloud下载进度 %f ",progress);
            } completion:^(NSData *imageData, UIImageOrientation orientation) {
                // 将imageData 写入临时目录
                if ([imageData writeToFile:model.fullPathToFile atomically:YES]) {
                    if (success) {
                        success();
                    }
                } else {
                    if (failure) {
                        failure();
                    }
                }
            } failed:^(NSDictionary *info) {
                if (failure) {
                    failure();
                }
            }];
            if (requestId) {
                requestId(request_Id);
            }
        }else {
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            CGFloat height = [UIScreen mainScreen].bounds.size.height;
            CGFloat imgWidth = model.imageSize.width;
            CGFloat imgHeight = model.imageSize.height;
            
            CGSize size;
            if (imgHeight > imgWidth / 9 * 17) {
                size = CGSizeMake(width, height);
            }else {
                size = CGSizeMake(model.endImageSize.width * 1.5, model.endImageSize.height * 1.5);
            }
            PHImageRequestID request_Id = [self getHighQualityFormatPhoto:model.asset size:size startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                if (showLog) NSSLog(@"正在请求下载iCloud");
                if (iCloudRequestId) {
                    iCloudRequestId(cloudRequestId);
                }
            } progressHandler:^(double progress) {
                if (showLog) NSSLog(@"iCloud下载进度 %f ",progress);
            } completion:^(UIImage *image) {
                NSData *imageData;
                if (image.imageOrientation != UIImageOrientationUp) {
                    image = [image normalizedImage];
                }
                imageData = UIImageJPEGRepresentation(image, 1.0);
                if ([imageData writeToFile:model.fullPathToFile atomically:YES]) {
                    if (success) {
                        success();
                    }
                } else {
                    if (failure) {
                        failure();
                    }
                }
            } failed:^(NSDictionary *info) {
                if (failure) {
                    failure();
                }
            }];
            if (requestId) {
                requestId(request_Id);
            }
        }
    }else {
        NSData *imageData;
        imageData = UIImageJPEGRepresentation(model.previewPhoto, 0.8);
        if ([imageData writeToFile:model.fullPathToFile atomically:YES]) {
            if (success) {
                success();
            }
        }else {
            if (failure) {
                failure();
            }
        }
    }
}
+ (AVAssetExportSession *)compressedVideoWithMediumQualityWriteToTemp:(id)obj pathFile:(NSString *)pathFile progress:(void (^)(float progress))progress success:(void (^)(void))success failure:(void (^)(void))failure {
    AVAsset *avAsset;
    if ([obj isKindOfClass:[AVAsset class]]) {
        avAsset = (AVAsset *)obj;
    }else if ([obj isKindOfClass:[NSURL class]]){
        avAsset = [AVURLAsset URLAssetWithURL:(NSURL *)obj options:nil];
    }else {
        if (failure) {
            failure();
        }
        return nil;
    }
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = [NSURL fileURLWithPath:pathFile];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                if (success) {
                    success();
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

/**
 将选中的图片写入本地
 @param selectList  选中的图片
 @param requestList 保存后返回的操作标识符
 @param completion  完成回调
 @param error       错误回调
 */
+ (void)selectListWriteToTempPath:(NSArray <YM_PhotoModel *> *)selectList
                      requestList:(Save_Image_Block)requestList
                       completion:(Complete_Block12)completion
                            error:(void (^)(void))error {
    if (selectList.count == 0) {
        if (showLog) NSSLog(@"请选择后再写入");
        if (error) {
            error();
        }
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *allUrl = [NSMutableArray array];
        NSMutableArray *imageUrls = [NSMutableArray array];
        NSMutableArray *videoUrls = [NSMutableArray array];
        for (YM_PhotoModel *photoModel in selectList) {
            if (photoModel.subType == YM_PhotoModelMediaSubType_Photo) {
                NSString *suffix;
                if (photoModel.asset) {
                    if (photoModel.type == YM_PhotoModelMediaType_PhotoGif) {
                        suffix = @"gif";
                    }else if ([[photoModel.asset valueForKey:@"filename"] hasSuffix:@"JPG"]) {
                        suffix = @"jpeg";
                    }else {
                        suffix = @"png";
                    }
                }else {
                    if (!photoModel.previewPhoto) {
                        photoModel.previewPhoto = photoModel.thumbPhoto;
                    }
                    if (UIImagePNGRepresentation(photoModel.previewPhoto)) {
                        suffix = @"png";
                    }else {
                        suffix = @"jpeg";
                    }
                }
                NSString *fileName = [[self uploadFileName] stringByAppendingString:[NSString stringWithFormat:@".%@",suffix]];
                NSString *fullPathToFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                photoModel.fullPathToFile = fullPathToFile;
                [imageUrls addObject:[NSURL fileURLWithPath:fullPathToFile]];
                [allUrl addObject:[NSURL fileURLWithPath:fullPathToFile]];
            }else {
                NSString *fileName = [[self uploadFileName] stringByAppendingString:@".mp4"];
                NSString *fullPathToFile = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                photoModel.fullPathToFile = fullPathToFile;
                [videoUrls addObject:[NSURL fileURLWithPath:fullPathToFile]];
                [allUrl addObject:[NSURL fileURLWithPath:fullPathToFile]];
            }
        }
        __block NSInteger i = 0 ,k = 0 , j = 0;
        __block NSInteger imageCount = imageUrls.count , videoCount = videoUrls.count , count = selectList.count , requestIndex = 0;
        __block BOOL writeError = NO;
        __block NSMutableArray *requestIds = [NSMutableArray array];
        __block NSMutableArray *videoSessions = [NSMutableArray array];
        for (YM_PhotoModel *photoModel in selectList) {
            if (writeError) {
                break;
            }
            if (photoModel.subType == YM_PhotoModelMediaSubType_Photo) {
                [self writeOriginalImageToTempWith:photoModel requestId:^(PHImageRequestID requestId) {
                    requestIndex++;
                    [requestIds addObject:@(requestId)];
                    if (requestIndex >= count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (requestList) {
                                requestList(requestIds,videoSessions);
                            }
                        });
                    }
                } iCloudRequestId:^(PHImageRequestID requestId) {
                    [requestIds addObject:@(requestId)];
                    if (requestIndex >= count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (requestList) {
                                requestList(requestIds,videoSessions);
                            }
                        });
                    }
                } success:^{
                    i++;
                    k++;
                    if (k == imageCount && !writeError) {
                        if (showLog) NSSLog(@"图片写入成功");
                    }
                    if (i == count && !writeError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(allUrl,imageUrls,videoUrls);
                            }
                        });
                    }
                } failure:^{
                    if (!writeError) {
                        writeError = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (error) {
                                error();
                            }
                        });
                    }
                }];
            } else {
                if (photoModel.asset) {
                    PHImageRequestID requestId = [self getAVAssetWithModel:photoModel startRequestIcloud:^(PHImageRequestID cloudRequestId, YM_PhotoModel *model) {
                        [requestIds addObject:@(cloudRequestId)];
                        if (requestIndex >= count) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (requestList) {
                                    requestList(requestIds,videoSessions);
                                }
                            });
                        }
                    } progressHandler:^(YM_PhotoModel *model, double progress) {
                        
                    } completion:^(YM_PhotoModel *model, AVAsset *asset) {
                        AVAssetExportSession * session = [self compressedVideoWithMediumQualityWriteToTemp:asset pathFile:model.fullPathToFile progress:^(float progress) {
                            
                        } success:^{
                            i++;
                            j++;
                            if (j == videoCount && !writeError) {
                                if (showLog) NSSLog(@"视频写入成功");
                            }
                            if (i == count && !writeError) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (completion) {
                                        completion(allUrl,imageUrls,videoUrls);
                                    }
                                });
                            }
                        } failure:^{
                            if (!writeError) {
                                writeError = YES;
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (error) {
                                        error();
                                    }
                                });
                            }
                        }];
                        requestIndex++;
                        if (session) {
                            [videoSessions addObject:session];
                        }
                        
                        if (requestIndex >= count) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (requestList) {
                                    requestList(requestIds,videoSessions);
                                }
                            });
                        }
                    } failed:^(YM_PhotoModel *model, NSDictionary *info) {
                        if (!writeError) {
                            writeError = YES;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (error) {
                                    error();
                                }
                            });
                        }
                    }];
                    requestIndex++;
                    [requestIds addObject:@(requestId)];
                    if (requestIndex >= count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (requestList) {
                                requestList(requestIds,videoSessions);
                            }
                        });
                    }
                }else {
                    AVAssetExportSession * session = [self compressedVideoWithMediumQualityWriteToTemp:photoModel.videoURL pathFile:photoModel.fullPathToFile progress:^(float progress) {
                        
                    } success:^{
                        i++;
                        j++;
                        if (j == videoCount && !writeError) {
                            if (showLog) NSSLog(@"视频写入成功");
                        }
                        if (i == count && !writeError) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (completion) {
                                    completion(allUrl,imageUrls,videoUrls);
                                }
                            });
                        }
                    } failure:^{
                        if (!writeError) {
                            writeError = YES;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (error) {
                                    error();
                                }
                            });
                        }
                    }];
                    requestIndex++;
                    if (session) {
                        [videoSessions addObject:session];
                    }
                    
                    if (requestIndex >= count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (requestList) {
                                requestList(requestIds,videoSessions);
                            }
                        });
                    }
                }
            }
        }
    });
}

#pragma mark - 数据格式化、获取等
/**
 格式化视频时长
 @param duration 视屏时长
 @return 格式化后的时长
 */
+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"00:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"00:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

/**
 相册名称转换
 @param englishName 相册名
 @return 转换后的相册名
 */
+ (NSString *)transFormPhotoTitle:(NSString *)englishName {
    NSString *photoName;
    if ([englishName isEqualToString:@"Bursts"]) {
        photoName = @"连拍快照";
    }else if([englishName isEqualToString:@"Recently Added"] ||
             [englishName isEqualToString:@"最後に追加した項目"] ||
             [englishName isEqualToString:@"최근 추가된 항목"] ){
        photoName = @"最近添加";
    }else if([englishName isEqualToString:@"Screenshots"] ||
             [englishName isEqualToString:@"スクリーンショット"] ||
             [englishName isEqualToString:@"스크린샷"] ){
        photoName = @"屏幕快照";
    }else if([englishName isEqualToString:@"Camera Roll"] ||
             [englishName isEqualToString:@"カメラロール"] ||
             [englishName isEqualToString:@"카메라 롤"] ){
        photoName = @"相机胶卷";
    }else if([englishName isEqualToString:@"Selfies"] ||
             [englishName isEqualToString:@"셀카"] ){
        photoName = @"自拍";
    }else if([englishName isEqualToString:@"My Photo Stream"]){
        photoName = @"我的照片流";
    }else if([englishName isEqualToString:@"Videos"] ||
             [englishName isEqualToString:@"ビデオ"] ){
        photoName = @"视频";
    }else if([englishName isEqualToString:@"All Photos"] ||
             [englishName isEqualToString:@"すべての写真"] ||
             [englishName isEqualToString:@"비디오"] ){
        photoName = @"所有照片";
    }else if([englishName isEqualToString:@"Slo-mo"] ||
             [englishName isEqualToString:@"スローモーション"] ){
        photoName = @"慢动作";
    }else if([englishName isEqualToString:@"Recently Deleted"] ||
             [englishName isEqualToString:@"最近削除した項目"] ){
        photoName = @"最近删除";
    }else if([englishName isEqualToString:@"Favorites"] ||
             [englishName isEqualToString:@"お気に入り"] ||
             [englishName isEqualToString:@"최근 삭제된 항목"] ){
        photoName = @"个人收藏";
    }else if([englishName isEqualToString:@"Panoramas"] ||
             [englishName isEqualToString:@"パノラマ"] ||
             [englishName isEqualToString:@"파노라마"] ){
        photoName = @"全景照片";
    }else {
        photoName = englishName;
    }
    return photoName;
}

/**
 获取数组里面图片的大小（多次回调）
 @param photos      图片模型
 @param completion  数据回调（返回图片大小）
 */
+ (void)FetchPhotosBytes:(NSArray <YM_PhotoModel *> *)photos
              completion:(void (^)(NSString *totalBytes))completion {
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0 ; i < photos.count ; i++) {
            YM_PhotoModel *model = photos[i];
            if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
                NSData *imageData;
                if (UIImagePNGRepresentation(model.thumbPhoto)) {
                    //返回为png图像。
                    imageData = UIImagePNGRepresentation(model.thumbPhoto);
                }else {
                    //返回为JPEG图像。
                    imageData = UIImageJPEGRepresentation(model.thumbPhoto, 1.0);
                }
                dataLength += imageData.length;
                assetCount ++;
                if (assetCount >= photos.count) {
                    NSString *bytes = [self getBytesFromDataLength:dataLength];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) completion(bytes);
                    });
                }
            }else {
                [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    dataLength += imageData.length;
                    assetCount ++;
                    if (assetCount >= photos.count) {
                        NSString *bytes = [self getBytesFromDataLength:dataLength];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(bytes);
                        });
                    }
                }];
            }
        }
    });
}

/**
 获取指定字符串的宽度
 @param text        需要计算的字符串
 @param height      高度大小
 @param fontSize    字体大小
 @return 宽度大小
 */
+ (CGFloat)getTextWidth:(NSString *)text
                 height:(CGFloat)height
               fontSize:(CGFloat)fontSize {
    CGSize newSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    
    return newSize.width;
}

/**
 获取指定字符串的高度
 @param text        需要计算的字符串
 @param width       宽度大小
 @param fontSize    字体大小
 @return 高度大小
 */
+ (CGFloat)getTextHeight:(NSString *)text
                   width:(CGFloat)width
                fontSize:(CGFloat)fontSize {
    CGSize newSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    
    return newSize.height;
}

/** 判断是否为iPhone的屏幕尺寸 */
+ (BOOL)isIphone6 {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if([platform isEqualToString:@"iPhone7,1"]){
        return YES;
    }
    if([platform isEqualToString:@"iPhone7,2"]) {
        return YES;
    }
    if ([platform isEqualToString:@"iPhone8,1"]) {
        return YES;
    }
    return NO;
}


#pragma mark - private
+ (BOOL)platform {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    BOOL have = NO;
    if ([platform isEqualToString:@"iPhone8,1"]) { // iphone6s
        have = YES;
    }else if ([platform isEqualToString:@"iPhone8,2"]) { // iphone6s plus
        have = YES;
    }else if ([platform isEqualToString:@"iPhone9,1"]) { // iphone7
        have = YES;
    }else if ([platform isEqualToString:@"iPhone9,2"]) { // iphone7 plus
        have = YES;
    }else if ([platform isEqualToString:@"iPhone10,1"]) { // iphone7 plus
        have = YES;
    }else if ([platform isEqualToString:@"iPhone10,2"]) { // iphone7 plus
        have = YES;
    }else if ([platform isEqualToString:@"iPhone10,3"]) { // iphone7 plus
        have = YES;
    }else if ([platform isEqualToString:@"iPhone10,4"]) { // iphone7 plus
        have = YES;
    }else if ([platform isEqualToString:@"iPhone10,5"]) { // iphone7 plus
        have = YES;
    }else if ([platform isEqualToString:@"iPhone10,6"]) { // iphone7 plus
        have = YES;
    }
    return have;
}

@end
