//
//  DisplayDefinition.h
//  YMDisplay
//
//  Created by 黄玉洲 on 2022/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface BaseDisplayDefinition : NSObject

@property (assign, nonatomic) int aspectWidth;
@property (assign, nonatomic) int aspectHeight;

@property (assign, nonatomic) bool hiDPI; // 默认true；

@property (assign, nonatomic) int minMultiplier;
@property (assign, nonatomic) int maxMultiplier;

@property (copy, nonatomic) NSString * definitionDescription;

@end

#pragma mark - 以分辨率比率来创建虚拟屏
@interface DisplayDefinition : BaseDisplayDefinition

@property (assign, nonatomic) int inches; // 屏幕尺寸(默认24)

+ (instancetype)aspectW:(int)aspectW aspectH:(int)aspectH hiDPI:(bool)hiDPI descript:(NSString *)descript;
+ (instancetype)aspectW:(int)aspectW aspectH:(int)aspectH hiDPI:(bool)hiDPI inches:(int)inches descript:(NSString *)descript;
+ (NSArray <DisplayDefinition *> *)defaltDisplayDefinitions;

@property (assign, nonatomic, readonly) double refreshRate; // 默认:60,[24, 25, 30, 48, 50, 60, 90, 120] 只有60Hz在实践中似乎是有用的

@end



#pragma mark - 以固定分辨率来创建虚拟屏
@interface DisplayResolutionDefinition : BaseDisplayDefinition

+ (instancetype)width:(int)width height:(int)height ppi:(int)ppi descript:(NSString *)descript;
+ (instancetype)width:(int)width height:(int)height ppi:(int)ppi hiDPI:(bool)hiDPI descript:(NSString *)descript;
+ (NSArray <DisplayResolutionDefinition *> *)defaltDisplayDefinitions;

@property (assign, nonatomic) int width;
@property (assign, nonatomic) int height;

@property (assign, nonatomic, readonly) int inches;
@property (assign, nonatomic) int ppi; // 分辨率密度

@end

NS_ASSUME_NONNULL_END
