//
//  YMRuntimeTool.m
//  YMTool
//
//  Created by 黄玉洲 on 2020/2/6.
//  Copyright © 2020年 huangyuzhou. All rights reserved.
//

#import "YMRuntimeTool.h"


@interface YMRuntimeTool ()


@end

@implementation YMRuntimeTool



#pragma mark - 类相关
/**
 通过字符获取Class类
 @param name 类名
 @return Class
 */
+ (Class)ymClassWithName:(NSString *)name {
    if (!name || name.length == 0) {
        return nil;
    }
    return objc_getClass([name UTF8String]);
}

/**
 通过字符获取Class元类
 @param name 类名
 @return Class
 */
+ (Class)ymMetaClassWithName:(NSString *)name {
    if (!name || name.length == 0) {
        return nil;
    }
    return objc_getMetaClass([name UTF8String]);
}

/**
 创建类并分配空间(仅在创建之后,注册之前 能够添加成员变量)
 @param className  类名
 @param superClass 父类
 @param size 类和元类对象末尾要分配给索引ivars的字节数。 通常应为 0
 @return Class
 */
+ (Class)ymAllocateClass:(NSString *)className
              superClass:(Class)superClass
                    size:(NSInteger)size  {
    if (!className || className.length == 0) {
        return nil;
    }
    return objc_allocateClassPair(superClass, [className UTF8String], size);
}

/**
 注册一个类(注册后方可使用该类创建对象)
 @param classObj 注册使用objc_allocateClassPair分配的类。
 */
+ (void)ymRegisterClassPair:(Class)classObj {
    objc_registerClassPair(classObj);
}


/**
 销毁一个类及其相关的元类(注销后无法初始化对象)
 @param classObj 要销毁的类。它必须由objc_allocateClassPair分配
 */
+ (void)ymDisposeClassPair:(Class)classObj {
    objc_disposeClassPair(classObj);
}

/**
 将新的实例变量添加到类中

 @param classObj 类
 @param name 成员变量名字
 @param size 大小
 @param alignment 对其方式
 @param types 参数类型
 
 @return 如果成功添加实例变量，则为YES，否则为NO
        （例如，该类已经包含具有该名称的实例变量）。
 
 @note
 1.此函数只能在objc_allocateClassPair之后和objc_registerClassPair之前调用
 2.不支持将实例变量添加到现有类中
 3.该类不得为元类。 不支持将实例变量添加到元类
 4.实例变量的最小字节对齐方式是1 << align。
   实例变量的最小对齐方式取决于ivar的类型和计算机体系结构。
   对于任何指针类型的变量，请传递log2（sizeof（pointer_type））。
 如：
 [self ymAddIvarToClass:[self class]
                   name:@"test"
                   size:sizeof(NSString *)
              alignment:log2(sizeof(NSString *))
                  types:@encode(NSString *)]
 */
+ (BOOL)ymAddIvarToClass:(Class)classObj
                    name:(NSString *)name
                    size:(size_t)size
               alignment:(uint8_t)alignment
                   types:(const char *)types  {
    return class_addIvar(classObj, [name UTF8String], size, alignment, types);
}

/**
 为具有给定名称和实现的类添加新方法

 @param classObj 要向其添加方法的类。
 @param sel   一个选择器，用于指定要添加的方法的名称
 @param imp   一个函数，它是新方法的实现。 该函数必须至少包含两个参数-self和_cmd。
 @param types 一个字符数组，描述方法参数的类型。如"v@:"
 @return 如果成功添加方法则为YES，否则为NO
        （例如，该类已经包含具有该名称的方法实现）
 
 @note 该方法将添加超类实现的替代，但不会替代此类中的现有实现。
       要更改现有的实现，请使用ymSetImplementationOfMethod:imp:
 */
+ (BOOL)ymAddMethodToClass:(Class)classObj
                       sel:(SEL)sel
                attributes:(IMP)imp
                     types:(const char * _Nullable)types {
    return class_addMethod(classObj, sel, imp, types);
}

