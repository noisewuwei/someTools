//
//  YM_CustomCollectionReusableView.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_CustomCollectionReusableView.h"

#ifdef __IPHONE_11_0
@implementation YM_CustomLayer

- (CGFloat)zPosition {
    return 0;
}

@end
#endif

@interface YM_CustomCollectionReusableView ()

@end

@implementation YM_CustomCollectionReusableView

#ifdef __IPHONE_11_0
+ (Class)layerClass {
    return [YM_CustomLayer class];
}
#endif

@end
