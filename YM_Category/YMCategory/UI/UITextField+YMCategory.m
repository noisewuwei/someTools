//
//  UITextField+YMCategory.m
//  YMCategory
//
//  Created by 蒋天宝 on 2021/3/25.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import "UITextField+YMCategory.h"

@implementation UITextField (YMCategory)

/// 自动大小写类型 默认UITextAutocapitalizationTypeSentences
/// UITextAutocapitalizationTypeNone：关闭
/// UITextAutocapitalizationTypeWords：单词
/// UITextAutocapitalizationTypeSentences：句子
/// UITextAutocapitalizationTypeAllCharacters：所有
- (UITextField * _Nonnull (^)(UITextAutocapitalizationType))ymAutoapitalizationType {
    return ^UITextField * (UITextAutocapitalizationType type) {
        self.autocapitalizationType = type;
        return self;
    };
}

/// 自动联想类型 默认UITextAutocorrectionTypeDefault
/// UITextAutocorrectionTypeDefault：自动
/// UITextAutocorrectionTypeNo：关闭
/// UITextAutocorrectionTypeYes：开启
- (UITextField * _Nonnull (^)(UITextAutocorrectionType))ymAutocorrectionType {
    return ^UITextField * (UITextAutocorrectionType type) {
        self.autocorrectionType = type;
        return self;
    };
}

/// 拼写检查类型 默认UITextSpellCheckingTypeDefault
/// UITextSpellCheckingTypeDefault：自动
/// UITextSpellCheckingTypeNo：关闭
/// UITextSpellCheckingTypeYes：开启
- (UITextField * _Nonnull (^)(UITextSpellCheckingType))ymSpellCheckingType {
    return ^UITextField * (UITextSpellCheckingType type) {
        self.spellCheckingType = type;
        return self;
    };
}

/// 智能引号类型 默认UITextSmartQuotesTypeDefault
/// UITextSmartQuotesTypeDefault：自动
/// UITextSmartQuotesTypeNo：关闭
/// UITextSmartQuotesTypeYes：开启
- (UITextField * _Nonnull (^)(UITextSmartQuotesType))ymSmartQuotesType  API_AVAILABLE(ios(11.0)){
    return ^UITextField * (UITextSmartQuotesType type) {
        self.smartQuotesType = type;
        return self;
    };
}

/// 智能破折号类型 默认UITextSmartDashesTypeDefault
/// UITextSmartDashesTypeDefault：自动
/// UITextSmartDashesTypeNo：关闭
/// UITextSmartDashesTypeYes：开启
- (UITextField * _Nonnull (^)(UITextSmartDashesType))ymSmartDashesType  API_AVAILABLE(ios(11.0)){
    return ^UITextField * (UITextSmartDashesType type) {
        self.smartDashesType = type;
        return self;
    };
}

/// 智能插入删除类型 默认UITextSmartInsertDeleteTypeDefault
/// UITextSmartInsertDeleteTypeDefault：自动
/// UITextSmartInsertDeleteTypeNo：关闭
/// UITextSmartInsertDeleteTypeYes：开启
- (UITextField * _Nonnull (^)(UITextSmartInsertDeleteType))ymSmartInsertDeleteType  API_AVAILABLE(ios(11.0)){
    return ^UITextField * (UITextSmartInsertDeleteType type) {
        self.smartInsertDeleteType = type;
        return self;
    };
}

/// 键盘类型 默认UIKeyboardTypeDefault
/// UIKeyboardTypeDefault：当前输入方法的默认类型。
/// UIKeyboardTypeASCIICapable：显示一个可以输入ASCII字符的键盘
/// UIKeyboardTypeNumbersAndPunctuation：数字和分类的标点符号
/// UIKeyboardTypeURL：为URL入口优化的类型(显示. / com)。
/// UIKeyboardTypeNumberPad：一个数字垫与地区适当的数字(0-9，۰-۹， ०-९，等)，适合引脚输入。
/// UIKeyboardTypePhonePad：一个电话板(1-9，*，0，#，数字下面有字母)
/// UIKeyboardTypeNamePhonePad：为输入人名或电话号码优化的类型
/// UIKeyboardTypeEmailAddress：为多个电子邮件地址条目优化的类型(显示空格@。突出)
/// UIKeyboardTypeDecimalPad API_AVAILABLE(ios(4.1))：一个带小数点的数字键盘
/// UIKeyboardTypeTwitter API_AVAILABLE(ios(5.0))：为twitter文本输入优化的类型(容易访问@ #)
/// UIKeyboardTypeWebSearch API_AVAILABLE(ios(7.0))：一个默认的面向url的键盘类型(显示空间)。突出)
/// UIKeyboardTypeASCIICapableNumberPad API_AVAILABLE(ios(10.0))：数字垫(0-9)将永远是ASCII数字
/// UIKeyboardTypeAlphabet = UIKeyboardTypeASCIICapable：弃用
- (UITextField * _Nonnull (^)(UIKeyboardType))ymKeyboardType {
    return ^UITextField * (UIKeyboardType type) {
        self.keyboardType = type;
        return self;
    };
}

/// 键盘外观 默认UIKeyboardAppearanceDefault
/// UIKeyboardAppearanceDefault：默认
/// UIKeyboardAppearanceDark：黑色
/// UIKeyboardAppearanceLight：白色
/// UIKeyboardAppearanceAlert：弃用
- (UITextField * _Nonnull (^)(UIKeyboardAppearance))ymKeyboardAppearance {
    return ^UITextField * (UIKeyboardAppearance type) {
        self.keyboardAppearance = type;
        return self;
    };
}

/// Return键样式 默认UIReturnKeyDefault
- (UITextField * _Nonnull (^)(UIReturnKeyType))ymReturnKeyType {
    return ^UITextField * (UIReturnKeyType type) {
        self.returnKeyType = type;
        return self;
    };
}

@end
