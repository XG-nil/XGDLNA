//
//  XGDeviceListVC.m
//  XGDLNA
//
//  Created by wangxinyu on 2020/2/10.
//  Copyright © 2020年 wangxinyu. All rights reserved.
//
#import "XGMacros.h"
#import "XGDeviceListVC.h"
#import "XGDeviceControlVC.h"
#import "CLUPnP.h"

@interface XGDeviceListVC ()<UITableViewDelegate, UITableViewDataSource, CLUPnPServerDelegate>

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSArray* deviceArray;
@property (nonatomic,strong) CLUPnPServer *server;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation XGDeviceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.tableView];
    self.server = [CLUPnPServer shareServer];
    self.server.searchTime = 5;
    self.server.delegate = self;
    [self.server start];
    // Do any additional setup after loading the view.
}

#pragma mark - CLUPnPServerDelegate
- (void)upnpSearchChangeWithResults:(NSArray<CLUPnPDevice *> *)devices{
    NSMutableArray *deviceMarr = [NSMutableArray array];
    for (CLUPnPDevice *device in devices) {
        if ([device.uuid containsString:serviceType_AVTransport]) {
            [deviceMarr addObject:device];
        }
    }
    self.deviceArray = [deviceMarr copy];
    [self.tableView reloadData];
}

- (void)upnpSearchErrorWithError:(NSError *)error{
    NSLog(@"DLNA_Error======>%@", error);
}


#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    CLUPnPDevice *device = self.deviceArray[indexPath.row];
    cell.textLabel.text = device.friendlyName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *testUrl = @"http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4";
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CLUPnPDevice *device = self.deviceArray[indexPath.row];
    XGDeviceControlVC *controller = [[XGDeviceControlVC alloc] init];
    controller.device = device;
    controller.playUrl = testUrl;
    controller.server = self.server;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceArray.count;
}

#pragma mark - lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}


@end
