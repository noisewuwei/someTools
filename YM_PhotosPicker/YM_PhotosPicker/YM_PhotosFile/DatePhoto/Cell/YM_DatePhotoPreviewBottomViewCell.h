//
//  YM_DatePhotoPreviewBottomViewCell.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoModel.h"

@interface YM_DatePhotoPreviewBottomViewCell : UICollectionViewCell

@property (strong, nonatomic) YM_PhotoModel *model;

@property (strong, nonatomic) UIColor *selectColor;

- (void)cancelRequest;

@end
