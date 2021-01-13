import "super16" for Super16, Gfx
import "random" for Random
import "images" for Image

Super16.init({
  "width": 640,
  "height": 480,
  "scale": 2 
}) {
  var random = Random.new(1986)

  var img = Image.fromFile("assets/vram.png")
  Gfx.vram(0,0, img)
  img.dispose()

  for(s in Gfx.sprites){
    s.set(16, 16, 54*16, 16*16)
    s.prio = 1+random.int(4)
    s.pos(random.int(Gfx.width/2),random.int(Gfx.height/2))
  }

  for(m in Gfx.layers){
    for(y in 0...32){
      for(x in 0...32){
        m.tile(x,y,Gfx.tid(x,y))
        m.prio(x,y, x%2 == 0 ? true : false)
      }
    }
  }
}

var Offset = [0,0]
var Rot = 0

Super16.run {
  Offset[0] = -(Super16.time/1000).sin * 100 
  Offset[1] = (Super16.time/1000).cos * 100

  Gfx.bg0.pos(Offset[0], Offset[1])
  Gfx.bg1.pos(-Offset[0], Offset[1])
  Gfx.bg2.pos(-Offset[0], -Offset[1])
  Gfx.bg3.pos(Offset[0], -Offset[1])

  Rot = Rot + 0.25
  for(s in Gfx.sprites){
    s.rot = Rot+s.id/300
  }
}