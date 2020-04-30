precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

uniform float time;

const float PI = 3.14159265;

float random(float num) {
    return fract(sin(num) * 43758.5453123);
}

void main() {
    
    float duration = 0.3;
    
    float maxJitter = 0.06;
    
    float colorRedOffset = 0.01;
    
    float colorBlueOffset = -0.025;
    
    float timeScope = mod(time, duration * 2.0);
    
    float amplitude = max(sin(time * (PI/duration)), 0.0);
    
    float randomJitter = random(v_textureCoordinate.y) * 2.0 - 1.0;
    
    bool needOffset = abs(randomJitter) < maxJitter * amplitude;
    
    float x = v_textureCoordinate.x + (needOffset ? randomJitter : (randomJitter * amplitude * 0.006));
//    float y = v_textureCoordinate.y + (needOffset ? randomJitter : (randomJitter * amplitude * 0.006));
    
    vec2 texCoordAfterOffset = vec2(x, v_textureCoordinate.y);
//    vec2 texCoordAfterOffset = vec2(x, y);
    
    vec4 color = texture2D(inputTexture, texCoordAfterOffset);
    
    vec4 colorRed = texture2D(inputTexture, vec2(texCoordAfterOffset.x + colorRedOffset * amplitude, texCoordAfterOffset.y));
    
    vec4 colorBlue = texture2D(inputTexture, vec2(texCoordAfterOffset.x + colorBlueOffset * amplitude, texCoordAfterOffset.y)); 
    
    gl_FragColor = vec4(colorRed.r, color.g, colorBlue.b, color.a);
}
