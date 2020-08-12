attribute vec4 position;
attribute vec2 texCoord;
varying lowp vec2 varyTexCoord;

void main(void){
    gl_Position = position;
    varyTexCoord = texCoord;
}
