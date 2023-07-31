////
////  FFPopup+YQ_ProgressHub.m
////  youqu
////
////  Created by 黄玉洲 on 2019/4/25.
////  Copyright © 2019年 TouchingApp. All rights reserved.
////
//
//#import "FFPopup+YQ_ProgressHub.h"
//#import "NSString+YMCategory.h"
//#import "UIView+YMRectCategory.h"
//
//CGFloat animationDuration = 1;
//
//@implementation FFPopup (YQ_ProgressHub)
//
//+ (void)showSuccessText:(NSString *)text {
//    // 最大宽度
//    CGFloat maxWidth = 200;
//    
//    // 字体属性
//    UIFont * textFont = kFontRatio(14.0f);
//    
//    // 适应大小
//    CGSize textSize = [text ym_stringForSizeWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) font:textFont];
//    textSize.height = kRatio(21);
//    
//    // 两边边距
//    CGFloat edge = kRatio(24);
//    
//    UIView * backView = [UIView new];
//    backView.frame = [[UIScreen mainScreen] bounds];
//    backView.backgroundColor = [UIColor clearColor];
//    
//    
//    UIView * containView = [UIView new];
//    containView.frame = CGRectMake(0, 0, textSize.width + kRatio(11.5+6) + edge * 2, textSize.height);
//    containView.center = backView.center;
//    containView.layer.contents = (__bridge id)kImageName(@"iPublic_HubView").CGImage;
//    containView.contentMode = UIViewContentModeScaleAspectFill;
//    [backView addSubview:containView];
//    
//    UIImageView * imageView = [[UIImageView alloc] initWithImage:kImageName(@"iPublic_Success")];
//    imageView.frame = CGRectMake(edge, 0, kRatio(11.5), kRatio(9));
//    imageView.centerY = containView.height / 2.0;
//    [containView addSubview:imageView];
//    
//    UILabel * label = [UILabel new];
//    label.frame = CGRectMake(imageView.right + kRatio(6), 0, textSize.width, kRatio(20));
//    label.centerY = imageView.centerY;
//    label.text = text;
//    label.textColor = [UIColor whiteColor];
//    label.font = textFont;
//    [containView addSubview:label];
//    
//    FFPopup * popup = [FFPopup popupWithContentView:backView];
//    popup.maskType = FFPopupMaskType_Dimmed;
////    popup.showType = FFPopupShowType_None;
//    popup.dimmedMaskAlpha = 0;
////    popup.backgroundColor = [UIColor clearColor];
//    [popup showWithDuration:animationDuration];
//}
//
//@end
