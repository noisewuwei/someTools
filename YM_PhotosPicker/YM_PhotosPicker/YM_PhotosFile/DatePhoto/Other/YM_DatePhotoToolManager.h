//
//  YM_DatePhotoToolManager.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YM_PhotoModel.h"

typedef enum : NSUInteger {
    YM_DatePhotoToolManagerRequestTypeHD = 0, // 高清
    YM_DatePhotoToolManagerRequestTypeOriginal // 原图
} YM_DatePhotoToolManagerRequestType;

typedef void (^ YM_DatePhotoToolManagerSuccessHandler)(NSArray<NSURL *> *allURL,NSArray<NSURL *> *photoURL, NSArray<NSURL *> *videoURL);
typedef void (^ YM_DatePhotoToolManagerFailedHandler)(void);

typedef void (^ YM_DatePhotoToolManagerGetImageListSuccessHandler)(NSArray<UIImage *> *imageList);
typedef void (^ YM_DatePhotoToolManagerGetImageListFailedHandler)(void);

typedef void (^ YM_DatePhotoToolManagerGetImageDataListSuccessHandler)(NSArray<NSData *> *imageDataList);
typedef void (^ YM_DatePhotoToolManagerGetImageDataListFailedHandler)(void);



@interface YM_DatePhotoToolManager : NSObject

/**
 将选择的模型数组写入临时目录 -   HXDatePhotoToolManagerRequestTypeHD
 
 注意!!!!
 如果有网络图片时,对应的URL为该网络图片的地址。顺序下标与网络图片在模型数组的下标一致
 也可以根据 http || https 来判断是否网络图片
 
 @param modelList 模型数组
 @param success 成功回调
 @param failed 失败回调
 */
- (void)writeSelectModelListToTempPathWithList:(NSArray<YM_PhotoModel *> *)modelList
                                       success:(YM_DatePhotoToolManagerSuccessHandler)success
                                        failed:(YM_DatePhotoToolManagerFailedHandler)failed;

/**
 将选择的模型数组写入临时目录
 
 注意!!!!
 如果有网络图片时,对应的URL为该网络图片的地址。顺序下标与网络图片在模型数组的下标一致
 也可以根据 http || https 来判断是否网络图片
 
 @param modelList 模型数组
 @param requestType 请求类型
 @param success 成功回调
 @param failed 失败回调
 */
- (void)writeSelectModelListToTempPathWithList:(NSArray<YM_PhotoModel *> *)modelList
                                   requestType:(YM_DatePhotoToolManagerRequestType)requestType
                                       success:(YM_DatePhotoToolManagerSuccessHandler)success
                                        failed:(YM_DatePhotoToolManagerFailedHandler)failed;

/**
 根据模型数组获取与之对应的image数组   -   HXDatePhotoToolManagerRequestTypeHD
 如果有网络图片时，会先判断是否已经下载完成了，未下载完则重新下载。
 @param modelList 模型数组
 @param success 成功
 @param failed 失败
 */
- (void)getSelectedImageList:(NSArray<YM_PhotoModel *> *)modelList
                     success:(YM_DatePhotoToolManagerGetImageListSuccessHandler)success
                      failed:(YM_DatePhotoToolManagerGetImageListFailedHandler)failed;

/**
 根据模型数组获取与之对应的image数组
 如果有网络图片时，会先判断是否已经下载完成了，未下载完则重新下载。
 @param modelList 模型数组
 @param requestType 请求类型
 @param success 成功回调
 @param failed 失败回调
 */
- (void)getSelectedImageList:(NSArray<YM_PhotoModel *> *)modelList
                 requestType:(YM_DatePhotoToolManagerRequestType)requestType
                     success:(YM_DatePhotoToolManagerGetImageListSuccessHandler)success
                      failed:(YM_DatePhotoToolManagerGetImageListFailedHandler)failed;

/**
 取消获取image
 */
- (void)cancelGetImageList;

/**
 根据模型数组获取与之对应的NSData数组
 如果有网络图片时，会先判断是否已经下载完成了，未下载完则重新下载。
 
 @param modelList 模型数组
 @param success 成功
 @param failed 失败
 */
- (void)getSelectedImageDataList:(NSArray<YM_PhotoModel *> *)modelList
                         success:(YM_DatePhotoToolManagerGetImageDataListSuccessHandler)success
                          failed:(YM_DatePhotoToolManagerGetImageDataListFailedHandler)failed;

- (void)gifModelAssignmentData:(NSArray<YM_PhotoModel *> *)gifModelArray
                       success:(void (^)(void))success
                        failed:(void (^)(void))failed;


@end
