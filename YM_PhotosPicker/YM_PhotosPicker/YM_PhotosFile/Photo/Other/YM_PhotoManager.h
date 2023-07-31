//
//  YM_PhotoManager.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/3.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "YM_AlbumModel.h"
#import "YM_PhotoModel.h"
#import "YM_PhotoTools.h"
#import "YM_PhotoConfiguration.h"
#import "YM_CustomAssetModel.h"

/** 照片选择器的管理类, 使用照片选择器时必须先懒加载此类,然后赋值给对应的对象 */
typedef NS_ENUM(NSUInteger, YM_PhotoManagerType) {
    YM_PhotoManagerType_Photo = 0,        //!< 只显示图片
    YM_PhotoManagerType_Video = 1,        //!< 只显示视频
    YM_PhotoManagerType_All               //!< 图片和视频一起显示
};

/** 视屏的选择按钮显示风格 */
typedef NS_ENUM(NSUInteger, YM_PhotoManagerVideoSelectedType) {
    YM_PhotoManagerVideoSelectedType_Normal = 0,  //!< 普通状态显示选择按钮
    YM_PhotoManagerVideoSelectedType_Single       //!< 单选不显示选择按钮
};


/** 相片管理类 */
@interface YM_PhotoManager : NSObject

/**
 初始化
 @param type 内容类型
 @return YM_PhotoManager
 */
- (instancetype)initWithType:(YM_PhotoManagerType)type;

/** 照片选择器所要显示的内容类型 */
@property (assign, nonatomic) YM_PhotoManagerType type;

/** 视屏的选择按钮显示风格 */
@property (assign, nonatomic) YM_PhotoManagerVideoSelectedType videoSelectedType;

/** 配置信息 */
@property (strong, nonatomic) YM_PhotoConfiguration * configuration;

/**
 添加模型数组
 @param modelArray ...
 */
- (void)addModelArray:(NSArray<YM_PhotoModel *> *)modelArray;


/**
 添加自定义资源模型
 如果图片/视频 选中的数量超过最大选择数时,之后选中的会变为未选中
 如果设置的图片/视频不能同时选择时
 图片在视频前面的话只会将图片添加到已选数组.
 视频在图片前面的话只会将视频添加到已选数组.
 如果 type = YM_PhotoManagerType_Photo 时 会过滤掉视频
 如果 type = YM_PhotoManagerType_Video 时 会过滤掉图片
 
 @param assetArray 模型数组
 */
- (void)addCustomAssetModel:(NSArray<YM_CustomAssetModel *> *)assetArray;

/**
 添加本地视频数组   内部会将  deleteTemporaryPhoto 设置为NO
 
 @param urlArray <NSURL *> 本地视频地址
 @param selected 是否选中   选中的话YM_PhotoView自动添加显示 没选中可以在相册里手动选中
 */
- (void)addLocalVideo:(NSArray<NSURL *> *)urlArray selected:(BOOL)selected;

/**
 *  本地图片数组 <UIImage *> 装的是UIImage对象 - 已设置为选中状态
 */
@property (copy, nonatomic) NSArray *localImageList;

/**
 添加本地图片数组  内部会将  deleteTemporaryPhoto 设置为NO
 
 @param images <UIImage *> 装的是UIImage对象
 @param selected 是否选中   选中的话YM_PhotoView自动添加显示 没选中可以在相册里手动选中
 */
- (void)addLocalImage:(NSArray *)images selected:(BOOL)selected;

/**
 将本地图片添加到相册中  内部会将  configuration.deleteTemporaryPhoto 设置为NO
 
 @param images <UIImage *> 装的是UIImage对象
 */
- (void)addLocalImageToAlbumWithImages:(NSArray *)images;

/**
 添加网络图片数组
 
 @param imageUrls 图片地址  NSString*
 @param selected 是否选中
 */
- (void)addNetworkingImageToAlbum:(NSArray<NSString *> *)imageUrls selected:(BOOL)selected;

/**
 相册列表
 */
@property (strong, nonatomic,readonly) NSMutableArray *albums;

/**
 网络图片地址数组
 */
@property (strong, nonatomic) NSArray<NSString *> *networkPhotoUrls;

/**
 源对象信息
 */
@property (strong, nonatomic) id sourceObject;

/**
 获取系统所有相册
 @param firstModel 第一个相册模型
 @param albums     所有相册模型
 @param isFirst    是否第一次加载
 */
- (void)getAllPhotoAlbums:(void(^)(YM_AlbumModel *firstAlbumModel))firstModel
                   albums:(void(^)(NSArray *albums))albums
                  isFirst:(BOOL)isFirst;

/**
 根据某个相册模型获取照片列表
 
 @param albumModel 相册模型
 @param complete 照片列表和首个选中的模型
 */
- (void)getPhotoListWithAlbumModel:(YM_AlbumModel *)albumModel complete:(void (^)(NSArray *allList , NSArray *previewList,NSArray *photoList ,NSArray *videoList ,NSArray *dateList , YM_PhotoModel *firstSelectModel))complete;

/**
 将下载完成的iCloud上的资源模型添加到数组中
 */
- (void)addICloudModel:(YM_PhotoModel *)model;

/**
 判断最大值
 */
- (NSString *)maximumOfJudgment:(YM_PhotoModel *)model;

- (BOOL)videoCanSelected;

