//
//  YM_PhotoTools.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "YM_PhotoModel.h"
#import "YM_AlbumModel.h"
#import "UIView+YM_Extension.h"
#import "NSBundle+YM_PhotoPicker.h"
#import "NSDate+YM_Extension.h"
#import "UIFont+YM_Extension.h"
#import <CoreLocation/CoreLocation.h>
#import "YM_PhotoDefine.h"

@class YM_PhotoManager;
@class YM_PhotoDateModel;

/** 请求iCloud回调 */
typedef void(^Start_Request_iCloud_Block1)(PHImageRequestID cloudRequestId);
typedef void(^Start_Request_iCloud_Block2)(PHImageRequestID cloudRequestId, YM_PhotoModel *model);
typedef void(^Start_Request_iCloud_Block3)(YM_PhotoModel *model, PHImageRequestID iCloudRequestId);


/** 进度回调 */
typedef void(^Progress_Handler_Block)(YM_PhotoModel *model, double progress);

/** 完成回调 */
typedef void(^Complete_Block1)(NSArray<YM_PhotoModel *> *modelArray);
typedef void(^Complete_Block2)(YM_PhotoModel *model, NSData *imageData, UIImageOrientation orientation);
typedef void(^Complete_Block3)(CLPlacemark *placemark,YM_PhotoDateModel *model);
typedef void(^Complete_Block4)(UIImage *image,NSDictionary *info);
typedef void(^Complete_Block5)(UIImage *image, YM_PhotoModel *model);
typedef void(^Complete_Block6)(UIImage *image, YM_AlbumModel *model);
typedef void(^Complete_Block7)(AVAssetExportSession * exportSession, NSDictionary *info);
typedef void(^Complete_Block8)(NSData *imageData, UIImageOrientation orientation);
typedef void(^Complete_Block9)(YM_PhotoModel *model, AVAsset *asset);
typedef void(^Complete_Block10)(YM_PhotoModel *model, PHLivePhoto *livePhoto);
typedef void(^Complete_Block11)(AVAsset *asset, NSArray<UIImage *> *images);
typedef void(^Complete_Block12)(NSArray<NSURL *> *allUrl, NSArray<NSURL *> *imageUrls, NSArray<NSURL *> *videoUrls);

typedef void(^Save_Image_Block)(NSArray *imageRequestIds, NSArray *videoSessions);


/** 错误回调 */
typedef void(^Failed_Block1)(YM_PhotoModel *model, NSDictionary *info);


@interface YM_PhotoTools : NSObject

/**
 获取bundle文件中的图片
 @param imageName 图片名
 @return UIImage图片
 */
+ (UIImage *)ym_imageNamed:(NSString *)imageName;

/**
 保存模型数组到本地
 @param manager 照片管理者
 @param success 成功
 @param failed  失败
 */
+ (void)saveSelectModelArrayWithManager:(YM_PhotoManager *)manager
                                success:(void (^)(void))success
                                 failed:(void (^)(void))failed;

/**
 删除本地保存的模型数组
 @param manager 照片管理者
 @return 删除结果
 */
+ (BOOL)deleteLocalSelectModelArrayWithManager:(YM_PhotoManager *)manager;

/**
 获取本地保存的模型数组
 @param manager   相片管理者
 @param complete  成功回调
 */
+ (void)getSelectedModelArrayWithManager:(YM_PhotoManager *)manager
                                complete:(Complete_Block1)complete;

/**
 保存模型数组到本地
 @param modelArray 要保存的模型数组
 @param fileName   文件名
 @return 保存结果
 */
+ (BOOL)saveSelectModelArray:(NSArray<YM_PhotoModel *> *)modelArray
                    fileName:(NSString *)fileName;

/**
 获取保存在本地的模型数组
 @param fileName 文件名
 @return 模型数组
 */
+ (NSArray<YM_PhotoModel *> *)getSelectedModelArrayWithFileName:(NSString *)fileName;

/**
 删除保存在本地的模型数组
 @param fileName 文件名
 @return 模型数组
 */
+ (BOOL)deleteSelectModelArrayWithFileName:(NSString *)fileName;

