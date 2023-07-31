//
//  YMButtonCell.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/28.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, kButtonCellAlign) {
    kButtonCellAlign_Left = 1 << 0,
    kButtonCellAlign_Right = 1 << 1,
    kButtonCellAlign_Center = 1 << 2,
};

typedef NS_ENUM(NSInteger, kButtonImagePosition) {
    kButtonImagePosition_Left = 1 << 0,
    kButtonImagePosition_Right = 1 << 1,
    kButtonImagePosition_Top = 1 << 2,
    kButtonImagePosition_Bottom = 1 << 3,
};

@interface YMButtonCell : NSButtonCell

- (instancetype)initWithAlign:(kButtonCellAlign)align
                imagePosition:(kButtonImagePosition)position;
@property (assign, nonatomic) CGFloat imageEdge;
@property (strong, nonatomic) NSColor * textColor;
@end

NS_ASSUME_NONNULL_END