/**
 返回类的名称
 @param classObj 一个类对象
 @return 类的名称，如果cls为Nil，则为空字符串。
 */
+ (NSString *)ymClassNameOfClass:(Class)classObj {
    const char * name = class_getName(classObj);
    return [[NSString alloc] initWithUTF8String:name];
}

/**
 指示类对象是否为元类。

 @param classObj 类对象
 @return 如果cls是元类，则为YES，如果cls是非元类，则为NO。如果cls是Nil，则NO。
 */
+ (BOOL)ymValidateMetaClass:(Class)classObj {
    return class_isMetaClass(classObj);
}

/**
 返回一个类的父类

 @param classObj 类对象
 @return 该类的父类；如果没有，则Nil。如果cls为根类或者nil，则为nil。
 
 @note 通常应使用 NSObject的父类方法代替此函数
 */
+ (Class)ymSuperOfClass:(Class)classObj {
    return class_getSuperclass(classObj);
}

/**
 返回具有给定类的给定名称的属性

 @param classObj 要检查的类
 @param propertyName 要检查的属性的名称
 @return 类型为objc_property的指针，用于描述属性；如果类未使用该名称声明属性，则为NULL；如果cls为Nil，则为NULL。
 */
+ (objc_property_t)ymPropertyOfClass:(Class)classObj
                        propertyName:(NSString *)propertyName {
    return class_getProperty(classObj, [propertyName UTF8String]);;
}

/**
 拷贝类的属性列表

 @param classObj 要拷贝的类
 @param count 属性数量
 @return 属性列表
 */
+ (objc_property_t *)ymPropertysOfClass:(Class)classObj
                                  count:(NSInteger*)count {
    unsigned int outCount;
    objc_property_t * propertys = class_copyPropertyList(classObj, &outCount);
    if (count) {
        *count = outCount;
    }
    return propertys;
}

/**
 获取对象的类名

 @param object 要获取的对象
 @return 对象的类名
 */
+ (NSString *)ymClassNameOfObject:(id)object {
    return [NSString stringWithUTF8String:object_getClassName(object)];
}

/**
 获取对象的Class

 @param object 要获取的对象
 @return 对象的类
 */
+ (Class)ymClassOfObject:(id)object {
    return object_getClass(object);
}

/**
 设置对象的Class

 @param object 要设置的对象
 @param classObj  要设置的类
 @return 对象类的前一个值；如果对象为nil，则为Nil。
 */
+ (Class)ymSetClassOfObject:(id)object
                      class:(Class)classObj {
    return object_setClass(object, classObj);
}

#pragma mark - 协议相关
/**
 创建一个新的协议实例，直到向其注册后才能使用
 @param protocolName 要创建的协议的名称
 @return Protocol对象或nil
 */
+ (Protocol *)ymAllocateProtocol:(NSString *)protocolName {
    if (!protocolName || protocolName.length == 0) {
        return nil;
    }
    return objc_allocateProtocol([protocolName UTF8String]);
}

/**
 在运行时注册一个新构建的协议。
 该协议将可以使用，并且在此之后是不变的。

 @param protocol Protocol
 */
+ (void)ymRegisterProtocol:(Protocol *)protocol {
    objc_registerProtocol(protocol);
}

/**
 返回指定的协议(需要经过objc_registerProtocol才能获取到)
 @param protocolName 协议名称
 @return 协议名称，如果找不到协议名称，则为NULL。
 */
+ (Protocol *)ymProtocolOfName:(NSString *)protocolName {
    if (!protocolName || protocolName.length == 0) {
        return nil;
    }
    return objc_getProtocol([protocolName UTF8String]);
}

/**
 返回运行时已知的所有协议的数组

 @param count 返回数组中的协议数量
 @return 运行时已知的所有协议的数组
 */
+ (__unsafe_unretained Protocol **)ymProtocolList:(NSInteger *)count {
    unsigned int outCount;
    __unsafe_unretained Protocol ** protocolList = objc_copyProtocolList(&outCount);
    if (count) {
        *count = outCount;
    }
    return protocolList;
}

