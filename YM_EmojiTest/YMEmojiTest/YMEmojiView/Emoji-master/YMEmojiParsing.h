//
//  YMEmojiParsing.h
//  YMEmojiTest
//
//  Created by 黄玉洲 on 16/10/27.
//  Copyright © 2016年 黄玉洲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMEmojiParsing : NSObject
/**
 *  将表情字符转换为表情
 *
 *  @param faceString 表情字符
 *
 *  @return 返回表情
 */
+ (NSString *)parsingStringToFace:(NSString *)faceString;

/**
 *  将表情转换成表情字符
 *
 *  @param faceString 表情
 *
 *  @return 表情字符
 */
+ (NSString *)parsingFaceToString:(NSString *)faceString;

@end
