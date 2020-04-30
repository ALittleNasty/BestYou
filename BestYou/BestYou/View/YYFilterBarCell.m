//
//  YYFilterBarCell.m
//  SplitFilterDemo
//
//  Created by 胡阳 on 2020/4/21.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYFilterBarCell.h"

NSString *const kYYFilterBarCellID = @"kYYFilterBarCellID";


@interface YYFilterBarCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *selectedIV;

@end

@implementation YYFilterBarCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor colorWithRed:141.0/255.0 green:209.0/255.0 blue:247.0/255.0 alpha:1.0];
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    _nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_nameLabel];
    
    CGFloat equalWH = 20.f;
    _selectedIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select"]];
    _selectedIV.frame = CGRectMake(self.contentView.bounds.size.width - equalWH, 0.f, equalWH, equalWH);
    [self.contentView addSubview:_selectedIV];
    _selectedIV.hidden = YES;
}

- (void)setIsChoosen:(BOOL)isChoosen
{
    if (isChoosen == _isChoosen) { return; }
    
    _isChoosen = isChoosen;
    _selectedIV.hidden = !_isChoosen;
}

- (void)setName:(NSString *)name
{
    _nameLabel.text = name;
}

@end
