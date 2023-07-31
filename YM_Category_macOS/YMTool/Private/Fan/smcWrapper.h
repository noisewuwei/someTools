/*
 *	FanControl
 *
 *	Copyright (c) 2006-2012 Hendrik Holtmann
 *  Portions Copyright (c) 2013 Michael Wilber
 *
 *	smcWrapper.m - MacBook(Pro) FanControl application
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 2 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import <Cocoa/Cocoa.h>
#import "smc.h"
#import "smcConstants.h"

@interface smcWrapper : NSObject

+ (smcWrapper *)share;

- (void)cleanUp;

/// 获取风扇转速
/// @param fanNumber  风扇编号
- (int)getFanRPM:(int)fanNumber;

/// 获取设定的风扇转速
/// @param fanNumber 风扇编号
- (int)getSetupFanRPM:(int)fanNumber;

/// 获取风扇个数
- (int)getFanNum;

/// 风扇描述
/// @param fan_number 风扇编号
- (NSString*)getFanDescript:(int)fan_number;

/// 获取最小转速
/// @param fanNumber 风扇编号
- (int)getMinSpeed:(int)fanNumber;

/// 获取最大转速
/// @param fanNumber 风扇编号
- (int)getMaxSpeed:(int)fanNumber;

/// 获取风扇模式
/// @param fanNumber 风扇编号
/// @return 0:自动 1:手动
- (int)getFanMode:(int)fanNumber;

/// 调用SMC命令以设置转速
/// @param key 键
/// @param value 值
- (BOOL)setExternalWithKey:(NSString *)key value:(NSString *)value;

/// 自动控制风扇转速
/// @param isAuto 是否自动
/// @param fanNumber 风扇编号
- (BOOL)setFanAuto:(BOOL)isAuto fanNumber:(int)fanNumber;

/// 设置风扇转速
/// @param speed 转速
/// @param fanNumber 风扇编号
- (BOOL)setFanSpeed:(int)speed fanNumber:(int)fanNumber;


#pragma mark - setter
- (void)setSMCBinaryPath:(NSString *)path;


@end
