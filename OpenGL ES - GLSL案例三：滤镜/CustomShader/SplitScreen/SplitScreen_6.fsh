precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

void main(void){
    vec2 temp = varyTexCoord;
    
    if(temp.x <= 1.0 / 3.0){
        temp.x = temp.x + 1.0 / 3.0;
    }else if(temp.x >= 2.0 / 3.0){
        temp.x = temp.x - 1.0 / 3.0;
    }
    if(temp.y <= 0.5){
        temp.y = temp.y + 0.5;
    }
    
    gl_FragColor = texture2D(colorMap, temp);
}
//顶点坐标从左下角开始
//纹理坐标从左上角开始，但是因为纹理经过了翻转，坐标系原点也跟着旋转，所以纹理坐标从左下角开始
