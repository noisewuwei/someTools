//
//  YM_EmojiModel.m
//  YMEmojiTest
//
//  Created by 黄玉洲 on 16/10/29.
//  Copyright © 2016年 黄玉洲. All rights reserved.
//

#import "YM_EmojiModel.h"

@implementation YM_EmojiModel

+ (NSDictionary *)emojis
{
    static NSDictionary * emojis = nil;
    if (!emojis){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"json"];
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:path];
        emojis = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingAllowFragments error:nil];
    }
    return emojis;
}

+ (instancetype)peopleEmoji{
    YM_EmojiModel *emoji = [YM_EmojiModel new];
    emoji.title = @"情感";
    emoji.emojis = [self emojis][@"people"];
    emoji.type = YMEmojiTypePeople;
    return emoji;
}

+ (instancetype)foodEmoji{
    YM_EmojiModel *emoji = [YM_EmojiModel new];
    emoji.title = @"食物";
    emoji.emojis = [self emojis][@"food"];
    emoji.type = YMEmojiTypeFood;
    return emoji;
}

+ (instancetype)natureEmoji{
    YM_EmojiModel *emoji = [YM_EmojiModel new];
    emoji.title = @"自然";
    emoji.emojis = [self emojis][@"nature"];
    emoji.type = YMEmojiTypeNature;
    return emoji;
}

+ (instancetype)activityEmoji{
    YM_EmojiModel *emoji = [YM_EmojiModel new];
    emoji.title = @"活动";
    emoji.emojis = [self emojis][@"activity"];
    emoji.type = YMEmojiTypeActivity;
    return emoji;
}

+ (instancetype)placeEmoji{
    YM_EmojiModel *emoji = [YM_EmojiModel new];
    emoji.title = @"地点";
    emoji.emojis = [self emojis][@"place"];
    emoji.type = YMEmojiTypePlace;
    return emoji;
}

+ (instancetype)substanceEmoji{
    YM_EmojiModel *emoji = [YM_EmojiModel new];
    emoji.title = @"物体";
    emoji.emojis = [self emojis][@"substance"];
    emoji.type = YMEmojiTypeSubstance;
    return emoji;
}

+ (instancetype)bannerEmoji{
    YM_EmojiModel *emoji = [YM_EmojiModel new];
    emoji.title = @"旗帜";
    emoji.emojis = [self emojis][@"banner"];
    emoji.type = YMEmojiTypeBanner;
    return emoji;
}

+ (instancetype)numberEmoji{
    YM_EmojiModel *emoji = [YM_EmojiModel new];
    emoji.title = @"符号";
    emoji.emojis = [self emojis][@"number"];
    emoji.type = YMEmojiTypeNumber;
    return emoji;
}

+ (NSArray *)allEmojis{
    return @[[self peopleEmoji],
             [self foodEmoji],
             [self natureEmoji],
             [self activityEmoji],
             [self placeEmoji],
             [self substanceEmoji],
             [self bannerEmoji],
             [self numberEmoji]];
}

@end


