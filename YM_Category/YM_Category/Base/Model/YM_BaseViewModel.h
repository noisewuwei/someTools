//
//  YM_BaseViewModel.h
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YMTool/YMNotifyTool.h>
#import "UIViewController+YMHUDCategory.h"
#import "YYModel.h"

typedef void(^VMSuccessBlock)(void);
typedef void(^VMSuccessOjbcBlock)(id);
typedef void(^VMFailBlock)(NSString * failContent);
@interface YM_BaseViewModel : NSObject

@end
