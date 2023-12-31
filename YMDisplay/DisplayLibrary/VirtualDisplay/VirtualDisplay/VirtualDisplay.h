//
//  VirtualDisplay.h
//  YMDisplay
//
//  Created by 黄玉洲 on 2022/7/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VirtualDisplay : NSObject
{
    unsigned int _vendorID;
    unsigned int _productID;
    unsigned int _serialNum;
    NSString *_name;
    struct CGSize _sizeInMillimeters;
    unsigned int _maxPixelsWide;
    unsigned int _maxPixelsHigh;
    struct CGPoint _redPrimary;
    struct CGPoint _greenPrimary;
    struct CGPoint _bluePrimary;
    struct CGPoint _whitePoint;
    id _queue;
    id _terminationHandler;
    void *_client;
    unsigned int _displayID;
    unsigned int _hiDPI;
    NSArray *_modes;
    unsigned int _serverRPC_port;
    unsigned int _proxyRPC_port;
    unsigned int _clientHandler_port;
}

@property(readonly, nonatomic) NSArray *modes; // @synthesize modes=_modes;
@property(readonly, nonatomic) unsigned int hiDPI; // @synthesize hiDPI=_hiDPI;
@property(readonly, nonatomic) unsigned int displayID; // @synthesize displayID=_displayID;
@property(readonly, nonatomic) id terminationHandler; // @synthesize terminationHandler=_terminationHandler;
@property(readonly, nonatomic) id queue; // @synthesize queue=_queue;
@property(readonly, nonatomic) struct CGPoint whitePoint; // @synthesize whitePoint=_whitePoint;
@property(readonly, nonatomic) struct CGPoint bluePrimary; // @synthesize bluePrimary=_bluePrimary;
@property(readonly, nonatomic) struct CGPoint greenPrimary; // @synthesize greenPrimary=_greenPrimary;
@property(readonly, nonatomic) struct CGPoint redPrimary; // @synthesize redPrimary=_redPrimary;
@property(readonly, nonatomic) unsigned int maxPixelsHigh; // @synthesize maxPixelsHigh=_maxPixelsHigh;
@property(readonly, nonatomic) unsigned int maxPixelsWide; // @synthesize maxPixelsWide=_maxPixelsWide;
@property(readonly, nonatomic) struct CGSize sizeInMillimeters; // @synthesize sizeInMillimeters=_sizeInMillimeters;
@property(readonly, nonatomic) NSString *name; // @synthesize name=_name;
@property(readonly, nonatomic) unsigned int serialNum; // @synthesize serialNum=_serialNum;
@property(readonly, nonatomic) unsigned int productID; // @synthesize productID=_productID;
@property(readonly, nonatomic) unsigned int vendorID; // @synthesize vendorID=_vendorID;
- (BOOL)applySettings:(id)arg1;
- (void)dealloc;
- (id)initWithDescriptor:(id)arg1;

+ (instancetype)initWithDescriptor:(id)arg1;

@end

NS_ASSUME_NONNULL_END
