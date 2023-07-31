//
//  YM_AlbumListQuadrateViewCell.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_AlbumListQuadrateViewCell.h"
#import <Photos/Photos.h>

#import "YM_PhotoTools.h"

@interface YM_AlbumListQuadrateViewCell ()

@property (strong, nonatomic) UIImageView *coverView;
@property (strong, nonatomic) UIButton *selectNumberBtn;
@property (strong, nonatomic) UILabel *albumNameLb;
@property (strong, nonatomic) UILabel *photoNumberLb;
@property (assign, nonatomic) PHImageRequestID requestID;

@end

@implementation YM_AlbumListQuadrateViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.albumNameLb];
    [self.contentView addSubview:self.photoNumberLb];
    //    [self.contentView addSubview:self.selectNumberBtn];
}
- (void)setModel:(YM_AlbumModel *)model {
    _model = model;
    if (!model.asset) {
        model.asset = model.result.lastObject;
    }
    kWeakSelf
    self.requestID = [YM_PhotoTools getImageWithAlbumModel:model size:CGSizeMake(self.hx_w * 1.5, self.hx_w * 1.5) completion:^(UIImage *image, YM_AlbumModel *model) {
        kStrongSelf
        if (self.model == model) {
            self.coverView.image = image;
        }
    }];
    
    self.albumNameLb.text = model.albumName;
    self.photoNumberLb.text = @(model.result.count).stringValue;
    //    if (model.selectedCount == 0) {
    //        self.selectNumberBtn.hidden = YES;
    //    }else {
    //        self.selectNumberBtn.hidden = NO;
    //    }
    //    [self.selectNumberBtn setTitle:@(model.selectedCount).stringValue forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverView.frame = CGRectMake(0, 0, self.hx_w, self.hx_w);
    self.albumNameLb.frame = CGRectMake(0, self.hx_w + 6, self.hx_w, 14);
    self.photoNumberLb.frame = CGRectMake(0, CGRectGetMaxY(self.albumNameLb.frame) + 4, self.hx_w, 14);
    self.selectNumberBtn.hx_size = CGSizeMake(12, 12);
    self.selectNumberBtn.hx_x = self.hx_w - 5 - self.selectNumberBtn.hx_w;
    CGFloat margin = (self.hx_h - self.hx_w) / 2 + 3;
    self.selectNumberBtn.center = CGPointMake(self.selectNumberBtn.center.x, self.hx_w + margin);
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
#pragma mark - < cell懒加载 >
- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.layer.masksToBounds = YES;
        _coverView.layer.cornerRadius = 4;
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds = YES;
    }
    return _coverView;
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
        _photoNumberLb.font = [UIFont systemFontOfSize:13];
    }
    return _photoNumberLb;
}
- (UIButton *)selectNumberBtn {
    if (!_selectNumberBtn) {
        _selectNumberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectNumberBtn.userInteractionEnabled = NO;
        [_selectNumberBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectNumberBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        //        [_selectNumberBtn setBackgroundColor:self.manager.themeColor];
        _selectNumberBtn.layer.cornerRadius = 12.f / 2;
        _selectNumberBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _selectNumberBtn;
}
@end

