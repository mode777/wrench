import "super16" for Gfx
import "json" for Json
import "file" for File
import "image" for Image

class Font {
  fromFile(imageFile, descriptionFile, slot, vramx, vramy){
    var json = Json.parse(File.read(descriptionFile))
    var img = Image.fromFile(imageFile)
    Gfx.vram(vramx, vramy, img)
    var fnt = Font.new(slot, vramx, vramy, json["line-height"])
    for(i in 0...json["glyphs"].count){
      var glyphs = json["glyphs"][i].codePoints
      var widths = json["widths"][i]

      for(j in 0...glyphs.count) {
        var cp = glyphs[j]
        var width = widths[j]
        fnt.addGlyph(cp, width)
      }
      fnt.newLine()
    }
  }

  construct new(slot, x, y, lineHeight){
    _startX = x
    _x = x
    _y = y
    _slot = slot
    _lineHeight = lineHeight
    
    Gfy.fonts[_slot].clear()
  }

  addGlyph(codePoint,width){
    Gfx.fonts[_slot].glyph(codePoint, _x, _y, width, _lineHeight)
    _x = _x + width
  }

  newLine(){
    _y = _y + _lineHeight
    _x = _startX
  }
}