//
//  YM_BaseNavigationController.m
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import "YM_BaseNavigationController.h"
#import "YM_PanGestureRecognizer.h"
#import "YM_BaseViewController.h"

@interface YM_BaseNavigationController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) YM_PanGestureRecognizer * pan;

@property (strong, nonatomic) UIView                  * backView;

@property (assign, nonatomic) BOOL                      animatedFlag;

@property (strong, nonatomic) UIImageView             * backImageView;

@property (strong, nonatomic) NSMutableArray          * imageArray;

/** 截取上一层级的界面，在拖动返回的时候进行展示 */
@property (strong, nonatomic) UIImage                 * fristImg;

@end

/** 拖动手势范围 */
static CGFloat kPanSize = 100;

@implementation YM_BaseNavigationController

- (void)dealloc {
    NSLog(@"导航栏 %@ 释放", self);
    [self removeObserver];
}

- (instancetype)init {
    if (self = [super init]) {
        _modalStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.hidden = YES;
    self.interactivePopGestureRecognizer.enabled = NO;
    [self.backView addSubview:self.backImageView];
    _backView.backgroundColor = [UIColor whiteColor];
    
    [self.view addGestureRecognizer:self.pan];
    
    [self addObserver];
}

#pragma mark - 观察者
- (void)addObserver {
    [_pan addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"state"]) {
        [self stateChange:_pan.state];
    }
}

- (void)removeObserver {
    @try {
        [_pan removeObserver:self forKeyPath:@"state"];
    } @catch (NSException *exception) {
        NSLog(@"%s: %@", __FUNCTION__, exception.reason);
    }
}

#pragma mark - push method/pop method
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated {
    [self startAnimated:animated];
    [super pushViewController:viewController animated:animated];
    // 修改tabBra的frame
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.tabBarController.tabBar.frame = frame;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self startAnimated:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return [super popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController
                                            animated:(BOOL)animated {
    [self startAnimated:animated];
    BOOL start = NO;
    for (UIViewController * tempVC in self.viewControllers) {
        if (start) {
            if ([tempVC canPerformAction:@selector(customDealloc) withSender:nil]) {
                [tempVC performSelector:@selector(customDealloc)];
            }
            [[NSNotificationCenter defaultCenter] removeObserver:tempVC];
            continue;
        }
        if ([tempVC isEqual:viewController]) {
            start = YES;
        }
    }
    return [super popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    [self startAnimated:animated];
    for (NSInteger i = 1; i < [self.viewControllers count]; i++) {
        UIViewController * tempVC = self.viewControllers[i];
        if ([tempVC canPerformAction:@selector(customDealloc) withSender:nil]) {
            [tempVC performSelector:@selector(customDealloc)];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:tempVC];
    }
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark - <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // 判断当前界面是否可以pop
    if (self.viewControllers.count == 1) {
        return NO;
    }
    
    // 是否可以拖拽
    if(_isPan == NO) {
        return NO;
    }

    // 动画进行中
    if (self.animatedFlag) {
        return NO;
    }
    
    // 获取触摸点在当前控制器视图上的位置
    CGPoint touchPoint = [gestureRecognizer locationInView:self.controllerWrapperView];
    
    // 如果触摸点在屏幕外、或者在状态栏上，不允许拖拽
    if (touchPoint.x < 0 ||
        touchPoint.y < 20 ||
        touchPoint.x > self.view.frame.size.width) {
        return NO;
    }
    
    // 获取移动距离（x,y > 0 为向右、向下滑动）
    CGPoint translation = [gestureRecognizer translationInView:self.view];
    
    // 判断是否为向右滑动
    if (translation.x <= 0) {
        return NO;
    }
    
    // 判断全局触摸，如果全局触摸关闭，则判断触摸范围
    if(_globalTouch == NO && touchPoint.x >= kPanSize) {
        return NO;
    }
    
    // 是否是右滑
    BOOL succeed = fabs(translation.y / translation.x) < tan(M_PI/6);
    return succeed;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (![gestureRecognizer isEqual:self.pan]) {
        return YES;
    }
    
    // 获取开始触摸点的坐标
    CGPoint touchPoint = [self.pan beganLocationInView:self.controllerWrapperView];
    
    // 是否允许触摸
    if(_isPan == NO) {
        return NO;
    }
    
    // 触摸对象是否为当前拖拽屏幕的触摸对象
    if (gestureRecognizer != self.pan) {
        return NO;
    }
    
    // 触摸状态不是触摸开始
    if (self.pan.state != UIGestureRecognizerStateBegan) {
        return NO;
    }
    
    // 判断全局触摸，如果全局触摸关闭，则判断触摸范围
    if(_globalTouch == NO && touchPoint.x >= kPanSize){
        return NO;
    }
    
    // 判断触摸状态是否为开始状态，如果是其他的状态，则返回允许
    if (otherGestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return YES;
    }
    
    // 点击区域判断 如果在左边 40 以内, 强制手势后退
    if (touchPoint.x < kPanSize) {
        [self cancelOtherGestureRecognizer:otherGestureRecognizer];
        return YES;
    }
    
    // 如果是scrollview 或者webview,手势禁止
    if ([[otherGestureRecognizer view] isKindOfClass:[UIScrollView class]]) {
        return NO;
    }
    
    return NO;
}

- (void)cancelOtherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSSet *touchs = [self.pan.event touchesForGestureRecognizer:otherGestureRecognizer];
    [otherGestureRecognizer touchesCancelled:touchs withEvent:self.pan.event];
}


#pragma mark - <YM_PanGestureDelegate>
/** 拖拽开始 */
- (void)startPanBack {
    
}

/**
 完成拖拽
 @param reset 是否重置拖拽
 */
- (void)finshPanBackWithReset:(BOOL)reset {
    if (reset) {
        [self resetPanBack];
    } else {
        [self finshPanBack];
    }
}

/** 拖拽完成 */
- (void)finshPanBack {
    
}

/** 拖拽重置 */
- (void)resetPanBack {
    
}

#pragma mark - getter
- (UIView *)controllerWrapperView {
    return self.visibleViewController.view.superview;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return _modalStyle;
}


#pragma mark - private
/** 启用动画 */
- (void)startAnimated:(BOOL)animated {
    self.animatedFlag = YES;
    NSTimeInterval delay = animated ? 0.8 : 0.1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishedAnimated) object:nil];
    [self performSelector:@selector(finishedAnimated) withObject:nil afterDelay:delay];
}

