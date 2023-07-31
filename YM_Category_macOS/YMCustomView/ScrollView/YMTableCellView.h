//
//  YMTableCellView.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/5.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMTableCellView : NSTableCellView

+ (NSString *)identifier;
+ (id)cellWithTable:(NSTableView *)tableView;

@end

NS_ASSUME_NONNULL_END
