//
//  YM_DatePhotoViewSectionHeaderView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_CustomCollectionReusableView.h"
#import "YM_PhotoDateModel.h"

@interface YM_DatePhotoViewSectionHeaderView : YM_CustomCollectionReusableView

@property (strong, nonatomic) YM_PhotoDateModel *model;
@property (assign, nonatomic) BOOL changeState;
@property (assign, nonatomic) BOOL translucent;
@property (strong, nonatomic) UIColor *suspensionBgColor;
@property (strong, nonatomic) UIColor *suspensionTitleColor;

@end
