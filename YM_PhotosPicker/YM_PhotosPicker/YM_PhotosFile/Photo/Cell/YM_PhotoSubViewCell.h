//
//  YM_PhotoSubViewCell.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YM_PhotoSubViewCellDelegate <NSObject>

- (void)cellDidDeleteClcik:(UICollectionViewCell *)cell;

@end

@class YM_PhotoModel;
@interface YM_PhotoSubViewCell : UICollectionViewCell

@property (weak, nonatomic) id<YM_PhotoSubViewCellDelegate> delegate;

@property (strong, nonatomic, readonly) UIImageView *imageView;

@property (strong, nonatomic) YM_PhotoModel *model;

/**  隐藏cell上的删除按钮  */
@property (assign, nonatomic) BOOL hideDeleteButton;

/** 删除网络图片时是否显示Alert */
@property (assign, nonatomic) BOOL showDeleteNetworkPhotoAlert;

/** 重新下载 */
- (void)againDownload;

@end
