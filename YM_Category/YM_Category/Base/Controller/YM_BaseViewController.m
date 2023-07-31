//
//  YM_BaseViewController.m
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import "YM_BaseViewController.h"
#import "YM_BaseTool.h"
#import "YM_BaseNavigationController.h"
#import "YM_BaseTabBarController.h"

@interface YM_BaseViewController () <UINavigationControllerDelegate> {
    // 导航栏标题
    NSString * _title;
    
    // 是否透明导航栏（可交互）
    BOOL _transparentNav;
    
    // 是否隐藏导航栏（不可交互）
    BOOL _hideNav;
    
    // 默认导航栏颜色
    UIColor * _normalNavColor;
}

/** 导航栏 */
@property (nonatomic, strong) UIImageView * navigationBar;

/* 导航栏标题 */
@property (strong, nonatomic) UILabel * titleLabel;

/** 标题图片（不能与titleName共用） */
@property (strong, nonatomic) UIImageView * titleImageView;

/** 导航栏线条 */
@property (strong, nonatomic) UIView * lineView;

/** 动画进行中 */
@property (assign, nonatomic) BOOL animatedFlag;

/** 截取上一层级的界面，在拖动返回的时候进行展示（视图） */
@property (strong, nonatomic) UIImageView * screenShotView;

/** 截取上一层级的界面，在拖动返回的时候进行展示(图片) */
@property (strong, nonatomic) UIImage * screenShot;

/** 渐变背景色 */
@property (strong, nonatomic) CAGradientLayer * gradientLayer;

@property (strong, nonatomic) UIView * leftView;
@property (strong, nonatomic) UIView * rightView;

@end

@implementation YM_BaseViewController

- (void)dealloc {
    NSLog(@"控制器 %@ 释放", self);
    [self removeNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    if ([self.navigationController isKindOfClass:[YM_BaseNavigationController class]]) {
        YM_BaseNavigationController * nav = (YM_BaseNavigationController *)self.navigationController;
        nav.isPan = _isPan;
        nav.globalTouch = _globalTouch;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navigationController.viewControllers == 0) {
        [self runRelease];
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent animated:NO];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        // 禁用掉自动设置的内边距，自行控制controller上index为0的控件以及scrollview控件的位置
        self.automaticallyAdjustsScrollViewInsets = NO;
        // 视图延伸不考虑透明的Bars(这里包含导航栏和状态栏)
        // 意思就是延伸到边界
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
        // 一键关闭iOS13+深色模式
        // plist中的UIUserInterfaceStyleLight同样作用
    //    if (@available(iOS 13.0, *)) {
    //        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    //    }

    [self initBaseData];
    [self initBaseUI];
}

#pragma mark - 初始化
- (void)initBaseData {
    // 是否可拖拽
    _isPan = YES;
    
    // 是否可全界面拖拽
    _globalTouch = NO;
    
    // 默认导航栏颜色
    _normalNavColor = [UIColor whiteColor];
}

/* 初始化 */
- (void)initBaseUI {
    self.view.backgroundColor = [UIColor whiteColor];
//    self.view.layer.contents = (__bridge id)kImageName(@"public_back").CGImage;
    // 在主线程异步加载，使下面的方法最后执行，防止其他的控件挡住了导航栏
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.navigationBar];
        [self.navigationBar addSubview:self.titleLabel];
        [self.navigationBar addSubview:self.titleImageView];
    });
    
    // 初始化
    [self.view addSubview:self.screenShotView];
}

#pragma mark - 界面
- (void)layoutView {

}

