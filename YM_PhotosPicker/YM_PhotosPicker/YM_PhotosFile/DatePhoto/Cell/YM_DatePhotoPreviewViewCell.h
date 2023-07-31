//
//  YM_DatePhotoPreviewViewCell.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoModel.h"

@interface YM_DatePhotoPreviewViewCell : UICollectionViewCell

@property (assign, nonatomic) BOOL stopCancel;
@property (strong, nonatomic) YM_PhotoModel *model;
@property (strong, nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic, readonly) AVPlayerLayer *playerLayer;
@property (strong, nonatomic, readonly) UIImage *gifImage;
@property (strong, nonatomic) UIButton *videoPlayBtn;
@property (assign, nonatomic) BOOL dragging;
@property (nonatomic, copy) void (^cellTapClick)();
@property (nonatomic, copy) void (^cellDidPlayVideoBtn)(BOOL play);
@property (nonatomic, copy) void (^cellDownloadICloudAssetComplete)(YM_DatePhotoPreviewViewCell *myCell);
- (void)againAddImageView;
- (void)resetScale;
- (void)requestHDImage;
- (void)cancelRequest;

@end
