//
//  soulOut.h
//  SplitFilterDemo
//
//  Created by 胡阳 on 2020/4/24.
//  Copyright © 2020 胡阳. All rights reserved.

/*
 灵魂出窍滤镜: 是两个层的叠加，并且上面的那层随着时间的推移，会逐渐放大且不透明度逐渐降低。这里也用到了放大的效果，我们这次用片段着色器来实现
 */
precision highp float;

// 纹理
uniform sampler2D inputTexture;
// 纹理坐标
varying vec2 v_textureCoordinate;

// 传递进来的时间戳
uniform float time;

//一次灵魂出窍效果的时长 0.7
const float duration = 0.7;

//透明度上限
const float maxAlpha = 0.4;

//放大图片上限
const float maxScale = 1.8;

void main() {
    
    //进度值[0,1]
    float process = mod(time, duration) / duration;
    
    //透明度[0.4, 0]
    float alpha = maxAlpha * (1 - process);
    
    //缩放比例[1.0,1.8]
    float scale = 1.0 + (maxScale - 1.0) * process;
    
    //放大纹理坐标
    float x = 0.5 + (v_textureCoordinate.x - 0.5) * scale;
    float y = 0.5 + (v_textureCoordinate.y - 0.5) * scale;
    vec2 changedCoord = vec2(x, y);
    
    //获取对应放大纹理坐标下的纹素(颜色值rgba)
    vec4 changedColor = texture2D(inputTexture, changedCoord);
    
    //原始的纹理坐标下的纹素(颜色值rgba)
    vec4 originalColor = texture2D(inputTexture, v_textureCoordinate);
    
    //颜色混合 默认颜色混合方程式 = originalColor * (1.0-alpha) + changedColor * alpha;
    gl_FragColor = originalColor * (1.0 - alpha) + changedColor * aplha;
}

