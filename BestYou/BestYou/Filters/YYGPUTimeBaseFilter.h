//
//  YYGPUTimeBaseFilter.h
//  BestYou
//
//  Created by 胡阳 on 2020/5/9.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYGPUTimeBaseFilter : GPUImageFilter
{
    GLuint timeUniform;
}

@property (nonatomic, assign) float time;

@end

NS_ASSUME_NONNULL_END
