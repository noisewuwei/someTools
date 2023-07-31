//
//  YM_DateVideoEditViewController.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoManager.h"
#import "YM_PhotoModel.h"
#import "YM_DateVideoEditBottomView.h"

@class YM_DateVideoEditViewController;

@protocol YM_DateVideoEditViewControllerDelegate <NSObject>
@optional
- (void)dateVideoEditViewControllerDidClipClick:(YM_DateVideoEditViewController *)dateVideoEditViewController beforeModel:(YM_PhotoModel *)beforeModel afterModel:(YM_PhotoModel *)afterModel;
@end


@interface YM_DateVideoEditViewController : UIViewController

@property (weak, nonatomic) id<YM_DateVideoEditViewControllerDelegate> delegate;
@property (strong, nonatomic) YM_PhotoModel *model;
@property (strong, nonatomic) YM_PhotoManager *manager;
@property (assign, nonatomic) BOOL outside;
@property (strong, nonatomic) AVAsset *avAsset;

@end
