uniform sampler2D uSampler;

varying mediump vec2 texcoord;

uniform mediump vec4 color;

void main(void) {
  mediump vec2 uv = mod(texcoord, vec2(1.0)); 
  gl_FragColor = texture2D(uSampler, texcoord);
}