//
//  YMToolHeader.h
//  YMTool
//
//  Created by 海南有趣 on 2020/5/14.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#ifdef DEBUG
    #define YMTooLog(format, ...) \
        printf("%s\n", [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String]); 
#else
    #define YMTooLog(...) NSLog(__VA_ARGS__)
#endif


#define YMToolWeakSelf  \
__weak __typeof(self) weakSelf = self;
//@weakify(self);

/** strongSelf */
#define YMToolStrongSelf \
__strong __typeof(weakSelf) self = weakSelf;

