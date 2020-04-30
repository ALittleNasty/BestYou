precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

void main() {
    
    vec2 uv = v_textureCoordinate;
    if (uv.y <= 0.5) {
        uv.y = uv.y + 0.25;
    } else {
        uv.y = uv.y - 0.25;
    }
    
    
    if (uv.x <= 1.0/3.0) {
        uv.x = uv.x + 1.0/3.0;
    } else if (uv.x > 2.0/3.0) {
        uv.x = uv.x - 1.0/3.0;
    }
    
    vec4 mask = texture2D(inputTexture, uv);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
