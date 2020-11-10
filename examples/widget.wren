class Transform2d {

  x { _x }
  x=(v) { _x = v }

  y { _y }
  y=(v) { _y = v }

  originX { _originX }
  originX=(v) { _originX = v }

  originY { _originY }
  originY=(v) { _originY = v }

  scaleX { _scaleX }
  scaleX=(v) { _scaleX = v }

  scaleY { _scaleY }
  scaleY=(v) { _scaleY = v }

  rotation { _rotation }
  rotation=(v) { _rotation = v }

  construct new(){
    _x = 0
    _y = 0
    _originX = 0
    _originY = 0
    _scaleX = 1
    _scaleY = 1
    _rotation = 0
  }

  push(ctx){
    ctx.save()
    ctx.translate(_x,_y)
    ctx.rotate(_rotation)
    ctx.scale(_scaleX, _scaleY)
    ctx.translate(-_originX, -_originY)
  }

  pop(ctx){
    ctx.restore()
  }
}



class Widget {
  construct new(){
    _transform = Transform2d.new()
  }

  


}

class ImagePanel  {
  construct new(w,h){

  }




}