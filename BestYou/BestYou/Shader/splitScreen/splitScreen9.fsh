precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

void main() {
    
    vec2 uv = v_textureCoordinate;
    
    if (uv.y <= 1.0/3.0) {
        uv.y = uv.y * 3.0;
    } else if (uv.y <= 2.0/3.0) {
        uv.y = (uv.y - 1.0/3.0) * 3.0;
    } else {
        uv.y = (uv.y - 2.0/3.0) * 3.0;
    }
    
    if (uv.x <= 1.0/3.0) {
        uv.x = uv.x * 3.0;
    } else if (uv.x <= 2.0/3.0) {
        uv.x = (uv.x - 1.0/3.0) * 3.0;
    } else {
        uv.x = (uv.x - 2.0/3.0) * 3.0;
    }
    
    vec4 mask = texture2D(inputTexture, uv);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
