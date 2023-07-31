//
//  YM_DatePhotoEditViewController.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoManager.h"

@class YM_DatePhotoEditViewController;
@protocol YM_DatePhotoEditViewControllerDelegate <NSObject>
@optional

- (void)datePhotoEditViewControllerDidClipClick:(YM_DatePhotoEditViewController *)datePhotoEditViewController beforeModel:(YM_PhotoModel *)beforeModel afterModel:(YM_PhotoModel *)afterModel;
@end

@interface YM_DatePhotoEditViewController : UIViewController

@property (weak, nonatomic) id<YM_DatePhotoEditViewControllerDelegate> delegate;
@property (strong, nonatomic) YM_PhotoModel *model;
@property (strong, nonatomic) YM_PhotoManager *manager;
@property (assign, nonatomic) BOOL outside;
@end


