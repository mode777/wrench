import "super16" for Super16, Gfx, Time, Sub, Input
import "images" for Image


Super16.init {
  var img = Image.fromFile("assets/tetris.png")
  Gfx.vram(0,0,img)
  img.dispose()

  Gfx.bg0.tileFill(0, 0, 128, 128, Gfx.tid(1,0))
}

Super16.run {

}