/** 模态出指定界面（带导航栏） */
- (void)presentViewController:(UIViewController *)vc haveNavBar:(BOOL)haveNavBar {
    if (haveNavBar) {
        YM_BaseNavigationController * nav = [[YM_BaseNavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    } else {
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
}

/** 设置工具栏索引 */
- (void)setTabbarIndex:(NSInteger)index {
    if ([self.tabBarController isKindOfClass:[YM_BaseTabBarController class]]) {
        YM_BaseTabBarController * tabbarVC = (YM_BaseTabBarController *)self.tabBarController;
        [tabbarVC selectedIndex:index];
    } else {
        [self.tabBarController setSelectedIndex:index];
    }
}

- (NSInteger)tabbarIndex {
    if ([self.tabBarController isKindOfClass:[YM_BaseTabBarController class]]) {
        YM_BaseTabBarController * tabbarVC = (YM_BaseTabBarController *)self.tabBarController;
        return [tabbarVC selectedIndex];
    } else {
        return self.tabBarController.selectedIndex;
    }
}


#pragma mark - 导航栏左右侧视图
/**
 导航栏左侧视图
 @param leftItem 左侧元素
 */
- (void)leftNavigationItem:(UIView *)leftItem {
    [self.navigationBar addSubview:leftItem];
    
    CGFloat width = leftItem.frame.size.width > ymScreenWidth / 3 - 20? ymScreenWidth / 3 - 20:leftItem.frame.size.width;
    leftItem.frame = CGRectMake(15, ymStatusBarHeight , width, ymNavBarHeight);
}

/**
 导航栏左侧按钮构建方法
 @param target 事件响应对象
 @param sel    方法
 @return UIButton
 */
- (UIButton *)leftBtnWithTarget:(id)target
                            sel:(SEL)sel {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, ymRatio(35), ymRatio(35));
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [button addTarget:target
               action:sel
     forControlEvents:UIControlEventTouchUpInside];
    
    UIImage * image = [UIImage imageNamed:@"public_nav_arrow"];
//    if (ymIsiPad) {
//        image = [self scaleImage:image toScale:1.5];
//    }
    [button setImage:image
            forState:UIControlStateNormal];
    
    _leftView = button;
    return button;
}

/**
 导航栏右侧视图
 @param rightItem 右侧元素
 */
- (void)rightNavigationItem:(UIView *)rightItem{
    [self.navigationBar addSubview:rightItem];
    CGFloat width = rightItem.frame.size.width > self.view.frame.size.width / 3 - 20? self.view.frame.size.width / 3 - 20 : rightItem.frame.size.width;
    rightItem.frame = CGRectMake(self.view.frame.size.width - width - 15, ymStatusBarHeight , width, ymNavBarHeight);
    _rightView = rightItem;
}

#pragma mark - 按钮事件
- (void)leftButtonAction:(UIButton *)sender {
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)rightButtonAction:(UIButton *)sender {
    
}

#pragma mark - public
/** 让导航栏透明 */
- (void)transparentNavigation {
    _transparentNav = YES;
}

/** 让导航栏隐藏 */
- (void)hideNavigation {
    _hideNav = YES;
}

/** 注册通知（子类重写） */
- (void)registerNotification {}

/** 移除通知(deallo时自动调用) */
- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** 进行重写，执行要释放的代码 */
- (void)runRelease {}

#pragma mark - 手势
/**
 标题点击手势
 @param tapGesture 手势对象
 */
- (void)titleTapAction:(UITapGestureRecognizer *)tapGesture {
    
}

#pragma mark - private
- (void)startAnimated:(BOOL)animated {
    self.animatedFlag = YES;
    NSTimeInterval delay = animated ? 0.8 : 0.1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(finishedAnimated) object:nil];
    [self performSelector:@selector(finishedAnimated)
               withObject:nil
               afterDelay:delay];
}

- (void)finishedAnimated {
    self.animatedFlag = NO;
}

- (BOOL)shouldAutorotate {
    return _allowAutorotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        interfaceOrientation = UIInterfaceOrientationLandscapeRight;
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
    } else {
        interfaceOrientation = UIInterfaceOrientationPortrait;
    }
    return interfaceOrientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask orientation;
    orientation = _allowAutorotate ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    return orientation;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self startAnimated:animated];
    return [self.navigationController popViewControllerAnimated:animated];
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - setter
- (void)setTitle:(NSString *)title {
    if (title) {
        _title = title;
        _titleLabel.text = title;
        _titleLabel.hidden = NO;
        _titleImageView.hidden = YES;
    }
}

- (void)setNavigationBarImage:(UIImage *)navigationBarImage {
    if (navigationBarImage) {
        _navigationBarImage = navigationBarImage;
        _titleImageView.hidden = NO;
        _titleLabel.hidden = YES;
        _titleImageView.image = navigationBarImage;
        
        CGFloat width = _navigationBarImage.size.width;
        CGFloat height = _navigationBarImage.size.height;
        CGFloat x = _navigationBar.frame.size.width / 2 - width / 2.0;
        CGFloat y = _navigationBar.frame.size.height / 2 - height / 2.0 + 10;
        _titleImageView.frame = CGRectMake(x, y, width, height);
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (titleColor) {
        _titleColor = titleColor;
        _titleLabel.textColor = titleColor;
    }
}

- (void)setGradientColors:(NSArray<UIColor *> *)gradientColors {
    if (gradientColors) {
        _gradientColors = gradientColors;
        _gradientLayer.colors = [self gradientCGColors];
    }
}

- (void)setIsPan:(BOOL)isPan {
    _isPan = isPan;
    YM_BaseNavigationController * nav = (YM_BaseNavigationController *)self.navigationController;
    nav.isPan = _isPan;
    nav.globalTouch = _globalTouch;
}

#pragma mark override
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dismissViewControllerAnimated:flag completion:completion];
}

