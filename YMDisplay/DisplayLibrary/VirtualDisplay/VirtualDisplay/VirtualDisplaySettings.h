//
//  VirtualDisplaySettings.h
//  VirtualDisplay
//
//  Created by 黄玉洲 on 2022/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VirtualDisplaySettings : NSObject
{
    NSArray *_modes;
    unsigned int _hiDPI;
}

@property(nonatomic) unsigned int hiDPI; // @synthesize hiDPI=_hiDPI;
- (void)dealloc;
- (id)init;
@property(retain, nonatomic) NSArray *modes;

@end

NS_ASSUME_NONNULL_END
