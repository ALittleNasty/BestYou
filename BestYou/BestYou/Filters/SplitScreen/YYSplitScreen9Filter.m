//
//  YYSplitScreen9Filter.m
//  BestYou
//
//  Created by 胡阳 on 2020/5/9.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "YYSplitScreen9Filter.h"
// glsl 9 分屏代码
NSString *const kGPUImageSplitScreen9FragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 
 void main()
 {
     lowp vec2 uv = textureCoordinate;
     if (uv.y <= 1.0/3.0) {
         uv.y = uv.y * 3.0;
     } else if (uv.y <= 2.0/3.0) {
         uv.y = (uv.y - 1.0/3.0) * 3.0;
     } else {
         uv.y = (uv.y - 2.0/3.0) * 3.0;
     }
     
     if (uv.x <= 1.0/3.0) {
         uv.x = uv.x * 3.0;
     } else if (uv.x <= 2.0/3.0) {
         uv.x = (uv.x - 1.0/3.0) * 3.0;
     } else {
         uv.x = (uv.x - 2.0/3.0) * 3.0;
     }
     
     lowp vec4 mask = texture2D(inputImageTexture, uv);
     gl_FragColor = vec4(mask.rgb, 1.0);
 }
);
@implementation YYSplitScreen9Filter
- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kGPUImageSplitScreen9FragmentShaderString];
    if (self) {
        
    }
    return self;
}
@end