#pragma mark - getter
- (NSString *)title {
    return _title;
}

/** 将UIColor数组转为CGColor数组（渐变色功能） */
- (NSArray <CIColor *> *)gradientCGColors {
    NSMutableArray * mArray = [NSMutableArray array];
    for (id color in _gradientColors) {
        if ([color isKindOfClass:[UIColor class]]) {
            CGColorRef cgColor = ((UIColor *)color).CGColor;
            [mArray addObject:(__bridge id)cgColor];
        }
    }
    return mArray;
}

#pragma mark - 懒加载
- (UIImageView *)screenShotView {
    if (!_screenShotView) {
        _screenShotView = [[UIImageView alloc] initWithFrame:self.view.frame];
    }
    return _screenShotView;
}

/* 导航栏 */
- (UIImageView *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ymScreenWidth, ymNavigationHeight)];
        _navigationBar.userInteractionEnabled = YES;
        [_navigationBar.layer addSublayer:self.gradientLayer];
        
        // 设置导航栏背景色
        _navigationBar.backgroundColor = _normalNavColor;
//        _navigationBar.image = kImageName(@"navigation_back");
        
        // 添加线段
        [_navigationBar addSubview:self.lineView];
        
        // 如果透明导航栏
        if (_transparentNav) {
            _navigationBar.hidden = NO;
            _navigationBar.backgroundColor = [UIColor clearColor];
            _lineView.hidden = YES;
            _gradientLayer.hidden = YES;
        }
        
        // 如果隐藏导航栏
        if (_hideNav) {
            _navigationBar.hidden = YES;
            _lineView.hidden = YES;
            _gradientLayer.hidden = YES;
        }
    }
    return _navigationBar;
}


- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = _navigationBar.bounds;
        
        NSMutableArray * mArray = [NSMutableArray array];
        for (id color in _gradientColors) {
            if ([color isKindOfClass:[UIColor class]]) {
                CGColorRef cgColor = ((UIColor *)color).CGColor;
                [mArray addObject:(__bridge id)cgColor];
            }
        }
        
        _gradientLayer.colors = [self gradientCGColors];
        _gradientLayer.startPoint = CGPointMake(0.5, 1);
        _gradientLayer.endPoint = CGPointMake(0.5, 0);
    }
    return _gradientLayer;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.frame = CGRectMake(0, _navigationBar.frame.size.height, _navigationBar.frame.size.width, 0.5);
        _lineView.backgroundColor = [UIColor clearColor];;
    }
    return _lineView;
}

/* 标题标签 */
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
//        _titleLabel.frame = CGRectMake(_navigationBar.width / 3,
//                                       ymStatusBarHeight,
//                                       _navigationBar.width / 3,
//                                       _navigationBar.height - ymStatusBarHeight);
        _titleLabel.frame = CGRectMake(40, ymStatusBarHeight, _navigationBar.frame.size.width - 80, ymNavBarHeight);
        _titleLabel.textColor = _titleColor ? _titleColor : [UIColor blackColor];
        _titleLabel.font = ymFont(17.0);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = _title;
    }
    return _titleLabel;
}

- (UIImageView *)titleImageView {
    if (!_titleImageView) {
        _titleImageView = [[UIImageView alloc] init];
        _titleImageView.userInteractionEnabled = YES;
        if (_navigationBarImage) {
            _titleImageView.image = _navigationBarImage;
            _titleImageView.hidden = NO;
            _titleLabel.hidden = YES;
        } else {
            _titleImageView.hidden = YES;
            _titleLabel.hidden = NO;
        }
        
        CGFloat width = _navigationBarImage.size.width;
        CGFloat height = _navigationBarImage.size.height;
        CGFloat x = _navigationBar.frame.size.width / 2 - width / 2.0;
        CGFloat y = _navigationBar.frame.size.height / 2 - height / 2.0 + 10;
        _titleImageView.frame = CGRectMake(x, y, width, height);
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapAction:)];
        [_titleImageView addGestureRecognizer:tapGesture];
    }
    return _titleImageView;
}

@end
