import "wren-forms/resources" for SharedResource

class ControlRenderer {

  background { _background.get(_attributes["background-color"]) }
  foreground { _foreground.get(_attributes["foreground-color"]) }

  construct new(control){
    _control = control
    _bounds = control.bounds
    _attributes = control.attributes
    _children = control.controls

    var cache = _control.application.resourceCache
    _font = SharedResource.new("font", cache)
    _backgroundImage = SharedResource.new("image", cache)
    _foreground = SharedResource.new("color", cache)
    _background = SharedResource.new("color", cache)
  }

  configure(config){}

  render(renderer){
    // var box = _bounds.box
    // _ctx.beginPath()
    // _ctx.fillColor(background)
    // _ctx.rect(box[0], box[1], box[2], box[3])
    // _ctx.fill()

    // for(c in _children){
    //   c.render()
    // }
  }

  dispose(){
    _font.dispose()
    _backgroundImage.dispose()
    _foreground.dispose()
    _background.dispose()
  }
}