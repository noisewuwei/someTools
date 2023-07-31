//
//  YM_EditRatio.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YM_EditRatio : NSObject

@property (nonatomic, assign) BOOL isLandscape;

@property (nonatomic, readonly) CGFloat ratio;

@property (nonatomic, strong) NSString *titleFormat;

- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2;

@end
