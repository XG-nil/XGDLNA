//
//  XGDeviceControlVC.h
//  XGDLNA
//
//  Created by wangxinyu on 2020/2/10.
//  Copyright © 2020年 wangxinyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLUPnP.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XGDeviceControlVC : UIViewController

@property(nonatomic,copy) NSString *playUrl;

@property(nonatomic,strong) CLUPnPDevice *device;

@property (nonatomic,strong) CLUPnPServer *server;

@end

NS_ASSUME_NONNULL_END
