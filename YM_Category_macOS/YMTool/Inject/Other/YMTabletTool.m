//
//  YMTabletTool.m
//  YMTool
//
//  Created by zuler on 2022/8/1.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import "YMTabletTool.h"
#import <Carbon/Carbon.h>

@interface YMTabletTool()

@property (strong, nonatomic) dispatch_queue_t tabletQueue;

@end

@implementation YMTabletTool

static YMTabletTool * instance = nil;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [YMTabletTool new];
    });
    return instance;
}

- (void)postMouseAction:(int)status point:(CGPoint)point{
    dispatch_async(self.tabletQueue, ^{
        if (status == 1) {
            CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
            CGEventRef theEvent = CGEventCreateMouseEvent(source, kCGEventLeftMouseDown, point, kCGMouseButtonLeft);
            CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, 1);
            CGEventSetIntegerValueField(theEvent, kCGMouseEventSubtype, kCGEventMouseSubtypeTabletPoint);
            CGEventSetDoubleValueField(theEvent, kCGMouseEventPressure, 0.1);;
    //        CGEventSetIntegerValueField(theEvent, kCGTabletEventPointX, 803);
    //        CGEventSetIntegerValueField(theEvent, kCGTabletEventPointY, 565);
    //        CGEventSetIntegerValueField(theEvent, kCGTabletEventPointZ, 0);
    //        CGEventSetIntegerValueField(theEvent, kCGTabletEventPointButtons, 0x1);
    //        CGEventSetDoubleValueField(theEvent, kCGTabletEventTiltX, 0.08233893856624043);
    //        CGEventSetDoubleValueField(theEvent, kCGTabletEventTiltY, 0);
            CGEventSetType(theEvent, kCGEventLeftMouseDown);
            CGEventPost(kCGHIDEventTap, theEvent);
            CFRelease(theEvent);
            CFRelease(source);
        }else{
            CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
            CGEventRef theEvent = CGEventCreateMouseEvent(source, kCGEventLeftMouseUp, point, kCGMouseButtonLeft);
            CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, 1);
            CGEventSetIntegerValueField(theEvent, kCGMouseEventSubtype, kCGEventMouseSubtypeTabletPoint);
            CGEventSetDoubleValueField(theEvent, kCGMouseEventPressure, 0);
    //        CGEventSetIntegerValueField(theEvent, kCGTabletEventPointX, 696);
    //        CGEventSetIntegerValueField(theEvent, kCGTabletEventPointY, 505);
    //        CGEventSetIntegerValueField(theEvent, kCGTabletEventPointZ, 0);
    //        CGEventSetIntegerValueField(theEvent, kCGTabletEventPointButtons, 0x1);
    //        CGEventSetDoubleValueField(theEvent, kCGTabletEventTiltX, 0.086245307779168071);
    //        CGEventSetDoubleValueField(theEvent, kCGTabletEventTiltY, 0.98821985534226509);
            CGEventSetType(theEvent, kCGEventLeftMouseUp);
            CGEventPost(kCGHIDEventTap, theEvent);
            CFRelease(theEvent);
            CFRelease(source);
        }
    });
}

- (void)postMouseMovePoint:(CGPoint)point{
    dispatch_async(self.tabletQueue, ^{
        CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
        CGEventRef theEvent = CGEventCreateMouseEvent(source, kCGEventMouseMoved, point, kCGMouseButtonLeft);
        CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, 0);
        CGEventSetIntegerValueField(theEvent, kCGMouseEventSubtype, kCGEventMouseSubtypeTabletPoint);
        CGEventSetIntegerValueField(theEvent, kCGMouseEventButtonNumber, -1);

        CGEventSetType(theEvent, kCGEventMouseMoved);
        CGEventPost(kCGHIDEventTap, theEvent);
        CFRelease(theEvent);
        CFRelease(source);
    });
}

- (void)postTabletProximity:(int)value penType:(int)type vendorType:(int)vendorpointertype mask:(int)capabilitymask{//1 pen 3 eraser
    dispatch_async(self.tabletQueue, ^{
        CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
        CGEventRef theEvent = CGEventCreate(source);
        CGEventSetType(theEvent, kCGEventTabletProximity);
        CGEventSetIntegerValueField(theEvent, kCGTabletProximityEventEnterProximity, value);
        CGEventSetIntegerValueField(theEvent, kCGTabletProximityEventPointerType, type);
        CGEventSetIntegerValueField(theEvent, kCGTabletProximityEventVendorPointerType, vendorpointertype);
        CGEventSetIntegerValueField(theEvent, kCGTabletProximityEventCapabilityMask, capabilitymask);
        CGEventPost(kCGHIDEventTap, theEvent);
        CFRelease(theEvent);
        CFRelease(source);
    });
}

- (void)postTabletPenEventPoint:(CGPoint)point pressure:(double)pressure retation:(double)rotation tiltx:(double)tiltx tilty:(double)tilty{
    dispatch_async(self.tabletQueue, ^{
        CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
        CGEventRef theEvent = CGEventCreateMouseEvent(source, kCGEventLeftMouseDragged, point, kCGMouseButtonLeft);
        CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, 0);
        CGEventSetIntegerValueField(theEvent, kCGMouseEventSubtype, kCGEventMouseSubtypeTabletPoint);
        CGEventSetDoubleValueField(theEvent, kCGMouseEventPressure, pressure);
    //    CGEventSetIntegerValueField(theEvent, kCGTabletEventPointX, 572);
    //    CGEventSetIntegerValueField(theEvent, kCGTabletEventPointY, 396);
    //    CGEventSetIntegerValueField(theEvent, kCGTabletEventPointZ, 0);
    //    CGEventSetIntegerValueField(theEvent, kCGTabletEventPointButtons, 0x1);
        CGEventSetDoubleValueField(theEvent, kCGTabletEventTiltX, tiltx);
        CGEventSetDoubleValueField(theEvent, kCGTabletEventTiltY, tilty);
        CGEventSetDoubleValueField(theEvent, kCGTabletEventRotation, rotation);
        CGEventPost(kCGHIDEventTap, theEvent);
        CFRelease(theEvent);
        CFRelease(source);
    });
}

- (dispatch_queue_t)tabletQueue {
    if (!_tabletQueue) {
        _tabletQueue = dispatch_queue_create("com.tabletQueue.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _tabletQueue;
}


@end
