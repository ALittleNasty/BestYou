//
//  glitch.h
//  SplitFilterDemo
//
//  Created by 胡阳 on 2020/4/24.
//  Copyright © 2020 胡阳. All rights reserved.

// 统一设置 float 类型为高精度
precision highp float;
// 输入的纹理
uniform sampler2D inputTexture;
// 传递过来的纹理坐标
varying vec2 v_textureCoordinate;

// 传递进来的时间
uniform float time;

// 定义一个常量 PI
const float PI = 3.14159265;

// 定义一个求随机数的函数
float random(float num) {
    // fract(n) 函数会返回一个浮点数的小数点后面的部分, 舍弃掉整数部分
    return fract(sin(num) * 43758.5453123);
}

void main() {
    // 一次毛刺滤镜的时间
    float duration = 0.3;
    // 最大抖动的幅度
    float maxJitter = 0.06;
    // 红色偏移量
    float colorRedOffset = 0.01;
    // 蓝色偏移量
    float colorBlueOffset = -0.025;
    // 时间范围 [0.0, 0.6]
    float timeScope = mod(time, duration * 2.0);
    // 振幅 [0.0, 1.0]
    float amplitude = max(sin(time * (PI/duration)), 0.0);
    // 像素随机偏移
    float randomJitter = random(v_textureCoordinate.y) * 2.0 - 1.0;
    // 是否需要偏移
    bool needOffset = abs(randomJitter) < maxJitter * amplitude;
    
    // 获取纹理X值.根据needOffset,来计算它X撕裂.
    // needOffset = YES ,撕裂较大;
    // needOffset = NO,撕裂较小.
    float x = v_textureCoordinate.x + (needOffset ? randomJitter : (randomJitter * amplitude * 0.006));
    
    // 撕裂后的纹理坐标x,y
    vec2 texCoordAfterOffset = vec2(x, v_textureCoordinate.y);
    
    //根据撕裂后获取的纹理颜色值
    vec4 color = texture2D(inputTexture, texCoordAfterOffset);
    //撕裂后的纹理颜色红色偏移
    vec4 colorRed = texture2D(inputTexture, vec2(texCoordAfterOffset.x + colorRedOffset * amplitude, texCoordAfterOffset.y));
    //撕裂后的纹理颜色蓝色偏移
    vec4 colorBlue = texture2D(inputTexture, vec2(texCoordAfterOffset.x + colorBlueOffset * amplitude, texCoordAfterOffset.y));
    
    // 红色/蓝色部分发生撕裂.
    gl_FragColor = vec4(colorRed.r, color.g, colorBlue.b, color.a);
}

 