/**
 将协议添加到类中

 @param classObj 要修改的类
 @param protocol 要添加到cls的协议
 @return 如果成功添加方法，则为YES，否则为NO（例如，该类已经遵循该协议）
 */
+ (BOOL)ymAddProtocolToClass:(Class)classObj
                    protocol:(Protocol *)protocol{
    return class_addProtocol(classObj, protocol);
}

/**
 判断类是否遵循某协议

 @param classObj    要检查的类
 @param protocol 要检查的协议
 @return 是否遵循
 */
+ (BOOL)ymConformsProtocol:(Class)classObj
                  protocol:(Protocol *)protocol {
    return class_conformsToProtocol(classObj, protocol);
}

/**
 拷贝类遵循的协议列表

 @param classObj 要拷贝的类
 @param count 协议数量
 @return 协议列表
 */
+ (__unsafe_unretained Protocol **)ymProtocolListOfClass:(Class)classObj
                                                   count:(NSInteger *)count {
    unsigned int outCount;
    __unsafe_unretained Protocol ** protocols = class_copyProtocolList(classObj, &outCount);
    if (count) {
        *count = outCount;
    }
    return protocols;
}


/**
 判断一个协议是否遵循另一个协议

 @param protocol1 被判断的协议
 @param protocol2 要遵循的协议
 @return YES/NO
 */
+ (BOOL)ymConformsProtocol:(Protocol *)protocol1
                 protocol2:(Protocol *)protocol2 {
    return protocol_conformsToProtocol(protocol1, protocol2);
}

/**
 获取协议名称

 @param protocol 要获取的协议
 @return 协议命
 */
+ (NSString *)ymNameOfProtocol:(Protocol *)protocol {
    return [NSString stringWithUTF8String:protocol_getName(protocol)];
}

/**
 拷贝协议的属性列表

 @param protocol 协议
 @param count    个数
 @return 属性列表
 */
+ (objc_property_t *)ymAttributesOfProtocol:(Protocol *)protocol
                                              count:(NSInteger *)count {
    unsigned int outCount;
    objc_property_t * propertys = protocol_copyPropertyList(protocol, &outCount);
    if (count) {
        *count = outCount;
    }
    return propertys;
}

/**
 拷贝某协议所遵循的协议列表

 @param protocol 协议
 @param count    个数
 @return 协议列表
 */
+ (__unsafe_unretained Protocol **)ymProtocolsOfProtocol:(Protocol *)protocol count:(NSInteger *)count {
    unsigned int outCount;
    __unsafe_unretained Protocol ** protocolList = protocol_copyProtocolList(protocol, &outCount);
    if (count) {
        *count = outCount;
    }
    return protocolList;
}

/**
 拷贝协议的方法列表

 @param protocol 协议
 @param count    个数
 @param isRequiredMethod 是否为必要方法
 @param isInstanceMethod 是否为实例方法
 @return 方法列表
 */
+ (struct objc_method_description * )ymMethodDesOfProtocol:(Protocol *)protocol
                                                     count:(NSInteger *)count
                                          isRequiredMethod:(BOOL)isRequiredMethod
                                          isInstanceMethod:(BOOL)isInstanceMethod {
    unsigned int outCount;
    struct objc_method_description * protocolDes = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &outCount);
    if (count) {
        *count = outCount;
    }
    return protocolDes;
}

/**
 为一个协议遵循另一协议

 @param protocol    要遵循协议的协议
 @param newProtocol 被遵循的协议
 */
+ (void)ymConformsToProtocol:(Protocol *)protocol
                 newProtocol:(Protocol *)newProtocol {
    protocol_addProtocol(protocol, newProtocol);
}

/**
 向协议添加属性。该协议必须正在构建中

 @param protocol 向其添加属性的协议
 @param name 属性的名称
 @param attibutes 属性的特性数组
 @param attributeCount 属性中的特性数
 @param isRequiredProperty 是否为必须
 @param isInstanceProperty 是否为实例
 */
