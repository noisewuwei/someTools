//
//  YM_DatePhotoBottomView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoManager.h"

@protocol YM_DatePhotoBottomViewDelegate <NSObject>
@optional
- (void)datePhotoBottomViewDidPreviewBtn;
- (void)datePhotoBottomViewDidDoneBtn;
- (void)datePhotoBottomViewDidEditBtn;
@end

/** 相册选择列表界面底部的工具栏（包含完成按钮、原图按钮） */
@interface YM_DatePhotoBottomView : UIView

/** 代理对象 */
@property (weak, nonatomic) id<YM_DatePhotoBottomViewDelegate> delegate;

/** 相片资源管理类 */
@property (strong, nonatomic) YM_PhotoManager *manager;

/** 选中数量 */
@property (assign, nonatomic) NSInteger selectCount;

/** “原图”按钮 */
@property (strong, nonatomic) UIButton *originalBtn;

/** 视图背景 */
@property (strong, nonatomic) UIToolbar *bgView;

@end
