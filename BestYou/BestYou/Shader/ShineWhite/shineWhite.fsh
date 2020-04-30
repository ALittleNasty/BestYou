precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

uniform float time;

const float PI = 3.1415926;

const float duration = 0.6;

void main() {
    
    float timeScope = mod(time, duration);
    
    vec4 whiteColor = vec4(1.0, 182.0/255.0, 113.0/255.0, 1.0);
    
    float ratio = abs(sin(time * (PI / duration)));
    
    vec4 color = texture2D(inputTexture, v_textureCoordinate);
    
    gl_FragColor = color * (1.0 - ratio) + whiteColor * ratio;
}
