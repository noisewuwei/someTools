//
//  YMCGSCommon.h
//  YMCGSInternal
//
//  Created by 黄玉洲 on 2022/2/18.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef int YMCGSConnectionID;
typedef int YMCGSWorkspaceID;
typedef enum YMCGSCursorID {
    YMCGSCursorIDIDArrow = 0,
    YMCGSCursorIDIDIBeam,
    YMCGSCursorIDIDIBeamXOR,
    YMCGSCursorIDIDAlias,
    YMCGSCursorIDIDCopy,
    YMCGSCursorIDIDMove,
    YMCGSCursorIDIDArrowCtx,
    YMCGSCursorIDIDWait,
    YMCGSCursorIDIDEmpty,
}YMCGSCursorID;

/// 获取ID
CG_EXTERN YMCGSConnectionID YMCGSMainConnectionID(void);

NS_ASSUME_NONNULL_END
