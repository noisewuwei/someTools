//
//  YMMouseModel.h
//  YM_Category_macOS
//
//  Created by 黄玉洲 on 2021/12/23.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMMouseHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface YMMouseModel : NSObject

@property (assign, nonatomic) YMMouseButton mouseButton;
@property (assign, nonatomic) CGPoint       mousePoint;
@property (assign, nonatomic) CGEventType   eventType;


// 新版API使用
@property (assign, nonatomic) CGMouseButton button;      // 那个按键
@property (assign, nonatomic) int64_t       clickCount;  // 第几次点击
@property (assign, nonatomic) int64_t       subtype;     // 子类型
@property (assign, nonatomic) NSInteger     buttonNumber;// 哪个按键

// 旧版API使用
@property (assign, nonatomic) BOOL leftMouseDown;       // 左键是否按下
@property (assign, nonatomic) BOOL rightMouseDown;      // 右键是否按下
@property (assign, nonatomic) BOOL middleMouseDown;     // 中间键是否按下
@property (assign, nonatomic) BOOL otherMouseDown1;     // 后侧边键是否按下
@property (assign, nonatomic) BOOL otherMouseDown2;     // 前侧边键是否按下

@end

NS_ASSUME_NONNULL_END
