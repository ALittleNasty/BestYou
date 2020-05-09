//
//  YYSplitScreen6Filter.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/9.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYSplitScreen6Filter.h"
// glsl 6 分屏代码
NSString *const kGPUImageSplitScreen6FragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 
 void main()
 {
     lowp vec2 uv = textureCoordinate;
     if (uv.x <= 0.5) {
         uv.x = uv.x + 0.25;
     } else {
         uv.x = uv.x - 0.25;
     }
     
     
     if (uv.y <= 1.0/3.0) {
         uv.y = uv.y + 1.0/3.0;
     } else if (uv.y > 2.0/3.0) {
         uv.y = uv.y - 1.0/3.0;
     }
     
     lowp vec4 mask = texture2D(inputImageTexture, uv);
     gl_FragColor = vec4(mask.rgb, 1.0);
 }
);
@implementation YYSplitScreen6Filter
- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGPUImageSplitScreen6FragmentShaderString];
    if (self) {
        
    }
    return self;
}
@end
