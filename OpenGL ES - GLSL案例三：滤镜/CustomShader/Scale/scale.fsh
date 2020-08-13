precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

void main(void) {
    vec3 mask = texture2D(colorMap, varyTexCoord).rgb;
    gl_FragColor = vec4(mask, 1.0);
}
