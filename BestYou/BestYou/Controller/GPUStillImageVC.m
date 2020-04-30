//
//  GPUStillImageVC.m
//  BestYou
//
//  Created by 胡阳 on 2020/4/30.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "GPUStillImageVC.h"
#import <GPUImage.h>
#import <Masonry/Masonry.h>

@interface GPUStillImageVC ()

@property (nonatomic, strong) UIImageView *resultImageView;

@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;

@end

@implementation GPUStillImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI
{
    _resultImageView = [[UIImageView alloc] initWithImage:_image];
    [self.view addSubview:_resultImageView];
    [_resultImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = -1.0;
    slider.maximumValue = 1.0;
    slider.value = 0.0;
    slider.continuous = YES;
    slider.minimumTrackTintColor = [UIColor greenColor];
    slider.maximumTrackTintColor = [UIColor redColor];
    slider.thumbTintColor = [UIColor redColor];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-40);
        make.height.equalTo(@35);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
    }];
    
    _brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    _brightnessFilter.brightness = 0.0;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    // 更新亮度值
    _brightnessFilter.brightness = slider.value;
    
    // 设置亮度调整范围为整张图像
    [_brightnessFilter forceProcessingAtSize:_image.size];
    
    // 使用单个滤镜
    [_brightnessFilter useNextFrameForImageCapture];
    
    // 数据源头(静态图片)
    GPUImagePicture *stillImageSoucer = [[GPUImagePicture alloc] initWithImage:_image];
    
    //为图片添加一个滤镜
    [stillImageSoucer addTarget:_brightnessFilter];
    
    //处理图片
    [stillImageSoucer processImage];
    
    //处理完成,从FrameBuffer帧缓存区中获取图片
    UIImage *newImage = [_brightnessFilter imageFromCurrentFramebuffer];
    
    //更新图片
    _resultImageView.image = newImage;
}

@end
