//
//  UIViewController+YMHUDCategory.m
//  DS_Lottery
//
//  Created by huangyuzhou on 2018/9/9.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "UIViewController+YMHUDCategory.h"
#import "MBProgressHUD.h"
@implementation UIViewController (YMHUDCategory)

- (void)showhud {
    [self removesubviewshud];
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.hidden = NO;
    });
}

- (void)showhudtext:(NSString *)text {
    [self removesubviewshud];
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = text;
    });
}

- (void)showMessagetext:(NSString *)text {
    [self removesubviewshud];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!text) {
            return;
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = text;
        hud.label.adjustsFontSizeToFitWidth = YES;
        hud.offset = CGPointMake(0.f, 0);
        [hud hideAnimated:YES afterDelay:1.0f];
    });
}

-(void)hidehud {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView * view in self.view.subviews)
        {
            if ([view isKindOfClass:[MBProgressHUD class]])
            {
                MBProgressHUD *hud = (MBProgressHUD *)view;
                [hud hideAnimated:YES];
            }
        }
    });
}

-(void)hudSuccessText:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Set the custom view mode to show any view.
        hud.mode = MBProgressHUDModeCustomView;
        // Set an image view with a checkmark.
        UIImage *image = [[UIImage imageNamed:@"MBHUD_Success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        // Looks a bit nicer if we make it square.
        hud.square = YES;
        // Optional label text.
        hud.label.text = text;
        
        [hud hideAnimated:YES afterDelay:2.f];
    });
}

- (void)hudErrorText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Set the custom view mode to show any view.
        hud.mode = MBProgressHUDModeCustomView;
        // Set an image view with a checkmark.
        UIImage *image = [[UIImage imageNamed:@"MBHUD_Error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        // Looks a bit nicer if we make it square.
        hud.square = YES;
        // Optional label text.
        hud.label.text = text;
        
        [hud hideAnimated:YES afterDelay:2.f];
    });
}

- (void)removesubviewshud {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView * view in self.view.subviews) {
            if ([view isKindOfClass:[MBProgressHUD class]]) {
                [view removeFromSuperview];
            }
        }
    });
}


@end
