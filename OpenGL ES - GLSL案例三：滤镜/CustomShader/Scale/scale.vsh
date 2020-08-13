attribute vec4 position;
attribute vec2 texCoord;
varying lowp vec2 varyTexCoord;
uniform float Time;

void main(void){
    
    const float PI = 3.1415926;
    const float maxScale = 0.3;
    const float duration = 0.6;
    
    float time = mod(Time, duration);
    float amplitude = 1.0 + maxScale * sin(time * (PI / duration));
    vec2 temp = vec2(position.x * amplitude, position.y * amplitude);
    
    gl_Position = vec4(temp, position.zw);
    varyTexCoord = texCoord;
}
// sin(time * (PI / duration)) 获得任意持续时间内 0 ~ 1 ~ 0 的振幅值
//sin : 0~90~180度 函数值为： 0~1~0
