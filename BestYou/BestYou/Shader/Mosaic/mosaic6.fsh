precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

const float mosaicSize = 0.02;

void main() {
    
    float len = mosaicSize;
    float TR = 0.866025;
    
    float x = v_textureCoordinate.x;
    float y = v_textureCoordinate.y;
    
    int ix = int(x/1.5/len);
    int iy = int(y/TR/len);
    vec2 v1, v2, vn;
    
    if (ix/2 * 2 == ix) {
        if (iy / 2 * 2 == iy) {
            v1 = vec2(len * 1.5 * float(ix), len * TR * float(iy));
            v2 = vec2(len * 1.5 * float(ix + 1), len * TR * float(iy + 1));
        } else {
            v1 = vec2(len * 1.5 * float(ix), len * TR * float(iy + 1));
            v2 = vec2(len * 1.5 * float(ix + 1), len * TR * float(iy));
        }
    } else {
        if (iy / 2 * 2 == iy) {
            v1 = vec2(len * 1.5 * float(ix), len * TR * float(iy + 1));
            v2 = vec2(len * 1.5 * float(ix + 1), len * TR * float(iy));
        } else {
            v1 = vec2(len * 1.5 * float(ix), len * TR * float(iy));
            v2 = vec2(len * 1.5 * float(ix + 1), len * TR * float(iy + 1));
        }
    }
    
    float d1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
    float d2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));
    
    if (d1 < d2) {
        vn = v1;
    } else {
        vn = v2;
    } 
    
    gl_FragColor = texture2D(inputTexture, vn);
}
