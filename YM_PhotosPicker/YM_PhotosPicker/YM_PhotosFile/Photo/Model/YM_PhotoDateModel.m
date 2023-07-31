//
//  YM_PhotoDateModel.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PhotoDateModel.h"
#import "YM_PhotoTools.h"

@implementation YM_PhotoDateModel

- (NSString *)dateString {
    if (!_dateString) {
        
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([self.date isToday]) {
            _dateString = [NSBundle ym_localizedStringForKey:@"今天"];
        }else if ([self.date isYesterday]) {
            _dateString = [NSBundle ym_localizedStringForKey:@"昨天"];
        }else if ([self.date isSameWeek]) {
            _dateString = [self.date getNowWeekday];
        }else if ([self.date isThisYear]) {
            if ([language hasPrefix:@"en"]) {
                // 英文
                _dateString = [NSString stringWithFormat:@"%@ %@",[self.date dateStringWithFormat:@"MMM dd"],[self.date getNowWeekday]];
            } else if ([language hasPrefix:@"zh"]) {
                // 中文
                _dateString = [NSString stringWithFormat:@"%@ %@",[self.date dateStringWithFormat:@"MM月dd日"],[self.date getNowWeekday]];
            }else if ([language hasPrefix:@"ko"]) {
                // 韩语
                _dateString = [NSString stringWithFormat:@"%@ %@",[self.date dateStringWithFormat:@"MM월dd일"],[self.date getNowWeekday]];
            }else if ([language hasPrefix:@"ja"]) {
                // 日语
                _dateString = [NSString stringWithFormat:@"%@ %@",[self.date dateStringWithFormat:@"MM月dd日"],[self.date getNowWeekday]];
            } else {
                // 英文
                _dateString = [NSString stringWithFormat:@"%@ %@",[self.date dateStringWithFormat:@"MMM dd"],[self.date getNowWeekday]];
            }
        }else {
            if ([language hasPrefix:@"en"]) {
                // 英文
                _dateString = [self.date dateStringWithFormat:@"MMMM dd, yyyy"];
            } else if ([language hasPrefix:@"zh"]) {
                // 中文
                _dateString = [self.date dateStringWithFormat:@"yyyy年MM月dd日"];
            }else if ([language hasPrefix:@"ko"]) {
                // 韩语
                _dateString = [self.date dateStringWithFormat:@"yyyy년MM월dd일"];
            }else if ([language hasPrefix:@"ja"]) {
                // 日语
                _dateString = [self.date dateStringWithFormat:@"yyyy年MM月dd日"];
            } else {
                // 其他
                _dateString = [self.date dateStringWithFormat:@"MMMM dd, yyyy"];
            }
        }
    }
    return _dateString;
}

- (NSMutableArray *)locationList {
    if (!_locationList) {
        _locationList = [NSMutableArray array];
    }
    return _locationList;
}

@end
