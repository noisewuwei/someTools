//
//  YM_DatePhotoCameraViewCell.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoModel.h"
@class YM_CustomCameraController;

@interface YM_DatePhotoCameraViewCell : UICollectionViewCell

@property (strong, nonatomic) YM_PhotoModel *model;
@property (strong, nonatomic, readonly) YM_CustomCameraController *cameraController;

- (void)starRunning;

- (void)stopRunning;

@end
