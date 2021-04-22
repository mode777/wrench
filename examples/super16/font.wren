import "super16" for Super16, Gfx, Time, Sub, Input
import "super16-font" for FontLoader
import "images" for Image

class Util {
  static reverse(str){
    var nstr = []
    for(i in str.count-1..0){
      nstr.add(str[i])
    }
    return nstr.join("")
  }
}

Super16.init {
  Gfx.vram(0,0,Image.fromFile("assets/tetris.png"))
  //FontLoader.loadJson("assets/font2.json", Gfx.fnt0, 0, 48)
  FontLoader.loadJson("assets/font3.json", Gfx.fnt0, 0, 7*16)

  Gfx.fnt0.text(0, 13, 0, Util.reverse("0123456789+-=*\%ABCDEFGHIJKLMNOPQRSTUVWXYZ("))
  Gfx.fnt0.text(0, 26, 100, Util.reverse("!?\":.abcdefghijklmnopqrstuvwxyz),/#~&"))
  Gfx.fnt0.text(100, 100, 200, "HALLO KATE, WIE GEHT'S?")

  Sub.run {
    for(i in 200...300){
      Gfx.sprites[i].prio = 0
    }
    for(i in 200...300){
      Gfx.sprites[i].prio = 1
      Sub.wait(2)
    }
  }
  
}

Super16.run {

}