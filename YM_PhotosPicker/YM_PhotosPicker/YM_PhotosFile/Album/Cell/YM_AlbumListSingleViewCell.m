//
//  YM_AlbumListSingleViewCell.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_AlbumListSingleViewCell.h"
#import "YM_PhotoTools.h"

@interface YM_AlbumListSingleViewCell ()

@property (strong, nonatomic) UIImageView *coverView1;
@property (strong, nonatomic) UIImageView *coverView2;
@property (strong, nonatomic) UIImageView *coverView3;
@property (strong, nonatomic) UILabel *albumNameLb;
@property (strong, nonatomic) UILabel *photoNumberLb;
@property (assign, nonatomic) PHImageRequestID requestId1;
@property (assign, nonatomic) PHImageRequestID requestId2;
@property (assign, nonatomic) PHImageRequestID requestId3;

@end

@implementation YM_AlbumListSingleViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self.contentView addSubview:self.coverView3];
    [self.contentView addSubview:self.coverView2];
    [self.contentView addSubview:self.coverView1];
    [self.contentView addSubview:self.albumNameLb];
    [self.contentView addSubview:self.photoNumberLb];
}
- (void)cancelRequest {
    if (self.requestId1) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestId1];
        self.requestId1 = -1;
    }
    if (self.requestId2) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestId2];
        self.requestId2 = -1;
    }
    if (self.requestId3) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestId3];
        self.requestId3 = -1;
    }
}
- (void)setModel:(YM_AlbumModel *)model {
    _model = model;
    NSInteger photoCount = model.result.count;
    if (!model.asset) {
        model.asset = model.result.lastObject;
    }
    kWeakSelf
    self.requestId1 = [YM_PhotoTools getImageWithAlbumModel:model size:CGSizeMake(self.hx_h * 1.6, self.hx_h * 1.6) completion:^(UIImage *image, YM_AlbumModel *model) {
        kStrongSelf
        if (self.model == model) {
            self.coverView1.image = image;
        }
    }];
    if (photoCount == 1) {
        self.coverView2.hidden = YES;
        self.coverView3.hidden = YES;
    }else if (photoCount == 2) {
        if (!model.asset2) {
            model.asset2 = model.result[1];
        }
        self.requestId2 = [YM_PhotoTools getImageWithAlbumModel:model asset:model.asset2 size:CGSizeMake(self.hx_h * 0.7, self.hx_h * 0.7) completion:^(UIImage *image, YM_AlbumModel *model) {
            if (self.model == model) {
                self.coverView2.image = image;
            }
        }];
        self.coverView2.hidden = NO;
        self.coverView3.hidden = YES;
    }else {
        if (!model.asset2) {
            model.asset2 = model.result[1];
        }
        if (!model.asset3) {
            model.asset3 = model.result[2];
        }
        self.coverView2.hidden = NO;
        self.coverView3.hidden = NO;
        
        self.requestId2 = [YM_PhotoTools getImageWithAlbumModel:model asset:model.asset2 size:CGSizeMake(self.hx_h * 0.7, self.hx_h * 0.7) completion:^(UIImage *image, YM_AlbumModel *model) {
            if (self.model == model) {
                self.coverView2.image = image;
            }
        }];
        self.requestId3 = [YM_PhotoTools getImageWithAlbumModel:model asset:model.asset3 size:CGSizeMake(self.hx_h * 0.5, self.hx_h * 0.5) completion:^(UIImage *image, YM_AlbumModel *model) {
            if (self.model == model) {
                self.coverView3.image = image;
            }
        }];
    }
    
    self.albumNameLb.text = model.albumName;
    self.photoNumberLb.text = @(photoCount).stringValue;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverView1.frame = CGRectMake(10, 5, self.hx_h - 10, self.hx_h - 10);
    if (self.model.count == 2) {
        self.coverView2.frame = CGRectMake(12.5, 3.5, self.hx_h - 15, self.hx_h - 15);
    }else {
        self.coverView2.frame = CGRectMake(12.5, 3.5, self.hx_h - 15, self.hx_h - 15);
        self.coverView3.frame = CGRectMake(15, 2, self.hx_h - 20, self.hx_h - 20);
    }
    CGFloat albumNameLbX = CGRectGetMaxX(self.coverView1.frame) + 12;
    CGFloat albumNameLbY = self.hx_h / 2  - 16;
    self.albumNameLb.frame = CGRectMake(albumNameLbX, albumNameLbY, self.hx_w - albumNameLbX - 40, 14);
    self.photoNumberLb.frame = CGRectMake(albumNameLbX, self.hx_h / 2 + 2, self.hx_w, 13);
}
- (void)dealloc {
    [self cancelRequest];
}
#pragma mark - < cell懒加载 >
- (UIImageView *)coverView1 {
    if (!_coverView1) {
        _coverView1 = [[UIImageView alloc] init];
        _coverView1.contentMode = UIViewContentModeScaleAspectFill;
        _coverView1.clipsToBounds = YES;
    }
    return _coverView1;
}
- (UIImageView *)coverView2 {
    if (!_coverView2) {
        _coverView2 = [[UIImageView alloc] init];
        _coverView2.contentMode = UIViewContentModeScaleAspectFill;
        _coverView2.clipsToBounds = YES;
    }
    return _coverView2;
}
- (UIImageView *)coverView3 {
    if (!_coverView3) {
        _coverView3 = [[UIImageView alloc] init];
        _coverView3.contentMode = UIViewContentModeScaleAspectFill;
        _coverView3.clipsToBounds = YES;
    }
    return _coverView3;
}
- (UILabel *)albumNameLb {
    if (!_albumNameLb) {
        _albumNameLb = [[UILabel alloc] init];
        _albumNameLb.textColor = [UIColor blackColor];
        _albumNameLb.font = [UIFont systemFontOfSize:13];
    }
    return _albumNameLb;
}
- (UILabel *)photoNumberLb {
    if (!_photoNumberLb) {
        _photoNumberLb = [[UILabel alloc] init];
        _photoNumberLb.textColor = [UIColor lightGrayColor];
        _photoNumberLb.font = [UIFont systemFontOfSize:12];
    }
    return _photoNumberLb;
}


@end
