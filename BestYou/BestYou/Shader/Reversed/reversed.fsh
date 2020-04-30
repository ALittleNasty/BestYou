precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

void main() {
    vec2 reversedCoord = vec2(v_textureCoordinate.x, 1.0 - v_textureCoordinate.y);
    vec4 mask = texture2D(inputTexture, reversedCoord);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
