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

typedef void(^YYFilterListViewCompletion)(NSUInteger type, NSString *filterName, BOOL enableBeauty);

typedef NS_ENUM(NSUInteger, YYFilterListViewType) {
    
    YYFilterListViewTypeDefault = 0, // 默认的滤镜列表
    YYFilterListViewTypeBeauty = 1   // 是否开启美颜的开关
};

NS_ASSUME_NONNULL_BEGIN

@interface YYFilterListView : UIView


- (void)showWithType:(YYFilterListViewType)type;

- (void)dismissWithCompletion:(YYFilterListViewCompletion)completion;

@end

NS_ASSUME_NONNULL_END
