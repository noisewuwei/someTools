//
//  YM_DatePhotoCameraViewCell.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoCameraViewCell.h"
#import "YM_CustomCameraController.h"
#import "YM_CustomPreviewView.h"
#import "YM_PhotoDefine.h"
@interface YM_DatePhotoCameraViewCell ()

@property (strong, nonatomic) UIButton *cameraBtn;

@property (strong, nonatomic) YM_CustomCameraController *cameraController;

@property (strong, nonatomic) YM_CustomPreviewView *previewView;

@end

@implementation YM_DatePhotoCameraViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI  {
    [self.contentView addSubview:self.previewView];
    [self.contentView addSubview:self.cameraBtn];
}
- (void)starRunning {
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    if (self.cameraController.captureSession) {
        return;
    }
    kWeakSelf
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        kStrongSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if ([self.cameraController setupSession:nil]) {
                    [self.previewView setSession:self.cameraController.captureSession];
                    [self.cameraController startSession];
                    self.cameraBtn.selected = YES;
                }
            }
        });
    }];
}
- (void)stopRunning {
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus != AVAuthorizationStatusAuthorized) {
        return;
    }
    if (!self.cameraController.captureSession) {
        return;
    }
    [self.cameraController stopSession];
    self.cameraBtn.selected = NO;
}
- (void)setModel:(YM_PhotoModel *)model {
    _model = model;
    [self.cameraBtn setImage:model.thumbPhoto forState:UIControlStateNormal];
    [self.cameraBtn setImage:model.previewPhoto forState:UIControlStateSelected];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.cameraBtn.frame = self.bounds;
    self.previewView.frame = self.bounds;
}
- (void)dealloc {
    [self stopRunning];
    if (showLog) NSSLog(@"camera - dealloc");
}
- (UIButton *)cameraBtn {
    if (!_cameraBtn) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraBtn.userInteractionEnabled = NO;
    }
    return _cameraBtn;
}
- (YM_CustomCameraController *)cameraController {
    if (!_cameraController) {
        _cameraController = [[YM_CustomCameraController alloc] init];
    }
    return _cameraController;
}
- (YM_CustomPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[YM_CustomPreviewView alloc] init];
        _previewView.pinchToZoomEnabled = NO;
        _previewView.tapToFocusEnabled = NO;
        _previewView.tapToExposeEnabled = NO;
    }
    return _previewView;
}

@end
