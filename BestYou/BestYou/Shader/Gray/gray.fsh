precision highp float;
uniform sampler2D inputTexture;
varying vec2 v_textureCoordinate; 
const highp vec3 ratio = vec3(0.2125, 0.7154, 0.0721);

void main() {
    vec4 mask = texture2D(inputTexture, v_textureCoordinate);
    float grayValue = dot(mask.rgb, ratio);
    gl_FragColor = vec4(vec3(grayValue), 1.0);
}
