//
//  YM_DatePhotoEditViewController.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoEditViewController.h"
#import "YM_DatePhotoEditBottomView.h"
#import "YM_EditGridLayer.h"
#import "YM_EditCornerView.h"
#import "YM_EditRatio.h"
#import "UIImage+YM_Extension.h"
@interface YM_DatePhotoEditViewController () <YM_DatePhotoEditBottomViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) YM_DatePhotoEditBottomView *bottomView;
@property (assign, nonatomic) BOOL orientationDidChange;
@property (assign, nonatomic) PHImageRequestID requestId;
@property (strong, nonatomic) YM_EditGridLayer *gridLayer;
@property (strong, nonatomic) YM_EditCornerView *leftTopView;
@property (strong, nonatomic) YM_EditCornerView *rightTopView;
@property (strong, nonatomic) YM_EditCornerView *leftBottomView;
@property (strong, nonatomic) YM_EditCornerView *rightBottomView;
@property (assign, nonatomic) CGRect clippingRect;
@property (strong, nonatomic) YM_EditRatio *clippingRatio;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) CGFloat imageWidth;
@property (assign, nonatomic) CGFloat imageHeight;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) UIPanGestureRecognizer *imagePanGesture;
@property (assign, nonatomic) BOOL isSelectRatio;

@end

@implementation YM_DatePhotoEditViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageWidth = self.model.imageSize.width;
    self.imageHeight = self.model.imageSize.height;
    [self setupUI];
    [self setupModel];
    if (!self.manager.configuration.movableCropBox) {
        self.bottomView.enabled = NO;
    }else {
        if (CGPointEqualToPoint(self.manager.configuration.movableCropBoxCustomRatio, CGPointZero)) {
            self.bottomView.enabled = NO;
        }
    }
    [self changeSubviewFrame:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopTimer];
    [[PHImageManager defaultManager] cancelImageRequest:self.requestId];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.orientationDidChange) {
        self.orientationDidChange = NO;
        [self changeSubviewFrame:NO];
    }
}
- (void)deviceOrientationChanged:(NSNotification *)notify {
    self.orientationDidChange = YES;
}
- (void)deviceOrientationWillChanged:(NSNotification *)notify {
    [self stopTimer];
}
- (void)dealloc {
    if (showLog) NSSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
    [[PHImageManager defaultManager] cancelImageRequest:self.requestId];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}
