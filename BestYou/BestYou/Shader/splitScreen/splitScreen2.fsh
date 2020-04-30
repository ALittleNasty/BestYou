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
    
    vec4 mask = texture2D(inputTexture, uv);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
