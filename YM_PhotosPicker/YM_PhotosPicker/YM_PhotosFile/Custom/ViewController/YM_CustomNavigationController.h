//
//  YM_CustomNavigationController.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YM_CustomNavigationController : UINavigationController

/** 是否为相机 */
@property (nonatomic) BOOL isCamera;

/** 是否支持旋转 */
@property (assign, nonatomic) BOOL supportRotation;

@end
