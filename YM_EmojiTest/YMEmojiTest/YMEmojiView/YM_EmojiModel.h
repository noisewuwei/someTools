//
//  YM_EmojiModel.h
//  YMEmojiTest
//
//  Created by 黄玉洲 on 16/10/29.
//  Copyright © 2016年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YMEmojiType) {
    // emoji show type
    YMEmojiTypePeople = 0,
    YMEmojiTypeFood,
    YMEmojiTypeNature,
    YMEmojiTypeActivity,
    YMEmojiTypePlace,
    YMEmojiTypeSubstance,
    YMEmojiTypeBanner,
    YMEmojiTypeNumber
};

@interface YM_EmojiModel : NSObject

@property (assign, nonatomic) YMEmojiType type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *emojis;

@end

@interface YM_EmojiModel (Generate)
+ (NSArray *)allEmojis;
@end
