//
//  TD_BaseNetwork.h
//  ToDesk-iOS
//
//  Created by 蒋天宝 on 2021/2/19.
//  Copyright © 2021 海南有趣. All rights reserved.
//


//#import "TD_BaseRequest.h"
//
//
//typedef NS_ENUM(NSInteger, kNetworkStatus) {
//    /** 未知 */
//    kNetworkStatus_Unknown          = -1,
//    /** 无网络 */
//    kNetworkStatus_NotReachable     = 0,
//    /** 蜂窝 */
//    kNetworkStatus_WWAN = 1,
//    /** wifi */
//    kNetworkStatus_WiFi
//};
//
///** 监听网络状态 */
//static NSString * kKey_NetworkStatus = @"kKey_NetworkStatus";
//
//@interface TD_BaseNetwork : NSObject
//
//#pragma mark - POST
///**
// Post请求
// @param parameter 参数
// @param type 接口类型
// @param successBlock 成功回调
// @param failBlock 失败回调
// */
//+ (void)postRequest:(NSDictionary <NSString *, NSString *> *)parameter
//               type:(kInterfaceType)type
//            success:(void(^)(id json))successBlock
//               fail:(void(^)(NSString * fail))failBlock;
//
//
///**
// 上传文件Post请求
// @param parameter 参数
// @param files 文件
// @param fileType 文件类型
// @param type 接口类型
// @param successBlock 成功回调
// @param failBlock 失败回调
// */
//+ (void)postRequest:(NSDictionary <NSString *, NSString *> *)parameter
//              files:(NSArray <NSData *> *)files
//           fileType:(kUploadFileType)fileType
//               type:(kInterfaceType)type
//            success:(void(^)(id json))successBlock
//               fail:(void(^)(NSString * fail))failBlock;
//
//@end
