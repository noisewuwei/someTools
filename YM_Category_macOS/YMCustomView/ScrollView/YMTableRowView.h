//
//  YMTableRowView.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/31.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMTableRowView : NSTableRowView

+ (NSString *)identifier;

+ (YMTableRowView *)viewWithTableView:(NSTableView *)tableView;

+ (YMTableRowView *)viewWithTableView:(NSTableView *)tableView
                                          normalColor:(NSColor *)normalColor
                                          selectColor:(NSColor *)normalColor;

@property (strong, nonatomic) NSColor * normalColor;
@property (strong, nonatomic) NSColor * selectionColor;
@end

NS_ASSUME_NONNULL_END
