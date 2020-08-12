precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

void main(void){
    vec2 temp = varyTexCoord;
    if (temp.x <= 0.5) {
        temp.x = temp.x + 0.25;
    }else{
        temp.x = temp.x - 0.25;
    }
    gl_FragColor = texture2D(colorMap, temp);
}
