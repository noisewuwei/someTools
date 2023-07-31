//
//  YM_AlbumListQuadrateViewCell.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_AlbumModel.h"

static NSString * YM_AlbumListQuadrateViewCellID = @"YM_AlbumListQuadrateViewCell";
@interface YM_AlbumListQuadrateViewCell : UICollectionViewCell

@property (strong, nonatomic) YM_AlbumModel *model;

- (void)cancelRequest ;

@end
