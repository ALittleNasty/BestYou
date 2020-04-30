precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

void main() {
    vec4 mask = texture2D(inputTexture, v_textureCoordinate);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
