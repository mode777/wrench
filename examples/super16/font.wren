import "super16" for Super16, Gfx, Time, Sub, Input
import "images" for Image

Super16.init {
  var img = Image.fromFile("assets/font.png")
  Gfx.vram(0,0,img)
  Gfx.fnt0.glyph("A", 0, 8, 8, 8)
  Gfx.fnt0.text(10, 10, 0, "AAAAAAAAAA")
}

Super16.run {

}