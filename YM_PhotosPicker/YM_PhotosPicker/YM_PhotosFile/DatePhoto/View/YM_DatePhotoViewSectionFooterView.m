//
//  YM_DatePhotoViewSectionFooterView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoViewSectionFooterView.h"
#import "NSBundle+YM_PhotoPicker.h"
#import "UIView+YM_Extension.h"

@interface YM_DatePhotoViewSectionFooterView ()

@property (strong, nonatomic) UILabel *titleLb;

@end

@implementation YM_DatePhotoViewSectionFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.titleLb];
}
- (void)setVideoCount:(NSInteger)videoCount {
    _videoCount = videoCount;
    if (self.photoCount > 0 && videoCount > 0) {
        NSString *photoStr;
        if (self.photoCount > 1) {
            photoStr = @"Photos";
        }else {
            photoStr = @"Photo";
        }
        NSString *videoStr;
        if (videoCount > 1) {
            videoStr = @"Videos";
        }else {
            videoStr = @"Video";
        }
        self.titleLb.text = [NSString stringWithFormat:@"%ld %@、%ld %@",self.photoCount,[NSBundle ym_localizedStringForKey:photoStr],videoCount,[NSBundle ym_localizedStringForKey:videoStr]];
        
    }else if (self.photoCount > 0) {
        NSString *photoStr;
        if (self.photoCount > 1) {
            photoStr = @"Photos";
        }else {
            photoStr = @"Photo";
        }
        self.titleLb.text = [NSString stringWithFormat:@"%ld %@",self.photoCount,[NSBundle ym_localizedStringForKey:photoStr]];
    }else {
        NSString *videoStr;
        if (videoCount > 1) {
            videoStr = @"Videos";
        }else {
            videoStr = @"Video";
        }
        self.titleLb.text = [NSString stringWithFormat:@"%ld %@",videoCount,
                             [NSBundle ym_localizedStringForKey:videoStr]];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLb.frame = CGRectMake(0, 0, self.hx_w, 50);
}
- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.textColor = [UIColor blackColor];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.font = [UIFont systemFontOfSize:15];
    }
    return _titleLb;
}
@end
