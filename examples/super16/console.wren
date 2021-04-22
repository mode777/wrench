import "super16" for Super16, Gfx, Time, Sub, Input
import "super16-font" for FontLoader
import "images" for Image

class Console {
  construct new(w, h){
    _w = w
    _h = h
    Gfx.bg0.tileSize(8,17)
    Gfx.bg1.enabled = false
    Gfx.bg2.enabled = false
    Gfx.bg3.enabled = false

    var glyphs = ["!\"#$\%&'()*+,-./0123456789:;<=>?@",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`",
    "abcdefghijklmnopqrstuvwxyz{|}~ "]

    _tids = {}
    var y = 0

    for(row in glyphs){  
      var x = 0
      for(c in row){
        _tids[c] = Gfx.tid(x+1,y)
        x = x+1
      }
      y = y+1
    }

    Gfx.vram(8,0, Image.fromFile("assets/font-console.png"))
    
    _x = 0
    _y = 0
  }

  write(str){
    for(c in str){
      if(c == " ") {
        _x = _x+1
      } else if(c == "\n") {
        _y = _y+1
        _x = 0
      } else {
        var tid = _tids[c]
        //System.print([c, tid])
        Gfx.bg0.tile(_x,_y,tid)
        _x = _x+1
      }
      if(_x > _w){
        _y = _y+1
        _x = 0
      }
    }
  }
}

Super16.start {
  var cons = Console.new(59, 15)

  cons.write("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")

  while(true){
    Sub.step()
  }
}