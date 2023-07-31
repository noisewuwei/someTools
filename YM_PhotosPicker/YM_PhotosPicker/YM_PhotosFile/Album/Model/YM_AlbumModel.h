//
//  YM_AlbumModel.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/** 每个相册的模型 */
@interface YM_AlbumModel : NSObject


/** 相册名称 */
@property (copy, nonatomic) NSString *albumName;

/** 照片数量 */
@property (assign, nonatomic) NSInteger count;

/** 封面Asset */
@property (strong, nonatomic) PHAsset *asset;

/** 单选时的第二个资源 */
@property (strong, nonatomic) PHAsset *asset2;

/** 单选时的第三个资源 */
@property (strong, nonatomic) PHAsset *asset3;

/** 照片集合对象 */
@property (strong, nonatomic) PHFetchResult *result;

/** 标记 */
@property (assign, nonatomic) NSInteger index;

/** 选中的个数 */
@property (assign, nonatomic) NSInteger selectedCount;

@end
