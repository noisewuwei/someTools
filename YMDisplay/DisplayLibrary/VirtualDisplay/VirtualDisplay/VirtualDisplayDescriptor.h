//
//  VirtualDisplayDescriptor.h
//  VirtualDisplay
//
//  Created by 黄玉洲 on 2022/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VirtualDisplayDescriptor : NSObject
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
}

@property(retain, nonatomic) id queue; // @synthesize queue=_queue;
@property(retain, nonatomic) NSString *name; // @synthesize name=_name;
@property(nonatomic) struct CGPoint whitePoint; // @synthesize whitePoint=_whitePoint;
@property(nonatomic) struct CGPoint bluePrimary; // @synthesize bluePrimary=_bluePrimary;
@property(nonatomic) struct CGPoint greenPrimary; // @synthesize greenPrimary=_greenPrimary;
@property(nonatomic) struct CGPoint redPrimary; // @synthesize redPrimary=_redPrimary;
@property(nonatomic) unsigned int maxPixelsHigh; // @synthesize maxPixelsHigh=_maxPixelsHigh;
@property(nonatomic) unsigned int maxPixelsWide; // @synthesize maxPixelsWide=_maxPixelsWide;
@property(nonatomic) struct CGSize sizeInMillimeters; // @synthesize sizeInMillimeters=_sizeInMillimeters;
@property(nonatomic) unsigned int serialNum; // @synthesize serialNum=_serialNum;
@property(nonatomic) unsigned int productID; // @synthesize productID=_productID;
@property(nonatomic) unsigned int vendorID; // @synthesize vendorID=_vendorID;
- (void)dealloc;
- (id)init;
@property(copy, nonatomic) id terminationHandler;
- (id)dispatchQueue;
- (void)setDispatchQueue:(id)arg1;

@end

NS_ASSUME_NONNULL_END
