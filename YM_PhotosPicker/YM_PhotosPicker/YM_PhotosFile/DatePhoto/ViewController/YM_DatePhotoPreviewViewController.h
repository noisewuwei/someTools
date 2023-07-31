//
//  YM_DatePhotoPreviewViewController.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import "YM_PhotoManager.h"

@class YM_DatePhotoPreviewViewController;
@class YM_DatePhotoPreviewBottomView;
@class YM_DatePhotoPreviewViewCell;
@class YM_PhotoView;

@protocol YM_DatePhotoPreviewViewControllerDelegate <NSObject>
@optional
- (void)datePhotoPreviewControllerDidSelect:(YM_DatePhotoPreviewViewController *)previewController model:(YM_PhotoModel *)model;

- (void)datePhotoPreviewControllerDidDone:(YM_DatePhotoPreviewViewController *)previewController;

- (void)datePhotoPreviewDidEditClick:(YM_DatePhotoPreviewViewController *)previewController;

- (void)datePhotoPreviewSingleSelectedClick:(YM_DatePhotoPreviewViewController *)previewController model:(YM_PhotoModel *)model;

- (void)datePhotoPreviewDownLoadICloudAssetComplete:(YM_DatePhotoPreviewViewController *)previewController model:(YM_PhotoModel *)model;

- (void)datePhotoPreviewSelectLaterDidEditClick:(YM_DatePhotoPreviewViewController *)previewController beforeModel:(YM_PhotoModel *)beforeModel afterModel:(YM_PhotoModel *)afterModel;

- (void)datePhotoPreviewDidDeleteClick:(YM_DatePhotoPreviewViewController *)previewController deleteModel:(YM_PhotoModel *)model deleteIndex:(NSInteger)index;
@end

@interface YM_DatePhotoPreviewViewController : UIViewController <UIViewControllerTransitioningDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) id<YM_DatePhotoPreviewViewControllerDelegate> delegate;

@property (strong, nonatomic) YM_PhotoManager *manager;

@property (strong, nonatomic) NSMutableArray *modelArray;

@property (assign, nonatomic) NSInteger currentModelIndex;

@property (assign, nonatomic) BOOL outside;

@property (assign, nonatomic) BOOL selectPreview;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) YM_DatePhotoPreviewBottomView *bottomView;

@property (strong, nonatomic) YM_PhotoView *photoView;

@property (assign, nonatomic) BOOL previewShowDeleteButton;

@property (assign, nonatomic) BOOL stopCancel;

- (YM_DatePhotoPreviewViewCell *)currentPreviewCell:(YM_PhotoModel *)model;

- (void)setSubviewAlphaAnimate:(BOOL)animete
                      duration:(NSTimeInterval)duration;

@end
