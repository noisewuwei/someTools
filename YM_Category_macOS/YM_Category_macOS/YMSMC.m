//
//  YMSMC.m
//  YM_Category_macOS
//
//  Created by 黄玉洲 on 2022/1/27.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import "YMSMC.h"
#import "smcWrapper.h"

#pragma mark - YMSMC
@interface YMSMC ()
{
    io_connect_t conn;
}

@end

@implementation YMSMC

- (instancetype)init {
    if (self = [super init]) {
        [[self class] setRights];
        [self runFan];
    }
    return self;
}

- (void)runFan {
    [smcWrapper init];
    
    static BOOL fanAuto = YES;
    
    bool is_auto = fanAuto;
    [[smcWrapper share] setExternalWithKey:@"F0Md" value:is_auto ? @"00" : @"01"];
    float f_val = 3000;
    uint8 *vals = (uint8*)&f_val;
    //NSString str_val = ;
    [[smcWrapper share] setExternalWithKey:@"F0Tg" value:[NSString stringWithFormat:@"%02x%02x%02x%02x",vals[0],vals[1],vals[2],vals[3]]];
    
    fanAuto = !fanAuto;
}

/// 设置权力
+ (void)setRights {
    NSString * smcPath = [[NSBundle mainBundle] pathForResource:@"smc" ofType:@""];
    NSFileManager * fanManage = [NSFileManager defaultManager];
    NSDictionary * fdic = [fanManage attributesOfItemAtPath:smcPath error:nil];
    
    // 已经经root权限
    if ([[fdic valueForKey:@"NSFileOwnerAccountName"] isEqualToString:@"root"] &&
        [[fdic valueForKey:@"NSFileGroupOwnerAccountName"] isEqualToString:@"admin"] &&
        ([[fdic valueForKey:@"NSFilePosixPermissions"] intValue] == 3437)) {
        return;
     }
    
    BOOL result = NO;
    
    // 使用commPipe是否安全?
    FILE *commPipe;
    AuthorizationRef authorizationRef;
    AuthorizationItem gencitem = { "system.privilege.admin", 0, NULL, 0 };
    AuthorizationRights gencright = { 1, &gencitem };
    int flags = kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed;
    OSStatus status = AuthorizationCreate(&gencright,  kAuthorizationEmptyEnvironment, flags, &authorizationRef);
//    result = [self checkRightStatus:status];
    
    NSString *tool=@"/usr/sbin/chown";
    NSArray *argsArray = @[@"root:admin", smcPath];
    int i;
    char *args[255];
    for(i = 0;i < [argsArray count];i++){
        args[i] = (char *)[argsArray[i] cStringUsingEncoding:NSUTF8StringEncoding];
    }
    args[i] = NULL;
    status = AuthorizationExecuteWithPrivileges(authorizationRef,[tool UTF8String],0,args,&commPipe);
    result = [self checkRightStatus:status] ? YES : result;

    
    tool=@"/bin/chmod";
    argsArray = @[@"6555",smcPath];
    for(i = 0;i < [argsArray count];i++){
        args[i] = (char *)[argsArray[i] cStringUsingEncoding:NSUTF8StringEncoding];
    }
    args[i] = NULL;
    status = AuthorizationExecuteWithPrivileges(authorizationRef,[tool UTF8String],0,args,&commPipe);
    result = [self checkRightStatus:status] ? YES : result;
    
    if (!result) {
        NSLog(@"授权失败，请重试");
    }
}

+ (BOOL)checkRightStatus:(OSStatus)status {
    if (status != errAuthorizationSuccess) {
        return NO;
    }
    return YES;
}

@end
