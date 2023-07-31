//
//  YM_ImageInterceptionView.m
//  EditImage-Demo
//
//  Created by 蒋天宝 on 2021/2/22.
//  Copyright © 2021 chk. All rights reserved.
//

#import "YM_ImageInterceptionView.h"
#import "YM_PhotoMaskView.h"
@interface YM_ImageInterceptionView () <UIScrollViewDelegate, YM_PhotoMaskViewDelegate>
{
    CGFloat _edge; // 圆形截图区域的边距
    CGFloat _circleSize; // 圆形截图区域大小
    UIColor * _shadowColor; // 阴影色
    CGFloat   _shadowAlpha; // 阴影透明度
    UIColor * _borderColor; // 边框线颜色
    
    CGRect            _rect;
    UIEdgeInsets      _imageInset;
}

@property (strong, nonatomic) UIScrollView * scrollView;

@property (strong, nonatomic) UIImageView * imageView;

@property (strong, nonatomic) YM_PhotoMaskView * viewMask;

@property (strong, nonatomic) UIImage * souceImage;

@end

@implementation YM_ImageInterceptionView

+ (YM_ImageInterceptionView *)xib {
    return
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([YM_ImageInterceptionView class])
                                  owner:self
                                options:nil].firstObject;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        self.userInteractionEnabled = YES;
        
        _shadowColor = [UIColor blackColor];
        _shadowAlpha = 0.4;
        
        _edge = 0;
        
        CGSize size = [[UIScreen mainScreen] bounds].size;
        _circleSize = size.width;
    }
    return self;
}

- (instancetype)initWithCircleSize:(CGFloat)size {
    if (self = [self init]) {
        _circleSize = size;
        _edge =  ([[UIScreen mainScreen] bounds].size.width - _circleSize) / 2.0;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_scrollView && _souceImage) {
        [self layoutView];
    }
}

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)fitScreenWithImage:(UIImage *)image {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize newSize;
    BOOL min = image.size.height>image.size.width;
    if (min && image.size.width < screenSize.width) {
        CGFloat scale = screenSize.width/image.size.width;
        newSize = CGSizeMake(screenSize.width, image.size.height*scale);
    }
    // 比圆大
    else if (min && image.size.width >= screenSize.width) {
        CGFloat scale = screenSize.width/image.size.width;
        newSize = CGSizeMake(screenSize.width, image.size.height*scale);
    } else{
        CGFloat scale = screenSize.width/image.size.height;
        newSize = CGSizeMake(image.size.width * scale, screenSize.width);
    }
     image = [self imageWithImageSimple:image scaledToSize:newSize];
    return image;
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    [self addSubview:self.scrollView];
    
    [_scrollView addSubview:self.imageView];
    
    [self addSubview:self.viewMask];
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
}

#pragma mark <YM_PhotoMaskViewDelegate>
- (void)photoMaskView:(YM_PhotoMaskView *)maskView scrollViewRect:(CGRect)rect {
    _rect = rect;
    CGFloat top = (_souceImage.size.height-_rect.size.height)/2;
    CGFloat left = (_souceImage.size.width-_rect.size.width)/2;
    CGFloat bottom = self.bounds.size.height-top-_rect.size.height;
    CGFloat right = self.bounds.size.width-_rect.size.width-left;
    self.scrollView.contentInset = UIEdgeInsetsMake(top, left, bottom, right);
    CGFloat maskCircleWidth = _rect.size.width;
    
    CGSize imageSize = _souceImage.size;
    //setp 2: setup contentSize:
    CGFloat minimunZoomScale = imageSize.width < imageSize.height ? maskCircleWidth / imageSize.width : maskCircleWidth / imageSize.height;
    CGFloat maximumZoomScale = 1.5;
    self.scrollView.minimumZoomScale = minimunZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
    self.scrollView.zoomScale = self.scrollView.zoomScale < minimunZoomScale ? minimunZoomScale : self.scrollView.zoomScale;
    _imageInset = self.scrollView.contentInset;
}

#pragma mark public
/// 裁剪图片
- (UIImage *)cropImage {
    // 获取当前图片视图和源图片比例
    CGFloat imageViewWidth = _imageView.frame.size.width / _scrollView.zoomScale;
    CGFloat imageViewHeight = _imageView.frame.size.height / _scrollView.zoomScale;
    CGFloat widthZoom = imageViewWidth / _souceImage.size.width;
    CGFloat heightZoom = imageViewHeight / _souceImage.size.height;
    
    // 转换裁剪坐标
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGRect rect = CGRectMake(_edge, screenSize.height / 2 - _circleSize / 2, _circleSize, _circleSize);
    CGRect newRect = [_viewMask convertRect:rect toView:_imageView];
    newRect = CGRectMake(newRect.origin.x / widthZoom, newRect.origin.y / heightZoom, newRect.size.width / widthZoom, newRect.size.height / heightZoom);
    
    // 进行裁剪
    CGImageRef imageRef = CGImageCreateWithImageInRect([_souceImage CGImage], newRect);
    UIImage * image = [UIImage imageWithCGImage:imageRef scale:_souceImage.scale orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    
    return image;
}

#pragma mark setter
/// 设置源图像
/// @param image 要截取的图像
- (void)setSourceImage:(UIImage *)image {
    if (image) {
        _souceImage = [self fitScreenWithImage:image];
    }
}

/// 背景色
- (void)setBackColor:(UIColor *)backColor {
    self.backgroundColor = backColor;
}

#pragma mark 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        scrollView.delegate = self;
        scrollView.contentSize = _souceImage.size;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.bounces = YES;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView * imageView = [[UIImageView alloc] initWithImage:_souceImage];
        imageView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        imageView.userInteractionEnabled = NO;
        _imageView = imageView;
    }
    return _imageView;
}

- (YM_PhotoMaskView *)viewMask {
    if (!_viewMask) {
        YM_PhotoMaskView * view = [[YM_PhotoMaskView alloc] initWithFrame:self.bounds cropSize:_circleSize];
        view.delegate = self;
        [view setShadowAlpha:_shadowAlpha];
        [view setShadowColor:_shadowColor];
        [view setBackColor:self.backgroundColor];
        [view setBorderColor:_borderColor];
        view.borderColor = _borderColor;
        view.lineDashPattern = _lineDashPattern;
        _viewMask = view;
    }
    return _viewMask;
}


@end
