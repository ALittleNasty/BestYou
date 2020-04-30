//
//  shineWhite.h
//  SplitFilterDemo
//
//  Created by 胡阳 on 2020/4/24.
//  Copyright © 2020 胡阳. All rights reserved.

https://www.jianshu.com/p/b54a48ffb62e
/*
 mod 函数: 传入 x 和 y,得到 x - y * floor(x/y), 简单的可以理解为求模运算(%)
 */
 
// 统一设置 float 高精度
precision highp float;
// 纹理
uniform sampler2D inputTexture;
// 纹理坐标
varying vec2 v_textureCoordinate;

// 传递进来的时间
uniform float time;

// 常量 PI
const float PI = 3.1415926;

// 常量 一次闪白滤镜的时间
const float duration = 0.6;

void main() {
    
    // 时间范围
    float timeScope = mod(time, duration);
    
    // 白色色值
    vec4 whiteColor = vec4(1.0, 1.0, 1.0, 1.0);
    
    // 白色所占的比例
    float ratio = abs(sin(time * (PI / duration)));
    
    // 原始颜色值
    vec4 color = texture2D(inputTexture, v_textureCoordinate);
    
    // 原始颜色值 * (1.0 - 比例) + 白色色值 * 比例
    gl_FragColor = color * (1.0 - ratio) + whiteColor * ratio;
}
