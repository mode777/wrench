uniform sampler2D texture;

varying highp vec2 texcoord;
uniform highp vec2 texSize;
uniform highp float pixelscale;
uniform highp float prio;
uniform highp vec2 tilesize;

void main(void) {
  highp vec4 tile = texture2D(texture, texcoord / texSize);
  tile *= 255.0;
  // highp float prioFlag = tile.z;
  highp float uPrio = mod(prio, 2.0);
  highp float tPrio = sign(tile.z);
  highp float mult = step(tPrio, uPrio) * step(uPrio, tPrio);
  tile *= mult;

  highp vec2 oneTile = (texSize / tilesize);
  
  highp vec2 offset = fract(texcoord);

  highp vec4 pixel = texture2D(texture, (tile.xy + offset) / oneTile);


  gl_FragColor = pixel;
}