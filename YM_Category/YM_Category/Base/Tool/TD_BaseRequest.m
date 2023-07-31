//
//  TD_BaseRequest.m
//  ToDesk-iOS
//
//  Created by 蒋天宝 on 2021/2/19.
//  Copyright © 2021 海南有趣. All rights reserved.
//

//#import "TD_BaseRequest.h"
//#import "TD_LoginModel.h"
//@interface TD_BaseRequest ()
//{
//    /** 公有参数 */
//    NSDictionary <NSString *, NSString *> * _publicParameter;
//    /** 请求参数 */
//    NSMutableDictionary <NSString *, NSString *> * _requestParameter;
//    kInterfaceType _type;
//}
//
///** 请求key */
//@property (copy, nonatomic) NSString * requestKey;
//
//@property (copy, nonatomic) NSString * typeName;
//
//@end
//
//@implementation TD_BaseRequest
//
//- (instancetype)initWithType:(kInterfaceType)type {
//    if (self = [super init]) {
//        _type = type;
//        _typeName = [self typeNameWithType:_type];
//    }
//    return self;
//}
//
//- (instancetype)init {
//    if (self = [super init]) {
//        _requestParameter = [NSMutableDictionary dictionary];
//    }
//    return self;
//}
//
////#pragma mark - httpHeader / httpBody
/////** 该方法要在httpBody之后使用 */
////- (NSDictionary *)httpHeader {
////    if (!_httpHeader) {
////        if (!self.httpBody) {
////            return nil;
////        }
////        // 截取8~24位字符串（0位第一位）
////        NSString * token = [TD_UserShare share].loginModel.token;
////        if (token) {
////            _httpHeader = @{@"token" : token};
////        }
////    }
////    return _httpHeader;
////}
////
////- (NSData *)httpBody {
////    if (!_httpBody) {
////        NSString * httpBodyStr = [self httpBodyStr:NO
////                                         parameter:_requestParameter
////                                              date:nil];
////        NSData * httpBody =  [httpBodyStr dataUsingEncoding:NSUTF8StringEncoding];
////        _httpBody = httpBody;
////    }
////    return _httpBody;
////}
//
///**
//// 获取httpBody字符串
//// @param isEncryption 是否加密
//// @return NSString
//// */
////- (NSString *)httpBodyStr:(BOOL)isEncryption
////                parameter:(NSDictionary *)parameter
////                     date:(NSDate *)date {
////    NSData * data = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:nil];
////    NSString * dexstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////    return dexstring;
////}
//
//#pragma mark - getter
///** 公共参数 */
//- (NSDictionary<NSString *,NSString *> *)publicParameter {
//    NSMutableDictionary * parameter = [NSMutableDictionary dictionary];
//    NSString * token = [NSString ymNullToString:[TD_UserShare share].loginModel.token];
//    [parameter setObject:token forKey:@"token"];
//    
//    _publicParameter = parameter;
//    return _publicParameter;
//}
//
///** 将公有参数和私有参数合并起来 */
//- (NSMutableDictionary *)parameterWithCustomParameter:(NSDictionary *)parameter {
//    NSMutableDictionary * mDic = [[self publicParameter] mutableCopy];
//    for (NSString * key in parameter) {
//        if (parameter[key]) {
//            [mDic setObject:parameter[key] forKey:key];
//        }
//    }
//    return mDic;
//}
//
///**
// 网络错误编码转换
// @param code 错误编码
// @return 编码描述
// */
//+ (NSString *)errorCode:(NSInteger)code {
//    NSString * errorDescription = @"";
//    switch (code) {
//        case 200:
//            errorDescription = @"请求成功";
//            break;
//        case 404:
//            errorDescription = @"请求的地址不存在";
//            break;
//        case 408:
//            errorDescription = @"请求超时";
//            break;
//        case 500:
//            errorDescription = @"服务器内部错误";
//            break;
//        case 501:
//            errorDescription = @"服务不可用";
//            break;
//        case 502:
//            errorDescription = @"错误网关";
//            break;
//        case 503:
//            errorDescription = @"服务不可用";
//            break;
//        case 504:
//            errorDescription = @"网关超时";
//            break;
//        case 505:
//            errorDescription = @"HTTP版本不受支持";
//            break;
//        default:
//            errorDescription = @"请检查网络";
//            break;
//    }
//    return errorDescription;
//}
//
//- (NSString *)requestKey {
//    if (!_requestKey) {
//        _requestKey = @"";
//    }
//    return _requestKey;
//}
//
//- (NSDictionary *)parameter {
//    return _requestParameter;
//}
//
//- (NSString *)typeNameWithType:(kInterfaceType)type {
//    switch (type) {
//        case kInterfaceType_Portrait: return @"upload.php?";
//        default: return @""; break;
//    }
//}
//
//#pragma mark - setter
//- (void)setParameter:(NSDictionary *)parameter {
//    // 结合公参和私参
//    if (parameter) {
//        _requestParameter = [self parameterWithCustomParameter:parameter];
//        [_requestParameter setObject:_typeName forKey:@"name"];
//    }
//}
//
//#pragma mark -
//#pragma mark ---------------- 父类重写 ----------------
///** 请求基路径 */
//- (NSString *)baseUrl {
//    return kRequestBaseURL;
//}
//
///** 请求子路径 */
//- (NSString *)requestUrl {
//    return @"";
//}
//
///** 请求方式 */
//- (YTKRequestMethod)requestMethod {
//    return self.method;
//}
//
///** 超时请求 */
//- (NSTimeInterval)requestTimeoutInterval {
//    return 30;
//}
//
///** 私有参数 */
//- (id)requestArgument {
//    return _requestParameter;
//}
//
/////** Header */
////- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
////    return [self httpHeader];
////}
//
///** 请求参数序列化 */
//- (YTKRequestSerializerType)requestSerializerType {
//    return YTKRequestSerializerTypeHTTP;
//}
//
///** 响应数据序列化 */
//- (YTKResponseSerializerType)responseSerializerType {
//    return YTKResponseSerializerTypeHTTP;
//}
//
//@end
