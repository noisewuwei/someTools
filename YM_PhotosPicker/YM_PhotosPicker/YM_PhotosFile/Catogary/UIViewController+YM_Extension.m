//
//  UIViewController+YM_Extension.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "UIViewController+YM_Extension.h"
#import "YM_PhotoPicker.h"

@implementation UIViewController (YM_Extension)

- (void)hx_presentAlbumListViewControllerWithManager:(YM_PhotoManager *)manager delegate:(id)delegate {
    YM_AlbumListViewController *vc = [[YM_AlbumListViewController alloc] init];
    vc.delegate = delegate ? delegate : (id)self;
    vc.manager = manager;
    YM_CustomNavigationController *nav = [[YM_CustomNavigationController alloc] initWithRootViewController:vc];
    nav.supportRotation = manager.configuration.supportRotation;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)hx_presentAlbumListViewControllerWithManager:(YM_PhotoManager *)manager done:(YM_AlbumListVCDoneBlock)done cancel:(YM_AlbumListVCCancelBlock)cancel {
    YM_AlbumListViewController *vc = [[YM_AlbumListViewController alloc] init];
    vc.manager = manager;
    vc.doneBlock = done;
    vc.cancelBlock = cancel;
    vc.delegate = (id)self;
    YM_CustomNavigationController *nav = [[YM_CustomNavigationController alloc] initWithRootViewController:vc];
    nav.supportRotation = manager.configuration.supportRotation;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)hx_presentCustomCameraViewControllerWithManager:(YM_PhotoManager *)manager delegate:(id)delegate {
    YM_CustomCameraViewController *vc = [[YM_CustomCameraViewController alloc] init];
    vc.delegate = delegate ? delegate : (id)self;
    vc.manager = manager;
    vc.isOutside = YES;
    YM_CustomNavigationController *nav = [[YM_CustomNavigationController alloc] initWithRootViewController:vc];
    nav.isCamera = YES;
    nav.supportRotation = manager.configuration.supportRotation;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)hx_presentCustomCameraViewControllerWithManager:(YM_PhotoManager *)manager done:(YM_CustomCameraViewControllerDidDoneBlock)done cancel:(YM_CustomCameraViewControllerDidCancelBlock)cancel {
    YM_CustomCameraViewController *vc = [[YM_CustomCameraViewController alloc] init];
    vc.doneBlock = done;
    vc.cancelBlock = cancel;
    vc.manager = manager;
    vc.isOutside = YES;
    vc.delegate = (id)self;
    YM_CustomNavigationController *nav = [[YM_CustomNavigationController alloc] initWithRootViewController:vc];
    nav.isCamera = YES;
    nav.supportRotation = manager.configuration.supportRotation;
    [self presentViewController:nav animated:YES completion:nil];
}

- (BOOL)navigationBarWhetherSetupBackground {
    if ([self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]) {
        return YES;
    }else if ([self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompact]) {
        return YES;
    }else if ([self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefaultPrompt]) {
        return YES;
    }else if ([self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompactPrompt]) {
        return YES;
    }else if (self.navigationController.navigationBar.backgroundColor) {
        return YES;
    }
    return NO;
}

#pragma mark - 授权
/**
 显示授权提示
 @param type 要授权的类型
 */
- (void)showAuthorizationWithtType:(YM_AuthorizationType)type {
    
    // 界面提示内容、提示弹窗内容
    NSString * content = @"";
    NSString * alert = @"";
    NSString * guide = @"";
    if (type == YM_AuthorizationType_Photo) {
        content = @"无法访问照片\n请点击这里前往设置中允许访问照片";
        alert = @"无法访问相册";
        guide = @"请在设置-隐私-相册中允许访问相册";
    } else if (type == YM_AuthorizationType_Camera) {
        content = @"";
    }
    
    // 在界面上加载提示内容
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 100)];
    label.text = [NSBundle ym_localizedStringForKey:content];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goSetup)]];
    [self.view addSubview:label];
    
    // 显示授权提示框
    [self showAuthorizationAlert:alert guide:guide left:@"取消" right:@"设置"];
}

/**
 显示授权提示框
 @param alert       提示内容
 @param guide       提示引导
 @param leftStr     左侧按钮内容
 @param rightString 右侧按钮内容
 */
- (void)showAuthorizationAlert:(NSString *)alert
                         guide:(NSString *)guide
                          left:(NSString *)leftStr
                         right:(NSString *)rightString {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:[NSBundle ym_localizedStringForKey:alert] message:[NSBundle ym_localizedStringForKey:guide] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:leftStr] style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ym_localizedStringForKey:rightString] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/** 跳转设置 */
- (void)goSetup {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
