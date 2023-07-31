//
//  UIImageView+YM_Extension.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YM_PhotoModel;
@interface UIImageView (YM_Extension)

- (void)hx_setImageWithModel:(YM_PhotoModel *)model
                    progress:(void (^)(CGFloat progress, YM_PhotoModel *model))progressBlock
                   completed:(void (^)(UIImage * image, NSError * error, YM_PhotoModel * model))completedBlock;

@end
