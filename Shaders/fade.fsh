varying MEDP vec4 colorVarying;
varying MEDP vec2 uvVarying;

uniform sampler2D sampler;

void main() { 
    vec4 texColor = texture2D (sampler, uvVarying);
    
    float alpha = texColor.a * colorVarying.a;
    gl_FragColor = vec4(
      texColor.r * colorVarying.r * colorVarying.a,
      texColor.g * colorVarying.g * colorVarying.a,
      texColor.b * colorVarying.b * colorVarying.a,
      alpha
    );
}
