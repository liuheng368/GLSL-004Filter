precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;
uniform float Time;

void main(void) {
    const float PI = 3.1415926;
    const float duration = 0.6;
    const float maxAlpha = 0.4;
    const float maxScale = 0.8;
    
    float progress = mod(Time, duration) / duration;    //0 ~ 1
    float alpha = maxAlpha - (maxAlpha * progress);     //0.4 ~ 0
    float scale = 1.0 +  maxScale * progress;           //1 ~ 1.8
    
    vec2 weakTexCoords = vec2(0.5 + (varyTexCoord.x - 0.5) / scale, 0.5 + (varyTexCoord.y - 0.5) / scale);
    vec4 weakColor = texture2D(colorMap, weakTexCoords);
    vec4 color = texture2D(colorMap, varyTexCoord);
    
    gl_FragColor = color * (1.0 - alpha) + weakColor * alpha;
}

//纹理坐标的放大原理：获取放大到当前点的纹理坐标

//按中心点来缩放
//1.这里0.5的计算可以理解为：将坐标轴移动到中心点，其坐标值就需要减0.5。例如：之前的原点（0，0）移动后为（-0.5，-0.5）
//2.计算后，需要将坐标周移动到原始位置，其坐标值就需要加0.5。
