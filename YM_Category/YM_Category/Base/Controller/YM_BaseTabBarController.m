//
//  YM_BaseTabBarController.m
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import "YM_BaseTabBarController.h"
#import "YM_BaseViewController.h"
#import "YM_BaseNavigationController.h"
#import "YM_BaseTabBar.h"
#import "YM_BaseTool.h"

#pragma mark - UITabBarController+autoRotate
@interface UITabBarController (autoRotate)

- (BOOL)shouldAutorotate;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;

@end

@implementation UITabBarController (autoRotate)

- (BOOL)shouldAutorotate{
    BOOL shouldAutorotate = [self.selectedViewController shouldAutorotate];
//    NSLog(@"11 %d", shouldAutorotate);
    return shouldAutorotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIInterfaceOrientation orientation = [self.selectedViewController preferredInterfaceOrientationForPresentation];
//    NSLog(@"12 %d", orientation);
    return orientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    UIInterfaceOrientationMask orientation = [self.selectedViewController supportedInterfaceOrientations];
//    NSLog(@"13 %d", orientation);
    return orientation;
}

@end

#pragma mark - YM_TabbarControllerModel
@interface YM_TabbarControllerModel ()

/** 子控制器 */
@property (strong, nonatomic) UIViewController * viewController;

/** 标题 */
@property (copy, nonatomic) NSString * title;

/** 默认图片 */
@property (copy, nonatomic) NSString * norImageName;

/** 选中图片 */
@property (copy, nonatomic) NSString * preImageName;

@end

@implementation YM_TabbarControllerModel

+ (instancetype)initWithVC:(UIViewController *)vc
                     title:(NSString *)title
              norImageName:(NSString *)norImageName
              preImageName:(NSString *)preImageName {
    YM_TabbarControllerModel * model = [YM_TabbarControllerModel new];
    model.viewController = vc;
    model.title = title;
    model.norImageName = norImageName;
    model.preImageName = preImageName;
    return model;
}


@end

#pragma mark - YM_BaseTabBarController
@interface YM_BaseTabBarController () {
    NSArray <YM_TabbarControllerModel *> * _tabbarModels;
}
@property (strong, nonatomic) YM_BaseTabBar * ymTabBar;

@end

@implementation YM_BaseTabBarController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithModels:(NSArray <YM_TabbarControllerModel *> *)models {
    if (self = [super init]) {
        _tabbarColor = [UIColor whiteColor];
        if ([models count] > 0) {
            _tabbarModels = models;
            [self layoutView];
        } else {
            @throw [NSException exceptionWithName:@"init error"
                                           reason:@"controllers is nil" userInfo:nil];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [_ymTabBar setBarTintColor:_tabbarColor];
}

#pragma mark - 初始化
- (void)layoutView {
    
    // 便利创建工具栏控制器
    NSMutableArray * navs = [NSMutableArray array];
    NSMutableArray * titles = [NSMutableArray array];
    NSMutableArray * selImageNames = [NSMutableArray array];
    NSMutableArray * preImageNames = [NSMutableArray array];
    NSMutableArray * normalColors = [NSMutableArray array];
    NSMutableArray * highColors = [NSMutableArray array];
    for (YM_TabbarControllerModel * model in _tabbarModels) {
        [navs addObject:model.viewController];
        [titles addObject:model.title];
        [selImageNames addObject:model.norImageName];
        [preImageNames addObject:model.preImageName];
        [normalColors addObject:model.normalColor ? model.normalColor : [UIColor new]];
        [highColors addObject:model.highColor ? model.highColor : [UIColor new]];
    }
    
    // 设置工具栏颜色
    _ymTabBar = [[YM_BaseTabBar alloc] initWithFrame:CGRectMake(0, 0, ymScreenWidth, ymTabBarHeight)
                                            titles:titles
                                      norImageNames:selImageNames
                                      preImageNames:preImageNames
                                        normalColors:normalColors
                                           selColors:highColors];
    [_ymTabBar setBarTintColor:_tabbarColor];
    _ymTabBar.translucent = NO;
    __weak __typeof(self) weakSelf = self;
    _ymTabBar.selectIndexBlock = ^(NSInteger index) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (index != self.selectedIndex) {
            self.selectedIndex = index;
        }
    };
    [self setValue:_ymTabBar forKeyPath:@"tabBar"];
    
    
    
    [self setViewControllers:navs];
    [self selectedIndex:0];
}

/** 选中 */
- (void)selectedIndex:(NSInteger )index {
    [_ymTabBar setSelectedIndex:index];
}

@end
