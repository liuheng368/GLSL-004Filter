precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

void main(void){
    vec2 temp = varyTexCoord;
    if(temp.x <= 0.5){
        temp.x = temp.x * 2.0;
    }else{
        temp.x = (temp.x - 0.5) * 2.0;
    }
    if(temp.y <= 0.5){
        temp.y = temp.y * 2.0;
    }else{
        temp.y = (temp.y - 0.5) * 2.0;
    }
    gl_FragColor = texture2D(colorMap, temp);
}
