precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

uniform float time;

const float duration = 0.7;

const float maxScale = 1.1;

const float offset = 0.02;

void main() {
    
    float process = mod(time, duration) / duration;
    
    vec2 offsetCoord = vec2(offset, offset) * process;
    
    float scale = 1.0 + (maxScale - 1.0) * process;
    
    float x = 0.5 + (v_textureCoordinate.x - 0.5) / scale;
    float y = 0.5 + (v_textureCoordinate.y - 0.5) / scale;
    vec2 scaleTextureCoord = vec2(x, y);
    
    vec4 colorR = texture2D(inputTexture, scaleTextureCoord + offsetCoord);
    vec4 colorB = texture2D(inputTexture, scaleTextureCoord - offsetCoord);
    vec4 color = texture2D(inputTexture, scaleTextureCoord);
    
    gl_FragColor = vec4(colorR.r, color.g, colorB.b, color.a);
}