/**  关于选择完成之前的一些方法  **/
/**
 完成之前选择的总数量
 */
- (NSInteger)selectedCount;
/**
 完成之前选择的照片数量
 */
- (NSInteger)selectedPhotoCount;
/**
 完成之前选择的视频数量
 */
- (NSInteger)selectedVideoCount;
/**
 完成之前选择的所有数组
 */
- (NSArray *)selectedArray;
/**
 完成之前选择的照片数组
 */
- (NSArray *)selectedPhotoArray;
/**
 完成之前选择的视频数组
 */
- (NSArray *)selectedVideoArray;
/**
 完成之前是否原图
 */
- (BOOL)original;
/**
 完成之前设置是否原图
 */
- (void)setOriginal:(BOOL)original;
/**
 完成之前的照片数组是否达到最大数
 @return yes or no
 */
- (BOOL)beforeSelectPhotoCountIsMaximum;
/**
 完成之前的视频数组是否达到最大数
 @return yes or no
 */
- (BOOL)beforeSelectVideoCountIsMaximum;
/**
 完成之前从已选数组中删除某个模型
 */
- (void)beforeSelectedListdeletePhotoModel:(YM_PhotoModel *)model;
/**
 完成之前添加某个模型到已选数组中
 */
- (void)beforeSelectedListAddPhotoModel:(YM_PhotoModel *)model;
/**
 完成之前添加编辑之后的模型到已选数组中
 */
- (void)beforeSelectedListAddEditPhotoModel:(YM_PhotoModel *)model;
/**
 完成之前将拍摄之后的模型添加到已选数组中
 */
- (void)beforeListAddCameraTakePicturesModel:(YM_PhotoModel *)model;

/*--  关于选择完成之后的一些方法  --*/
/**
 完成之后选择的总数是否达到最大
 */
- (BOOL)afterSelectCountIsMaximum;
/**
 完成之后选择的照片数是否达到最大
 */
- (BOOL)afterSelectPhotoCountIsMaximum;
/**
 完成之后选择的视频数是否达到最大
 */
- (BOOL)afterSelectVideoCountIsMaximum;
/**
 完成之后选择的总数
 */
- (NSInteger)afterSelectedCount;
/**
 完成之后选择的所有数组
 */
- (NSArray *)afterSelectedArray;
/**
 完成之后选择的照片数组
 */
- (NSArray *)afterSelectedPhotoArray;
/**
 完成之后选择的视频数组
 */
- (NSArray *)afterSelectedVideoArray;
/**
 设置完成之后选择的照片数组
 */
- (void)setAfterSelectedPhotoArray:(NSArray *)array;
/**
 设置完成之后选择的视频数组
 */
- (void)setAfterSelectedVideoArray:(NSArray *)array;
/**
 完成之后是否原图
 */
- (BOOL)afterOriginal;
/**
 交换完成之后的两个模型在已选数组里的位置
 */
- (void)afterSelectedArraySwapPlacesWithFromModel:(YM_PhotoModel *)fromModel fromIndex:(NSInteger)fromIndex toModel:(YM_PhotoModel *)toModel toIndex:(NSInteger)toIndex;
/**
 替换完成之后的模型
 */
- (void)afterSelectedArrayReplaceModelAtModel:(YM_PhotoModel *)atModel withModel:(YM_PhotoModel *)model;
/**
 完成之后添加编辑之后的模型到数组中
 */
- (void)afterSelectedListAddEditPhotoModel:(YM_PhotoModel *)model;
/**
 完成之后将拍摄之后的模型添加到已选数组中
 */
- (void)afterListAddCameraTakePicturesModel:(YM_PhotoModel *)model;
/**
 完成之后从已选数组中删除指定模型
 */
- (void)afterSelectedListdeletePhotoModel:(YM_PhotoModel *)model;
/**
 完成之后添加某个模型到已选数组中
 */
- (void)afterSelectedListAddPhotoModel:(YM_PhotoModel *)model;



- (void)selectedListTransformAfter;
- (void)selectedListTransformBefore;

/**
 取消选择
 */
- (void)cancelBeforeSelectedList;

/**
 清空所有已选数组
 */
- (void)clearSelectedList;

/**  cell上添加photoView时所需要用到的方法  */
- (void)changeAfterCameraArray:(NSArray *)array;
- (void)changeAfterCameraPhotoArray:(NSArray *)array;
- (void)changeAfterCameraVideoArray:(NSArray *)array;
- (void)changeAfterSelectedCameraArray:(NSArray *)array;
- (void)changeAfterSelectedCameraPhotoArray:(NSArray *)array;
- (void)changeAfterSelectedCameraVideoArray:(NSArray *)array;
- (void)changeAfterSelectedArray:(NSArray *)array;
- (void)changeAfterSelectedPhotoArray:(NSArray *)array;
- (void)changeAfterSelectedVideoArray:(NSArray *)array;
- (void)changeICloudUploadArray:(NSArray *)array;
- (NSArray *)afterCameraArray;
- (NSArray *)afterCameraPhotoArray;
- (NSArray *)afterCameraVideoArray;
- (NSArray *)afterSelectedCameraArray;
- (NSArray *)afterSelectedCameraPhotoArray;
- (NSArray *)afterSelectedCameraVideoArray;
- (NSArray *)afterICloudUploadArray;

- (NSString *)version;


@end
