//
//  YM_DatePhotoViewCell.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoModel.h"
@class YM_DatePhotoViewCell;

@protocol YM_DatePhotoViewCellDelegate <NSObject>
@optional

- (void)datePhotoViewCell:(YM_DatePhotoViewCell *)cell
             didSelectBtn:(UIButton *)selectBtn;

- (void)datePhotoViewCellRequestICloudAssetComplete:(YM_DatePhotoViewCell *)cell;
@end

@interface YM_DatePhotoViewCell : UICollectionViewCell

@property (weak, nonatomic) id<YM_DatePhotoViewCellDelegate> delegate;
@property (assign, nonatomic) NSInteger section;
@property (assign, nonatomic) NSInteger item;
@property (strong, nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic) CALayer *selectMaskLayer;
@property (strong, nonatomic) YM_PhotoModel *model;
@property (assign, nonatomic) BOOL singleSelected;
@property (strong, nonatomic) UIColor *selectBgColor;
@property (strong, nonatomic) UIColor *selectedTitleColor;

- (void)cancelRequest;
- (void)startRequestICloudAsset;
- (void)bottomViewPrepareAnimation;
- (void)bottomViewStartAnimation;
@end


