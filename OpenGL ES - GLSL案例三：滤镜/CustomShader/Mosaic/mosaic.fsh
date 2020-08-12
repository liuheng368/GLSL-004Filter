precision highp float;
varying lowp vec2 varyTexCoord;
uniform sampler2D colorMap;

void main(void) {
    vec3 realColor = texture2D(colorMap, vec2(1.0 - varyTexCoord.x, 1.0 - varyTexCoord.y)).rgb;
    
    
    
    gl_FragColor = vec4(realColor, 1.0);
}


git init
git add .
git commit -m "first commit"
git remote add origin git@github.com:liuheng368/GLSL-003Mix.git
git push -u origin master
