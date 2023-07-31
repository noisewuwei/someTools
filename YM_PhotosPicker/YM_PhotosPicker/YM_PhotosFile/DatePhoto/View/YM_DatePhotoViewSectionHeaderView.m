//
//  YM_DatePhotoViewSectionHeaderView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoViewSectionHeaderView.h"
#import "YM_PhotoTools.h"
#import "UIFont+YM_Extension.h"
@interface YM_DatePhotoViewSectionHeaderView ()

@property (strong, nonatomic) UILabel *dateLb;

@property (strong, nonatomic) UILabel *subTitleLb;

@property (strong, nonatomic) UIToolbar *bgView;

@end

@implementation YM_DatePhotoViewSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self addSubview:self.bgView];
    [self addSubview:self.dateLb];
    [self addSubview:self.subTitleLb];
}
- (void)setChangeState:(BOOL)changeState {
    _changeState = changeState;
    if (self.translucent) {
        self.bgView.translucent = changeState;
    }
    if (self.suspensionBgColor) {
        self.translucent = NO;
    }
    if (changeState) {
        if (self.translucent) {
            self.bgView.alpha = 1;
        }
        if (self.suspensionTitleColor) {
            self.dateLb.textColor = self.suspensionTitleColor;
            self.subTitleLb.textColor = self.suspensionTitleColor;
        }
        if (self.suspensionBgColor) {
            self.bgView.barTintColor = self.suspensionBgColor;
        }
    }else {
        if (!self.translucent) {
            self.bgView.barTintColor = [UIColor whiteColor];
        }
        if (self.translucent) {
            self.bgView.alpha = 0;
        }
        self.dateLb.textColor = [UIColor blackColor];
        self.subTitleLb.textColor = [UIColor blackColor];
    }
}
- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    if (!translucent) {
        self.bgView.translucent = YES;
        self.bgView.barTintColor = [UIColor whiteColor];
    }
}
- (void)setModel:(YM_PhotoDateModel *)model {
    _model = model;
    if (model.location) {
        if (model.hasLocationTitles) {
            self.dateLb.frame = CGRectMake(8, 4, self.hx_w - 16, 30);
            self.subTitleLb.hidden = NO;
            self.subTitleLb.text = model.locationSubTitle;
            self.dateLb.text = model.locationTitle;
        }else {
            self.dateLb.frame = CGRectMake(8, 0, self.hx_w - 16, 50);
            self.dateLb.text = model.dateString;
            self.subTitleLb.hidden = YES;
            kWeakSelf
            [YM_PhotoTools getDateLocationDetailInformationWithModel:model completion:^(CLPlacemark *placemark, YM_PhotoDateModel *model) {
                kStrongSelf
                if (placemark.locality) {
                    NSString *province = placemark.administrativeArea;
                    NSString *city = placemark.locality;
                    NSString *area = placemark.subLocality;
                    NSString *street = placemark.thoroughfare;
                    NSString *subStreet = placemark.subThoroughfare;
                    if (area) {
                        model.locationTitle = [NSString stringWithFormat:@"%@ ﹣ %@",city,area];
                    }else {
                        model.locationTitle = [NSString stringWithFormat:@"%@",city];
                    }
                    if (street) {
                        if (subStreet) {
                            model.locationSubTitle = [NSString stringWithFormat:@"%@・%@%@",model.dateString,street,subStreet];
                        }else {
                            model.locationSubTitle = [NSString stringWithFormat:@"%@・%@",model.dateString,street];
                        }
                    }else if (province) {
                        model.locationSubTitle = [NSString stringWithFormat:@"%@・%@",model.dateString,province];
                    }else {
                        model.locationSubTitle = [NSString stringWithFormat:@"%@・%@",model.dateString,city];
                    }
                }else {
                    NSString *province = placemark.administrativeArea;
                    model.locationSubTitle = [NSString stringWithFormat:@"%@・%@",model.dateString,province];
                    model.locationTitle = province;
                }
                model.hasLocationTitles = YES;
                if (self.model == model) {
                    self.subTitleLb.text = model.locationSubTitle;
                    self.dateLb.text = model.locationTitle;
                    self.dateLb.frame = CGRectMake(8, 4, self.hx_w - 16, 30);
                    self.subTitleLb.hidden = NO;
                }
            }];
        }
    }else {
        self.dateLb.frame = CGRectMake(8, 0, self.hx_w - 16, 50);
        self.dateLb.text = model.dateString;
        self.subTitleLb.hidden = YES;
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.model.location) {
        self.dateLb.frame = CGRectMake(8, 4, self.hx_w - 16, 30);
        self.subTitleLb.frame = CGRectMake(8, 26, self.hx_w - 16, 20);
    }else {
    }
    self.bgView.frame = self.bounds;
}
- (UILabel *)dateLb {
    if (!_dateLb) {
        _dateLb = [[UILabel alloc] init];
        _dateLb.textColor = [UIColor blackColor];
        _dateLb.font = [UIFont ym_pingFangFontOfSize:15];
    }
    return _dateLb;
}
- (UIToolbar *)bgView {
    if (!_bgView) {
        _bgView = [[UIToolbar alloc] init];
        _bgView.translucent = NO;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}
- (UILabel *)subTitleLb {
    if (!_subTitleLb) {
        _subTitleLb = [[UILabel alloc] init];
        _subTitleLb.textColor = [UIColor blackColor];
        _subTitleLb.font = [UIFont ym_pingFangFontOfSize:11];
    }
    return _subTitleLb;
}


@end
