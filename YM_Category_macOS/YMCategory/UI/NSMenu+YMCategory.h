//
//  NSMenu+YMCategory.h
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/6.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Cocoa/Cocoa.h>



@interface NSMenu (YMCategory)

/// 遍历构造
/// @param title 标题
+ (NSMenu *)ymMenuWithTitle:(NSString *)title;

/// 添加选项
/// @param title 选项标题
/// @param target 事件对象
/// @param selector 回调方法
- (void)ymMenuAddItem:(NSString *)title target:(id)target action:(SEL)selector;

/// 添加子菜单
/// @param childMenu 子菜单
/// @param parentItem 父选项
- (void)ymMenuAddMenu:(NSMenu *)childMenu forItem:(NSMenuItem *)parentItem;

/// 在指定视图上弹出菜单
/// @param inView   要显示菜单的视图
/// @param location 菜单坐标起始点
- (void)ymMenuPopupInView:(NSView *)inView atLocation:(NSPoint)location;

#pragma mark 坐标
/// 获取指定视图在window上的菜单坐标
/// @param controlView 指定的视图
- (CGPoint)ymMenuPointFromView:(NSView *)controlView;
- (CGPoint)ymMenuPointFromView:(NSView *)controlView toView:(NSView *)toView;
@end


