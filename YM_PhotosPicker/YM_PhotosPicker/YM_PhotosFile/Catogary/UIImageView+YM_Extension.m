//
//  UIImageView+YM_Extension.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "UIImageView+YM_Extension.h"
#import "YM_PhotoModel.h"

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#elif __has_include("UIImageView+WebCache.h")
#import "UIImageView+WebCache.h"
#endif

@implementation UIImageView (YM_Extension)

- (void)hx_setImageWithModel:(YM_PhotoModel *)model
                    progress:(void (^)(CGFloat progress, YM_PhotoModel *model))progressBlock
                   completed:(void (^)(UIImage * image, NSError * error, YM_PhotoModel * model))completedBlock {
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
    kWeakSelf
    // 崩溃在这里说明SDWebImage版本过低
    [self sd_setImageWithURL:model.networkPhotoUrl placeholderImage:model.thumbPhoto options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        kStrongSelf
        model.receivedSize = receivedSize;
        model.expectedSize = expectedSize;
        CGFloat progress = (CGFloat)receivedSize / expectedSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) {
                progressBlock(progress, model);
            }
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error != nil) {
            model.downloadError = YES;
            model.downloadComplete = YES;
        }else {
            if (image) {
                self.image = image;
                model.imageSize = image.size;
                model.thumbPhoto = image;
                model.previewPhoto = image;
                model.downloadComplete = YES;
                model.downloadError = NO;
            }
        }
        if (completedBlock) {
            completedBlock(image,error,model);
        }
    }];
#else
    NSAssert(NO, @"请导入SDWebImage后再使用网络图片功能");
#endif
}


@end
