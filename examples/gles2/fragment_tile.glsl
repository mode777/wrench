uniform sampler2D texture;

varying lowp vec2 texcoord;
uniform lowp vec2 texSize;
uniform lowp float pixelscale;
uniform lowp float prio;
uniform lowp vec2 tilesize;

void main(void) {
  lowp vec4 tile = texture2D(texture, texcoord / texSize);
  tile *= 255.0;
  lowp float prioFlag = tile.z;
  lowp float uPrio = mod(prio, 2.0);
  lowp float tPrio = sign(tile.z);
  lowp float mult = step(tPrio, uPrio) * step(uPrio, tPrio);
  tile *= mult;

  lowp vec2 oneTile = (texSize / tilesize);
  
  lowp vec2 offset = fract(texcoord);
  gl_FragColor = texture2D(texture, (tile.xy + offset) / oneTile);
}