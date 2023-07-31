//
//  DisplayDefinition.m
//  YMDisplay
//
//  Created by 黄玉洲 on 2022/7/10.
//

#import "DisplayDefinition.h"


#pragma mark - 屏幕配置基类
@interface BaseDisplayDefinition ()

@end


@implementation BaseDisplayDefinition

- (void)setupMultiplier:(int)aspectW aspectH:(int)aspectH hiDPI:(bool)hiDPI {
    self.aspectWidth = aspectW;
    self.aspectHeight = aspectH;
    self.hiDPI = hiDPI;
    
    int minX = 720;
    int minY = 720;
    int maxX = 8192;
    int maxY = 8192;
    self.minMultiplier =
    MAX((int)(ceil((float)minX) / ((float)aspectW * (hiDPI ? 2 : 1) )),
        (int)(ceil((float)minY) / ((float)aspectH * (hiDPI ? 2 : 1) )));
    self.maxMultiplier =
    MIN((int)(ceil((double)maxX) / (double)aspectW * (hiDPI ? 2 : 1) ),
        (int)(ceil((double)maxY / (double)aspectH * (hiDPI ? 2 : 1) )));
}

@end

#pragma mark - 以分辨率比率来创建虚拟屏
@interface DisplayDefinition ()

@property (assign, nonatomic) double refreshRate;

@end

@implementation DisplayDefinition

- (instancetype)init {
    if (self = [super init]) {
        self.refreshRate = 60;
    }
    return self;
}

#pragma mark - Class method
+ (instancetype)aspectW:(int)aspectW aspectH:(int)aspectH hiDPI:(bool)hiDPI descript:(NSString *)descript {
    return [self aspectW:aspectW aspectH:aspectH hiDPI:hiDPI inches:24 descript:descript];
}

+ (instancetype)aspectW:(int)aspectW aspectH:(int)aspectH hiDPI:(bool)hiDPI inches:(int)inches descript:(NSString *)descript {
    DisplayDefinition * definition = [[DisplayDefinition alloc] init];
    definition.definitionDescription = descript;
    definition.inches = inches;
    [definition setupMultiplier:aspectW aspectH:aspectH hiDPI:hiDPI];
    return definition;
}

+ (NSArray <DisplayDefinition *> *)defaltDisplayDefinitions {
    NSArray * definitions = @[
        [DisplayDefinition aspectW:16 aspectH:9 hiDPI:false descript:@"16:9 (HD/4K/5K/6K)"],
        [DisplayDefinition aspectW:16 aspectH:9 hiDPI:true descript:@"16:9 (HD/4K/5K/6K) hiDPI"],
        [DisplayDefinition aspectW:16 aspectH:10 hiDPI:false descript:@"16:10 (W*XGA)"],
        [DisplayDefinition aspectW:16 aspectH:10 hiDPI:true descript:@"16:10 (W*XGA) hiDPI"],
//        [DisplayDefinition aspectW:16 aspectH:12 hiDPI:true descript:@"4:3 (VGA, iPad)"],
//        [DisplayDefinition aspectW:256 aspectH:135 hiDPI:true descript:@"17:9 (4K-DCI)"],
//        [DisplayDefinition aspectW:64 aspectH:27 hiDPI:true descript:@"21.3:9 (UW-HD/4K/5K)"],
//        [DisplayDefinition aspectW:43 aspectH:18 hiDPI:true descript:@"21.5:9 (UW-QHD)"],
//        [DisplayDefinition aspectW:24 aspectH:10 hiDPI:false descript:@"24:10 (UW-QHD+)"],
//        [DisplayDefinition aspectW:32 aspectH:10 hiDPI:false descript:@"32:10 (D-W*XGA)"],
//        [DisplayDefinition aspectW:32 aspectH:9 hiDPI:true descript:@"32:9 (D-HD/QHD)"],
//        [DisplayDefinition aspectW:20 aspectH:20 hiDPI:true descript:@"1:1 (Square)"],
//        [DisplayDefinition aspectW:9 aspectH:16 hiDPI:true descript:@"9:16 (HD/4K/5K/6K - Portrait)"],
//        [DisplayDefinition aspectW:10 aspectH:16 hiDPI:true descript:@"10:16 (W*XGA - Portrait)"],
//        [DisplayDefinition aspectW:12 aspectH:16 hiDPI:true descript:@"12:16 (VGA - Portrait)"],
//        [DisplayDefinition aspectW:135 aspectH:256 hiDPI:true descript:@"9:17 (4K-DCI - Portrait)"],
//        [DisplayDefinition aspectW:15 aspectH:10 hiDPI:true descript:@"3:2 (Photography)"],
//        [DisplayDefinition aspectW:15 aspectH:12 hiDPI:true descript:@"5:4 (Photography)"],
//        [DisplayDefinition aspectW:152 aspectH:100 hiDPI:false descript:@"15.2:10 (iPad Mini 2021)"],
//        [DisplayDefinition aspectW:66 aspectH:41 hiDPI:true descript:@"23:16 (iPad Air 2020)"],
//        [DisplayDefinition aspectW:199 aspectH:139 hiDPI:true descript:@"14.3:10 (iPad Pro 11\")"]
    ];

    return definitions;
}

