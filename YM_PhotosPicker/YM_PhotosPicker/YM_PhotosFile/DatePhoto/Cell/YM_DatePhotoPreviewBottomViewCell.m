//
//  YM_DatePhotoPreviewBottomViewCell.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoPreviewBottomViewCell.h"
#import <Photos/Photos.h>
#import "YM_PhotoTools.h"
#import "UIImageView+YM_Extension.h"
#import "YM_PhotoModel.h"

@interface YM_DatePhotoPreviewBottomViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) PHImageRequestID requestID;

@end

@implementation YM_DatePhotoPreviewBottomViewCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self.contentView addSubview:self.imageView];
}
- (void)setModel:(YM_PhotoModel *)model {
    _model = model;
    
    kWeakSelf
    if (model.thumbPhoto) {
        self.imageView.image = model.thumbPhoto;
        if (model.networkPhotoUrl) {
            [self.imageView hx_setImageWithModel:model progress:^(CGFloat progress, YM_PhotoModel *model) {
                kStrongSelf
                if (self.model == model) {
                    
                }
            } completed:^(UIImage *image, NSError *error, YM_PhotoModel *model) {
                kStrongSelf
                if (self.model == model) {
                    if (error != nil) {
                    }else {
                        if (image) {
                            self.imageView.image = image;
                        }
                    }
                }
            }];
        }
    }else {
        self.requestID = [YM_PhotoTools getImageWithModel:model completion:^(UIImage *image, YM_PhotoModel *model) {
            kStrongSelf
            if (self.model == model) {
                self.imageView.image = image;
            }
        }];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}
- (void)setSelectColor:(UIColor *)selectColor {
    if (!_selectColor) {
        self.layer.borderColor = self.selected ? [selectColor colorWithAlphaComponent:0.5].CGColor : nil;
    }
    _selectColor = selectColor;
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.borderWidth = selected ? 5 : 0;
    self.layer.borderColor = selected ? [self.selectColor colorWithAlphaComponent:0.5].CGColor : nil;
}
- (void)cancelRequest {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
}
- (void)dealloc {
    [self cancelRequest];
}


@end
