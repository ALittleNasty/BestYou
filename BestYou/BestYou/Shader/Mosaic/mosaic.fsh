precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

const vec2 texSize = vec2(500.0, 500.0);
const vec2 mosaicSize = vec2(10.0, 10.0);

void main() {
    
    vec2 realPos = vec2(v_textureCoordinate.x * texSize.x, v_textureCoordinate.y * texSize.y);
    
    vec2 mosaicPos = vec2(floor(realPos.x/mosaicSize.x) * mosaicSize.x, floor(realPos.y/mosaicSize.y) * mosaicSize.y);
    
    vec2 mosaicTextureCoord = vec2(mosaicPos.x/texSize.x, mosaicPos.y/texSize.y);
    
    vec4 color = texture2D(inputTexture, mosaicTextureCoord);
    
    gl_FragColor = color;
}
