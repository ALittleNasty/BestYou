attribute vec4 position;
attribute vec2 textureCoordinate;
varying vec2 v_textureCoordinate;
 
uniform float time;

const float PI = 3.1415926;

const float duration = 0.6;
 
const float maxScale = 1.3;

void main() {
     
    float timeScope = mod(time, duration);
     
    float amplitude = 1.0 + abs(sin(time * (PI/duration))) * (maxScale - 1.0);
     
    vec4 pos = vec4(position.x * amplitude, position.y * amplitude, position.zw);
    
    gl_Position = pos;
    
    v_textureCoordinate = textureCoordinate;
}
