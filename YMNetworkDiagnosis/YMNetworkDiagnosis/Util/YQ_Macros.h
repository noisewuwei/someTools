//
//  YQ_Macros.h
//  wujiVPN
//
//  Created by 黄玉洲 on 2019/3/18.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
NS_ASSUME_NONNULL_BEGIN

// MARK: - 系统相关
static CGFloat kSupportVersion = 11.0;

#pragma mark - 屏幕大小尺寸相关
#define kPhoneX [YQ_Macros isPhoneX]

/** AppDelegate相关 */
#define kApplication [UIApplication sharedApplication]
#define kWindow  [kAppDelegate delegate].window

/** 导航栏高度 */
#define kNavigationHeight (kPhoneX ? 88.0 : 64.0)

/* 工具栏高度 */
#define kTabBarHeight (kPhoneX ? (49.0 + kSafeAreaHeight) : 49.0)
/** tabbar高度（iPhoneX判断） */
#define kSafeAreaHeight (kPhoneX ? 34.0 : 0.0)

/** 状态栏高度 */
#define kStatusBarHeight  (kPhoneX ? 44.0 : 20.0)

/** 获取屏幕宽高 */
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

/** 判断是否为ipad */
#define kIsiPad (kScreenHeight > 1023)

/** 屏幕比例系数 */
#define kRatio(size) [YQ_Macros ratioSize:size]

#pragma mark - 字体
/** 不加粗 */
#define kFontRatio(fontSize) \
[YQ_Macros fontWithBold:NO size:fontSize isRatio:YES]

/** 加粗 */
#define kFontBoldRatio(fontSize) \
[YQ_Macros fontWithBold:YES size:fontSize isRatio:YES]

/** 指定字体 */
#define kFontNameRatio(fontName, fontSize) \
[YQ_Macros fontWithFontName:fontName size:fontSize isRatio:YES]



#pragma mark - 图片
/** 便利图片获取和图片占位符 */
#define kImageName(name) [UIImage imageNamed:name]
#define kPlaceHolder image [UIImage imageNamed:@"advert_placeholder"]

#pragma mark - 强弱引用
/** weakSelf */
#define kWeakSelf  \
__weak __typeof(self) weakSelf = self;
//@weakify(self);


/** strongSelf */
#define kStrongSelf \
__strong __typeof(weakSelf) self = weakSelf;
//@strongify(self);

#pragma mark - 日志打印
#ifdef DEBUG
//#define DLog(fmt, ...) NSLog((@"%s" "[行号:%d] \n %s"), __FUNCTION__, __LINE__, [[NSString stringWithFormat:(fmt), ##__VA_ARGS__] UTF8String])
#define DLog(format, ...) printf("%s <%s 行号%d> %s\n", [[NSString stringWithFormat:@"%@", [NSDate date]] UTF8String], __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])
#else
#define DLog(...) NSLog(__VA_ARGS__)
#endif

#pragma mark - 字符获取
/** 获取预定字符 */
#define kString(s) NSLocalizedStringFromTable(s, @"YQ_CH_String", nil)

/** 用户协议 */
static NSString * kURL_UserPotocol = @"http://osadmin.ilemon.cn/license/license.html";
//static NSString * kUserPotocol = @"https://www.baidu.com";
@interface YQ_Macros : NSObject



/** 判断是否是PhoneX */
+ (BOOL)isPhoneX;

/** 计算比例 */
+ (CGFloat)ratioSize:(CGFloat)size;

/**
 UIFont便利构造
 @param bold 是否加粗
 @param size 大小
 @param isRatio 是否比例化
 @return UIFont
 */
+ (UIFont *)fontWithBold:(BOOL)bold
                    size:(CGFloat)size
                 isRatio:(BOOL)isRatio;

/**
 UIFont便利构造
 @param fontName 指定字体名
 @param size 大小
 @param isRatio 是否比例化
 @return UIFont
 */
+ (UIFont *)fontWithFontName:(NSString *)fontName
                    size:(CGFloat)size
                 isRatio:(BOOL)isRatio;

@end

NS_ASSUME_NONNULL_END
