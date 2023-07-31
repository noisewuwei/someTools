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

#import "smcWrapper.h"
#import <CommonCrypto/CommonDigest.h>
NSString * const smc_checksum=@"4fc00a0979970ee8b55f078a0c793c4d";
static NSString * kSmcBinaryPath = nil;
NSArray *allSensors;

io_connect_t conn; // 连接端口
@implementation smcWrapper

+ (smcWrapper *)share {
    static smcWrapper * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[smcWrapper alloc] init];
    });
    return instance;
}

/// 初始化SMC服务
- (instancetype)init {
    if (self = [super init]) {
        SMCOpen(&conn);
    }
    return self;
}

/// 停止SMC服务
- (void)cleanUp{
    SMCClose(conn);
}

/// 获取风扇转速
/// @param fanNumber  风扇编号
- (int)getFanRPM:(int)fanNumber {
    UInt32Char_t  key;
    SMCVal_t      val;
    sprintf(key, "F%cAc", fannum[fanNumber]);
    SMCReadKey2(key, &val,conn);
    int running= [self convertToNumber:val];
    return running;
}

/// 获取设定的风扇转速
/// @param fanNumber 风扇编号
- (int)getSetupFanRPM:(int)fanNumber {
    UInt32Char_t  key;
    SMCVal_t      val;
    //kern_return_t result;
    sprintf(key, "F%cTg", fannum[fanNumber]);
    SMCReadKey2(key, &val, conn);
    int running= [self convertToNumber:val];
    return running;
}

/// 获取风扇个数
- (int)getFanNum {
    SMCVal_t      val;
    int           totalFans;
    SMCReadKey2("FNum", &val,conn);
    totalFans = [self convertToNumber:val];
    return totalFans;
}

/// 风扇描述
/// @param fanNumber 风扇编号
- (NSString*)getFanDescript:(int)fanNumber {
    UInt32Char_t  key;
    char temp;
    SMCVal_t      val;
    //kern_return_t result;
    NSMutableString *desc;

    sprintf(key, "F%cID", fannum[fanNumber]);
    SMCReadKey2(key, &val,conn);

    if(val.dataSize>0){
        desc=[[NSMutableString alloc]init];
        int i;
        for (i = 0; i < val.dataSize; i++) {
            if ((int)val.bytes[i]>32) {
                temp=(unsigned char)val.bytes[i];
                [desc appendFormat:@"%c",temp];
            }
        }
    }
    else {
        //On MacBookPro 15.1 descriptions aren't available
        desc=[[NSMutableString alloc] initWithFormat:@"Fan #%d: ",fanNumber+1];
    }
    return desc;
}

/// 获取最小转速
/// @param fanNumber 风扇编号
- (int)getMinSpeed:(int)fanNumber {
    UInt32Char_t  key;
    SMCVal_t      val;
    //kern_return_t result;
    sprintf(key, "F%cMn", fannum[fanNumber]);
    SMCReadKey2(key, &val, conn);
    int min= [self convertToNumber:val];
    return min;
}

/// 获取最大转速
/// @param fanNumber 风扇编号
- (int)getMaxSpeed:(int)fanNumber {
    UInt32Char_t  key;
    SMCVal_t      val;
    //kern_return_t result;
    sprintf(key, "F%cMx", fannum[fanNumber]);
    SMCReadKey2(key, &val, conn);
    int max= [self convertToNumber:val];
    return max;
}

/// 获取风扇模式
/// @param fanNumber 风扇编号
/// @return 0:自动 1:手动
- (int)getFanMode:(int)fanNumber {
    UInt32Char_t  key;
    SMCVal_t      val;
    kern_return_t result;
    
    sprintf(key, "F%dMd", fanNumber);
    result = SMCReadKey2(key, &val,conn);
    // Auto mode's key is not available
    if (result != kIOReturnSuccess) {
        return -1;
    }
    int mode = [self convertToNumber:val];
    return mode;
}

- (NSString *)smcPath:(NSString *)bundlePath {
    NSURL * url = [NSURL URLWithString:bundlePath];
    NSError * error;
    
    NSFileManager * fileManage = [NSFileManager defaultManager];
    NSArray<NSURL *> *subFiles = [fileManage contentsOfDirectoryAtURL:url
                                           includingPropertiesForKeys:@[NSURLPathKey]
                                                              options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                error:&error];
    
    for (NSURL * tempUrl in subFiles) {
        if ([[tempUrl lastPathComponent] isEqual:@"smc"]) {
            return [tempUrl path];
        } else {
            NSString * smcFilePath = [self smcPath:[tempUrl path]];
            if ([[smcFilePath lastPathComponent] isEqual:@"smc"]) {
                return smcFilePath;
            }
        }
    }
    
    return @"";
}

