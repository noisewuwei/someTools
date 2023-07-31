//
//  YM_PhotoCustomNavigationBar.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PhotoCustomNavigationBar.h"
#import "YM_PhotoTools.h"
@interface YM_PhotoCustomNavigationBar ()

@end

@implementation YM_PhotoCustomNavigationBar


- (void)layoutSubviews {
    [super layoutSubviews];
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.hx_h = kNavigationBarHeight;
        for (UIView *view in self.subviews) {
            if([NSStringFromClass([view class]) containsString:@"Background"]) {
                view.frame = self.bounds;
            }
            else if ([NSStringFromClass([view class]) containsString:@"ContentView"]) {
                CGRect frame = view.frame;
                frame.origin.y = kNavigationBarHeight - 44;
                frame.size.height = self.bounds.size.height - frame.origin.y;
                view.frame = frame;
            }
        }
    }
#endif
}


@end
