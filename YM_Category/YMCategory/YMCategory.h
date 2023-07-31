//
//  YMCategory.h
//  YMCategory
//
//  Created by 黄玉洲 on 2019/12/3.
//  Copyright © 2019年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for YMCategory.
FOUNDATION_EXPORT double YMCategoryVersionNumber;

//! Project version string for YMCategory.
FOUNDATION_EXPORT const unsigned char YMCategoryVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <YMCategory/PublicHeader.h>

#ifdef DEBUG
    #define YMLog(format, ...) \
        printf("\n————————————%s————————————\n", [[NSString stringWithFormat:@"%@", [NSDate date]] UTF8String]); \
        printf("%s 行号%d\n", __PRETTY_FUNCTION__, __LINE__); \
        printf("%s\n", [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String]); \
        printf("—————————————————————————————————————————————————\n");
#else
    #define YMLog(...) NSLog(__VA_ARGS__)
#endif

#import <YMCategory/CABasicAnimation+YMCategory.h>

#import <YMCategory/UIButton+YMCategory.h>
#import <YMCategory/UICollectionView+YMCategory.h>
#import <YMCategory/UIColor+YMCategory.h>
#import <YMCategory/UIImage+YMCategory.h>
#import <YMCategory/UITableView+YMCategory.h>
#import <YMCategory/UIView+YMCategory.h>
#import <YMCategory/UIGestureRecognizer+YMCategory.h>
#import <YMCategory/UIDevice+YMCategory.h>
#import <YMCategory/UITextField+YMCategory.h>

#import <YMCategory/NSData+YMCategory.h>
#import <YMCategory/NSDate+YMCategory.h>
#import <YMCategory/NSDictionary+YMCategory.h>
#import <YMCategory/NSObject+YMCategory.h>
#import <YMCategory/NSArray+YMCategory.h>
#import <YMCategory/NSPredicate+YMCategory.h>
#import <YMCategory/NSString+YMCategory.h>
#import <YMCategory/NSString+YMPredicate.h>
#import <YMCategory/NSBundle+YMCategory.h>
