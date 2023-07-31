//
//  YM_TextField.m
//  YM_TextField
//
//  Created by 黄玉洲 on 2018/11/4.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "YM_TextField.h"

@implementation YM_TextField

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 通知
- (void)textFieldDidChange:(NSNotification *)notify {
    UITextField * textField = (UITextField *)notify.object;
    if (![textField isEqual:self]) {
        return;
    }
    
    UITextRange *selectedRange = textField.markedTextRange;
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (!position) {
        // 没有高亮选择的字
        // 过滤非汉字字符
        textField.text = [self filterCharactor:textField.text withRegex:@"[^\u4e00-\u9fa5]"];
        if (textField.text.length >= 4) {
            textField.text = [textField.text substringToIndex:4];
            
        }
    }
}

/** 根据正则，过滤特殊字符 */
- (NSString *)filterCharactor:(NSString *)string
                    withRegex:(NSString *)regexStr{
    NSString *searchText = string;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, searchText.length) withTemplate:@""];
    return result;
}

#pragma mark - setter
- (void)setIsLimitChinese:(BOOL)isLimitChinese {
    _isLimitChinese = isLimitChinese;
    if (isLimitChinese) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

@end
