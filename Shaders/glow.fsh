varying MEDP vec2 uvVarying;

uniform float texelWidth;
uniform float texelHeight;
uniform vec4 glowColor;
uniform sampler2D sampler;

vec4 porterDuffOver (vec4 bkg, vec4 fgd) {
  vec3 cfgdPremultiplied = fgd.rgb * fgd.a;
  vec3 cbkgPremultiplied = bkg.rgb * bkg.a;
  
  vec3 cout = cfgdPremultiplied + (1 - fgd.a) * cbkgPremultiplied;
  float aout = fgd.a + (1 - fgd.a) * bkg.a;
  
  return vec4(
    cout.r / aout, cout.g / aout, cout.b / aout, aout
  );
}

void main() { 
    vec4 texColor = texture2D (sampler, uvVarying);
    
    float alpha = 0;
    alpha += texture2D(sampler, uvVarying + vec2(texelWidth, texelHeight)).a;
    alpha += texture2D(sampler, uvVarying + vec2(-texelWidth, texelHeight)).a;
    alpha += texture2D(sampler, uvVarying + vec2(texelWidth, -texelHeight)).a;
    alpha += texture2D(sampler, uvVarying + vec2(-texelWidth, -texelHeight)).a;
    alpha += texture2D(sampler, uvVarying + vec2(texelWidth, 0)).a;
    alpha += texture2D(sampler, uvVarying + vec2(-texelWidth, 0)).a;
    alpha += texture2D(sampler, uvVarying + vec2(0, texelHeight)).a;
    alpha += texture2D(sampler, uvVarying + vec2(0, -texelHeight)).a;
    alpha /= 8;
    alpha = clamp(alpha - texColor.a, 0, 1);
    
    vec4 localGlowColor = vec4(alpha, alpha, alpha, alpha);
    
    gl_FragColor = localGlowColor + texColor;
}
