precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;
//该值取值GUPImage
const highp vec3 GRAY = vec3(0.2125, 0.7154, 0.0721);
void main(void) {
    vec3 realColor = texture2D(colorMap, varyTexCoord).rgb;
    float result = dot(realColor, GRAY);
    gl_FragColor = vec4(vec3(result), 1.0);
}

//度滤镜原理理
//整数⽅方法:Gray=(R*30+G*59+B*11)/100灰

