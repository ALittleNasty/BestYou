//
//  GPUVideoCameraVC.m
//  BestYou
//
//  Created by 胡阳 on 2020/4/30.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "GPUVideoCameraVC.h"
#import <AVKit/AVKit.h>
#import <Masonry/Masonry.h>
#import <GPUImage.h>

static float const kMaxRecordTime = 30.0;

#define COMPRESSEDVIDEOPATH [NSHomeDirectory() stringByAppendingFormat:@"/Documents/CompressionVideoField"]

@interface GPUVideoCameraVC ()<GPUImageVideoCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/** 开始按钮按钮 */
@property (nonatomic, strong) UIButton *startBtn;

/** 结束录制按钮 */
@property (nonatomic, strong) UIButton *stopBtn;

/** 播放视频按钮 */
@property (nonatomic, strong) UIButton *playBtn;

/** 摄像头 */
@property (nonatomic, strong) GPUImageVideoCamera *camera;

/** 素描滤镜 */
@property (nonatomic, strong) GPUImageSketchFilter *filter;

/** 视频输出视图 */
@property (nonatomic,strong) GPUImageView *displayView;

/** 视频写入 */
@property (nonatomic,strong) GPUImageMovieWriter *movieWriter;

/** 视频写入的地址URL */
@property (nonatomic,strong) NSURL *movieURL;

/** 视频写入路径 */
@property (nonatomic,copy) NSString *moviePath;

/** 压缩成功后的视频路径 */
@property (nonatomic,copy) NSString *resultPath;

/** 视频时长 */
@property (nonatomic,assign) int seconds;

/** 系统计时器 */
@property (nonatomic,strong) NSTimer *timer;

/** 计时器常量 */
@property (nonatomic,assign) int recordSecond;

/** 视频播放器 */
@property (nonatomic,strong) AVPlayerViewController *player;
@end

@implementation GPUVideoCameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self setupVideoCamera];
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    UIBarButtonItem *switchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"switch_camera"] style:UIBarButtonItemStylePlain target:self action:@selector(switchCamera)];
    self.navigationItem.rightBarButtonItem = switchItem;
    
    _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _startBtn.backgroundColor = [UIColor blueColor];
    [_startBtn setTitle:@"开始" forState:UIControlStateNormal];
    [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_startBtn];
    [_startBtn addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
    [_startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(30);
        make.bottom.equalTo(self.view.mas_bottom).offset(-40);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
    
    _stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _stopBtn.backgroundColor = [UIColor blueColor];
    [_stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    [_stopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_stopBtn];
    [_stopBtn addTarget:self action:@selector(stopAction) forControlEvents:UIControlEventTouchUpInside];
    [_stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-40);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playBtn.backgroundColor = [UIColor blueColor];
    [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_playBtn];
    [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.bottom.equalTo(self.view.mas_bottom).offset(-40);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
}

- (void)setupVideoCamera
{
     NSString *defultPath = [self getVideoPathCache];
     self.moviePath = [defultPath stringByAppendingPathComponent:[self getVideoNameWithType:@"mp4"]];
     // 录制路径
     self.movieURL = [NSURL fileURLWithPath:self.moviePath];
     // ？
     unlink([self.moviePath UTF8String]);
     
    // 创建视频写入工具类
     self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(1280.0, 720.0)];
     self.movieWriter.encodingLiveVideo = YES;
     self.movieWriter.shouldPassthroughAudio = YES;
    
    // 创建摄像头
    _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _camera.horizontallyMirrorFrontFacingCamera = YES;
    _camera.delegate = self;
    
    _filter = [[GPUImageSketchFilter alloc] init];
    // 给视频写入器添加素描滤镜
    [self.filter addTarget:self.movieWriter];
    
    // 创建显示图层
    _displayView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    _displayView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view insertSubview:_displayView atIndex:0];
    [_displayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 设置滤镜
    [_camera addTarget:_filter];
    [_filter addTarget:_displayView];
    
    // 开始捕获画面
    [_camera startCameraCapture];
}

#pragma mark - GPUImageVideoCameraDelegate
 
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    
}

#pragma mark - Action

// 切换摄像头
- (void)switchCamera
{
    [_camera rotateCamera];
}

// 开始录制视频
- (void)startAction
{
    self.camera.audioEncodingTarget = self.movieWriter;
    // 开始录制
    [self.movieWriter startRecording];
    
    [self.timer setFireDate:[NSDate distantPast]];
    [self.timer fire];
}

// 停止录制视频
- (void)stopAction
{
    [self.timer invalidate];
    self.timer = nil;
    
    __weak typeof(self) ws = self;
    [self.movieWriter finishRecording];
    [self.filter removeTarget:self.movieWriter];
    self.camera.audioEncodingTarget = nil;
    
    [self compressVideoWithUrl:self.movieURL compressionType:AVAssetExportPresetHighestQuality filePath:^(NSString *resultPath, float memorySize, NSString *videoImagePath, int seconds) {
       
        NSData *data = [NSData dataWithContentsOfFile:resultPath];
        CGFloat totalTime = (CGFloat)data.length / 1024 / 1024;
        NSLog(@"录制视频大小: %.2f MB", totalTime);
        
        ws.resultPath = resultPath;
    }];
}

// 播放录制视频
- (void)playAction
{
    if (_player == nil) {
        _player = [[AVPlayerViewController alloc] init];
        _player.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    _player.player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:self.resultPath]];
    [self presentViewController:_player animated:NO completion:nil];
}

