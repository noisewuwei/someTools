//
//  YM_PhotoModel.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/3.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    YM_PhotoModelMediaType_Photo          = 0,    //!< 照片
    YM_PhotoModelMediaType_LivePhoto      = 1,    //!< LivePhoto
    YM_PhotoModelMediaType_PhotoGif       = 2,    //!< gif图
    YM_PhotoModelMediaType_Video          = 3,    //!< 视频
    YM_PhotoModelMediaType_Audio          = 4,    //!< 预留
    YM_PhotoModelMediaType_CameraPhoto    = 5,    //!< 通过相机拍的照片
    YM_PhotoModelMediaType_CameraVideo    = 6,    //!< 通过相机录制的视频
    YM_PhotoModelMediaType_Camera         = 7     //!< 跳转相机
} YM_PhotoModelMediaType;

typedef enum : NSUInteger {
    YM_PhotoModelMediaSubType_Photo = 0,  //!< 照片
    YM_PhotoModelMediaSubType_Video       //!< 视频
} YM_PhotoModelMediaSubType;

typedef enum : NSUInteger {
    YM_PhotoModelVideoStateNormal = 0,   //!< 普通状态
    YM_PhotoModelVideoStateUndersize,    //!< 视频时长小于3秒
    YM_PhotoModelVideoStateOversize      //!< 视频时长超出限制
} YM_PhotoModelVideoState;

@class YM_PhotoManager;

@interface YM_PhotoModel : NSObject

/**
 文件在手机里的原路径(照片 或 视频)
 
 - 如果是通过相机拍摄的并且没有保存到相册(临时的) 视频有值, 照片没有值
 */
@property (strong, nonatomic) NSURL *fileURL;
/**
 创建日期
 
 - 如果是通过相机拍摄的并且没有保存到相册(临时的) 为当前时间([NSDate date])
 */
@property (strong, nonatomic) NSDate *creationDate;
/**
 修改日期
 
 - 如果是通过相机拍摄的并且没有保存到相册(临时的) 为当前时间([NSDate date])
 */
@property (strong, nonatomic) NSDate *modificationDate;
/**
 位置信息 NSData 对象
 
 - 如果是通过相机拍摄的并且没有保存到相册(临时的) 没有值
 */
@property (strong, nonatomic) NSData *locationData;
/**
 位置信息 CLLocation 对象
 */
@property (strong, nonatomic) CLLocation *location;

