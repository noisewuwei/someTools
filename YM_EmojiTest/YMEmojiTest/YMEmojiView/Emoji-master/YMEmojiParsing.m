//
//  YMEmojiParsing.m
//  YMEmojiTest
//
//  Created by 黄玉洲 on 16/10/27.
//  Copyright © 2016年 黄玉洲. All rights reserved.
//

#import "YMEmojiParsing.h"
#import "Emoji.h"
@implementation YMEmojiParsing

+ (NSString *)parsingStringToFace:(NSString *)faceString
{
    NSArray *faces = [Emoji allEmoji];
    //将原字符串还原为表情
    NSMutableString *contentString = [NSMutableString stringWithFormat:@"%@",faceString];
    for (int i = 0; i<(NSInteger)[contentString length]-4; i++) {
        if ([[contentString substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"<"]) {//如果当前字符为"<"
            if ([[contentString substringWithRange:NSMakeRange(i+4, 1)] isEqualToString:@">"]) {//如果后面5个字符中包含">"
                //则将字符串判定为表情
                NSInteger faceIndex = [[contentString substringWithRange:NSMakeRange(i+1, 3)] integerValue];
                NSString *emoji = [faces objectAtIndex:faceIndex];
                [contentString replaceCharactersInRange:NSMakeRange(i, 5) withString:emoji];
                i++;//替换了一个表情，增量＋＋
            }
        }
    }
    return contentString;
}

+ (NSString *)parsingFaceToString:(NSString *)faceString
{
    if (faceString.length == 0) {
        return nil;
    }
    NSArray *emojis = [Emoji allEmoji];
    //因表情含特殊字符，所以将其特殊处理后再上传
    NSMutableString *content = [NSMutableString string];
    for (int i = 0; i<(int)[faceString length]; i++) {
        if (i == faceString.length - 1) {//最后一个字符
            [content appendString:[faceString substringWithRange:NSMakeRange(i, 1)]];
            break;
        }
        NSString *rangeString = [faceString substringWithRange:NSMakeRange(i, 2)];
        if ([emojis containsObject:rangeString]) {
            [content appendString:[NSString stringWithFormat:@"<%3lu>",(unsigned long)[emojis indexOfObject:rangeString]]];
            i++;//将这2个字符替换为表情标识，增量＋＋
        } else {
            [content appendString:[faceString substringWithRange:NSMakeRange(i, 1)]];//否则，添加当前位置的一个字符
        }
    }
    return content;
}

@end
