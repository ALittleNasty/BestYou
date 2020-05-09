//
//  YYFilterListView.h
//  BestYou
//
//  Created by 胡阳 on 2020/5/6.
//  Copyright © 2020 胡阳. All rights reserved.

/**
 *  滤镜选择的弹框列表
 */
#import <UIKit/UIKit.h>

typedef void(^YYFilterChangeCallback)(NSString * _Nullable filterName);

typedef void(^YYBeautyChangeCallback)(BOOL enableBeauty);

NS_ASSUME_NONNULL_BEGIN

@interface YYFilterListView : UIView

/// 滤镜切换的回调
@property (nonatomic, copy) YYFilterChangeCallback filterChangeCallback;

/// 开启/关闭美颜的回调
@property (nonatomic, copy) YYBeautyChangeCallback beautyChangeCallback;


- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