/**
 保存本地视频到系统相册和自定义相册
 @param albumName 自定义相册名称
 @param videoURL  本地视频地址
 */
+ (void)saveVideoToCustomAlbumWithName:(NSString *)albumName
                              videoURL:(NSURL *)videoURL;

/**
 保存图片到系统相册和自定义相册
 @param albumName 自定义相册名称
 @param photo uiimage
 */
+ (void)savePhotoToCustomAlbumWithName:(NSString *)albumName
                                 photo:(UIImage *)photo;

/**
 获取相片中的反地理编码
 @param model       相片模型
 @param completion  成功回调
 @return 反地理编码
 */
+ (CLGeocoder *)getDateLocationDetailInformationWithModel:(YM_PhotoDateModel *)model
                                               completion:(Complete_Block3)completion;

/**
 根据PHAsset对象获取照片信息（此方法会回调多次）
 @param asset      指定相片
 @param size       指定相片的尺寸（option.resizeMode = PHImageRequestOptionsResizeModeFast时有效）
 @param completion 完成回调
 @return PHImageRequestID
 */
+ (PHImageRequestID)getPhotoForPHAsset:(PHAsset *)asset
                                  size:(CGSize)size
                            completion:(Complete_Block4)completion;

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
                                                  error:(void(^)(NSDictionary *info))error;

/**
 根据模型获取image
 @param model      相片模型
 @param completion 完成后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getImageWithModel:(YM_PhotoModel *)model
                           completion:(Complete_Block5)completion;

/**
 根据模型获取指定大小的image(成功回调可能会执行多次)
 @param model       相片模型
 @param size        相片大小
 @param completion  完成后的block
 @return PHImageRequestID
 */
+ (PHImageRequestID)getImageWithAlbumModel:(YM_AlbumModel *)model
                                      size:(CGSize)size
                                completion:(Complete_Block6)completion;

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
                                completion:(Complete_Block6)completion;

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
                                      failed:(void(^)(NSDictionary *info))failed;

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
                                   failed:(void(^)(NSDictionary *info))failed;

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
                                         failed:(void(^)(NSDictionary *info))failed;

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
                                                failed:(void(^)(NSDictionary *info))failed;

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
                                              failed:(void(^)(NSDictionary *info))failed;

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
                                       failed:(void(^)(void))failed;

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
                                       failed:(void(^)(NSDictionary *info))failed;

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
                                  failed:(void(^)(void))failed;

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
                          failed:(void(^)(NSDictionary *info))failed;

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
                                 failed:(Failed_Block1)failed;


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
                                   failed:(Failed_Block1)failed;

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
                                   failed:(Failed_Block1)failed;

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
                          complete:(Complete_Block11)complete;

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
                            error:(void (^)(void))error;

#pragma mark - 数据格式化、获取等
/**
 格式化视频时长
 @param duration 视屏时长
 @return 格式化后的时长
 */
+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration;

/**
 相册名称转换
 @param englishName 相册名
 @return 转换后的相册名
 */
+ (NSString *)transFormPhotoTitle:(NSString *)englishName;

/**
 获取数组里面图片的大小（多次回调）
 @param photos      图片模型
 @param completion  数据回调（返回图片大小）
 */
+ (void)FetchPhotosBytes:(NSArray <YM_PhotoModel *> *)photos
              completion:(void (^)(NSString *totalBytes))completion;

/**
 获取指定字符串的宽度
 @param text        需要计算的字符串
 @param height      高度大小
 @param fontSize    字体大小
 @return 宽度大小
 */
+ (CGFloat)getTextWidth:(NSString *)text
                 height:(CGFloat)height
               fontSize:(CGFloat)fontSize;

/**
 获取指定字符串的高度
 @param text        需要计算的字符串
 @param width       宽度大小
 @param fontSize    字体大小
 @return 高度大小
 */
+ (CGFloat)getTextHeight:(NSString *)text
                   width:(CGFloat)width
                fontSize:(CGFloat)fontSize;

/** 判断是否为iPhone的屏幕尺寸 */
+ (BOOL)isIphone6;




@end