/// 调用SMC命令以设置转速
/// @param key 键
/// @param value 值
- (BOOL)setExternalWithKey:(NSString *)key value:(NSString *)value {
    NSString * smcPath = @"";
    if (kSmcBinaryPath.length > 0) {
        smcPath = kSmcBinaryPath;
    } else {
        smcPath = [self smcPath:[[NSBundle mainBundle] bundlePath]];
    }
    
    if (smcPath.length == 0) {
        NSLog(@"无法执行操作，需要导入smc执行文件");
        return NO;
    }
    kSmcBinaryPath = smcPath;
    
    if (![self setRights:smcPath]) {
        NSLog(@"smc权限不足，请重试");
        return NO;
    }

    NSArray *argsArray = @[@"-k",key,@"-w",value];
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: smcPath];
    [task setArguments: argsArray];
    
    NSPipe * outputPipe = [[NSPipe alloc] init];
    task.standardOutput = outputPipe;
    
    NSPipe * errorPipe = [[NSPipe alloc] init];
    task.standardError = errorPipe;
    
    [task launch];

    
//    NSData * outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
//    NSString * output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
//    
//    NSData * errortData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
//    NSString * error = [[NSString alloc] initWithData:errortData encoding:NSUTF8StringEncoding];
    
    return YES;
}

/// 自动控制风扇转速
/// @param isAuto 是否自动
/// @param fanNumber 风扇编号
- (BOOL)setFanAuto:(BOOL)isAuto fanNumber:(int)fanNumber {
    NSString * key = [NSString stringWithFormat:@"F%dMd", fanNumber];
    return [self setExternalWithKey:key value:isAuto ? @"00" : @"01"];
}

/// 设置风扇转速
/// @param speed 转速
/// @param fanNumber 风扇编号
- (BOOL)setFanSpeed:(int)speed fanNumber:(int)fanNumber {
    NSString * key = [NSString stringWithFormat:@"F%dTg", fanNumber];
    float speedFloat = (float)speed;
    uint8 *vals = (uint8*)&speedFloat;
    NSString * value = [NSString stringWithFormat:@"%02x%02x%02x%02x",vals[0],vals[1],vals[2],vals[3]];
    return [self setExternalWithKey:key value:value];
}

/// 数值转换
- (int)convertToNumber:(SMCVal_t)val {
    float fval = -1.0f;

    if (strcmp(val.dataType, DATATYPE_FLT) == 0 && val.dataSize == 4) {
        memcpy(&fval,val.bytes,sizeof(float));
    }
    else if (strcmp(val.dataType, DATATYPE_FPE2) == 0 && val.dataSize == 2) {
        fval = _strtof(val.bytes, val.dataSize, 2);
    }
    else if (strcmp(val.dataType, DATATYPE_UINT16) == 0 && val.dataSize == 2) {
        fval = (float)_strtoul((char *)val.bytes, val.dataSize, 10);
    }
    else if (strcmp(val.dataType, DATATYPE_UINT8) == 0 && val.dataSize == 1) {
        fval = (float)val.bytes[0];
    }
    else if (strcmp(val.dataType, DATATYPE_SP78) == 0 && val.dataSize == 2) {
        fval = ((val.bytes[0] * 256 + val.bytes[1]) >> 2)/64;
    }
    else {
        NSLog(@"%@", [NSString stringWithFormat:@"Unknown val:%s size-%d",val.dataType,val.dataSize]);
    }

    return (int)fval;
}

#pragma mark - 权限
/// 设置权限
- (BOOL)setRights:(NSString *)smcPath {
    NSFileManager * fanManage = [NSFileManager defaultManager];
    NSDictionary * fdic = [fanManage attributesOfItemAtPath:smcPath error:nil];
    
    // 已经经root权限
    if ([[fdic valueForKey:@"NSFileOwnerAccountName"] isEqualToString:@"root"] &&
        [[fdic valueForKey:@"NSFileGroupOwnerAccountName"] isEqualToString:@"admin"] &&
        ([[fdic valueForKey:@"NSFilePosixPermissions"] intValue] == 3437)) {
        return YES;
     }
    
    BOOL result = NO;
    
    // 使用commPipe是否安全?
    FILE *commPipe;
    AuthorizationRef authorizationRef;
    AuthorizationItem gencitem = { "system.privilege.admin", 0, NULL, 0 };
    AuthorizationRights gencright = { 1, &gencitem };
    int flags = kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed;
    AuthorizationCreate(&gencright,  kAuthorizationEmptyEnvironment, flags, &authorizationRef);

    
    NSString *tool=@"/usr/sbin/chown";
    NSArray *argsArray = @[@"root:admin", smcPath];
    int i;
    char *args[255];
    for(i = 0;i < [argsArray count];i++){
        args[i] = (char *)[argsArray[i] cStringUsingEncoding:NSUTF8StringEncoding];
    }
    args[i] = NULL;
    AuthorizationExecuteWithPrivileges(authorizationRef,[tool UTF8String],0,args,&commPipe);

    tool=@"/bin/chmod";
    argsArray = @[@"6555",smcPath];
    for(i = 0;i < [argsArray count];i++){
        args[i] = (char *)[argsArray[i] cStringUsingEncoding:NSUTF8StringEncoding];
    }
    args[i] = NULL;
    OSStatus status = AuthorizationExecuteWithPrivileges(authorizationRef,[tool UTF8String],0,args,&commPipe);
    result = [self checkRightStatus:status] ? YES : result;
    return result;
}

- (BOOL)checkRightStatus:(OSStatus)status {
    if (status != errAuthorizationSuccess) {
        return NO;
    }
    return YES;
}

#pragma mark - setter
- (void)setSMCBinaryPath:(NSString *)path {
    kSmcBinaryPath = path;
}

@end
