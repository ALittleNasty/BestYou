precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;
 
uniform float time;
 
const float duration = 0.7;
 
const float maxAlpha = 0.4;
 
const float maxScale = 1.8;

void main() {
     
    float process = mod(time, duration) / duration;
     
    float alpha = maxAlpha * (1.0 - process);
     
    float scale = 1.0 + (maxScale - 1.0) * process;
     
    float x = 0.5 + (v_textureCoordinate.x - 0.5) / scale;
    float y = 0.5 + (v_textureCoordinate.y - 0.5) / scale;
    vec2 changedCoord = vec2(x, y);
     
    vec4 changedColor = texture2D(inputTexture, changedCoord);
     
    vec4 originalColor = texture2D(inputTexture, v_textureCoordinate);
     
    gl_FragColor = originalColor * (1.0 - alpha) + changedColor * alpha; 
}
