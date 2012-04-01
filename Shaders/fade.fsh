varying MEDP vec4 colorVarying;
varying MEDP vec2 uvVarying;

uniform sampler2D sampler;

void main() { 
    vec4 texColor = texture2D (sampler, uvVarying);
    
    gl_FragColor = texColor * colorVarying;
}