+ (void)ymAddAttributeToProtocol:(Protocol *)protocol
                            name:(NSString *)name
                       attibutes:(const objc_property_attribute_t * _Nullable)attibutes
                  attributeCount:(unsigned int)attributeCount
              isRequiredProperty:(BOOL)isRequiredProperty
              isInstanceProperty:(BOOL)isInstanceProperty {
    protocol_addProperty(protocol,
                         [name UTF8String],
                         attibutes,
                         attributeCount,
                         isRequiredProperty,
                         isInstanceProperty);
}

/**
 返回给定协议的指定属性

 @param protocol 协议
 @param name     属性的名称
 @param isRequiredProperty 是否为必须
 @param isInstanceProperty 是否为实例
 @return 指定属性
 */
+ (objc_property_t)ymPropertyOfProtocol:(Protocol *)protocol
                                   name:(NSString *)name
                     isRequiredProperty:(BOOL)isRequiredProperty
                     isInstanceProperty:(BOOL)isInstanceProperty {
    return protocol_getProperty(protocol,
                                [name UTF8String],
                                isRequiredProperty,
                                isInstanceProperty);
}

/**
 获取协议中某方法的描述

 @param protocol 协议
 @param sel      方法
 @param isRequiredProperty 是否为必须
 @param isInstanceProperty 是否为实例
 @return 方法描述
 */
+ (struct objc_method_description)ymMethodDesOfProtocol:(Protocol *)protocol
                                                    sel:(SEL)sel
                                     isRequiredProperty:(BOOL)isRequiredProperty
                                     isInstanceProperty:(BOOL)isInstanceProperty{
    return protocol_getMethodDescription(protocol, sel, isRequiredProperty, isInstanceProperty);
}

#pragma mark - 实例相关

#if __has_feature(objc_arc)

#else
/**
 构造一个实例对象(ARC下无效)
 @param classObj 为其分配实例的类
 @param bytes cls实例的字节分配位置。 必须至少指向完全对齐的class_getInstanceSize（cls）个字节, 零填充内存。
 */
+ (id)ymConstructInstance:(Class)classObj
                    bytes:(NSInteger)bytes {
    uintptr_t ptr = 0;
    if (bytes == 0) {
        // 获取实例大小
        size_t objSize = class_getInstanceSize([class class]);
        
        // 设定大小
        size_t allocSize = 2 * objSize;
        
        // 将要分配的内存大小
        ptr = (uintptr_t)calloc(allocSize, 1);
    }
    return objc_constructInstance(classObj, (void *)ptr);
}

/**
 销毁一个类的实例而不释放内存，并删除该实例可能具有的所有关联引用。
 @param instance 要销毁的实例
 @return 销毁的实例
 */
+ (id)ymDestructInstance:(id)instance {
    return objc_destructInstance(instance);
}

/**
 拷贝对象
 
 @param objcect 要拷贝的对象
 @param size    对象大小
 @return 拷贝后的对象
 */
+ (id)ymCopyObject:(id)objcect
              size:(size_t)size {
    return object_copy(objcect, size);
}

/**
 释放对象
 
 @param object 要释放的对象
 @return 释放后的对象
 */
+ (id)ymDisposeObject:(id)object {
    return object_dispose(object);
}

#endif


/**
 使用给定的键和关联策略为给定的对象设置关联值。
 @param objc 关联的源对象
 @param key 关联的键
 @param value 与对象的键相关联的值
 @param association 关联的策略
 */
+ (void)ymSetAssociatedObject:(id)objc
                          key:(NSString *)key
                        value:(id)value
                  association:(kAssociation)association {
    objc_AssociationPolicy policy;
    switch (association) {
        case kAssociation_Assign:
            policy = OBJC_ASSOCIATION_ASSIGN;
            break;
        case kAssociation_Retain_Nonatomic:
            policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
            break;
        case kAssociation_Copy_Nonatomic:
            policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
            break;
        case kAssociation_Retain:
            policy = OBJC_ASSOCIATION_RETAIN;
            break;
        case kAssociation_Copy:
            policy = OBJC_ASSOCIATION_COPY;
            break;
        default:
            break;
    }
    objc_setAssociatedObject(objc,
                             [key UTF8String],
                             value,
                             policy);
}

