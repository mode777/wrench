import "shapes" for Rectangle

class ControlBounds {
  
  outer { _outer }
  inner { _inner }
  box { _box }

  pos { _attributes["position"] }
  size { _attributes["size"] }
  padding { _attributes["padding"] }
  margin { _attributes["margin"] }

  construct new(control){
    _outer = Rectangle.new()
    _inner = Rectangle.new()
    _box = Rectangle.new()
    _control = control 
    _attributes = _control.attributes
    update()
  }

  update(){
    _outer.set(pos[0]-margin[0], pos[1]-margin[0], size[0]+margin[0]*2, size[1]+margin[1]*2)
    _inner.set(pos[0]+padding[0], pos[1]+padding[1], size[0]-padding[0]*2, size[0]-padding[0]*2)
    _box.set(pos[0], pos[1], size[0], size[1])
  }

  configure(config){}

  dispose(){}

}