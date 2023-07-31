//
//  UIViewController+YM_Extension.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_AlbumListViewController.h"
#import "YM_CustomCameraViewController.h"
#import "YM_PhotoManager.h"

/** 授权类型 */
typedef NS_ENUM(NSInteger, YM_AuthorizationType) {
    YM_AuthorizationType_Photo,     // 访问相片
    YM_AuthorizationType_Camera,    // 访问相机
};

@interface UIViewController (YM_Extension)

/*  <HXAlbumListViewControllerDelegate>
 *  delegate 不传则代表自己
 */
- (void)hx_presentAlbumListViewControllerWithManager:(YM_PhotoManager *)manager
                                            delegate:(id)delegate;

/**
 跳转相册列表
 
 @param manager 照片管理者
 @param done 确定 NSArray<HXPhotoModel *> *allList - 所选的所有模型数组,
 NSArray<HXPhotoModel *> *videoList - 所选的视频模型数组
 NSArray<HXPhotoModel *> *photoList - 所选的照片模型数组
 NSArray<UIImage *> *imageList - 所选的所有UIImage对象数组(当requestImageAfterFinishingSelection = YES 时才有值,内部会在点击确定的时候去请求已经选择资源的图片，为视频时则是视频封面)
 BOOL original - 是否原图
 HXAlbumListViewController *viewController 相册列表控制器
 @param cancel 取消
 */
- (void)hx_presentAlbumListViewControllerWithManager:(YM_PhotoManager *)manager done:(YM_AlbumListVCDoneBlock)done cancel:(YM_AlbumListVCCancelBlock)cancel;

/*  <HXCustomCameraViewControllerDelegate>
 *  delegate 不传则代表自己
 */
- (void)hx_presentCustomCameraViewControllerWithManager:(YM_PhotoManager *)manager delegate:(id)delegate;

- (void)hx_presentCustomCameraViewControllerWithManager:(YM_PhotoManager *)manager  done:(YM_CustomCameraViewControllerDidDoneBlock)done cancel:(YM_CustomCameraViewControllerDidCancelBlock)cancel;

- (BOOL)navigationBarWhetherSetupBackground;

#pragma mark - 授权
/**
 显示授权提示
 @param type 要授权的类型
 */
- (void)showAuthorizationWithtType:(YM_AuthorizationType)type;

@end
