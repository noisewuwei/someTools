//
//  YM_DatePhotoEditBottomView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoManager.h"

@class YM_EditRatio;
@protocol YM_DatePhotoEditBottomViewDelegate <NSObject>
@optional
- (void)bottomViewDidCancelClick;
- (void)bottomViewDidRestoreClick;
- (void)bottomViewDidRotateClick;
- (void)bottomViewDidClipClick;
- (void)bottomViewDidSelectRatioClick:(YM_EditRatio *)ratio;
@end


@interface YM_DatePhotoEditBottomView : UIView

@property (weak, nonatomic) id<YM_DatePhotoEditBottomViewDelegate> delegate;
@property (assign, nonatomic) BOOL enabled;
- (instancetype)initWithManager:(YM_PhotoManager *)manager;

@end
