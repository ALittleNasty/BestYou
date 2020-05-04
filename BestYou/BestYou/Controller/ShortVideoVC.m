//
//  ShortVideoVC.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/4.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "ShortVideoVC.h"
#import "YYRecordButton.h"

#import <AVKit/AVKit.h>
#import <Masonry/Masonry.h>
#import <GPUImage.h>

static CGFloat const kButtonWH = 60.f;

@interface ShortVideoVC ()

@property (nonatomic, strong) YYRecordButton *recordBtn;


@end

@implementation ShortVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    _recordBtn = [[YYRecordButton alloc] initWithFrame:CGRectMake((screenWidth - kButtonWH) * 0.5, screenHeight - kButtonWH * 2, kButtonWH, kButtonWH)];
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
    
    UIButton *beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [beautyBtn setImage:[UIImage imageNamed:@"image_beauty"] forState:UIControlStateNormal];
    [beautyBtn addTarget:self action:@selector(beautyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beautyBtn];
    [beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(110);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
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
    
}

- (void)filterButtonAction
{
    
}

- (void)beautyButtonAction
{
    
}

#pragma mark - Hide Status Bar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
