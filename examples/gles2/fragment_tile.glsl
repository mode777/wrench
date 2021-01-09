uniform sampler2D texture;

varying mediump vec2 texcoord;
uniform mediump vec2 texSize;
uniform mediump float pixelscale;
uniform mediump float prio;
uniform mediump vec2 tilesize;

void main(void) {
  mediump vec4 tile = texture2D(texture, texcoord / texSize);
  tile *= 255.0;
  mediump float prioFlag = tile.z;
  mediump float prioSet = mod(prio, 2.0);
  mediump float mult = step(prioFlag, prioSet) * step(prioSet, prioFlag);
  tile *= mult;

  mediump vec2 oneTile = (texSize / tilesize);
  
  mediump vec2 offset = fract(texcoord);

  gl_FragColor = texture2D(texture, (tile.xy + offset) / oneTile);
}