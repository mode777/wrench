class Rectangle {
  right { _x + _w }
  bottom { _y + _h }
  left { _x }
  top { _y }

  x { _x }
  y { _y }
  w { _w }
  h { _h }
  width { _w }
  height { _h }
  
  construct new(x, y, w, h){
    set(x,y,w,h)
  }

  construct new(){}

  set(x, y, w, h){
    _x = x
    _y = y
    _w = w
    _h = h
  }

  isInside(x,y){ x >= left && x < right && y >= top && y < bottom }

  toString { "%(x), %(y), %(w), %(h)" }
}