precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate;

void main() {
    vec4 orangeColor = vec4(1.0, 165.0/255.0, 0.0, 1.0);
    vec4 mask = texture2D(inputTexture, v_textureCoordinate);
    float ratio = 0.6;
    gl_FragColor = mask * (1.0 - ratio) + orangeColor * ratio;
}
