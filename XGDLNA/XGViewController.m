//
//  ViewController.m
//  XGDLNA
//
//  Created by wangxinyu on 11/28/19.
//  Copyright © 2019 wangxinyu. All rights reserved.
//
#import "XGMacros.h"
#import "XGViewController.h"
#import "XGDeviceListVC.h"

@interface XGViewController ()

@end

@implementation XGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    startButton.frame = CGRectMake(0, SCREEN_HEIGHT/2 - 50, SCREEN_WIDTH, 100);
    [startButton setTitle:@"START DLNA" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(onStartButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)onStartButtonClick {
    XGDeviceListVC *deviceList = [[XGDeviceListVC alloc]init];
    [self.navigationController pushViewController:deviceList animated:YES];
    
}




@end
