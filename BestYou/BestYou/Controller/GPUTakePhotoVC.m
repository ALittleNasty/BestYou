//
//  GPUTakePhotoVC.m
//  BestYou
//
//  Created by 胡阳 on 2020/4/30.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "GPUTakePhotoVC.h"
#import "BYUtil.h"

#import <GPUImage.h>
#import <Masonry/Masonry.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface GPUTakePhotoVC ()
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;
@property (nonatomic, strong) GPUImageView *gpuImageView;
@end

@implementation GPUTakePhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self setupGPUCamera];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_camera stopCameraCapture];
}

- (void)setupUI
{
    self.view.backgroundColor = UIColor.blackColor;
    
    UIBarButtonItem *switchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"switch_camera"] style:UIBarButtonItemStylePlain target:self action:@selector(switchCamera)];
    self.navigationItem.rightBarButtonItem = switchItem;
    
    _gpuImageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_gpuImageView];
    [_gpuImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //添加一个按钮触发拍照
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom] ;
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"拍照" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
}

- (void)setupGPUCamera
{
    _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    _filterGroup = [[GPUImageFilterGroup alloc] init];
    
    // 组合滤镜达到美颜效果
    GPUImageBilateralFilter *filter1 = [[GPUImageBilateralFilter alloc] init];
    GPUImageBrightnessFilter *filter2 = [[GPUImageBrightnessFilter alloc] init];
    [self addGPUImageFilter:filter1];
    [self addGPUImageFilter:filter2];
    
    [_camera addTarget:_filterGroup];
    [_filterGroup addTarget:_gpuImageView];
    
    [_camera startCameraCapture];
}

- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    [_filterGroup addFilter:filter]; 

    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;

    NSInteger count = _filterGroup.filterCount;

    if (count == 1)
    {
        _filterGroup.initialFilters = @[newTerminalFilter];
        _filterGroup.terminalFilter = newTerminalFilter;

    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = _filterGroup.terminalFilter;
        NSArray *initialFilters                          = _filterGroup.initialFilters;

        [terminalFilter addTarget:newTerminalFilter];

        _filterGroup.initialFilters = @[initialFilters[0]];
        _filterGroup.terminalFilter = newTerminalFilter;
    }
}

#pragma mark - Action

- (void)switchCamera
{
    [_camera rotateCamera];
}

- (void)takePhoto
{
    [_camera capturePhotoAsJPEGProcessedUpToFilter:_filterGroup withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
        
        [BYUtil saveImageData:processedJPEG];
    }];
}
@end