#pragma mark -- Lazy Load Timer

// 计时器
-(NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateWithTime) userInfo:nil repeats:YES];
    }
    return _timer;
}

#pragma mark -- Timer Action

// 超过最大录制时长结束录制
-(void)updateWithTime {
    
    self.recordSecond++;
    if (self.recordSecond > kMaxRecordTime) {
        [self stopAction];
    }
}

#pragma mark - Util

// 获取视频地址
-(NSString *)getVideoPathCache
{
    NSString *videoCache = [NSTemporaryDirectory() stringByAppendingString:@"videos"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if (!existed) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return videoCache;
}

// 获取视频名称
-(NSString *)getVideoNameWithType:(NSString *)fileType
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:now];
    NSString *timeStr = [formatter stringFromDate:nowDate];
    NSString *fileName = [NSString stringWithFormat:@"video_%@.%@",timeStr,fileType];
    return fileName;
}

// 压缩视频
-(void)compressVideoWithUrl:(NSURL *)url compressionType:(NSString *)type filePath:(void(^)(NSString *resultPath,float memorySize,NSString * videoImagePath,int seconds))resultBlock
{
    NSString *resultPath;
    
    // 视频压缩前大小
    NSData *data = [NSData dataWithContentsOfURL:url];
    CGFloat totalSize = (float)data.length / 1024 / 1024;
    NSLog(@"压缩前大小：%.2fM",totalSize);
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    CMTime time = [avAsset duration];
    
    // 视频时长
    int seconds = ceil(time.value / time.timescale);
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:type]) {
        
        // 中等质量
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        
        // 用时间给文件命名 防止存储被覆盖
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        
        // 若压缩路径不存在重新创建
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL isExist = [manager fileExistsAtPath:COMPRESSEDVIDEOPATH];
        if (!isExist) {
            [manager createDirectoryAtPath:COMPRESSEDVIDEOPATH withIntermediateDirectories:YES attributes:nil error:nil];
        }
        resultPath = [COMPRESSEDVIDEOPATH stringByAppendingPathComponent:[NSString stringWithFormat:@"hy_outputVideo-%@.mp4", [formatter stringFromDate:[NSDate date]]]];
        
        session.outputURL = [NSURL fileURLWithPath:resultPath];
        session.outputFileType = AVFileTypeMPEG4;
        session.shouldOptimizeForNetworkUse = YES;
        [session exportAsynchronouslyWithCompletionHandler:^{
            
            switch (session.status) {
                case AVAssetExportSessionStatusCompleted:{
                    NSData *data = [NSData dataWithContentsOfFile:resultPath];
                    // 压缩过后的大小
                    float compressedSize = (float)data.length / 1024 / 1024;
                    resultBlock(resultPath, compressedSize, @"", seconds);
                    NSLog(@"压缩后大小：%.2f",compressedSize);
                }
                default:
                    break;
            }
        }];
    }
}

@end
