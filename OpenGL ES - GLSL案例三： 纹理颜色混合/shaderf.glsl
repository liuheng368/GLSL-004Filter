precision highp float;
varying lowp vec2 varyingTexCoord;
varying vec4 varyingColor;
uniform sampler2D colorMap;
uniform lowp float alpha;

void main() {
    vec4 vTexColor = texture2D(colorMap, varyingTexCoord);
    vec4 vColor = varyingColor;
    gl_FragColor = vTexColor * (1.0 - alpha) + vColor * alpha;
}