/**  是否正在下载iCloud上的资源  */
@property (assign, nonatomic) BOOL iCloudDownloading;
/**  iCloud下载进度  */
@property (assign, nonatomic) CGFloat iCloudProgress;
/**  下载iCloud的请求id  */
@property (assign, nonatomic) PHImageRequestID iCloudRequestID;
/**  预览界面导航栏上的大标题  */
@property (copy, nonatomic) NSString *barTitle;
/**  预览界面导航栏上的小标题  */
@property (copy, nonatomic) NSString *barSubTitle;
/**  照片PHAsset对象  */
@property (strong, nonatomic) PHAsset *asset;
/**  视频AVAsset对象  */
@property (strong, nonatomic) AVAsset *avAsset;
/**  PHAsset对象唯一标示  */
@property (copy, nonatomic) NSString *localIdentifier;
/**  是否iCloud上的资源  */
@property (nonatomic, assign) BOOL isICloud;
/**  照片类型  */
@property (assign, nonatomic) YM_PhotoModelMediaType type;
/**  照片子类型  */
@property (assign, nonatomic) YM_PhotoModelMediaSubType subType;
/**  临时的列表小图  */
@property (strong, nonatomic) UIImage *thumbPhoto;
/**  临时的预览大图  */
@property (strong, nonatomic) UIImage *previewPhoto;
/**  当前照片所在相册的名称 */
@property (copy, nonatomic) NSString *albumName;
/**  视频时长 */
@property (copy, nonatomic) NSString *videoTime;
/**  相机拍摄之后的视频秒数 */
@property (nonatomic, assign) NSTimeInterval videoDuration;
/**  选择的下标 */
@property (assign, nonatomic) NSInteger selectedIndex;
/**  模型对应的Section */
@property (assign, nonatomic) NSInteger dateSection;
/**  模型对应的item */
@property (assign, nonatomic) NSInteger dateItem;
/**  cell是否显示过 */
@property (assign, nonatomic) BOOL dateCellIsVisible;
/**  是否选中 */
@property (assign, nonatomic) BOOL selected;
/**  模型所对应的选中下标 */
@property (copy, nonatomic) NSString *selectIndexStr;
/**  照片原始宽高 */
@property (assign, nonatomic) CGSize imageSize;
/**  预览界面按比例缩小之后的宽高 */
@property (assign, nonatomic) CGSize endImageSize;
/**  预览界面按比例缩小之后的宽高 */
@property (assign, nonatomic) CGSize endDateImageSize;
/**  3dTouch按比例缩小之后的宽高 */
@property (assign, nonatomic) CGSize previewViewSize;
/**  预览界面底部cell按比例缩小之后的宽高 */
@property (assign, nonatomic) CGSize dateBottomImageSize;
/**  拍照之后的唯一标示 */
@property (copy, nonatomic) NSString *cameraIdentifier;
/**  通过相机摄像的视频URL */
@property (strong, nonatomic) NSURL *videoURL;
/**  网络图片的地址 */
@property (copy, nonatomic) NSURL *networkPhotoUrl;
/**  当前图片所在相册的下标 */
@property (assign, nonatomic) NSInteger currentAlbumIndex;
/**  网络图片已下载的大小 */
@property (assign, nonatomic) NSInteger receivedSize;
/**  网络图片总的大小 */
@property (assign, nonatomic) NSInteger expectedSize;
/**  网络图片是否下载完成 */
@property (assign, nonatomic) BOOL downloadComplete;
/**  网络图片是否下载错误 */
@property (assign, nonatomic) BOOL downloadError;
/**  临时图片 */
@property (strong, nonatomic) UIImage *tempImage;
/**  行数 */
@property (assign, nonatomic) NSInteger rowCount;
/**  照片列表请求的资源的大小 */
@property (assign, nonatomic) CGSize requestSize;
/**
 小图照片清晰度 越大越清晰、越消耗性能。太大可能会引起界面卡顿
 默认设置：[UIScreen mainScreen].bounds.size.width
 320    ->  0.8
 375    ->  1.4
 other  ->  1.7
 */
@property (assign, nonatomic) CGFloat clarityScale;
/**  如果当前为视频资源时是禁止选择  */
@property (assign, nonatomic) BOOL videoUnableSelect;
/**  是否隐藏选择按钮  */
@property (assign, nonatomic) BOOL needHideSelectBtn;

/**  如果当前为视频资源时的视频状态  */
@property (assign, nonatomic) YM_PhotoModelVideoState videoState;

@property (strong, nonatomic) NSData *gifImageData;
@property (copy, nonatomic) NSString *fullPathToFile;;
@property (strong, nonatomic) YM_PhotoManager *photoManager;

/**  通过image初始化 */
+ (instancetype)photoModelWithImage:(UIImage *)image;
/**  通过视频地址和视频时长初始化 */
+ (instancetype)photoModelWithVideoURL:(NSURL *)videoURL videoTime:(NSTimeInterval)videoTime;
/**  通过PHAsset对象初始化 */
+ (instancetype)photoModelWithPHAsset:(PHAsset *)asset;
/**  通过网络图片URL对象初始化 */
+ (instancetype)photoModelWithImageURL:(NSURL *)imageURL;
/**  通过本地视频地址URL对象初始化 */
+ (instancetype)photoModelWithVideoURL:(NSURL *)videoURL;
@end

