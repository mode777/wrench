uniform sampler2D texture;
uniform sampler2D map;

varying lowp vec2 texcoord;
uniform lowp vec2 texSize;
uniform lowp vec2 mapSize;
uniform lowp float pixelscale;
uniform lowp float prio;
uniform lowp vec2 tilesize;

void main(void) {
  lowp vec4 tile = texture2D(map, (floor(texcoord)+0.5) / mapSize);
  tile *= 255.0;
  lowp float uPrio = mod(prio, 2.0);
  lowp float tPrio = tile.z;
  lowp float mult = step(0.2, abs(uPrio - tPrio));
  tile *= mult;

  lowp vec2 oneTile = (texSize / tilesize);
  
  lowp vec2 offset = fract(texcoord);
  gl_FragColor = texture2D(texture, (tile.xy + offset) / oneTile);
}