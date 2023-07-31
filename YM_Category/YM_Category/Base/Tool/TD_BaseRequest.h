//
//  TD_BaseRequest.h
//  ToDesk-iOS
//
//  Created by 蒋天宝 on 2021/2/19.
//  Copyright © 2021 海南有趣. All rights reserved.
//

//#import <YTKNetwork/YTKNetwork.h>
//
//static NSString * kRequestBaseURL = @"http://106.75.130.166/";
//
//typedef void(^kSuccessBlock)(id object);
//typedef void(^kFailBlock)(NSString * failContent);
//
//typedef NS_ENUM(NSInteger, kInterfaceType) {
//    /// 上传头像
//    kInterfaceType_Portrait,
//};
//
//
///** 上传的文件的类型 */
//typedef NS_ENUM(NSInteger, kUploadFileType) {
//    /** JPG图片 */
//    kUploadFileType_ImageJPG,
//    /** PNG图片 */
//    kUploadFileType_ImagePNG
//};
//
//@interface TD_BaseRequest : YTKBaseRequest
//
//- (instancetype)initWithType:(kInterfaceType)type;
//@property (copy, nonatomic, readonly) NSString * typeName;
//
///** 请求方式 */
//@property (assign, nonatomic) YTKRequestMethod method;
//
///** 参数 */
//@property (strong, nonatomic) NSDictionary * parameter;
//
////@property (strong, nonatomic) NSDictionary * httpHeader;
////@property (strong, nonatomic) NSData * httpBody;
//
//#pragma mark - getter
///**
// 网络错误编码转换
// @param code 错误编码
// @return 编码描述
// */
//+ (NSString *)errorCode:(NSInteger)code;
//
//#pragma mark -
//#pragma mark ---------------- 文件请求 ----------------
//@property (strong, nonatomic) NSArray <NSData *> * files;
//@property (assign, nonatomic) kUploadFileType fileType;
//
//#pragma mark -
//#pragma mark ---------------- 类方法 ----------------
//#pragma mark 解析
///**
// 对返回的数据进行解密
// @param jsonData 返回的data数据
// @param isPassword 是否需要解密
// @return NSDictionary
// */
//+ (id)jsonWithData:(NSData *)jsonData
//           decData:(NSData *)decData
//            ivData:(NSData *)ivData
//        isPassword:(BOOL)isPassword;
//
//@end
//
//
