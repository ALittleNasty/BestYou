precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

const float rotateAngle = 80.0;
const float radius = 0.5;

void main() {
    
    ivec2 ires = ivec2(512, 512);
    float res = float(ires.y);
    
    vec2 st = v_textureCoordinate;
    
    float defaultRadius = res * radius;
    
    vec2 currentTexPos = res * st;
    
    vec2 distanceCurTexPos = currentTexPos - vec2(res/2.0, res/2.0);
    
    float r = length(distanceCurTexPos);
    
    float angle = atan(distanceCurTexPos.y, distanceCurTexPos.x);
    
    float decayFactor = (1.0 - (r/defaultRadius) * (r/defaultRadius));
    
    float beta = angle + radians(rotateAngle) * 2.0 * decayFactor;
    
    if (r <= defaultRadius) {
        currentTexPos = res/2.0 + r * vec2(cos(beta), sin(beta));
    }
    
    st = currentTexPos / res;
    
    vec4 mask = texture2D(inputTexture, st);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
