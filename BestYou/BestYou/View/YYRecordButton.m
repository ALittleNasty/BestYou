//
//  YYRecordButton.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/4.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYRecordButton.h"

@interface YYRecordButton ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation YYRecordButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubLayer];
    }
    return self;
}

- (void)setupSubLayer
{
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.layer.borderWidth = 3.f;
    self.layer.borderColor = [UIColor redColor].CGColor;
    
    _shapeLayer = [CAShapeLayer layer];
    CGRect frame = CGRectMake(10.f, 10.f, self.bounds.size.width - 20.f, self.bounds.size.height - 20.f);
    _shapeLayer.frame = frame;
    _shapeLayer.cornerRadius = (self.bounds.size.width - 20.f) / 2;
    _shapeLayer.backgroundColor = [UIColor redColor].CGColor;
    
    [self.layer addSublayer:_shapeLayer];
    
    
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (!selected) {
        CGRect frame = CGRectMake(10.f, 10.f, self.bounds.size.width - 20.f, self.bounds.size.height - 20.f);
        _shapeLayer.frame = frame;
        _shapeLayer.cornerRadius = (self.bounds.size.width - 20.f) / 2;
    } else {
        CGRect frame = CGRectMake(15.f, 15.f, self.bounds.size.width - 30.f, self.bounds.size.height - 30.f);
        _shapeLayer.frame = frame;
        _shapeLayer.cornerRadius = 5.f;
    }
}

@end
