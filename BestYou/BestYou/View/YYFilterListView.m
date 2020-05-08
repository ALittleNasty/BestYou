//
//  YYFilterListView.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/6.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYFilterListView.h"
#import "BYMacro.h"
#import "YYFilterBarCell.h"

#define kCellSize 60.f

#define kContainerHeight    200.f

@interface YYFilterListView ()<UICollectionViewDelegate, UICollectionViewDataSource>

/** 暗黑色的view */
@property (nonatomic, strong) UIView *darkView;

/** 容器 */
@property (nonatomic, strong) UIView *containerView;

/** 滤镜列表 */
@property (nonatomic, strong) UIView *filterListView;

/** 是否开启美颜的开关 */
@property (nonatomic, strong) UISwitch *beautySwitch;

/** 滤镜列表 */
@property (nonatomic, strong) UICollectionView *collectionView;

/** 滤镜列表数据 */
@property (nonatomic, copy) NSArray *items;

@end

@implementation YYFilterListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSDictionary *normal = @{@"name": @"正常", @"shaderName": @"normal"};
        NSDictionary *split2 = @{@"name": @"2分屏", @"shaderName": @"splitScreen2"};
        NSDictionary *split3 = @{@"name": @"3分屏", @"shaderName": @"splitScreen3"};
        NSDictionary *split4 = @{@"name": @"4分屏", @"shaderName": @"splitScreen4"};
        NSDictionary *split6 = @{@"name": @"6分屏", @"shaderName": @"splitScreen6"};
        NSDictionary *split9 = @{@"name":@"9分屏", @"shaderName": @"splitScreen9"};
        NSDictionary *gray = @{@"name":@"灰度", @"shaderName": @"gray"};
        NSDictionary *reversed = @{@"name":@"翻转", @"shaderName": @"reversed"};
        NSDictionary *vortex = @{@"name":@"旋涡", @"shaderName": @"vortex"};
        NSDictionary *mosaic = @{@"name":@"矩形", @"shaderName": @"mosaic"};
        NSDictionary *mosaic3 = @{@"name":@"三角形", @"shaderName": @"mosaic3"};
        NSDictionary *mosaic6 = @{@"name":@"六边形", @"shaderName": @"mosaic6"};
        NSDictionary *scale = @{@"name":@"缩放", @"shaderName": @"scale"};
        NSDictionary *soulOut = @{@"name":@"灵魂出窍", @"shaderName": @"soulOut"};
        NSDictionary *shake = @{@"name":@"晃动", @"shaderName": @"shake"};
        NSDictionary *glitch = @{@"name":@"毛刺", @"shaderName": @"glitch"};
        NSDictionary *shineWhite = @{@"name":@"闪白", @"shaderName": @"shineWhite"};
        _items = @[normal, glitch, shineWhite, shake, soulOut, scale,
                   mosaic, mosaic3, mosaic6,
                   split2, split3, split4, split6, split9,
                   gray, reversed, vortex];
        
        [self setupWrapper];
        
        [self setupBeautyView];
        
        [self setupFilterList];
        
        // 设置本身的大小为屏幕大小
        self.frame = [UIScreen mainScreen].bounds;
    }
    return self;
}

- (void)setupWrapper
{
    // 暗黑色背景
    _darkView = [[UIView alloc] init];
    [_darkView setAlpha:0];
    [_darkView setFrame:[UIScreen mainScreen].bounds];
    [_darkView setBackgroundColor:[UIColor cyanColor]];
    _darkView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [_darkView addGestureRecognizer:tap];
    [self addSubview:_darkView];
    
    // 容器
    _containerView = [[UIView alloc] init];
    _containerView.frame = CGRectMake(0.f, kScreenHeight, kScreenWidth, kContainerHeight);
    _containerView.backgroundColor = [UIColor blackColor] ;
    [_darkView addSubview:_containerView];
}

- (void)setupFilterList
{
    NSArray *titles = @[@"分屏", @"自定义", @"GPUImage"];
    CGFloat btnLeftPadding = 15.f;
    CGFloat btnY = 50.f;
    CGFloat btnWidth = 100.f;
    CGFloat btnHeight = 40.f;
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor cyanColor]];
        btn.layer.cornerRadius = 5.f;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = 100 + i;
        btn.frame = CGRectMake((btnLeftPadding + btnWidth) * i, btnY, btnWidth, btnHeight);
        [btn addTarget:self action:@selector(filterTypeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_containerView addSubview:btn];
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(kCellSize, kCellSize);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.frame = CGRectMake(0.0, 100.0, kScreenWidth, 80.f);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_containerView addSubview:_collectionView];
    [_collectionView registerClass:[YYFilterBarCell class] forCellWithReuseIdentifier:kYYFilterBarCellID];
}

- (void)setupBeautyView
{
    CGFloat beautyLabelWidth = 80.f;
    UILabel *beautyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, beautyLabelWidth, 40.f)];
    beautyLabel.textColor = [UIColor whiteColor];
    beautyLabel.text = @"美颜开关:";
    beautyLabel.font = [UIFont boldSystemFontOfSize:17];
    [_containerView addSubview:beautyLabel];
    
    BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:kBeautySwitchKey];
    CGRect frame = CGRectMake(100.f, 5.0, 50.f, 30.f);
    _beautySwitch = [[UISwitch alloc] initWithFrame:frame];
    _beautySwitch.backgroundColor = [UIColor clearColor];
    _beautySwitch.on = isOn;
    [_beautySwitch addTarget:self action:@selector(beautySwitchAction:) forControlEvents:UIControlEventValueChanged];
    [_containerView addSubview:_beautySwitch];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YYFilterBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYYFilterBarCellID forIndexPath:indexPath];
    NSDictionary *info = _items[indexPath.item];
    cell.name = info[@"name"];
    cell.isChoosen = (0 == indexPath.item);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if (_selection && (_currentIndex != indexPath.row)) {
//
//        _currentIndex = indexPath.item;
//        [_collectionView reloadData];
//
//        NSDictionary *info = _items[indexPath.item];
//        _selection(info[@"shaderName"]);
//    }
}


#pragma mark - Action

- (void)beautySwitchAction:(UISwitch *)sender
{
    BOOL isOn = sender.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kBeautySwitchKey];
}

- (void)filterTypeBtnAction:(UIButton *)btn
{
    NSLog(@"%zd", btn.tag-100);
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

- (void)dismiss
{
    [_darkView setAlpha:0];
    [_darkView setUserInteractionEnabled:NO];
    [_containerView setHidden:YES];
    [self removeFromSuperview];
}

@end
