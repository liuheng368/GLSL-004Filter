precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

const float mosaicSize = 0.03;

void main(void) {
    if(varyTexCoord.x >= 0.25 && varyTexCoord.x <= 0.75 && varyTexCoord.y >= 0.25 && varyTexCoord.y <= 0.75){
        float TR = 0.866025;
        float TB = 1.5;
        const float PI6 = 0.523599;
        
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
        
        float a = atan(varyTexCoord.x - result.x , varyTexCoord.y - result.y);
        
        vec2 area1 = vec2(result.x, result.y - mosaicSize * TR / 2.0);
        vec2 area2 = vec2(result.x + mosaicSize / 2.0, result.y - mosaicSize * TR / 2.0);
        vec2 area3 = vec2(result.x + mosaicSize / 2.0, result.y + mosaicSize * TR / 2.0);
        vec2 area4 = vec2(result.x, result.y + mosaicSize * TR / 2.0);
        vec2 area5 = vec2(result.x - mosaicSize / 2.0, result.y + mosaicSize * TR / 2.0);
        vec2 area6 = vec2(result.x - mosaicSize / 2.0, result.y - mosaicSize * TR / 2.0);
        
        vec2 vn;
        if (a >= -PI6 && a < PI6){
            vn = area1;
        }else if(a >= PI6 && a < 3.0 * PI6){
            vn = area2;
        }else if(a >= 3.0 * PI6 && a < 5.0 * PI6){
            vn = area3;
        }else if((a >= PI6 * 5.0 && a <= PI6 * 6.0) || (a<-PI6 * 5.0 && a>-PI6 * 6.0)){
            vn = area4;
        }else if(a < -PI6 * 3.0 && a >= -PI6 * 5.0){
            vn = area5;
        }else if(a <= -PI6 && a> -PI6 * 3.0){
            vn = area6;
        }
        gl_FragColor = texture2D(colorMap, vn);
    }else{
        gl_FragColor = texture2D(colorMap, varyTexCoord);
    }
}
//局部马赛克