/**
 返回与给定键的给定对象关联的值。
 @param objc 关联的源对象
 @param key 关联的键
 @return 与对象的键关联的值。
 */
+ (id)ymAssociatedOfObject:(id)objc
                       key:(NSString *)key {
    return objc_getAssociatedObject(objc, [key UTF8String]);
}

/**
 删除给定对象的所有关联
 @param objc 维护关联对象的对象
 
 @note 此功能的主要目的是使对象轻松返回“原始状态”，因此不应将其用于一般性地从对象中删除关联，因为它还会删除其他客户端可能已添加到该对象中的关联。
 通常，您应该将objc_setAssociatedObject与nil值一起使用以清除关联。
 */
+ (void)ymRemoveAssociatedObjects:(id)objc {
    objc_removeAssociatedObjects(objc);
}

/**
 返回给定类的指定类变量的Ivar
 (目前没有找到关于Objective-C中类变量的信息，一般认为Objective-C不支持类变量。
 注意，返回的列表不包含父类的成员变量和属性。)
 @param classObj 要获取其类变量的类定义
 @param name  要获取的类变量定义的名称
 @return 指向Ivar数据结构的指针，该数据结构包含有关名称指定的类变量的信息
 */
+ (Ivar)ymIvarOfClassWithClass:(Class)classObj
                          name:(NSString *)name {
    return class_getClassVariable(classObj, [name UTF8String]);
}

/**
 获取类实例的大小。
 
 @param classObj 要获取的类
 @return 实例大小
 */
+ (size_t)ymInstanceSizeOfClass:(Class)classObj {
    return class_getInstanceSize(classObj);
}

/**
 创建一个类的实例，在默认的malloc内存区域中为该类分配内存。

 @param classObj 为其分配实例的类
 @param bytes 一个整数，指示要分配的额外字节数。
              除了在类定义中定义的变量外，其他字节还可用于存储其他实例变量。
 @return 实例
 */
+ (id)ymCreateInstance:(Class)classObj
                 bytes:(size_t)bytes {
    return class_createInstance(classObj, bytes);
}

/**
 拷贝类的实例变量列表

 @param classObj 要拷贝的类
 @param count 变量数量
 @return 变量列表
 */
+ (Ivar *)ymIvarsOfClass:(Class)classObj
                   count:(NSInteger *)count {
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList(classObj, &outCount);
    if (count) {
        *count = outCount;
    }
    return ivars;
}

/**
 返回给定类的指定实例变量的Ivar

 @param classObj 获取其实例变量的类
 @param name  要获取的实例变量定义的名称
 @return 指向Ivar数据结构的指针，该数据结构包含有关由名称指定的实例变量的信息。
 */
+ (Ivar)ymIvarOfClass:(Class)classObj
                 name:(NSString *)name {
    return class_getInstanceVariable(classObj, [name UTF8String]);
}

/**
 设置对象中实例变量的值

 @param object 要设置的对象
 @param ivar   要设置的实例变量
 @param value  要设置的值
 */
+ (void)ymSetIvarOfObject:(id)object
                     ivar:(Ivar)ivar
                    value:(id)value
{
    object_setIvar(object, ivar, value);
}



#pragma mark - 方法相关
/**
 替换给定类的方法的实现
 
 @param classObj 要修改的类
 @param sel 要替换的方法
 @param imp 替换后的方法
 @param types 一个字符数组，描述方法参数的类型。
 由于函数必须至少包含两个参数-self和_cmd，因此第二个和第三个字符
 必须为"@:"（第一个字符为返回类型）。
 
 @return cls标识的类的名称标识的方法的先前实现
 
 @note
 此函数的行为有两种不同的方式：
 如果用名称标识的方法尚不存在，则将其添加为如同调用class_addMethod一样。
 指定的类型编码按给定方式使用。
 如果确实存在用名称标识的方法，则将其IMP替换为已调用method_setImplementation。
 指定的类型编码将被忽略
 */
