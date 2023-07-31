//
//  UIView+YM_Extension.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YM_PhotoManager;

@interface UIView (YM_Extension)

@property (assign, nonatomic) CGFloat hx_x;
@property (assign, nonatomic) CGFloat hx_y;
@property (assign, nonatomic) CGFloat hx_w;
@property (assign, nonatomic) CGFloat hx_h;
@property (assign, nonatomic) CGSize  hx_size;
@property (assign, nonatomic) CGPoint hx_origin;

/**
 获取当前视图的控制器
 
 @return 控制器
 */
- (UIViewController *)viewController;

- (void)showImageHUDText:(NSString *)text;
- (void)showLoadingHUDText:(NSString *)text;
- (void)handleLoading;

/* <YMAlbumListViewControllerDelegate> */
- (void)hx_presentAlbumListViewControllerWithManager:(YM_PhotoManager *)manager
                                            delegate:(id)delegate;

/* <YMCustomCameraViewControllerDelegate> */
- (void)hx_presentCustomCameraViewControllerWithManager:(YM_PhotoManager *)manager
                                               delegate:(id)delegate;

@end


@interface HXHUD : UIView
- (instancetype)initWithFrame:(CGRect)frame
                    imageName:(NSString *)imageName
                         text:(NSString *)text;

- (void)showloading;
@end
