//
//  NSMenu+YMCategory.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/8/6.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "NSMenu+YMCategory.h"

#import <AppKit/AppKit.h>


@implementation NSMenu (YMCategory)

/// 遍历构造
/// @param title 标题
+ (NSMenu *)ymMenuWithTitle:(NSString *)title {
    NSMenu * menu = [[NSMenu alloc] initWithTitle:title];
    return menu;
}

/// 添加选项
/// @param title 选项标题
/// @param target 事件对象
/// @param selector 回调方法
- (void)ymMenuAddItem:(NSString *)title target:(id)target action:(SEL)selector {
    [self ymMenuAddItem:title target:target action:selector keyEquivalent:@""];
}

/// 添加选项
/// @param title 选项标题
/// @param target 事件对象
/// @param selector 回调方法
/// @param charCode ？？
- (void)ymMenuAddItem:(NSString *)title target:(id)target action:(SEL)selector keyEquivalent:(NSString *)charCode {
    NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:title action:selector keyEquivalent:charCode];
    item.target = target;
    [self addItem:item];
}

/// 添加子菜单
/// @param childMenu 子菜单
/// @param parentItem 父选项
- (void)ymMenuAddMenu:(NSMenu *)childMenu forItem:(NSMenuItem *)parentItem {
    [self setSubmenu:childMenu forItem:parentItem];
}

/// 在指定视图上弹出菜单
/// @param inView   要显示菜单的视图,当nil时，视图在主屏幕上
/// @param location 菜单坐标起始点
- (void)ymMenuPopupInView:(NSView *)inView atLocation:(NSPoint)location {
    [self popUpMenuPositioningItem:nil atLocation:location inView:inView];
}

#pragma mark 坐标
/// 获取指定视图在window上的菜单起始坐标
/// @param controlView 指定的视图
- (CGPoint)ymMenuPointFromView:(NSView *)controlView  {
    NSView * parentView = controlView.superview;
    NSPoint controlViewPoint = [parentView convertPoint:controlView.frame.origin toView:parentView.window.contentView];
    NSPoint windowPoint = [parentView.window.contentView convertPoint:controlViewPoint toView:nil];
    return windowPoint;
}


@end
