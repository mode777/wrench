uniform sampler2D texture;
uniform sampler2D map;

varying lowp vec2 texcoord;
uniform lowp vec2 texSize;
uniform lowp vec2 mapSize;
uniform lowp float prio;
uniform lowp vec2 tilesize;
uniform lowp float pixelation;
uniform lowp float time;

void main(void) {
  lowp vec2 inp = texcoord;

  // water wobble
  //inp.x += mod(gl_FragCoord.y, 2.0) * -sin(gl_FragCoord.y / 50.0 + time) + mod(gl_FragCoord.y+1.0, 2.0) * sin(gl_FragCoord.y / 35.0 + time);
  //inp.y += cos(gl_FragCoord.y / 35.0 + time);

  //inp.x *= gl_FragCoord.y / 10.0;

  lowp vec4 tile = texture2D(map, (floor(inp)+0.5) / mapSize);
  //if((tile.x + tile.y) == 0.0) discard;

  tile *= 255.0;
  tile *= 1.0 - floor(mod(tile.z + prio + 0.1, 2.0));

  //lowp vec2 oneTile = (texSize / tilesize);
  lowp float oneTile = 0.015625;

  //lowp vec2 offset = ((floor(fract(inp) * tilesize / pixelation) + 0.5) / tilesize * pixelation);
  lowp vec2 offset = ((floor(fract(inp) * tilesize) + 0.5) / tilesize);
  lowp vec2 uv = (tile.xy + offset) * oneTile;

  gl_FragColor = texture2D(texture, uv);
  
}