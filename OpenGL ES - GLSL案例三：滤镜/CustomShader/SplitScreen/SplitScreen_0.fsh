precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

void main(void) {
    vec4 mask = texture2D(colorMap, varyTexCoord);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
