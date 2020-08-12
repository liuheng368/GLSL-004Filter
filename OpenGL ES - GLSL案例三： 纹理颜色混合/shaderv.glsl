attribute vec4 position;
attribute vec4 positionColor;
attribute vec2 textureCoord;

uniform mat4 projectionMatrix;
uniform mat4 viewModelMatrix;

varying lowp vec2 varyingTexCoord;
varying vec4 varyingColor;

void main() {
    varyingColor = positionColor;
    varyingTexCoord = textureCoord;
    
    gl_Position = projectionMatrix * viewModelMatrix * position;
}
