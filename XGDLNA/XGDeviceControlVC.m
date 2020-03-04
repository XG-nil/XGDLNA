//
//  XGDeviceControlVC.m
//  XGDLNA
//
//  Created by wangxinyu on 2020/2/10.
//  Copyright © 2020年 wangxinyu. All rights reserved.
//

#import "XGMacros.h"
#import "XGDeviceControlVC.h"

@interface XGDeviceControlVC () <CLUPnPResponseDelegate>

@property(nonatomic,strong) CLUPnPRenderer *render;
@property(nonatomic,strong) NSString *volume;
@property(nonatomic,assign) NSInteger seekTime;
@property(nonatomic,assign) BOOL isPlaying;
@property(nonatomic,strong) UIButton *playPauseButton;
@property(nonatomic,strong) UIButton *stopButton;
@property(nonatomic,strong) UIButton *nextButton;
@property(nonatomic,strong) UIButton *plusButton;
@property(nonatomic,strong) UIButton *minusButton;
@property(nonatomic,strong) UISlider *slider; //进度条
@property (strong,nonatomic)NSTimer *timer;
@property(nonatomic,assign) BOOL isNewUrl;

@end

@implementation XGDeviceControlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initRenderer];
    [self initView];
    [self refreshSlideTime];
    [self getCurrentVolume];
}

-(void)initRenderer{
    self.render = [[CLUPnPRenderer alloc] initWithModel:self.device];
    self.render.delegate = self;
    [self.render setAVTransportURL:self.playUrl];
    self.isNewUrl = YES;
    self.isPlaying = YES;
}

-(void)initView{
    [self.view addSubview:self.playPauseButton];
    [self.view addSubview:self.stopButton];
    [self.view addSubview:self.slider];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.plusButton];
    [self.view addSubview:self.minusButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    //timer置为nil，防止内存泄漏
    self.timer = nil;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

/**
 播放
 */
- (void)play{
    if (self.isPlaying == YES) {
        [self.render pause];
    } else {
        [self.render play];
    }
    self.isPlaying = !self.isPlaying;
}

/**
 退出
 */
- (void)stop{
    [self.render stop];
}

/**
 设置音量
 */
- (void)volumeChanged:(NSString *)volume{
    self.volume = volume;
    [self.render setVolumeWith:volume];
}

/**
 设置播放进度
 */
- (void)seekChanged:(NSInteger)seek{
    self.seekTime = seek;
    NSString *seekStr = [self timeFormatted:seek];
    [self.render seekToTarget:seekStr Unit:unitREL_TIME];
}

- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

/**
 切集
 */
- (void)playTheUrl:(NSString *)url{
    self.playUrl = url;
    [self.render setAVTransportURL:url];
    self.isNewUrl = YES;
    self.isPlaying = YES;
}

- (void)nextUrl{
    [self playTheUrl:@"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4"];
}

-(void)refreshSlideTime{
    [self.render getPositionInfo];
}

-(void)getCurrentVolume{
    [self.render getVolume];
}

-(void)volumePlus{
    NSInteger volume = [self.volume integerValue] + 1;
    self.volume = [NSString stringWithFormat:@"%ld",(long)volume];
    [self.render setVolumeWith:self.volume];
}

-(void)volumeMinus{
    NSInteger volume = [self.volume integerValue] - 1;
    self.volume = [NSString stringWithFormat:@"%ld",(long)volume];
    [self.render setVolumeWith:self.volume];
}

//拖放进度条
- (void)sliderValueChange{
    NSInteger sec = self.slider.value;
    [self seekChanged:sec];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshSlideTime) userInfo:nil repeats:YES];
    
}
#pragma mark - CLUPnPResponseDelegate
- (void)upnpSetAVTransportURIResponse{
    [self.render play];
}

- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info{
    //    NSLog(@"%@ === %@", info.currentTransportState, info.currentTransportStatus);
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [self.render play];
    }
}

//获取音频信息
- (void)upnpGetVolumeResponse:(NSString *)volume {
    self.volume = volume;
}

//获取播放进度
- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isNewUrl == YES && info.trackDuration > 0) {
            self.slider.maximumValue = info.trackDuration;
            self.isNewUrl = NO;
        }
        self.slider.value = info.relTime;
    });
}

- (void)upnpPlayResponse{
    NSLog(@"开始播放");
}

#pragma mark - lazy
- (UIButton *)playPauseButton{
    if (!_playPauseButton) {
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _playPauseButton.frame = CGRectMake(SCREEN_WIDTH/2 - 50, SCREEN_HEIGHT/2 - 80, 100, 40);
        [_playPauseButton setTitle:@"播放/暂停" forState:UIControlStateNormal];
        [_playPauseButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playPauseButton;
}

- (UIButton *)stopButton{
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _stopButton.frame = CGRectMake(SCREEN_WIDTH/2 - 50, SCREEN_HEIGHT/2, 80, 30);
        [_stopButton setTitle:@"退出" forState:UIControlStateNormal];
        [_stopButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopButton;
}

- (UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _nextButton.frame = CGRectMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT/2 - 80, 60, 40);
        [_nextButton setTitle:@"下一集" forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextUrl) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIButton *)plusButton{
    if (!_plusButton) {
        _plusButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _plusButton.frame = CGRectMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT/2 - 140, 60, 40);
        [_plusButton setTitle:@"音量+" forState:UIControlStateNormal];
        [_plusButton addTarget:self action:@selector(volumePlus) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusButton;
}

- (UIButton *)minusButton{
    if (!_minusButton) {
        _minusButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _minusButton.frame = CGRectMake(40, SCREEN_HEIGHT/2 - 140, 60, 40);
        [_minusButton setTitle:@"-音量" forState:UIControlStateNormal];
        [_minusButton addTarget:self action:@selector(volumeMinus) forControlEvents:UIControlEventTouchUpInside];
    }
    return _minusButton;
}

- (UISlider *)slider {
    if (_slider == nil) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT/2 + 60, SCREEN_WIDTH - 20, 2)];
        _slider.backgroundColor = [UIColor whiteColor];
        _slider.maximumValue = 60;//slide的最大值,先设置个缺省值
        _slider.thumbTintColor = [UIColor blueColor];
        [_slider thumbRectForBounds:CGRectMake(0, 0, 40, 40) trackRect:CGRectMake(0, 0, SCREEN_WIDTH - 20, 2) value:0];
        [_slider setMinimumTrackTintColor:[UIColor blueColor]];
        [_slider setMaximumTrackTintColor:[UIColor grayColor]];
        [_slider thumbRectForBounds:CGRectMake(0, 0, 8, 8) trackRect:CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 2) value:0];
        //初始化播放进度 为 00:00
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshSlideTime) userInfo:nil repeats:YES];
        [_slider addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventTouchUpInside];
    }
    return _slider;
}


@end
