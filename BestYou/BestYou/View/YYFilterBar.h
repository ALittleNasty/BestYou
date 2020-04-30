//
//  YYFilterBar.h
//  SplitFilterDemo
//
//  Created by 胡阳 on 2020/4/21.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYFilterBar : UIView

/// 点击的回调
@property (nonatomic, copy) void (^selection) (NSString *shaderName);

@end

NS_ASSUME_NONNULL_END

/*
 1. 遗留 bug 修复
 2. 修改 文件导入的左侧树形组件, 及整个页面样式
 3. 封装历史作业和表文件迁移左侧树形控件
 
 继续 UI 整改工作,并完成相关新增需求
 */
