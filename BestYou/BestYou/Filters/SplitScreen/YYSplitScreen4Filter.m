//
//  YYSplitScreen4Filter.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/9.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYSplitScreen4Filter.h"
// glsl 4 分屏代码
NSString *const kGPUImageSplitScreen4FragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 
 void main()
 {
     lowp vec2 uv = textureCoordinate;
     if (uv.y <= 0.5) {
         uv.y = uv.y * 2.0;
     } else {
         uv.y = (uv.y - 0.5) * 2.0;
     }
     
     if (uv.x <= 0.5) {
         uv.x = uv.x * 2.0;
     } else {
         uv.x = (uv.x - 0.5) * 2.0;
     }
     
     lowp vec4 mask = texture2D(inputImageTexture, uv);
     gl_FragColor = vec4(mask.rgb, 1.0);
 }
);
@implementation YYSplitScreen4Filter
- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGPUImageSplitScreen4FragmentShaderString];
    if (self) {
        
    }
    return self;
}
@end