@end


#pragma mark - 以固定分辨率来创建虚拟屏
@interface DisplayResolutionDefinition ()

@property (assign, nonatomic) int inches;

@end

@implementation DisplayResolutionDefinition

- (instancetype)init {
    if (self = [super init]) {
        self.hiDPI = true;
    }
    return self;
}

#pragma mark - Class method
+ (instancetype)width:(int)width height:(int)height ppi:(int)ppi descript:(NSString *)descript {
    return [self width:width height:height ppi:ppi hiDPI:true descript:descript];
}

+ (instancetype)width:(int)width height:(int)height ppi:(int)ppi hiDPI:(bool)hiDPI descript:(NSString *)descript {
    // 求比率
    int aspectW = 0;
    int aspectH = 0;
    for (int i=1; i<= width; i++) {
        if (width%i == 0 && height%i ==0 ) {
            aspectW = width / i;
            aspectH = height / i;
        }
    }
    
    
    // PPI=sqrt(pow(width, 2) + pow(height, 2)) / inches(英寸); 1 inches=25.4mm
    DisplayResolutionDefinition * definition = [[DisplayResolutionDefinition alloc] init];
    definition.width = width;
    definition.height = height;
    definition.ppi = ppi;
    float inches = sqrt(pow(width, 2) + pow(height, 2)) / ppi;
    NSLog(@"inches:%.1lf", inches);
    definition.inches = sqrt(pow(width, 2) + pow(height, 2)) / ppi;
    definition.definitionDescription = descript;
    [definition setupMultiplier:aspectW aspectH:aspectH hiDPI:hiDPI];
    return definition;
}

+ (NSArray <DisplayResolutionDefinition *> *)defaltDisplayDefinitions {
    NSArray * definitions = @[
        [DisplayResolutionDefinition width:6016 height:3384 ppi:218 hiDPI:true descript:@"32-inch Pro Display XDR"],
        [DisplayResolutionDefinition width:5120 height:2880 ppi:218 hiDPI:true descript:@"iMac (Retina 5K，27 英寸)"],
        [DisplayResolutionDefinition width:4096 height:2304 ppi:219 hiDPI:true descript:@"iMac (Retina 4K，21.5 英寸)"],
        [DisplayResolutionDefinition width:3072 height:1920 ppi:226 hiDPI:true descript:@"MacBook Pro (Retina, 16 英寸)"],
        [DisplayResolutionDefinition width:2880 height:1880 ppi:220 hiDPI:true descript:@"MacBook Pro (Retina, 15.4 英寸)"],
        [DisplayResolutionDefinition width:2560 height:1660 ppi:227 hiDPI:true descript:@"MacBook Pro (Retina, 13 英寸)"],
        [DisplayResolutionDefinition width:2560 height:1440 ppi:108 hiDPI:false descript:@"Apple Thunderbolt Display (27 英寸)"],
        [DisplayResolutionDefinition width:2304 height:1440 ppi:226 hiDPI:true descript:@"MacBook (Retina, 12 英寸)"],
        [DisplayResolutionDefinition width:1920 height:1200 ppi:94 hiDPI:false descript:@"iMac (24 英寸)"],
        [DisplayResolutionDefinition width:1920 height:1080 ppi:102 hiDPI:false descript:@"iMac (21.5 英寸)"],
        [DisplayResolutionDefinition width:1680 height:1050 ppi:99 hiDPI:false descript:@"iMac (20 英寸)"],
        [DisplayResolutionDefinition width:1440 height:900 ppi:127 hiDPI:false descript:@"MacBook Air (13.3 英寸)"],
        [DisplayResolutionDefinition width:1366 height:768 ppi:135 hiDPI:false descript:@"MacBook Air (11.6 英寸)"],
        [DisplayResolutionDefinition width:1280 height:800 ppi:113 hiDPI:false descript:@"MacBook Pro (13.3 英寸)"],
    ];

    return definitions;
}

@end
