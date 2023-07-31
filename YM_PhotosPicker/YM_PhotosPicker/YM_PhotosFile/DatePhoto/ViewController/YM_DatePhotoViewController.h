//
//  YM_DatePhotoViewController.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoManager.h"
#import "YM_CustomCollectionReusableView.h"
#import "YM_DatePhotoBottomView.h"

@class YM_DatePhotoViewController;
@class YM_DatePhotoViewCell;
@class YM_CustomCameraController;

@protocol YM_DatePhotoViewControllerDelegate <NSObject>
@optional

/**
 点击取消
 @param datePhotoViewController self
 */
- (void)datePhotoViewControllerDidCancel:(YM_DatePhotoViewController *)datePhotoViewController;

/**
 点击完成按钮
 @param datePhotoViewController self
 @param allList 已选的所有列表(包含照片、视频)
 @param photoList 已选的照片列表
 @param videoList 已选的视频列表
 @param original 是否原图
 */
- (void)datePhotoViewController:(YM_DatePhotoViewController *)datePhotoViewController
                 didDoneAllList:(NSArray<YM_PhotoModel *> *)allList
                         photos:(NSArray<YM_PhotoModel *> *)photoList
                         videos:(NSArray<YM_PhotoModel *> *)videoList
                       original:(BOOL)original;

/**
 改变了选择
 @param model 改的模型
 @param selected 是否选中
 */
- (void)datePhotoViewControllerDidChangeSelect:(YM_PhotoModel *)model
                                      selected:(BOOL)selected;
@end

/** 相片瀑布流控制器 */
@interface YM_DatePhotoViewController : UIViewController

@property (weak, nonatomic) id<YM_DatePhotoViewControllerDelegate> delegate;
@property (strong, nonatomic) YM_PhotoManager * manager;
@property (strong, nonatomic) YM_AlbumModel   * albumModel;
@property (strong, nonatomic) YM_DatePhotoBottomView *bottomView;

- (YM_DatePhotoViewCell *)currentPreviewCell:(YM_PhotoModel *)model;

- (BOOL)scrollToModel:(YM_PhotoModel *)model;

- (void)scrollToPoint:(YM_DatePhotoViewCell *)cell rect:(CGRect)rect;

@end
