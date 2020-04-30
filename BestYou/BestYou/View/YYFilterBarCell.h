//
//  YYFilterBarCell.h
//  SplitFilterDemo
//
//  Created by 胡阳 on 2020/4/21.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * _Nonnull const kYYFilterBarCellID;

NS_ASSUME_NONNULL_BEGIN

@interface YYFilterBarCell : UICollectionViewCell

@property (nonatomic, copy) NSString *name;

/// 是否选中
@property (nonatomic, assign) BOOL isChoosen;

@end

NS_ASSUME_NONNULL_END
