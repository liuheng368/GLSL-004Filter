precision highp float;

uniform float Time;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

const float DEGREE = 0.2;
void main(void) {
    vec2 temp = varyTexCoord;
    
    float hLine = distance(vec2(0.5, 0.5) , varyTexCoord);
    
    float aDegree = DEGREE * Time + atan(temp.y - 0.5, temp.x - 0.5);
    temp.x = hLine * cos(aDegree);
    temp.y = hLine * sin(aDegree);
    
    temp.x = temp.x + 0.5;
    temp.y = temp.y + 0.5;
    
    gl_FragColor = texture2D(colorMap, temp);
}

