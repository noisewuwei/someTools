//
//  VirtualDisplayMode.h
//  VirtualDisplay
//
//  Created by 黄玉洲 on 2022/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VirtualDisplayMode : NSObject
{
    unsigned int _width;
    unsigned int _height;
    double _refreshRate;
}

@property(readonly, nonatomic) double refreshRate; // @synthesize refreshRate=_refreshRate;
@property(readonly, nonatomic) unsigned int height; // @synthesize height=_height;
@property(readonly, nonatomic) unsigned int width; // @synthesize width=_width;
- (id)initWithWidth:(unsigned int)arg1 height:(unsigned int)arg2 refreshRate:(double)arg3;

@end

NS_ASSUME_NONNULL_END
