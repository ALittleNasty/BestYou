//
//  YYFilterBar.m
//  SplitFilterDemo
//
//  Created by 胡阳 on 2020/4/21.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYFilterBar.h"
#import "YYFilterBarCell.h"

#define kCellSize 60.f

@interface YYFilterBar ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *items;

/// 选中的索引(默认为 0)
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation YYFilterBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self basicSetup];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.itemSize = CGSizeMake(kCellSize, kCellSize);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_collectionView];
        [_collectionView registerClass:[YYFilterBarCell class] forCellWithReuseIdentifier:kYYFilterBarCellID];
    }
    return self;
}

- (void)basicSetup
{
    _currentIndex = 0;
    
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
    
    self.backgroundColor = [UIColor whiteColor];
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
    cell.isChoosen = (_currentIndex == indexPath.item);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selection && (_currentIndex != indexPath.row)) {
        
        _currentIndex = indexPath.item;
        [_collectionView reloadData];
        
        NSDictionary *info = _items[indexPath.item];
        _selection(info[@"shaderName"]);
    }
} 

@end
