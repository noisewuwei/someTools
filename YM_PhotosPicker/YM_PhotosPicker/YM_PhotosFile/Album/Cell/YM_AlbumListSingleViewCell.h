//
//  YM_AlbumListSingleViewCell.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_AlbumModel.h"

static NSString * YM_AlbumListSingleViewCellID = @"YM_AlbumListSingleViewCell";
@interface YM_AlbumListSingleViewCell : UITableViewCell

@property (strong, nonatomic) YM_AlbumModel *model;

- (void)cancelRequest;

@end