+ (IMP)ymReplaceMethod:(Class)classObj
                   sel:(SEL)sel
                   imp:(IMP)imp
                 types:(const char * _Nullable)types {
    return class_replaceMethod(classObj, sel, imp, types);
}

/**
 获取实例方法
 
 @param classObj 要检查的类
 @param sel   要检索的方法的选择器
 @return Method
 */
+ (Method)ymMethodOfInstanceWithClass:(Class)classObj
                                  sel:(SEL)sel {
    return class_getInstanceMethod(classObj, sel);
}

/**
 获取类方法
 
 @param classObj 要检查的类
 @param sel   要检索的方法的选择器
 @return Method
 */
+ (Method)ymMethodOfClassWithClass:(Class)classObj
                               sel:(SEL)sel {
    return class_getClassMethod(classObj, sel);
}

/**
 获取方法的实现

 @param classObj 要检查的类
 @param sel   要检索的方法的选择器
 @return IMP
 */
+ (IMP)ymIMPOfClass:(Class)classObj
                sel:(SEL)sel {
    return class_getMethodImplementation(classObj, sel);
}

/**
 判断类是否实现某方法

 @param classObj 要检查的类
 @param sel 要检索的方法的选择器
 @return 是否实现
 */
+ (BOOL)ymRespondsSelector:(Class)classObj
                       sel:(SEL)sel {
    return class_respondsToSelector(classObj, sel);
}

/**
 拷贝类的方法列表

 @param classObj 要拷贝的类
 @param count 方法数量
 @return 方法列表
 */
+ (Method *)ymMethodsOfClass:(Class)classObj
                       count:(NSInteger *)count {
    unsigned int outCount;
    Method * methods = class_copyMethodList(classObj, &outCount);
    if (count) {
        *count = outCount;
    }
    return methods;
}

/**
 设置方法的实现
 
 @param method 为其设置实现的方法
 @param imp    设置为此方法的实现
 @return 方法先前的实现
 */
+ (IMP)ymSetImpOfMethod:(Method)method
                               imp:(IMP)imp {
    return method_setImplementation(method, imp);
}

/**
 替换方法的实现

 @param method    要替换的方法实现
 @param newMethod 新的方法实现
 */
+ (void)ymExchangeImpOfMethod:(Method)method
                    newMethod:(Method)newMethod {
    method_exchangeImplementations(method, newMethod);
}

/**
 返回方法的SEL

 @param method 检查方法
 @return SEL类型的指针
 */
+ (SEL)ymSelOfMethod:(Method)method {
    return method_getName(method);
}

/**
 获取方法的实现

 @param method 检查方法
 @return IMP类型的指针
 */
+ (IMP)ymImpOfMethod:(Method)method {
    return method_getImplementation(method);
}

/**
 获取方法的类型编码

 @param method 检查方法
 @return 类型编码
 */
+ (NSString *)ymTypeEncodingOfMethod:(Method)method {
    return [NSString stringWithUTF8String:method_getTypeEncoding(method)];
}

/**
 获取方法的参数个数

 @param method 检查方法
 @return 参数个数
 */
+ (unsigned int)ymArgumentsNumberOfMethod:(Method)method {
    return method_getNumberOfArguments(method);
}

/**
 拷贝方法的返回类型

 @param method 检查方法
 @return 返回类型
 */
+ (NSString *)ymCopyReturnTypeOfMethod:(Method)method {
    return [NSString stringWithUTF8String:method_copyReturnType(method)];
}

/**
 获取方法的返回类型

 @param method 检查方法
 @return 返回类型
 */
+ (NSString *)ymReturnTypeOfMethod:(Method)method {
    char returnType;
    method_getReturnType(method, &returnType, sizeof(char));
    return [NSString stringWithFormat:@"%c", returnType];
}

/**
 返回描述方法的单个参数类型的字符串

 @param method 检查方法
 @param index  要检查的参数的索引
 @return 一个C字符串，描述索引索引处的参数类型；
         如果method没有参数索引，则为NULL。
         您必须使用free()释放字符串。
 */
