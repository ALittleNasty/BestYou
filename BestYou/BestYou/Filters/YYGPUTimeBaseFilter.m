//
//  YYGPUTimeBaseFilter.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/9.
//  Copyright © 2020 胡阳. All rights reserved.


#import "YYGPUTimeBaseFilter.h"

@implementation YYGPUTimeBaseFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString
{
    self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString];
    if (self) {
        
        timeUniform = [filterProgram uniformIndex:@"time"];
        self.time = 0.f;
    }
    return self;
}

- (void)setTime:(float)time
{
    _time = time;
    
    [self setFloat:time forUniform:timeUniform program:filterProgram];
}

@end
