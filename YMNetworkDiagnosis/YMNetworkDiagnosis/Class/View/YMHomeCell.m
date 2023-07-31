//
//  YMHomeCell.m
//  YMNetworkDiagnosis
//
//  Created by 黄玉洲 on 2019/5/14.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import "YMHomeCell.h"

@interface YMHomeCell ()

@end

@implementation YMHomeCell


+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString  * identifer = @"YMHomeCellID";
    YMHomeCell * cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil) {
        cell = [[YMHomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    return cell;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self layoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {

}


#pragma mark - setter


#pragma mark - 懒加载

@end