- (void)changeSubviewFrame:(BOOL)animated {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
        
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        
    }
    CGFloat bottomMargin = kBottomMargin;
    CGFloat width = self.view.hx_w - 40;
    CGFloat imageY = 30;
    if (kDevice_Is_iPhoneX && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
        bottomMargin = 21;
        width = self.view.hx_w - 80;
        imageY = 20;
    }
    CGFloat height = self.view.frame.size.height - 100 - imageY - bottomMargin;
    CGFloat imgWidth = self.imageWidth;
    CGFloat imgHeight = self.imageHeight;
    CGFloat w;
    CGFloat h;
    
    if (imgWidth > width) {
        imgHeight = width / imgWidth * imgHeight;
    }
    if (imgHeight > height) {
        w = height / self.imageHeight * imgWidth;
        h = height;
    }else {
        if (imgWidth > width) {
            w = width;
        }else {
            w = imgWidth;
        }
        h = imgHeight;
    }
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.frame = CGRectMake(0, imageY, w, h);
            self.imageView.center = CGPointMake(self.view.hx_w / 2, imageY + height / 2);
            self.gridLayer.frame = self.imageView.bounds;
        }];
    }else {
        self.imageView.frame = CGRectMake(0, imageY, w, h);
        self.imageView.center = CGPointMake(self.view.hx_w / 2, imageY + height / 2);
        self.gridLayer.frame = self.imageView.bounds;
    }
    self.bottomView.frame = CGRectMake(0, self.view.hx_h - 100 - bottomMargin, self.view.hx_w, 100 + bottomMargin);
    [self clippingRatioDidChange:animated];
}
- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.leftTopView];
    [self.view addSubview:self.leftBottomView];
    [self.view addSubview:self.rightTopView];
    [self.view addSubview:self.rightBottomView];
    
    [self setupModel];
}
- (void)setupModel {
    if (self.model.asset) {
        self.bottomView.userInteractionEnabled = NO;
        kWeakSelf
        [self.view showLoadingHUDText:nil];
        self.requestId = [YM_PhotoTools getImageData:self.model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
            kStrongSelf
            self.requestId = cloudRequestId;
        } progressHandler:^(double progress) {
            
        } completion:^(NSData *imageData, UIImageOrientation orientation) {
            dispatch_async(dispatch_get_main_queue(), ^{
                kStrongSelf
                self.bottomView.userInteractionEnabled = YES;
                UIImage *image = [UIImage imageWithData:imageData];
                if (image.imageOrientation != UIImageOrientationUp) {
                    image = [image normalizedImage];
                }
                self.originalImage = image;
                self.imageView.image = image;
                [self.view handleLoading];
                [self fixationEdit];
            });
        } failed:^(NSDictionary *info) {
            kStrongSelf
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view handleLoading];
                self.bottomView.userInteractionEnabled = YES;
            });
        }];
    }else {
        self.imageView.image = self.model.thumbPhoto;
        self.originalImage = self.model.thumbPhoto;
        [self fixationEdit];
    }
}
- (void)fixationEdit {
    if (self.manager.configuration.movableCropBox) {
        if (!self.manager.configuration.movableCropBoxEditSize) {
            self.leftTopView.hidden = YES;
            self.leftBottomView.hidden = YES;
            self.rightTopView.hidden = YES;
            self.rightBottomView.hidden = YES;
        }
        YM_EditRatio *ratio = [[YM_EditRatio alloc] initWithValue1:self.manager.configuration.movableCropBoxCustomRatio.x value2:self.manager.configuration.movableCropBoxCustomRatio.y];
        if (self.manager.configuration.movableCropBoxCustomRatio.x > self.manager.configuration.movableCropBoxCustomRatio.y) {
            ratio.isLandscape = YES;
        }
        [self bottomViewDidSelectRatioClick:ratio];
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.alpha = 1;
            if (self.manager.configuration.movableCropBoxEditSize) {
                self.leftTopView.alpha = 1;
                self.leftBottomView.alpha = 1;
                self.rightTopView.alpha = 1;
                self.rightBottomView.alpha = 1;
            }
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.alpha = 1;
            self.leftTopView.alpha = 1;
            self.leftBottomView.alpha = 1;
            self.rightTopView.alpha = 1;
            self.rightBottomView.alpha = 1;
        }];
    }
}
- (void)startTimer {
    if (!self.manager.configuration.movableCropBox) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeClipImageView) userInfo:nil repeats:NO];
        }
    }else {
        self.bottomView.enabled = YES;
    }
}
- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)changeClipImageView {
    if (CGSizeEqualToSize(self.clippingRect.size, self.imageView.hx_size)) {
        [self stopTimer];
        return;
    }
    UIImage *image = [self clipImage];
    self.imageView.image = image;
    CGFloat imgW = self.rightTopView.center.x - self.leftTopView.center.x;
    CGFloat imgH = self.leftBottomView.center.y - self.leftTopView.center.y;
    self.imageView.frame = CGRectMake(self.leftTopView.center.x, self.leftTopView.center.y, imgW, imgH);
    self.gridLayer.frame = self.imageView.bounds;
    self.imageWidth = image.size.width;
    self.imageHeight = image.size.height;
    [self changeSubviewFrame:YES];
    [self stopTimer];
    self.bottomView.enabled = YES;
}
- (UIImage *)clipImage {
    CGFloat zoomScale = self.imageView.bounds.size.width / self.imageView.image.size.width;
    CGFloat widthScale = self.imageView.image.size.width / self.imageView.hx_w;
    CGFloat heightScale = self.imageView.image.size.height / self.imageView.hx_h;
    
    CGRect rct = self.clippingRect;
    rct.size.width  *= widthScale;
    rct.size.height *= heightScale;
    rct.origin.x    /= zoomScale;
    rct.origin.y    /= zoomScale;
    
    CGPoint origin = CGPointMake(-rct.origin.x, -rct.origin.y);
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(rct.size, NO, self.imageView.image.scale);
    [self.imageView.image drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}
- (void)panGridView:(UIPanGestureRecognizer*)sender {
    static BOOL dragging = NO;
    static CGRect initialRect;
    
    if (sender.state==UIGestureRecognizerStateBegan) {
        CGPoint point = [sender locationInView:self.imageView];
        dragging = CGRectContainsPoint(self.clippingRect, point);
        initialRect = self.clippingRect;
    } else if(dragging) {
        CGPoint point = [sender translationInView:self.imageView];
        CGFloat left  = MIN(MAX(initialRect.origin.x + point.x, 0), self.imageView.frame.size.width-initialRect.size.width);
        CGFloat top   = MIN(MAX(initialRect.origin.y + point.y, 0), self.imageView.frame.size.height-initialRect.size.height);
        
        CGRect rct = self.clippingRect;
        rct.origin.x = left;
        rct.origin.y = top;
        self.clippingRect = rct;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        [self startTimer];
    }else {
        [self stopTimer];
    }
}
- (void)setClippingRect:(CGRect)clippingRect {
    _clippingRect = clippingRect;
    
    self.leftTopView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y) fromView:_imageView];
    self.leftBottomView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y+_clippingRect.size.height) fromView:_imageView];
    self.rightTopView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y) fromView:_imageView];
    self.rightBottomView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y+_clippingRect.size.height) fromView:_imageView];
    
    self.gridLayer.clippingRect = clippingRect;
    [self.gridLayer setNeedsDisplay];
}
- (void)setClippingRatio:(YM_EditRatio *)clippingRatio {
    if(clippingRatio != self.clippingRatio){
        _clippingRatio = clippingRatio;
        [self clippingRatioDidChange:YES];
    }
}
- (void)clippingRatioDidChange:(BOOL)animated {
    CGRect rect = self.imageView.bounds;
    if (self.clippingRatio) {
        CGFloat H = rect.size.width * self.clippingRatio.ratio;
        if (H<=rect.size.height) {
            rect.size.height = H;
        } else {
            rect.size.width *= rect.size.height / H;
        }
        
        rect.origin.x = (self.imageView.bounds.size.width - rect.size.width) / 2;
        rect.origin.y = (self.imageView.bounds.size.height - rect.size.height) / 2;
    }
    [self setClippingRect:rect animated:animated];
}

