//
//  ViewController.m
//  YM_Category
//
//  Created by 海南有趣 on 2020/6/28.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import "ViewController.h"
#import <YMCategory/YMCategory.h>
#import <YMCustomView/YMCustomView.h>
#import <YMTool/YMKeyCommandTool.H>

#import "YMTool.h"
#import "Masonry.h"
#import "YMProxySocket.h"
#import "YMCategoryLibary.h"
#import "YMToolLibary.h"
#import "YM_AlertView.h"
#import "TD_CameraVC.h"
typedef struct _ServerMsgHeader
{
    uint32_t msgLen;
    unsigned char msgId;
}ServerMsgHeader;

@interface ViewController () <GCDAsyncSocketDelegate, YM_TextViewDelegate, UITextFieldDelegate, YM_TextField_Delegate>
@property (strong, nonatomic) UIButton * recordingBtn;
@property (nonatomic, strong) YMProxySocket *s5Socket;
@property (strong, nonatomic) dispatch_queue_t socketQueue;         // 发数据的串行队列

@property (strong, nonatomic) YMKeyCommandTool * tool;
@property (strong, nonatomic) YM_SearchBarView * searchBar;
@end

@implementation ViewController

- (void)dealloc {
     
}

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    YM_SearchBarView * searchBar = [[YM_SearchBarView alloc] init];
    searchBar.frame = CGRectMake(100, 560, 200, 30);
    searchBar.placeHolder = @"111";
    searchBar.placeHolderFont = [UIFont systemFontOfSize:14.0f];
    searchBar.placeHolderColor = [UIColor cyanColor];
    searchBar.icon = [UIImage imageNamed:@"user_arrow"];
    searchBar.inputViewBackColor = [UIColor redColor];
    searchBar.cancelBtnWidth = 0;
    searchBar.delegate = self;
    searchBar.layer.cornerRadius = 15;
    searchBar.clipsToBounds = YES;
    [self.view addSubview:searchBar];
    _searchBar = searchBar;
    
    YM_ValidateCodeView * view = [[YM_ValidateCodeView alloc] initWithCodeNumber:6];
    view.isRatation = YES;
    [self.view addSubview:view];
    view.frame = CGRectMake(100, 100, 200, 50);

    NSLog(@"%@", [YMDeviceTool ymIDFA]);
    NSLog(@"%@", [YMDeviceTool ymIDFV]);
    NSLog(@"%@", [YMDeviceTool ymUQID]);
    
    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    TD_CameraVC * vc = [TD_CameraVC new];
//    [self presentViewController:vc animated:YES completion:nil];
    
    YM_AlertSheetView * sheetView = [[YM_AlertSheetView alloc] init];
    YM_AlertSheetAction * action = [YM_AlertSheetAction actionTitle:@"1" image:nil style:kAlertSheetAction_Cancel block:^(NSInteger index) {
        NSLog(@":close");
    }];
    [sheetView addAction:action];
    [sheetView show];
}

#pragma mark - socket 代理连接接收信息
// 代理方法
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
//    [TD_ConnectShare share].isConnectService = YES;
    YMLog(@"连接成功:%@, %d", host, port);
    
    // 使用SSL连接
//    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
//    [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
//    [sock startTLS:settings];//启动SSL连接请求
//
//    NSString * dataStr = @"0000004a 01120532 2e302e30 18032206 6950686f 6e653a36 34384341 30324434 2d373534 332d3432 32302d41 3941302d 39383430 43453538 46413638 2d30323a 30303a30 303a3030 3a30303a 3030";
//    NSData * data = [NSData ymDataFromHexStr:dataStr];
//    [self.s5Socket readDataWithTimeout:-1 tag:1000];           // 每次都要设置接收数据的时间, tag
//    [self.s5Socket writeData:data withTimeout:-1 tag:1000];    // 再发送
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
    [sock startTLS:settings];//启动SSL连接请求
}

/// 手动认证SSL证书
- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler {
    completionHandler(YES);
}

/// SSL证书安全，开始登陆中心服务器
- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    NSData * data = [self loginData];
    [self.s5Socket readDataWithTimeout:-1 tag:1000];
    [self.s5Socket writeData:data withTimeout:-1 tag:1000];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"接收到数据");
    
    NSMutableData *tmpbuf = [[NSMutableData alloc] init];
    [tmpbuf setLength:0];
    [tmpbuf appendData:data];
    NSData *redata = [tmpbuf subdataWithRange:NSMakeRange(1, tmpbuf.length - 1)];
    Byte *testByte = (Byte *)[data bytes];
    int type = testByte[0];
    
    [self.s5Socket readDataWithTimeout:-1 tag:100];       // 设置下次接收数据的时间, tag
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"%s %@", __func__, [err localizedDescription]);
}


- (NSString *)ymInsertString:(NSString *)string atInterval:(NSInteger)interval string:(NSString *)selfstr {
    NSMutableString * mString = [NSMutableString string];
    if (selfstr.length < interval) {
        return selfstr;
    }
    for (NSInteger i = 0; i < selfstr.length; i+=interval) {
        NSInteger startIndex = i;
        NSInteger endIndex = i+interval;
        if (endIndex > selfstr.length) {
            [mString appendFormat:@"%@", [selfstr substringFromIndex:startIndex]];
            break;
        }
        NSString * tempStr = [selfstr substringWithRange:NSMakeRange(startIndex, interval)];
        if (endIndex == selfstr.length) {
            [mString appendFormat:@"%@", tempStr];
        } else {
            [mString appendFormat:@"%@%@", tempStr, string];
        }
    }
    return mString;
}

#pragma mark 数据请求


#pragma mark 界面
/** 布局 */
- (void)layoutView {
    
}

- (void)buttonAction {
    
}


- (dispatch_queue_t)socketQueue {
    if (_socketQueue == nil) {
        _socketQueue = dispatch_queue_create("com.sendSocket", DISPATCH_QUEUE_SERIAL);
    }
    return _socketQueue;
}

#pragma mark 数据
- (NSData *)loginData {
    NSString * dataStr = @"1205322e 302e3018 03220fe7 8e89e7b1 b3e79a84 6950686f 6e653a36 45323343 39433745 2d373341 462d3435 44382d39 3737302d 44343331 39414143 35453246 2d30323a 30303a30 303a3030 3a30303a 3030";
    NSData * msg_data = [NSData ymDataFromHexStr:dataStr];
    
    // 包长
    size_t msglen = [msg_data length];
    size_t packagelen = msglen + sizeof(unsigned char);
    
    // 包头
    ServerMsgHeader msgHeader;
    memset(&msgHeader, 0, sizeof(msgHeader));
    
    // 包数据
    msgHeader.msgId = 1;
    msgHeader.msgLen = htonl(packagelen);

    // 追加包体
    NSMutableData *data = [NSMutableData dataWithBytes:&msgHeader length:sizeof(msgHeader)];
    [data appendData:msg_data];
    return data;
}

@end

