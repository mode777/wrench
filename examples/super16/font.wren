import "super16" for Super16, Gfx, Time, Sub, Input
import "images" for Image

Super16.init {
  var img = Image.fromFile("assets/font.png")
  Gfx.vram(0,16,img)
  Gfx.fnt0.glyph("A", 0, 24, 8, 8)
  Gfx.fnt0.text(10, 10, 0, "AAAAAAAAAA")

  // Gfx.sprites[0].set(200, 200, 0, 16, 0, 0)
  // Gfx.sprites[0].prio = 4
  // Gfx.sprites[0].pos(5,5)
}

Super16.run {

}