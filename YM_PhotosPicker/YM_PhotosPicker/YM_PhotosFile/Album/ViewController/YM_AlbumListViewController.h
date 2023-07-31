//
//  YM_AlbumListViewController.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_AlbumModel.h"
#import "YM_PhotoManager.h"

@class YM_AlbumListViewController;

/**
 点击完成按钮后的block回调
 @param allList         已选的所有列表(包含照片、视频)
 @param photoList       已选的照片列表
 @param videoList       已选的视频列表
 @param imageList       缩略图数组
 @param original        是否为原图
 @param viewController  self
 */
typedef void (^YM_AlbumListVCDoneBlock)(
NSArray<YM_PhotoModel *> *allList,
NSArray<YM_PhotoModel *> *photoList,
NSArray<YM_PhotoModel *> *videoList,
NSArray<UIImage *> *imageList,
BOOL original,
YM_AlbumListViewController *viewController);

/**
 点击取消按钮后的block回调
 @param viewController self
 */
typedef void (^YM_AlbumListVCCancelBlock)(YM_AlbumListViewController *viewController);


/** 协议 */
@protocol YM_AlbumListViewControllerDelegate <NSObject>
@optional

/**
 点击完成时获取图片image完成后的回调
 选中了原图返回的就是原图（设置requestImageAfterFinishingSelection = YES）
 @param albumListViewController self
 @param imageList 图片数组
 */
- (void)albumListViewController:(YM_AlbumListViewController *)albumListViewController
                didDoneAllImage:(NSArray<UIImage *> *)imageList;

/**
 点击完成
 @param albumListViewController self
 @param allList     已选的所有列表(包含照片、视频)
 @param photoList   已选的照片列表
 @param videoList   已选的视频列表
 @param original    是否为原图
 */
- (void)albumListViewController:(YM_AlbumListViewController *)albumListViewController
                 didDoneAllList:(NSArray<YM_PhotoModel *> *)allList
                         photos:(NSArray<YM_PhotoModel *> *)photoList
                         videos:(NSArray<YM_PhotoModel *> *)videoList
                       original:(BOOL)original;
@end

/** 相片列表界面 */
@interface YM_AlbumListViewController : UIViewController

/** 代理 */
@property (weak, nonatomic) id<YM_AlbumListViewControllerDelegate> delegate;

/** 相片管理类 */
@property (strong, nonatomic) YM_PhotoManager *manager;

/** 点击完成按钮后的block回调 */
@property (copy, nonatomic) YM_AlbumListVCDoneBlock doneBlock;

/** 点击取消按钮后的block回调 */
@property (copy, nonatomic) YM_AlbumListVCCancelBlock cancelBlock;

@end