+ (NSString *)ymCopyArgumentTypeOfMethod:(Method)method
                                   index:( unsigned int)index {
    char * argumentType = method_copyArgumentType(method, index);
    NSString * argumentTypeStr = [NSString stringWithUTF8String: argumentType];
    free(argumentType);
    return argumentTypeStr;
}

/**
 获取方法的描述

 @param method 方法
 @return 描述
 */
+ (struct objc_method_description *)ymDescriptiongOfMethod:(Method)method {
    return method_getDescription(method);
}

#pragma mark - 属性
/**
 获取属性名

 @param property 属性
 @return 属性名
 */
+ (NSString *)ymPropertyNameOfProperty:(objc_property_t)property {
    return [NSString stringWithUTF8String:property_getName(property)];
}

/**
 获取属性的特性

 @param property 属性
 @return 特性列表
 */
+ (NSString *)ymPropertyAttributeOfProperty:(objc_property_t)property {
    return [NSString stringWithUTF8String:property_getAttributes(property)];
}

/**
 拷贝属性中某特性的值

 @param property 属性
 @param attributeName 特性名
 @return 特性值
 */
+ (NSString *)ymCopyPropertyAttributeValueOfPropery:(objc_property_t)property attributeName:(NSString *)attributeName {
    char * value = property_copyAttributeValue(property, [attributeName UTF8String]);
    if (value) {
        return [NSString stringWithUTF8String:value];
    }
    return nil;
}

/**
 拷贝属性的特性列表

 @param property 属性
 @param count    特性数量
 @return 特性列表
 */
+ (objc_property_attribute_t *)ymPropertyAttirbutesOfProperty:(objc_property_t)property count:(NSInteger *)count {
    unsigned int outCount;
    objc_property_attribute_t * property_attributes = property_copyAttributeList(property, &outCount);
    if (count) {
        *count = outCount;
    }
    return property_attributes;
}

#pragma mark - Ivar

/**
 获取Ivar名称
 @param ivar Ivar
 @return 名称
 */
+ (NSString *)ymNameOfIvar:(Ivar)ivar {
    return [NSString stringWithUTF8String:ivar_getName(ivar)];
}

/**
 获取Ivar类型编码

 @param ivar Ivar
 @return 名称
 */
+ (NSString *)ymTypeEncodingOfIvar:(Ivar)ivar {
    return [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
}

/**
 获取偏移量

 @param ivar Ivar
 @return 偏移量
 */
+ (ptrdiff_t)ymOffsetOfIvar:(Ivar)ivar {
    return ivar_getOffset(ivar);
}

#pragma mark - SEL
/**
 获取SEL名称

 @param sel SEL
 @return 名称
 */
+ (NSString *)ymNameOfSel:(SEL)sel {
    return [NSString stringWithUTF8String:sel_getName(sel)];
}

/**
 注册方法
 @param name 方法名
 @return SEL
 */
+ (SEL)ymRegisterSelWithName:(NSString *)name {
    // 该方法与sel_getName一样
    return sel_registerName([name UTF8String]);
}

/**
 返回一个布尔值，该值指示两个选择器是否相等

 @param sel1 sel
 @param sel2 sel
 @return 是否相同
 */
+ (BOOL)ymIsEqual:(SEL)sel1
             sel2:(SEL)sel2 {
    return sel_isEqual(sel1, sel2);
}

#pragma mark - IMP
/**
 创建指向将在调用方法时调用该块的函数的指针
 
 @param block 实现此方法的块
 int (^impyBlock)(id, int, int) = ^(id _self, int a, int b) {
    return a+b;
 };
 
 @return IMP
 */
+ (IMP)ymImpOfBlock:(id)block {
    return imp_implementationWithBlock(block);
}

/**
 获取函数指针中的代码块

 @param imp IMP
 @return 代码块
 */
+ (id)ymBlockOfImp:(IMP)imp {
    return imp_getBlock(imp);
}

/**
 移除IMP中的代码块

 @param imp IMP
 @return 移除结果
 */
+ (BOOL)ymRemoveBlockOfImp:(IMP)imp {
    return imp_removeBlock(imp);
}

@end
