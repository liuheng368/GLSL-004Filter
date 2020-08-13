precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

const float mosaicSize = 0.03;

void main(void) {
    
    float TR = 0.866025;
    float TB = 1.5;
    
    int indexX = int(varyTexCoord.x / TB / mosaicSize);
    int indexY = int(varyTexCoord.y / TR / mosaicSize);
    vec2 v1, v2, result;
    
    if(indexX / 2 * 2 == indexX) {
        if(indexY / 2 * 2 == indexY) {
            v1 = vec2(float(indexX) * mosaicSize * TB, float(indexY) * mosaicSize * TR);
            v2 = vec2(float(indexX + 1) * mosaicSize * TB, float(indexY + 1) * mosaicSize * TR);
        }else{
            v1 = vec2(float(indexX) * mosaicSize * TB, float(indexY + 1) * mosaicSize * TR);
            v2 = vec2(float(indexX + 1) * mosaicSize * TB, float(indexY) * mosaicSize * TR);
        }
    }else{
        if(indexY / 2 * 2 == indexY) {
            v1 = vec2(float(indexX) * mosaicSize * TB, float(indexY + 1) * mosaicSize * TR);
            v2 = vec2(float(indexX + 1) * mosaicSize * TB, float(indexY) * mosaicSize * TR);
        }else{
            v1 = vec2(float(indexX) * mosaicSize * TB, float(indexY) * mosaicSize * TR);
            v2 = vec2(float(indexX + 1) * mosaicSize * TB, float(indexY + 1) * mosaicSize * TR);
        }
    }
    
    float s1 = sqrt(pow(varyTexCoord.x - v1.x, 2.0) + pow(varyTexCoord.y - v1.y, 2.0));
    float s2 = sqrt(pow(varyTexCoord.x - v2.x, 2.0) + pow(varyTexCoord.y - v2.y, 2.0));
    if(s1 < s2){
        result = v1;
    }else{
        result = v2;
    }
    
    gl_FragColor = texture2D(colorMap, result);
}