- (void)setClippingRect:(CGRect)clippingRect animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.leftTopView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y) fromView:self.imageView];
            self.leftBottomView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y+clippingRect.size.height) fromView:self.imageView];
            self.rightTopView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y) fromView:self.imageView];
            self.rightBottomView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y+clippingRect.size.height) fromView:self.imageView];
        } completion:^(BOOL finished) {
            if (self.isSelectRatio) {
                if (!self.manager.configuration.movableCropBox) {
                    [self changeClipImageView];
                }
                self.isSelectRatio = NO;
            }
        }];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"clippingRect"];
        animation.duration = 0.2;
        animation.fromValue = [NSValue valueWithCGRect:_clippingRect];
        animation.toValue = [NSValue valueWithCGRect:clippingRect];
        [self.gridLayer addAnimation:animation forKey:nil];
        
        self.gridLayer.clippingRect = clippingRect;
        self.clippingRect = clippingRect;
        [self.gridLayer setNeedsDisplay];
    } else {
        self.clippingRect = clippingRect;
    }
}
- (void)panCircleView:(UIPanGestureRecognizer*)sender {
    CGPoint point = [sender locationInView:self.imageView];
    CGPoint dp = [sender translationInView:self.imageView];
    
    CGRect rct = self.clippingRect;
    
    const CGFloat W = self.imageView.frame.size.width;
    const CGFloat H = self.imageView.frame.size.height;
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = W;
    CGFloat maxY = H;
    
    CGFloat ratio = (sender.view.tag == 1 || sender.view.tag==2) ? -self.clippingRatio.ratio : self.clippingRatio.ratio;
    
    switch (sender.view.tag) {
        case 0: // upper left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = rct.origin.y - ratio * rct.origin.x;
                CGFloat x0 = -y0 / ratio;
                minX = MAX(x0, 0);
                minY = MAX(y0, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.x = point.x;
            rct.origin.y = point.y;
            break;
        }
        case 1: // lower left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio* rct.origin.x ;
                CGFloat xh = (H - y0) / ratio;
                minX = MAX(xh, 0);
                maxY = MIN(y0, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = point.y - rct.origin.y;
            rct.origin.x = point.x;
            break;
        }
        case 2: // upper right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat x0 = -y0 / ratio;
                maxX = MIN(x0, W);
                minY = MAX(yw, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.y = point.y;
            break;
        }
        case 3: // lower right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat xh = (H - y0) / ratio;
                maxX = MIN(xh, W);
                maxY = MIN(yw, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = point.y - rct.origin.y;
            break;
        }
        default:
            break;
    }
    self.clippingRect = rct;
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        [self startTimer];
    }else {
        [self stopTimer];
    }
}
#pragma mark - < YM_DatePhotoEditBottomViewDelegate >
- (void)bottomViewDidCancelClick {
    [self stopTimer];
    if (self.outside) {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)bottomViewDidRestoreClick {
    if (self.manager.configuration.movableCropBox) {
        if (CGPointEqualToPoint(self.manager.configuration.movableCropBoxCustomRatio, CGPointZero)) {
            self.clippingRatio = [[YM_EditRatio alloc] initWithValue1:0 value2:0];
        }
    }else {
        if (CGSizeEqualToSize(self.clippingRect.size, self.originalImage.size)) {
            [self stopTimer];
            return;
        }
        if (!self.originalImage || self.imageView.image == self.originalImage) {
            [self stopTimer];
            return;
        }
    }
    [self stopTimer];
    self.clippingRatio = nil;
    self.bottomView.enabled = NO;
    self.imageView.image = self.originalImage;
    self.imageWidth = self.model.imageSize.width;
    self.imageHeight = self.model.imageSize.height;
    [self changeSubviewFrame:YES];
}
- (void)bottomViewDidRotateClick {
    [self stopTimer];
    if (!self.manager.configuration.movableCropBox) {
        self.clippingRatio = nil;
    }
    self.bottomView.enabled = YES;
    self.imageView.image = [self.imageView.image rotationImage:UIImageOrientationLeft];
    self.imageWidth = self.imageView.image.size.width;
    self.imageHeight = self.imageView.image.size.height;
    [self changeSubviewFrame:YES];
}
- (void)bottomViewDidClipClick {
    [self stopTimer];
    if (self.manager.configuration.movableCropBox) {
        [self changeClipImageView];
    }
    YM_PhotoModel *model = [YM_PhotoModel photoModelWithImage:self.imageView.image];
    if (self.outside) {
        [self dismissViewControllerAnimated:NO completion:^{
            if ([self.delegate respondsToSelector:@selector(datePhotoEditViewControllerDidClipClick:beforeModel:afterModel:)]) {
                [self.delegate datePhotoEditViewControllerDidClipClick:self beforeModel:self.model afterModel:model];
            }
        }];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(datePhotoEditViewControllerDidClipClick:beforeModel:afterModel:)]) {
        [self.delegate datePhotoEditViewControllerDidClipClick:self beforeModel:self.model afterModel:model];
    }
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)bottomViewDidSelectRatioClick:(YM_EditRatio *)ratio {
    [self stopTimer];
    self.isSelectRatio = YES;
    if(ratio.ratio==0){
        [self bottomViewDidRestoreClick];
    } else {
        self.clippingRatio = ratio;
        if (self.manager.configuration.movableCropBox) {
            if (CGPointEqualToPoint(self.manager.configuration.movableCropBoxCustomRatio, CGPointZero)) {
                self.bottomView.enabled = YES;
            }
        }
    }
}
#pragma mark - < 懒加载 >
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.alpha = 0;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_imageView.layer addSublayer:self.gridLayer];
        self.imagePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGridView:)];
        _imageView.userInteractionEnabled = YES;
        [_imageView addGestureRecognizer:self.imagePanGesture];
    }
    return _imageView;
}
- (YM_DatePhotoEditBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[YM_DatePhotoEditBottomView alloc] initWithManager:self.manager];
        _bottomView.delegate = self;
    }
    return _bottomView;
}
- (YM_EditGridLayer *)gridLayer {
    if (!_gridLayer) {
        _gridLayer = [[YM_EditGridLayer alloc] init];
        _gridLayer.bgColor   = [[UIColor blackColor] colorWithAlphaComponent:.5];
        _gridLayer.gridColor = [UIColor whiteColor];
    }
    return _gridLayer;
}
- (YM_EditCornerView *)leftTopView {
    if (!_leftTopView) {
        _leftTopView = [self editCornerViewWithTag:0];
    }
    return _leftTopView;
}
- (YM_EditCornerView *)leftBottomView {
    if (!_leftBottomView) {
        _leftBottomView = [self editCornerViewWithTag:1];
    }
    return _leftBottomView;
}
- (YM_EditCornerView *)rightTopView {
    if (!_rightTopView) {
        _rightTopView = [self editCornerViewWithTag:2];
    }
    return _rightTopView;
}
- (YM_EditCornerView *)rightBottomView {
    if (!_rightBottomView) {
        _rightBottomView = [self editCornerViewWithTag:3];
    }
    return _rightBottomView;
}
- (YM_EditCornerView *)editCornerViewWithTag:(NSInteger)tag {
    YM_EditCornerView *view = [[YM_EditCornerView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    view.backgroundColor = [UIColor clearColor];
    view.bgColor = [UIColor whiteColor];
    view.tag = tag;
    view.alpha = 0;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCircleView:)];
    [view addGestureRecognizer:panGesture];
    [panGesture requireGestureRecognizerToFail:self.imagePanGesture];
    return view;
}


@end
