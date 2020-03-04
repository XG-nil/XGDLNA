//
//  XGMacros.h
//  XGDLNA
//
//  Created by wangxinyu on 2020/2/10.
//  Copyright © 2020年 wangxinyu. All rights reserved.
//

#ifndef XGMacros_h
#define XGMacros_h

//screen
#define SCREEN_WIDTH                    MIN(([[UIScreen mainScreen] bounds].size.width),([[UIScreen mainScreen] bounds].size.height))
#define SCREEN_HEIGHT                   MAX(([[UIScreen mainScreen] bounds].size.height),([[UIScreen mainScreen] bounds].size.width))

//color
#define RGB(A, B, C)                    [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:1.0]
#define RGBColor(r,g,b,a) [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:a]

//weak/strong self
#define WEAK_SELF                   __weak __typeof(self)weakSelf = self;
#define STRONG_SELF                 __strong __typeof(weakSelf)self = weakSelf;

#endif /* XGMacros_h */
