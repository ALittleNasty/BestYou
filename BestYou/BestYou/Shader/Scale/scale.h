//
//  scale.h
//  SplitFilterDemo
//
//  Created by 胡阳 on 2020/4/24.
//  Copyright © 2020 胡阳. All rights reserved.

// 顶点坐标
attribute vec4 position;
// 纹理坐标
attribute vec2 textureCoordinate;
// 传递出去的纹理坐标
varying vec2 v_textureCoordinate;

//时间撮(及时更新)
uniform float time;

// 定义常量 PI
const float PI = 3.1415926;

//一次缩放效果时长 0.6
float duration = 0.6;

//最大缩放幅度
float maxScale = 1.2;

void main() {
    
    
    //表示时间周期.范围[0.0~0.6];
    float timeScope = mod(time, duration);
    
    //amplitude [1.0,1.3]
    float amplitude = 1.0 + abs(sin(time * (PI/duration))) * (maxScale - 1.0);
    
    // 顶点坐标x/y 分别乘以放大系数[1.0,1.3]
    vec4 pos = vec4(position.x * amplitude, position.y * amplitude, position.zw);
    
    // 给内建变量 gl_Position 赋值
    gl_Position = pos;
    
    // 传递纹理坐标
    v_textureCoordinate = textureCoordinate;
}
