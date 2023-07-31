//
//  YM_CustomCameraViewController.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class YM_PhotoManager;
@class YM_CustomCameraViewController;
@class YM_PhotoModel;

typedef void (^ YM_CustomCameraViewControllerDidDoneBlock)(YM_PhotoModel *model, YM_CustomCameraViewController *viewController);
typedef void (^ YM_CustomCameraViewControllerDidCancelBlock)(YM_CustomCameraViewController *viewController);

@protocol YM_CustomCameraViewControllerDelegate <NSObject>
@optional
- (void)customCameraViewController:(YM_CustomCameraViewController *)viewController didDone:(YM_PhotoModel *)model;
- (void)customCameraViewControllerDidCancel:(YM_CustomCameraViewController *)viewController;
@end

@interface YM_CustomCameraViewController : UIViewController

@property (weak, nonatomic) id<YM_CustomCameraViewControllerDelegate> delegate;
@property (strong, nonatomic) YM_PhotoManager *manager;
@property (assign, nonatomic) BOOL isOutside;
@property (copy, nonatomic) YM_CustomCameraViewControllerDidDoneBlock doneBlock;
@property (copy, nonatomic) YM_CustomCameraViewControllerDidCancelBlock cancelBlock;

@end
