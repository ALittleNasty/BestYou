//
//  ShortVideoVC.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/4.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "ShortVideoVC.h"
#import "YYRecordButton.h"
#import "YYFilterListView.h"
#import "BYMacro.h"

#import <AVKit/AVKit.h>
#import <Masonry/Masonry.h>
#import <GPUImage.h>

#import "LFGPUImageBeautyFilter.h"

static CGFloat const kButtonWH = 60.f;

@interface ShortVideoVC ()<GPUImageVideoCameraDelegate>

/** 录制按钮 */
@property (nonatomic, strong) YYRecordButton *recordBtn;

/** 滤镜弹框视图 */
@property (nonatomic, strong) YYFilterListView *filterListView;

/** 摄像头 */
@property (nonatomic, strong) GPUImageVideoCamera *camera;

/** 美颜滤镜 */
@property (nonatomic, strong) GPUImageFilter *beautyFilter;

/** 当前滤镜 */
@property (nonatomic, strong) GPUImageFilter *currentFilter;

/** 美颜组合 */
@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;

/** 视频输出视图 */
@property (nonatomic, strong) GPUImageView *displayView;

/** 视频写入 */
@property (nonatomic,strong) GPUImageMovieWriter *movieWriter;

@end

@implementation ShortVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self setupCamera];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    _recordBtn = [[YYRecordButton alloc] initWithFrame:CGRectMake((screenWidth - kButtonWH) * 0.5, screenHeight - kButtonWH -30.f, kButtonWH, kButtonWH)];
    _recordBtn.selected = NO;
    [self.view addSubview:_recordBtn];
    [_recordBtn addTarget:self action:@selector(recordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchBtn setImage:[UIImage imageNamed:@"switch_camera_white"] forState:UIControlStateNormal];
    [switchBtn addTarget:self action:@selector(switchButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchBtn];
    [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    UIButton *fliterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fliterBtn setImage:[UIImage imageNamed:@"image_fliter"] forState:UIControlStateNormal];
    [fliterBtn addTarget:self action:@selector(filterButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fliterBtn];
    [fliterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(70);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)setupCamera
{
    // 创建摄像头
    _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _camera.horizontallyMirrorFrontFacingCamera = YES;
    _camera.delegate = self;
    
    _filterGroup = [[GPUImageFilterGroup alloc] init];
     BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:kBeautySwitchKey];
    _beautyFilter = isOn ? [[GPUImageFilter alloc] init] : [[LFGPUImageBeautyFilter alloc] init];
    _currentFilter = [[GPUImageFilter alloc] init];
    [self addGPUImageFilter:_beautyFilter];
    [self addGPUImageFilter:_currentFilter];
    
    // 给视频写入器添加素描滤镜
//    [_filterGroup addTarget:self.movieWriter];
    
    // 创建显示图层
    _displayView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    _displayView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view insertSubview:_displayView atIndex:0];
    [_displayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 设置滤镜
    [_camera addTarget:_filterGroup];
    [_filterGroup addTarget:_displayView];
    
    // 开始捕获画面
    [_camera startCameraCapture];
}

- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    [_filterGroup addFilter:filter];

    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;

    NSInteger count = _filterGroup.filterCount;

    if (count == 1) {
        
        _filterGroup.initialFilters = @[newTerminalFilter];
        _filterGroup.terminalFilter = newTerminalFilter;
    } else {
        
        GPUImageOutput<GPUImageInput> *terminalFilter    = _filterGroup.terminalFilter;
        NSArray *initialFilters                          = _filterGroup.initialFilters;

        [terminalFilter addTarget:newTerminalFilter];

        _filterGroup.initialFilters = @[initialFilters[0]];
        _filterGroup.terminalFilter = newTerminalFilter;
    }
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    
}

#pragma mark - Action

- (void)recordButtonAction:(UIButton *)btn
{
    btn.selected = !btn.isSelected;
}

- (void)closeButtonAction
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)switchButtonAction
{
    [_camera rotateCamera];
}

- (void)filterButtonAction
{
    __weak typeof(self) ws = self;
    if (!_filterListView) {
        _filterListView = [[YYFilterListView alloc] initWithFrame:CGRectZero];
        _filterListView.filterChangeCallback = ^(NSString * _Nullable filterName) {
            [ws switchFilerWithName:filterName];
        };
        _filterListView.beautyChangeCallback = ^(BOOL enableBeauty) {
            [ws beautyActionWithFlag:enableBeauty];
        };
    }
    [_filterListView show];
}

#pragma mark - Filter Switch

- (void)switchFilerWithName:(NSString *)name
{
    NSLog(@"current select filter : %@", name);
    GPUImageFilter *filter = [[NSClassFromString(name) alloc] init];
    
    for (id <GPUImageInput> input in _currentFilter.targets) {
        [filter addTarget:input];
    }
    [_camera removeTarget:_currentFilter];
    [_currentFilter removeAllTargets];
    [_camera addTarget:filter];
    
    _currentFilter = nil;
    _currentFilter = filter;
}

#pragma mark - Enable Beauty

- (void)beautyActionWithFlag:(BOOL)enableBeauty
{
    NSLog(@"%@", enableBeauty ? @"开启美颜" : @"关闭美颜");
    /**
     这里我们采用的方案是:
     开启美颜: 使用 LFGPUImageBeautyFilter 美颜滤镜
     关闭美颜: 使用 GPUImageFilter 原始滤镜
     */
    GPUImageFilter *filter = enableBeauty ? [[LFGPUImageBeautyFilter alloc] init] : [[GPUImageFilter alloc] init];
       
    for (id <GPUImageInput> input in _beautyFilter.targets) {
       [filter addTarget:input];
    }
    [_camera removeTarget:_beautyFilter];
    [_beautyFilter removeAllTargets];
    [_camera addTarget:filter];

    _beautyFilter = nil;
    _beautyFilter = filter;
}

#pragma mark - Hide Status Bar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
