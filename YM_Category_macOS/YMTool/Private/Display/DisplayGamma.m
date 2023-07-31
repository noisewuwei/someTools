//
//  DisplayGamma.m
//  YMTool
//
//  Created by 黄玉洲 on 2022/8/15.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import "DisplayGamma.h"
#import <CoreGraphics/CGDirectDisplay.h>

typedef struct {
    uint32_t sampleCount;
    CGGammaValue * redTable;
    CGGammaValue * greenTable;
    CGGammaValue * blueTable;
} gammaInfo;

gammaInfo * allocGammaInfo(uint32_t capacity) {
    gammaInfo * info = malloc(sizeof(gammaInfo));
    info->redTable = malloc(capacity*sizeof(CGGammaValue));
    info->greenTable = malloc(capacity*sizeof(CGGammaValue));
    info->blueTable = malloc(capacity*sizeof(CGGammaValue));
    return info;
}

void freeGammaInfo(gammaInfo * info) {
    free(info->redTable);
    free(info->greenTable);
    free(info->blueTable);
    free(info);
}

gammaInfo * getGammaTableForDisplay(int displayID){
    uint32_t capacity = CGDisplayGammaTableCapacity(displayID);
    gammaInfo * info = allocGammaInfo(capacity);
    CGError err = CGGetDisplayTransferByTable (displayID, capacity, info->redTable, info->greenTable, info->blueTable, &info->sampleCount);
    if(err){
        freeGammaInfo(info);
        return NULL;
    }else{
        return info;
    }
}

gammaInfo * copyGammaInfo(gammaInfo * info){
    gammaInfo * copy = allocGammaInfo(info->sampleCount);
    copy->sampleCount = info->sampleCount;
    for(int i=0; i<info->sampleCount; i++){
        copy->redTable[i]   = info->redTable[i];
        copy->greenTable[i] = info->greenTable[i];
        copy->blueTable[i]  = info->blueTable[i];
    }
    return copy;
}

CGError setGammaInfoForDisplayID(int displayID, gammaInfo * info){
    CGError err = CGSetDisplayTransferByTable (displayID, info->sampleCount, info->redTable, info->greenTable, info->blueTable);
    return err;
}

@implementation DisplayGamma

+ (DisplayGamma *)initWithDisplayID:(int)displayID {
    DisplayGamma * gamma = [[DisplayGamma alloc] init];
    gammaInfo * temp = getGammaTableForDisplay(displayID);
    if (temp) {
        gamma.length = temp->sampleCount;
        for (int i = 0; i < temp->sampleCount; i++) {
            gamma.redTable[i] = @( temp->redTable[i] );
            gamma.greenTable[i] = @( temp->greenTable[i] );
            gamma.blueTable[i] = @( temp->blueTable[i] );
        }
        
        freeGammaInfo(temp);
        return gamma;
    }
    return nil;
}

- (instancetype)init {
    if (self = [super init]) {
        self.length = 0;
        self.redTable = [NSMutableArray array];
        self.greenTable = [NSMutableArray array];
        self.blueTable = [NSMutableArray array];
    }
    return self;
}

- (DisplayGamma *)clone {
    DisplayGamma * newGamma = [[DisplayGamma alloc] init];
    newGamma.length = self.length;
    newGamma.redTable = [self.redTable mutableCopy];
    newGamma.greenTable = [self.greenTable mutableCopy];
    newGamma.blueTable = [self.blueTable mutableCopy];
    return newGamma;
}

- (DisplayGamma *)copyWithBrightness:(float)brightness {
    DisplayGamma * gamma = [self clone];
    for(int i=0; i < self.length; i++){
        gamma.redTable[i]   = @(brightness*[gamma.redTable[i] floatValue]);
        gamma.greenTable[i] = @(brightness*[gamma.greenTable[i] floatValue]);
        gamma.blueTable[i]  = @(brightness*[gamma.blueTable[i] floatValue]);
    }
    return gamma;
}

- (CGError)applyToDisplayID:(int)displayID {
    gammaInfo * info = allocGammaInfo(self.length);
    info->sampleCount = self.length;
    for (int i = 0; i < self.length; i++) {
        info->redTable[i] = [self.redTable[i] floatValue];
        info->greenTable[i] = [self.greenTable[i] floatValue];
        info->blueTable[i] = [self.blueTable[i] floatValue];
    }
    CGError err = setGammaInfoForDisplayID(displayID, info);
    freeGammaInfo(info);
    return err;
}

@end
