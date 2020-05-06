//
//  YYFilterListView.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/6.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYFilterListView.h"
#import "BYMacro.h"

#define kContainerHeight    130.f

@interface YYFilterListView ()

/** 暗黑色的view */
@property (nonatomic, strong) UIView *darkView;

/** 容器 */
@property (nonatomic, strong) UIView *containerView;

/** 滤镜列表 */
@property (nonatomic, strong) UIView *filterListView;

/** 美颜的视图 */
@property (nonatomic, strong) UIView *beautyView;

/** 是否开启美颜的开关 */
@property (nonatomic, strong) UISwitch *beautySwitch;

@end

@implementation YYFilterListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 暗黑色背景
        _darkView = [[UIView alloc] init];
        [_darkView setAlpha:0];
        [_darkView setFrame:[UIScreen mainScreen].bounds];
        [_darkView setBackgroundColor:[UIColor cyanColor]];
        [self addSubview:_darkView];
          
        
        // 容器
        _containerView = [[UIView alloc] init];
        _containerView.frame = CGRectMake(0.f, kScreenHeight, kScreenWidth, kContainerHeight);
        _containerView.backgroundColor = [UIColor blackColor] ;
        [_darkView addSubview:_containerView];
        
        // 设置本身的大小为屏幕大小
        self.frame = [UIScreen mainScreen].bounds;
    }
    return self;
}

- (void)setupFilterList
{
    
}

- (void)setupBeautyView
{
    if (_beautyView == nil) {
        _beautyView = [[UIView alloc] initWithFrame:_containerView.bounds];
        _beautyView.backgroundColor = [UIColor lightTextColor];
        [_containerView addSubview:_beautyView];
    }
    
    if (_beautySwitch == nil) {
        
        BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:kBeautySwitchKey];
        CGRect frame = CGRectMake((kScreenWidth-40.f)*0.5, (kContainerHeight-40.f)*0.5, 40.f, 40.f);
        _beautySwitch = [[UISwitch alloc] initWithFrame:frame];
        _beautySwitch.on = isOn;
        [_beautySwitch addTarget:self action:@selector(beautySwitchAction:) forControlEvents:UIControlEventValueChanged];
        [_beautyView addSubview:_beautySwitch];
    }
    
    _beautyView.hidden = NO;
    _filterListView.hidden = YES;
}

#pragma mark - Action

- (void)beautySwitchAction:(UISwitch *)sender
{
    BOOL isOn = sender.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kBeautySwitchKey];
}

#pragma mark - Show & Dismiss

- (void)showWithType:(YYFilterListViewType)type
{
    [_darkView setAlpha:1.f];
    [_darkView setUserInteractionEnabled:YES];
    [_containerView setHidden:NO];
    if (type == YYFilterListViewTypeDefault) {
        [self setupFilterList];
    } else if (type == YYFilterListViewTypeBeauty) {
        [self setupBeautyView];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.25 animations:^{
        CGRect oldFrame = ws.containerView.frame;
        oldFrame.origin.y = kScreenHeight - kContainerHeight;
        ws.containerView.frame = oldFrame;
    }];
}

- (void)dismissWithCompletion:(YYFilterListViewCompletion)completion
{
    [_darkView setAlpha:0];
    [_darkView setUserInteractionEnabled:NO];
    [_containerView setHidden:YES];
    [self removeFromSuperview];
}

@end
