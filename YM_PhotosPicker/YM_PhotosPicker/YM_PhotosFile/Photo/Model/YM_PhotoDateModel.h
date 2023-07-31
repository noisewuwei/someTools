//
//  YM_PhotoDateModel.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@class CLGeocoder;

@interface YM_PhotoDateModel : NSObject

/**  位置信息 - 如果当前天数内包含带有位置信息的资源则有值 */
@property (strong, nonatomic) CLLocation *location;

/**  日期信息 */
@property (strong, nonatomic) NSDate *date;

/**  日期信息字符串 */
@property (copy, nonatomic) NSString *dateString;

/**  位置信息字符串 */
@property (copy, nonatomic) NSString *locationString;;

/**  同一天的资源数组 */
@property (copy, nonatomic) NSArray *photoModelArray;

/**  位置信息子标题 */
@property (copy, nonatomic) NSString *locationSubTitle;

/**  位置信息标题 */
@property (copy, nonatomic) NSString *locationTitle;

@property (strong, nonatomic) NSMutableArray *locationList;

@property (assign, nonatomic) BOOL hasLocationTitles;
//@property (strong, nonatomic) CLGeocoder *geocoder;

@end