/** 完成动画 */
- (void)finishedAnimated {
    self.animatedFlag = NO;
}

- (BOOL)shouldAutorotate{
    UIViewController *vc = self.topViewController;
    BOOL shouldAutorotate = [vc shouldAutorotate];
//    NSLog(@"21 %d", shouldAutorotate);
    return shouldAutorotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.topViewController;
    UIInterfaceOrientation orientation = [vc preferredInterfaceOrientationForPresentation];
//    NSLog(@"22 %d", orientation);
    return orientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.topViewController;
    UIInterfaceOrientationMask orientation = [vc supportedInterfaceOrientations];
//    NSLog(@"23 %d", orientation);
    return orientation;
}

- (void)stateChange:(UIGestureRecognizerState)state {
    switch (state) {
        case UIGestureRecognizerStatePossible: {
            break;
        }
        case UIGestureRecognizerStateBegan: {
            //调用代理方法
            [self startPanBack];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            break;
        }
        case UIGestureRecognizerStateFailed: {
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            //拖动速度
            CGPoint velocity = [self.pan velocityInView:self.view];
            //手指触摸的坐标
            CGPoint touchPoint = [self.pan translationInView:self.view];
            BOOL reset;
            if (touchPoint.x >=self.view.frame.size.width/3 || velocity.x > 1000) {
                reset = NO;
            } else {
                reset = YES;
            }
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [UIView animateWithDuration:0.3 animations:^{
                
            } completion:^(BOOL finished) {
                //代理回调拖动是否成功
                [self finshPanBackWithReset:reset];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }];
            break;
        }
        default:
            break;
    }
}


#pragma mark - 懒加载
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    return _backView;
}

- (UIImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    }
    return _backImageView;
}

- (YM_PanGestureRecognizer *)pan {
    if (!_pan) {
        // 实现全屏滑动的关键代码
        NSString * handle = @"handleNavigation";
        NSString * transition = @"Transition:";
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@", handle, transition]);
        _pan = [[YM_PanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:sel];
        _pan.delegate = self;
        _pan.maximumNumberOfTouches = 1;
    }
    return _pan;
}

@end
