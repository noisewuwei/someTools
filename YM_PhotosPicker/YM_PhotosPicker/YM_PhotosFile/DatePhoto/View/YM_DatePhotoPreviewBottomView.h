//
//  YM_DatePhotoPreviewBottomView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YM_PhotoModel;
@class YM_DatePhotoPreviewBottomView;
@class YM_PhotoManager;

@protocol YM_DatePhotoPreviewBottomViewDelegate <NSObject>
@optional
- (void)datePhotoPreviewBottomViewDidItem:(YM_PhotoModel *)model
                             currentIndex:(NSInteger)currentIndex
                              beforeIndex:(NSInteger)beforeIndex;

- (void)datePhotoPreviewBottomViewDidDone:(YM_DatePhotoPreviewBottomView *)bottomView;

- (void)datePhotoPreviewBottomViewDidEdit:(YM_DatePhotoPreviewBottomView *)bottomView;

@end

@interface YM_DatePhotoPreviewBottomView : UIView

@property (strong, nonatomic) UIToolbar *bgView;
@property (weak, nonatomic) id<YM_DatePhotoPreviewBottomViewDelegate> delagate;
@property (strong, nonatomic) NSMutableArray *modelArray;
@property (assign, nonatomic) NSInteger selectCount;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) BOOL hideEditBtn;
@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL outside;

@property (strong, nonatomic) UIToolbar *tipView;
@property (strong, nonatomic) UILabel *tipLb;
@property (assign, nonatomic) BOOL showTipView;
@property (copy, nonatomic) NSString *tipStr;

- (void)insertModel:(YM_PhotoModel *)model;

- (void)deleteModel:(YM_PhotoModel *)model;

- (instancetype)initWithFrame:(CGRect)frame
                   modelArray:(NSArray *)modelArray
                      manager:(YM_PhotoManager *)manager;

- (void)deselected;

- (void)deselectedWithIndex:(NSInteger)index;

@end


