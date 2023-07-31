//
//  YMCGSCommon.m
//  YMCGSInternal
//
//  Created by 黄玉洲 on 2022/2/18.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import "YMCGSCommon.h"

CG_EXTERN int CGSMainConnectionID(void);
YMCGSConnectionID YMCGSMainConnectionID(void) {
    return CGSMainConnectionID();
}
