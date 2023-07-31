//
//  DisplayGamma.h
//  YMTool
//
//  Created by 黄玉洲 on 2022/8/15.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreGraphics/CGError.h>

NS_ASSUME_NONNULL_BEGIN

@interface DisplayGamma : NSObject
@property int length;
@property NSMutableArray * redTable;
@property NSMutableArray * greenTable;
@property NSMutableArray * blueTable;

+ (DisplayGamma *)initWithDisplayID:(int)displayID;
- (DisplayGamma *)clone;
- (DisplayGamma *)copyWithBrightness:(float)brightness;
- (CGError)applyToDisplayID:(int)displayID;

@end

NS_ASSUME_NONNULL_END
