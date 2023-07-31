//
//  YMDeviceTool.m
//  youqu
//
//  Created by 黄玉洲 on 2019/5/16.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMDeviceTool.h"
#import "YMKeyChain.h"

#import <AdSupport/ASIdentifierManager.h>
#include <sys/stat.h>
#include <dlfcn.h>
 #import <sys/utsname.h>
#import <mach/mach.h>
#pragma mark - ========= YMDeviceTool =========
static NSString * kZeroStr = @"00000000-0000-0000-0000-000000000000";
@interface YMDeviceTool ()

@end

@implementation YMDeviceTool

#pragma mark - 获取本地标识编码
/** 获取IDFA */
+ (NSString *)ymIDFA {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

/** 获取IDFV */
+ (NSString *)ymIDFV {
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

static NSString * kUUID_Key = @"com.device.uuid";
/** 获取UUID（因每次启动都会改变，故此调用次方法会存储到钥匙串中） */
+ (NSString *)ymUUID {
    NSString * strUUID = [YMKeyChain readObjectForKey:kUUID_Key];
    
    //首次执行该方法时，uuid为空
    if (![strUUID isKindOfClass:[NSString class]] ||
        [strUUID isEqualToString:@""] ||
        !strUUID) {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        //将该uuid保存到keychain
        [YMKeyChain saveObject:strUUID forKey:kUUID_Key];
        CFRelease(uuidRef);
    }
    return strUUID;
}

static NSString * kUQID_Key = @"com.device.uqid";
//获取UQID
+ (NSString *)ymUQID {
//    return @"E221FBE6-CAE1-4407-977B-27B9BFE3760E";
    
    // 从keychain获取
    NSString *uqid = (NSString *)[YMKeyChain readObjectForKey:kUQID_Key];
    if (!uqid) {
        //从pasteboard取
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        id data = [pasteboard dataForPasteboardType:kUQID_Key];
        if (data) {
            uqid = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            //获取idfa
            uqid = [self ymIDFA];
            
            //idfa获取失败的情况，获取idfv
            if (uqid.length == 0 || [uqid isEqualToString:kZeroStr]) {
                uqid = [self ymIDFV];
                
                //idfv获取失败的情况，获取uuid
                if (uqid.length == 0 || [uqid isEqualToString:kZeroStr]) {
                    uqid = [self ymUUID];
                }
            }
            
            [self saveKeychain:uqid key:kUQID_Key];
        }
    }
    
    
    NSString * IDFA = [self ymIDFA];
    NSString * IDFV = [self ymIDFV];
    BOOL allowSave = NO;
    if (IDFA.length > 0 && ![IDFA isEqual:kZeroStr] && ![uqid isEqual:IDFA]) {
        uqid = IDFA;
        allowSave = YES;
    } else if (IDFV && ![IDFV isEqual:kZeroStr] && ![uqid isEqual:IDFV]) {
        uqid = IDFV;
        allowSave = YES;
    }
    
    if (allowSave) {
        [self saveKeychain:uqid key:kUQID_Key];
    }
    
    return uqid;
}

/// 将字符串保存到钥匙串
/// @param stringValue 字符串
/// @param key key
+ (void)saveKeychain:(NSString *)stringValue key:(NSString *)key {
    if (stringValue.length == 0) {
        return;
    }
    
    [YMKeyChain saveObject:stringValue forKey:key];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSData *data = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
    [pasteboard setData:data forPasteboardType:key];
}

#pragma mark - 越狱
/**
 判断越狱---以下检测的过程是越往下，越狱越高级
 https://www.cnblogs.com/jikexianfeng/p/5742887.html
 https://www.jianshu.com/p/a3fc10c70a29
 */
+ (BOOL)ymCheckJailbreak {
    // 使用判断文件的方式判断越狱
    BOOL result = [self checkJailbreak];
    if (result) {
        return YES;
    }
    
    // 使用判断跳转的方式判断越狱
    NSString * cydia_scheme = @"cydia://package/com.example.package";
    NSURL * cydia_scheme_url = [NSURL URLWithString:cydia_scheme];
    if([[UIApplication sharedApplication] canOpenURL:cydia_scheme_url]){
        return YES;
    }
    
    return NO;
}

#pragma mark - 文件相关
/**
 获取文件类型
 @param path 文件路径
 @return 文件类型
 */
+ (kFileType)ymFileTypeForPath:(NSString *)path {
    NSFileManager * manager = [NSFileManager defaultManager];
    // 判断是否存在
    if (!path || ![manager fileExistsAtPath:path]) {
        return kFileType_Unknown;
    }
    
    // 获取文件类型
    NSError * error = nil;
    NSString * fileType = [[manager attributesOfItemAtPath:path error:&error] fileType];
    if (error) {
        return kFileType_Unknown;
    }
    
    if ([fileType isEqual:NSFileTypeDirectory]) {
        return kFileType_Directory;
    } else if (NSFileTypeRegular) {
        return kFileType_Regular;
    } else if (NSFileTypeSymbolicLink) {
        return kFileType_SymbolicLink;
    } else if (NSFileTypeSocket) {
        return kFileType_Socket;
    } else if (NSFileTypeCharacterSpecial) {
        return kFileType_CharacterSpecial;
    } else if (NSFileTypeBlockSpecial) {
        return kFileType_BlockSpecial;
    } else {
        return kFileType_Unknown;
    }
}

/**
 返回指定文件的大小
 @param filePath 文件大小
 @return 字节bytes
 */
+ (long long)ymFileSizeAtPath:(NSString*)filePath {
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

/**
 获取文件夹下的总体大小
 @param folderPath 文件夹路径
 @return 字节bytes
 */
+ (long long)ymFolderSizeAtPath:(NSString *)folderPath {
    NSFileManager * manager = [NSFileManager defaultManager];
    
    // 判断是否为文件，如果是文件直接返回大小
    kFileType fileType = [self ymFileTypeForPath:folderPath];
    if (fileType != kFileType_Directory) {
        return [self ymFileSizeAtPath:folderPath];
    }
    
    // 目录/文件大小
    long long folderSize = 0;
    
    // 遍历文件夹，统计所有文件大小
    NSArray <NSString *> * pathNames = [manager contentsOfDirectoryAtPath:folderPath error:nil];
    for (NSString * pathName in pathNames) {
        NSString * path = [NSString stringWithFormat:@"%@/%@", folderPath, pathName];
        // 判断是否为文件夹，如果是则递归计算
        kFileType fileType = [self ymFileTypeForPath:path];
        if (fileType == kFileType_Directory) {
            folderSize += [self ymFolderSizeAtPath:path];
        } else {
            folderSize += [self ymFileSizeAtPath:path];
        }
    }
    
    return folderSize;
}

/**
 清理指定路径
 @param cleanPath 要清理的路径
 */
+ (void)ymCleanAtPath:(NSString *)cleanPath {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSArray <NSString *> * pathNames = [manager contentsOfDirectoryAtPath:cleanPath error:nil];
    for (NSString * pathName in pathNames) {
        NSString * path = [NSString stringWithFormat:@"%@/%@", cleanPath, pathName];
        // 判断是否为文件夹，如果是则递归删除
        kFileType fileType = [self ymFileTypeForPath:path];
        if (fileType == kFileType_Directory) {
            [self ymCleanAtPath:path];
        } else {
            BOOL isDeletable = [manager isDeletableFileAtPath:path];
            if (isDeletable) {
                NSError * error = nil;
                [manager removeItemAtPath:path error:&error];
            }
        }
    }
}

#pragma mark - private
/**
 使用fopen()函数判断文件是否存在
 "r"：只能从文件中读数据，该文件必须先存在，否则打开失败
 "w"：只能向文件写数据，若指定的文件不存在则创建它，如果存在则先删除它再重建一个新文件
 "a"：向文件增加新数据(不删除原有数据)，若文件不存在则打开失败，打开时位置指针移到文件末尾
 "r+"：可读/写数据，该文件必须先存在，否则打开失败
 "w+"：可读/写数据，用该模式打开新建一个文件，先向该文件写数据，然后可读取该文件中的数据
 "a+"：可读/写数据，原来的文件不被删去，位置指针移到文件末尾
 
 使用stat()判断文件是否存在
 */
+ (BOOL)checkJailbreak {
    NSArray * filePaths = @[@"Cydia", @"/apt/", @"/var/lib/apt",
                            @"/var/tmp/cydia.log", @"/etc/apt/", @"/var/cache/apt",
                            @"/bin/bash", @"/bin/sh", @"/Applications/Cydia.app",
                            @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                            @"/stash", @"evasi0n", @"blackra1n", @"l1mera1n",
                            @"dpkg", @"libhide", @"xCon", @"libactivator",
                            @"libsubstrate", @"PreferenceLoader", @"ssh-key",
                            @"/etc/apt", @"/var/lib/cydia", @"cache/apt",
                            @"syslog", @"/etc/ssh", @"/var/mobile/temp.txt",
                            @"/usr/sbin/sshd", @"/usr/libexec/ssh-keysign",
                            @"/etc/ssh/sshd_config", @"/privte/var/stash"];

    for (NSString * jailbreakPath in filePaths) {
        const char * cPath = [jailbreakPath UTF8String];
        FILE * file = fopen(cPath, "r");
        if (file != NULL) {
            fclose(file);
            NSLog(@"fopen() %@ 已存在", jailbreakPath);
            return YES;
        }
        fclose(file);
//        int result = open(cPath, O_RDONLY);
//        if (result == 0) {
//            NSLog(@"fopen() %@ 已存在", jailbreakPath);
//            return YES;
//        }
    }
    
    // 判断stat是否被替换
    int ret;
    Dl_info dylib_info;
    int (*func_stat)(const char *,struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        // 如果不是系统库，肯定被攻击了
        NSLog(@"lib:%s",dylib_info.dli_fname);
        //不相等，肯定被攻击了，相等为0
        if (strcmp(dylib_info.dli_fname, "/usr/lib/system/libsystem_kernel.dylib")) {
            NSLog(@"stat被替换了");
            return YES;
        }
    }
    
    // 使用stat判断文件
    for (NSString * jailbreakPath in filePaths) {
        const char * cPath = [jailbreakPath UTF8String];
        struct stat stat_info;
        int result = stat(cPath, &stat_info);
        if (result == 0) {
            NSLog(@"stat() %@ 已存在", jailbreakPath);
            return YES;
        }
    }
    
    // 检测当前程序运行的环境变量（如果攻击者给MobileSubstrate改名，但是原理都是通过DYLD_INSERT_LIBRARIES注入动态库）
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env != NULL) {
        NSLog(@"%s 已存在", env);
        return YES;
    }
    
    return NO;
}


/** FILE */
/**
typedef    struct __sFILE {
    unsigned char *_p;    //（某些）缓冲区中的当前位置
    int    _r;            // 读取空间用于getc()
    int    _w;            // 写入空间用于putc()
    short    _flags;      // 如果为0，此FILE是免费的
    short    _file;       // fileno，如果是Unix描述符，则为-1
    struct    __sbuf _bf; // 缓冲区（至少1个字节，如果！NULL）
    int    _lbfsize;      // 0或-_bf._size，用于内联putc
    
    // 操作
    void    *_cookie;     // cookie传递给io函数
    int    (* _Nullable _close)(void *);
    int    (* _Nullable _read) (void *, char *, int);
    fpos_t    (* _Nullable _seek) (void *, fpos_t, int);
    int    (* _Nullable _write)(void *, const char *, int);
    
    // 用于ungetc（）的长序列的单独缓冲区
    struct    __sbuf _ub;    // ungetc缓冲区
    struct __sFILEX *_extra; // 添加到FILE不破坏ABI
    int    _ur;              // 当_r计算ungetc数据时保存_r
    
    // 即使在malloc() 失败时也能满足最低要求
    unsigned char _ubuf[3];    // 保证ungetc()缓冲区
    unsigned char _nbuf[1];    // 保证getc()缓冲区
    
    // 当线穿过缓冲区边界时，为fgetln()分隔缓冲区
    struct    __sbuf _lb;    fgetln()的缓冲区
    
    // Unix stdio文件在fseek()上对齐以阻止边界
    int    _blksize;    // stat.st_blksize（可能是！= _bf._size）
    fpos_t    _offset;  // 当前lseek偏移量（参见警告）
} FILE;
*/

/** 常用函数 */
/*
 fopen(); 打开文件
 fclose(); 关闭一个流。
 
 feof(); 检测文件结束符
 fread(); 从文件流读取数据
 fwrite(); 将数据写至文件流
 fprintf(); 格式化输出数据至文件
 fscanf(); 格式化字符串输入
 fflush(); 更新缓冲区
 
 fgetc(); 由文件中读取一个字符
 fgets(); 文件中读取一字符串
 fputc(); 将一指定字符写入文件流中
 fputs(); 将一指定的字符串写入文件内
 
 fseek(); 移动文件流的读写位置
 fsetpos(); 定位流上的文件指针
 fgetpos(); 移动文件流的读写位置
 ftell(); 取得文件流的读取位置
 rewind(); 重设读取目录的位置为开头位置
 
 fileno(); 获取文件描述符
 ferror(); 检查流是否有错误
 
 freopen(); 打开文件
 remove(); 删除文件
 rename(); 更改文件名称或位置
 tmpfile(); 以wb+形式创建一个临时二进制文件
 tmpnam(); 产生一个唯一的文件名
 
 */

/*
struct stat {
    dev_t         st_dev;       //文件的设备编号
    ino_t         st_ino;       //节点
    mode_t        st_mode;      //文件的类型和存取的权限
    nlink_t       st_nlink;     //连到该文件的硬连接数目，刚建立的文件值为1
    uid_t         st_uid;       //用户ID
    gid_t         st_gid;       //组ID
    dev_t         st_rdev;      //(设备类型)若此文件为设备文件，则为其设备编号
    off_t         st_size;      //文件字节数(文件大小)
    unsigned long st_blksize;   //块大小(文件系统的I/O 缓冲区大小)
    unsigned long st_blocks;    //块数
    time_t        st_atime;     //最后一次访问时间
    time_t        st_mtime;     //最后一次修改时间
    time_t        st_ctime;     //最后一次改变时间(指属性)
};
*/

#pragma mark - 机子信息
/**
 获取物理内存
 @param isConversion 是否转换
 @return 物理内存
 */
+ (NSString *)ymPhysicalMemory:(BOOL)isConversion {
    if (isConversion) {
        return [self fileSizeToString:[NSProcessInfo processInfo].physicalMemory];
    } else {
        return [NSString stringWithFormat:@"%llu", [NSProcessInfo processInfo].physicalMemory];
    }
}

/** 处理器数量 */
+ (NSInteger)ymProcessorCount {
    return [NSProcessInfo processInfo].processorCount;
}

/** 活跃的处理器数 */
+ (NSInteger)ymActiveProcessorCount {
    return [NSProcessInfo processInfo].activeProcessorCount;
}

/** 系统运行时长 */
+ (float)ymSystemUptime {
    return [NSProcessInfo processInfo].systemUptime;
}

/// 获取机型
+ (ymDeviceType)ymDeviceType {
    NSLog(@"%@", [[UIDevice currentDevice] name]);
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
#pragma mark iPod
    if ([self isCheck:@[@"iPod1,1"] platform:platform]) {
        return ymDeviceType_iPod1;
    }
    if ([self isCheck:@[@"iPod2,1"] platform:platform]) {
        return ymDeviceType_iPod2;
    }
    if ([self isCheck:@[@"iPod3,1"] platform:platform]) {
        return ymDeviceType_iPod3;
    }
    if ([self isCheck:@[@"iPod4,1"] platform:platform]) {
        return ymDeviceType_iPod4;
    }
    if ([self isCheck:@[@"iPod5,1"] platform:platform]) {
        return ymDeviceType_iPod5;
    }
    if ([self isCheck:@[@"iPod7,1"] platform:platform]) {
        return ymDeviceType_iPod5;
    }

#pragma mark iPad
    if ([self isCheck:@[@"iPad2,1", @"iPad2,2", @"iPad2,3", @"iPad2,4"] platform:platform]) {
        return ymDeviceType_iPad2;
    }
    if ([self isCheck:@[@"iPad3,1", @"iPad3,2", @"iPad3,3"] platform:platform]) {
        return ymDeviceType_iPad3;
    }
    if ([self isCheck:@[@"iPad3,4", @"iPad3,5", @"iPad3,6"] platform:platform]) {
        return ymDeviceType_iPad4;
    }
    if ([self isCheck:@[@"iPad6,11", @"iPad6,12"] platform:platform]) {
        return ymDeviceType_iPad5;
    }
    if ([self isCheck:@[@"iPad4,1", @"iPad4,2", @"iPad4,3"] platform:platform]) {
        return ymDeviceType_iPadAir1;
    }
    if ([self isCheck:@[@"iPad5,3", @"iPad5,4"] platform:platform]) {
        return ymDeviceType_iPadAir2;
    }
    if ([self isCheck:@[@"iPad2,5", @"iPad2,6", @"iPad2,7"] platform:platform]) {
        return ymDeviceType_iPadMini1;
    }
    if ([self isCheck:@[@"iPad4,4", @"iPad4,5", @"iPad4,6"] platform:platform]) {
        return ymDeviceType_iPadMini2;
    }
    if ([self isCheck:@[@"iPad4,7", @"iPad4,8", @"iPad4,9"] platform:platform]) {
        return ymDeviceType_iPadMini3;
    }
    if ([self isCheck:@[@"iPad5,1", @"iPad5,2"] platform:platform]) {
        return ymDeviceType_iPadMini4;
    }
    if ([self isCheck:@[@"iPad6,3", @"iPad6,4"] platform:platform]) {
        return ymDeviceType_iPadPro9_7;
    }
    if ([self isCheck:@[@"iPad6,7", @"iPad6,8"] platform:platform]) {
        return ymDeviceType_iPadPro12_9;
    }
    if ([self isCheck:@[@"iPad7,1", @"iPad7,2"] platform:platform]) {
        return ymDeviceType_iPadPro12_9;
    }
    if ([self isCheck:@[@"iPad7,3", @"iPad7,4"] platform:platform]) {
        return ymDeviceType_iPadPro10_5;
    }

#pragma mark iPhone
    if ([self isCheck:@[@"iPhone3,1", @"iPhone3,2", @"iPhone3,3"] platform:platform])
        return ymDeviceType_iPhone4;
    if ([self isCheck:@[@"iPhone4,1"] platform:platform])
        return ymDeviceType_iPhone4S;
    if ([self isCheck:@[@"iPhone5,1", @"iPhone5,2"] platform:platform])
        return ymDeviceType_iPhone5;
   if ([self isCheck:@[@"iPhone5,3", @"iPhone5,4"] platform:platform])
       return ymDeviceType_iPhone5C;
    if ([self isCheck:@[@"iPhone6,1", @"iPhone6,2"] platform:platform])
       return ymDeviceType_iPhone5S;
    if ([self isCheck:@[@"iPhone7,1"] platform:platform])
        return ymDeviceType_iPhone6_Plus;
    if ([self isCheck:@[@"iPhone7,2"] platform:platform])
        return ymDeviceType_iPhone6;
    if ([self isCheck:@[@"iPhone8,1"] platform:platform])
        return ymDeviceType_iPhone6S;
    if ([self isCheck:@[@"iPhone8,2"] platform:platform])
        return ymDeviceType_iPhone6S_Plus;
    if ([self isCheck:@[@"iPhone8,4"] platform:platform])
        return ymDeviceType_iPhoneSE;
    if ([self isCheck:@[@"iPhone9,1", @"iPhone9,3"] platform:platform])
        return ymDeviceType_iPhone7;
    if ([self isCheck:@[@"iPhone9,2", @"iPhone9,4"] platform:platform])
        return ymDeviceType_iPhone7_Plus;
    if ([self isCheck:@[@"iPhone10,1", @"iPhone10,4"] platform:platform])
        return ymDeviceType_iPhone8;
    if ([self isCheck:@[@"iPhone10,2", @"iPhone10,5"] platform:platform])
        return ymDeviceType_iPhone8_Plus;
    if ([self isCheck:@[@"iPhone10,3", @"iPhone10,6"] platform:platform])
        return ymDeviceType_iPhoneX;
    if ([self isCheck:@[@"iPhone11,2"] platform:platform])
        return ymDeviceType_iPhoneXS;
    if ([self isCheck:@[@"iPhone11,4", @"iPhone11,6"] platform:platform])
        return ymDeviceType_iPhoneXSMax;
    if ([self isCheck:@[@"iPhone11,8"] platform:platform])
        return ymDeviceType_iPhoneXR;

#pragma mark other
    if ([self isCheck:@[@"AppleTV5,3"] platform:platform])
        return ymDeviceType_AppleTV;
    if ([self isCheck:@[@"AppleTV6,2"] platform:platform])
        return ymDeviceType_AppleTV4K;
    if ([self isCheck:@[@"AudioAccessory1,1"] platform:platform])
        return ymDeviceType_HomePod;
    if ([self isCheck:@[@"i386", @"x86_64"] platform:platform])
        return ymDeviceType_Simulator;
    return ymDeviceType_Simulator;
}

+ (BOOL)isCheck:(NSArray <NSString *> *)deviceType platform:(NSString *)platform {
    for (NSString * device in deviceType) {
        if ([device isEqual:platform]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 电池信息
/** 电池状态/电量监听 */
+ (void)ymBatteryMonitoring {
    if (![UIDevice currentDevice].batteryMonitoringEnabled) {
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            kBatteryState state = (kBatteryState)((UIDevice *)note.object).batteryState;
            [[NSNotificationCenter defaultCenter] postNotificationName:kBatteryStateDidChangeKey
                                                                object:@(state)];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryLevelDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            float batteryLevel = ((UIDevice *)note.object).batteryLevel;
            [[NSNotificationCenter defaultCenter] postNotificationName:kBatteryLevelDidChangeKey
                                                                object:@(batteryLevel * 100)];
        }];
    }
    
}

/** 电池状态 */
+ (kBatteryState)ymBatteryState {
    return (kBatteryState)[UIDevice currentDevice].batteryState;
}

/** 电池电量 */
+ (NSInteger)ymBatteryLevel {
    return [UIDevice currentDevice].batteryLevel * 100;
}



// 容量转换
+(NSString *)fileSizeToString:(unsigned long long)fileSize {
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    
    if (fileSize < 10)  {
        return @"0 B";
    }else if (fileSize < KB)    {
        return @"< 1 KB";
    }else if (fileSize < MB)    {
        return [NSString stringWithFormat:@"%.1f KB",((CGFloat)fileSize)/KB];
    }else if (fileSize < GB)    {
        return [NSString stringWithFormat:@"%.1f MB",((CGFloat)fileSize)/MB];
    }else   {
        return [NSString stringWithFormat:@"%.1f GB",((CGFloat)fileSize)/GB];
    }
}

#pragma mark - 对象保存（该方法应该能防止App信息被清除）
/** 获取对象 */
+ (NSData *)getDataWithKey:(NSString *)key {
    // 第一步，从沙盒获取数据
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    // 沙盒不存在。第二步，从keychain取数据
    if (!data) {
        data = [YMKeyChain readObjectForKey:key];
        
        // keychain不存在。第三步，从剪贴板取数据
        if (!data) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            data = [pasteboard dataForPasteboardType:key];
        }
    }
    return data;
}

/** 保存对象 */
+ (void)setData:(NSData *)data key:(NSString *)key {
    if (data && [data isKindOfClass:[NSData class]]) {
        // 保存到沙盒
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 保存到 keychian
        [YMKeyChain saveObject:data forKey:key];
        
        // 保存到剪贴板
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setData:data forPasteboardType:key];
    }
}

/** 清除对象 */
+ (void)cleanObjcWithKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [YMKeyChain saveObject:nil forKey:key];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setData:[NSData new] forPasteboardType:key];;
}

#pragma mark - App
/// 获取App占用内存(单位MB)
/// @return 正常获取返回值>0，否则返回-1
+ (float)appMemory {
    int64_t memoryUsageInByte = -1;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
        memoryUsageInByte = memoryUsageInByte / 1024.0 / 1024.0;
    }
    return memoryUsageInByte;
}


@end
