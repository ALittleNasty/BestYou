//
//  shake.h
//  SplitFilterDemo
//
//  Created by 胡阳 on 2020/4/24.
//  Copyright © 2020 胡阳. All rights reserved.

//抖动滤镜: 颜色偏移 + 微弱的放大效果
precision highp float;
// 纹理
uniform sampler2D inputTexture;
// 传递过来的 纹理坐标
varying vec2 v_textureCoordinate;

// 传递进来的时间
uniform float time;

// 一次特效的持续时间
const float duration = 0.7;

// 最大的放大比例
const float maxScale = 1.1;

// 偏移量
const float offset = 0.02;

void main() {
    
    // 获取进度[0,1]
    float process = mod(time, duration) / duration;
    
    // 颜色偏移值范围[0,0.02]
    vec2 offsetCoord = vec2(offset, offset) * process;
    
    // 缩放范围[1.0-1.1];
    float scale = 1.0 + (maxScale - 1.0) * process;
    
    // 放大纹理坐标.
    float x = 0.5 + (v_textureCoordinate.x - 0.5) / scale;
    float y = 0.5 + (v_textureCoordinate.y - 0.5) / scale;
    vec2 scaleTextureCoord = vec2(x, y);
    
    /**
     获取3组颜色rgb
     */
    // 原始颜色+offsetCoords
    vec4 colorR = texture2D(inputTexture, scaleTextureCoord + offsetCoord);
    // 原始颜色-offsetCoords
    vec4 colorB = texture2D(inputTexture, scaleTextureCoord - offsetCoord);
    // 原始颜色
    vec4 color = texture2D(inputTexture, scaleTextureCoord);
    
    /**
     从3组来获取颜色:
     colorR.r, color.g, colorB.b 注意这3种颜色取值可以打乱或者随意发挥.不一定写死.只是效果会有不一样.大家可以试试.
     color.a 获取原图的透明度
     */
    gl_FragColor = vec4(colorR.r, color.g, colorB.b, color.a);
}

