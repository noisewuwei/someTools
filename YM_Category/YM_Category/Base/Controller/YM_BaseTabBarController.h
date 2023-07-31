//
//  YM_BaseTabBarController.h
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YM_TabbarControllerModel : NSObject

+ (instancetype)initWithVC:(UIViewController *)vc
                     title:(NSString *)title
              norImageName:(NSString *)norImageName
              preImageName:(NSString *)preImageName;

/** 子控制器 */
@property (strong, nonatomic, readonly) UIViewController * viewController;

/** 标题 */
@property (copy, nonatomic, readonly) NSString * title;

/** 标题颜色 */
@property (strong, nonatomic) UIColor * normalColor;
@property (strong, nonatomic) UIColor * highColor;

/** 默认图片 */
@property (copy, nonatomic, readonly) NSString * norImageName;

/** 选中图片 */
@property (copy, nonatomic, readonly) NSString * preImageName;

@end

@interface YM_BaseTabBarController : UITabBarController

- (instancetype)initWithModels:(NSArray <YM_TabbarControllerModel *> *)models;

/** 工具栏颜色 */
@property (strong, nonatomic) UIColor * tabbarColor;

/** 选中 */
- (void)selectedIndex:(NSInteger)index;

@end
