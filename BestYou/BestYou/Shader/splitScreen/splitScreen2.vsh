attribute vec4 position;
attribute vec2 textureCoordinate;
varying vec2 v_textureCoordinate;

void main() {
    v_textureCoordinate = textureCoordinate;
    gl_Position = position;
}
