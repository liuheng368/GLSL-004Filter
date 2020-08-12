precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

void main(void) {
    vec4 realColor = texture2D(colorMap, varyTexCoord);
    gl_FragColor = vec4(vec3(realColor.g), 1.0);
}

//度滤镜原理理
//整数⽅方法:Gray=(R*30+G*59+B*11)/100灰

