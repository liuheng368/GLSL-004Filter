precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;
uniform float Time;

void main(void) {
    const float PI = 3.1415926;
    const float maxScale = 0.3;
    const float duration = 0.6;
    
    float time = mod(Time, duration);
    float amplitude = 1.0 + maxScale * sin(time * (PI / duration));
    vec2 temp = vec2(0.5 + (varyTexCoord.x - 0.5) / amplitude, 0.5 + (varyTexCoord.y - 0.5) / amplitude);
    
    gl_FragColor = vec4(texture2D(colorMap, temp).rgb, 1.0);
}
//纹理坐标的放大原理：获取放大到当前点的纹理坐标

//按中心点来缩放
//1.这里0.5的计算可以理解为：将坐标轴移动到中心点，其坐标值就需要减0.5。例如：之前的原点（0，0）移动后为（-0.5，-0.5）
//2.计算后，需要将坐标周移动到原始位置，其坐标值就需要加0.5。
