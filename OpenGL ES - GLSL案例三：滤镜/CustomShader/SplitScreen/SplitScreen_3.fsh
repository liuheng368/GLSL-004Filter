precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

void main(void){
    vec2 temp = varyTexCoord;
    if(temp.x <= 1.0/3.0){
        temp.x = temp.x + 1.0 / 3.0;
    }else if(temp.x >= 2.0/3.0){
        temp.x = temp.x - 1.0 / 3.0;
    }
    gl_FragColor = texture2D(colorMap, temp);
}
