//
//  TD_BaseNetwork.m
//  ToDesk-iOS
//
//  Created by 蒋天宝 on 2021/2/19.
//  Copyright © 2021 海南有趣. All rights reserved.
//

//#import "TD_BaseNetwork.h"
//#import "AFURLRequestSerialization.h"
//#import "AFNetworkReachabilityManager.h"
//#import "TD_LoginModel.h"
//#pragma mark - ---------------- 自定义上传 ----------------
//@interface YM_CustomNetwork : TD_BaseRequest
//
//@end
//
//@implementation YM_CustomNetwork
//
///**
// Post请求
// @param parameter 参数
// @param type 接口类型
// @param successBlock 成功回调
// @param failBlock 失败链接
// */
//+ (void)postRequest:(NSDictionary <NSString *, NSString *> *)parameter
//               type:(kInterfaceType)type
//            success:(void(^)(id json))successBlock
//               fail:(void(^)(NSString * fail))failBlock {
////    // 设置请求对象
////    YM_CustomNetwork * baseRequest = [[YM_CustomNetwork alloc] initWithType:type];
////    baseRequest.method = YTKRequestMethodPOST;
////    baseRequest.parameter = parameter;
////
////
////    DLog(@"\n接口：%@ \n请求的参数 %@", baseRequest.typeName, baseRequest.parameter);
////    [baseRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
////        NSDictionary * json = [YM_BaseRequest jsonWithData:request.responseData
////                                                   decData:baseRequest.keyDecData
////                                                    ivData:baseRequest.ivData
////                                                isPassword:kIsPasswork];
////        if ([json isKindOfClass:[NSString class]]) {
////            if (failBlock) {
////                failBlock(@"服务器错误，请联系客服！");
////            }
////            return;
////        }
////
////        DLog(@"\n接口：%@ \n返回的数据%@ ", baseRequest.typeName, json);
////        YM_BaseObject * baseModel = [YM_BaseObject yy_modelWithJSON:json];
////        if (![baseModel.error isEqual:@"0"]) {
////            if (failBlock) {
////                failBlock(baseModel.msg);
////            }
////        } else {
////            if (successBlock) {
////                successBlock(json);
////            }
////        }
////    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
////        NSString * errorDescription = [YM_BaseRequest errorCode:request.responseStatusCode];
////        NSLog(@"%@ + %@", errorDescription, request.error.localizedDescription);
////        if (failBlock) {
////            failBlock(errorDescription);
////        }
////    }];
//}
//
////- (NSURLRequest *)buildCustomUrlRequest {
////    NSURL * requestURL = [NSURL URLWithString:self.baseUrl];
////    NSData * httpBody = self.httpBody;
////    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
////    request.timeoutInterval = 30;
////    switch (self.method) {
////        case YTKRequestMethodPOST:
////            request.HTTPMethod = @"POST";
////            break;
////        case YTKRequestMethodGET:
////            request.HTTPMethod = @"GET";
////            break;
////        default:
////            request.HTTPMethod = @"POST";
////            break;
////    }
////    for (NSString * key in self.httpHeader) {
////        [request addValue:self.httpHeader[key] forHTTPHeaderField:key];
////    }
////    request.HTTPBody = httpBody;
////    return request;
////}
//
//@end
//
//#pragma mark - ---------------- 文件上传 ----------------
//@interface YM_FileNetwork : TD_BaseRequest
//
//@end
//
//@implementation YM_FileNetwork
//
//- (YTKRequestMethod)requestMethod {
//    return YTKRequestMethodPOST;
//}
//
//- (NSString *)requestUrl {
//    NSString * parameterStr = @"";
//    for (NSString * key in self.parameter) {
//        id value = self.parameter[key];
//        if ([parameterStr isEqual:@""]) {
//            parameterStr = [NSString stringWithFormat:@"%@=%@", key, value];
//        } else {
//            parameterStr = [NSString stringWithFormat:@"%@&%@=%@", parameterStr, key, value];
//        }
//    }
//    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", kRequestBaseURL, self.typeName, parameterStr];
//    return urlStr;
//}
//
//+ (void)postRequest:(NSDictionary <NSString *, NSString *> *)parameter
//              files:(NSArray <NSData *> *)files
//           fileType:(kUploadFileType)fileType
//               type:(kInterfaceType)type
//            success:(void(^)(id json))successBlock
//               fail:(void(^)(NSString * fail))failBlock {
//
//    // 设置请求对象
//    YM_FileNetwork * baseRequest = [[YM_FileNetwork alloc] initWithType:type];
//    baseRequest.method = YTKRequestMethodGET;
//    baseRequest.parameter = parameter;
//    baseRequest.files = files;
//    baseRequest.fileType = fileType;
//    
//    DLog(@"\n接口：%@ \n请求的参数 %@", baseRequest.typeName, baseRequest.parameter);
//    [baseRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
//        NSString * json = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil];
//        NSInteger errorcode = [json integerValue];
//        if (errorcode == 0) {
//            if (successBlock) {
//                successBlock(nil);
//            }
//        } else {
//            if (failBlock) {
//                failBlock(kString(@"Alter_Avatar_Fail"));
//            }
//        }
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//        NSString * errorDescription = [TD_BaseRequest errorCode:request.responseStatusCode];
//        NSLog(@"%@ + %@", errorDescription, request.error.localizedDescription);
//        if (failBlock) {
//            failBlock(request.error.localizedDescription);
//        }
//    }];
//}
//
//- (AFConstructingBlock)constructingBodyBlock {
//    NSString * name = @"";
//    NSString * formKey = @"";
//    NSString * type = @"";
//    switch (self.fileType) {
//        case kUploadFileType_ImageJPG:
//            name = @"image";
//            formKey = @"image";
//            type = @"image/jpeg";
//            break;
//        case kUploadFileType_ImagePNG:
//            name = @"image";
//            formKey = @"image";
//            type = @"image/png";
//            break;
//        default:
//            break;
//    }
//    
//    return ^(id<AFMultipartFormData> formData) {
//        NSInteger index = 0;
//        for (NSData * data in self.files) {
//            NSString * fileName = [NSString stringWithFormat:@"%@_%ld", name, index];
//            NSString * fileFormKey = [NSString stringWithFormat:@"%@_%ld", formKey, index];
//            NSString * fileType = type;
//            [formData appendPartWithFileData:data
//                                        name:fileName
//                                    fileName:fileFormKey
//                                    mimeType:fileType];
//            index++;
//        }
//    };
//}
//
/////// header和body一起上传
////- (id)requestArgument {
////    NSMutableDictionary * mDic = [self.httpHeader mutableCopy];
////    [mDic setValue:self.httpBody forKey:@"value"];
////    return mDic;
////}
//
//@end
//
//#pragma mark -
//#pragma mark ---------------- 请求方法入口类 ----------------
//@interface TD_BaseNetwork ()
//
//
//@end
//
//@implementation TD_BaseNetwork
//
//- (instancetype)init {
//    if (self = [super init]) {
//        
//    }
//    return self;
//}
//
//#pragma mark - post请求
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
//               fail:(void(^)(NSString * fail))failBlock {
//    [YM_CustomNetwork postRequest:parameter
//                             type:type
//                          success:successBlock
//                             fail:failBlock];
//}
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
//               fail:(void(^)(NSString * fail))failBlock {
//    [YM_FileNetwork postRequest:parameter
//                          files:files
//                       fileType:(kUploadFileType)fileType
//                           type:type
//                        success:successBlock
//                           fail:failBlock];
//}
//
//#pragma mark - 网络状态
///** 开始监听网络状态 */
//+ (void)startMonitoringNetwork {
//    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
//    [reachabilityManager startMonitoring];
//    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        kNetworkStatus networkStatus = (kNetworkStatus)status;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kKey_NetworkStatus object:@(networkStatus)];
//    }];
//}
//
///** 停止监听网络状态 */
//+ (void)stopMonitoringNetwork {
//    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
//    [reachabilityManager stopMonitoring];
//}
//
//@end
