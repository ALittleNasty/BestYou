//
//  mosaic6.h 片元着色器的代码注释
//
//  Created by 胡阳 on 2020/4/23.
//  Copyright © 2020 胡阳. All rights reserved.

precision highp float; // 统一设置 float 类型为高精度
uniform sampler2D inputTexture; // 输入的纹理
varying vec2 v_textureCoordinate; // 传递过来的纹理坐标

const float mosaicSize = 0.02; // 定义马赛克的大小

void main() {
    
    float len = mosaicSize;
    float TR = 0.866025;
    
    // 记录纹理坐标的x,y
    float x = v_textureCoordinate.x;
    float y = v_textureCoordinate.y;
    
    // ix, iy 表示纹理坐标在所对应的的矩阵坐标的值
    int ix = int(x/1.5/len);
    int iy = int(y/TR/len);
    
    // 声明 3 个二维向量用来记录中心点坐标
    vec2 v1, v2, vn;
    
    
    /*
     ix/2 * 2 == ix 这是一个判断奇偶的算法, 在 gl 里面 int 不支持模运算
     
     3/2 * 2 的结果是 2 不等于 3 本身,这是奇数
     4/2 * 2 的结果是 4 是等于 4 本身,这是偶数
     */
    if (ix/2 * 2 == ix) {
        if (iy / 2 * 2 == iy) {
            // 偶数行偶数列 (0, 0) (1, 1) 两个中心点
            v1 = vec2(len * 1.5 * float(ix), len * TR * float(iy));
            v2 = vec2(len * 1.5 * float(ix + 1), len * TR * float(iy + 1));
        } else {
            // 偶数行奇数列 (0,  1) (1, 0) 两个中心点
            v1 = vec2(len * 1.5 * float(ix), len * TR * float(iy + 1));
            v2 = vec2(len * 1.5 * float(ix + 1), len * TR * float(iy));
        }
    } else {
        if (iy / 2 * 2 == iy) {
            // 奇数行偶数列 (0, 0) (1, 1) 两个中心点
            v1 = vec2(len * 1.5 * float(ix), len * TR * float(iy + 1));
            v2 = vec2(len * 1.5 * float(ix + 1), len * TR * float(iy));
        } else {
            // 奇数行奇数列 (0,  1) (1, 0) 两个中心点
            v1 = vec2(len * 1.5 * float(ix), len * TR * float(iy));
            v2 = vec2(len * 1.5 * float(ix + 1), len * TR * float(iy + 1));
        }
    }
    
    // 计算当前纹理坐标(x,y) 与 中心点 v1 的距离
    float d1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
    // 计算当前纹理坐标(x,y) 与 中心点 v2 的距离
    float d2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));
    
    // 如果距离 v1 的距离短那么就取 v1 中心点的颜色值, 否则取 v2 中心点的颜色值
    // 通过比较得到最终的中心点 vn
    if (d1 < d2) {
        vn = v1;
    } else {
        vn = v2;
    }
    
    // 获取纹素
    gl_FragColor = texture2D(inputTexture, vn);
}

