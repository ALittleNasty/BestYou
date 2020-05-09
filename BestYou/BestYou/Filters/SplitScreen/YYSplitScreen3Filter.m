//
//  YYSplitScreen3Filter.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/9.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYSplitScreen3Filter.h"

// glsl 3 分屏代码
NSString *const kGPUImageSplitScreen3FragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 
 void main()
 {
     lowp vec2 uv = textureCoordinate;
     if (uv.y <= 1.0/3.0) {
         uv.y = uv.y + 1.0/3.0;
     } else if (uv.y > 2.0/3.0) {
         uv.y = uv.y - 1.0/3.0;
     }
     
     lowp vec4 mask = texture2D(inputImageTexture, uv);
     gl_FragColor = vec4(mask.rgb, 1.0);
 }
);

@implementation YYSplitScreen3Filter
- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGPUImageSplitScreen3FragmentShaderString];
    if (self) {
        
    }
    return self;
}
@end
