//
//  YM_DateVideoEditBottomView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoManager.h"

@class YM_DateVideoEditBottomView;

@protocol YM_DateVideoEditBottomViewDelegate <NSObject>
@optional

- (void)videoEditBottomViewDidCancelClick:(YM_DateVideoEditBottomView *)bottomView;

- (void)videoEditBottomViewDidDoneClick:(YM_DateVideoEditBottomView *)bottomView;

@end

@interface YM_DateVideoEditBottomView : UIView

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (weak, nonatomic) id<YM_DateVideoEditBottomViewDelegate> delegate;

- (instancetype)initWithManager:(YM_PhotoManager *)manager;

@end
