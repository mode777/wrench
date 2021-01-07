uniform sampler2D texture;

varying mediump vec2 texcoord;
uniform mediump vec2 texSize;

void main(void) {
  mediump vec4 tile = texture2D(texture, texcoord / texSize);
  mediump vec2 oneTile = (texSize / 16.0);
  
  mediump vec2 coordinates = tile.xy * 255.0;
  mediump vec2 offset = fract(texcoord);

  gl_FragColor = texture2D(texture, (coordinates + offset) / oneTile);
}