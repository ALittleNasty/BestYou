//
//  YYSplitScreen2Filter.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/9.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYSplitScreen2Filter.h"

// glsl 2 分屏代码
NSString *const kGPUImageSplitScreen2FragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 
 void main()
 {
     lowp vec2 uv = textureCoordinate;
     if (uv.y <= 0.5) {
         uv.y = uv.y + 0.25;
     } else {
         uv.y = uv.y - 0.25;
     }
     
     lowp vec4 mask = texture2D(inputImageTexture, uv);
     gl_FragColor = vec4(mask.rgb, 1.0);
 }
);

@implementation YYSplitScreen2Filter

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGPUImageSplitScreen2FragmentShaderString];
    if (self) {
        
    }
    return self;
}

@end
