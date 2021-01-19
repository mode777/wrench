import "super16" for Super16, Gfx, Time, Sub, Input
import "images" for Image
import "random" for Random

var CoreLoop = Fn.new {
  var gameover = false
  var random = Random.new()
  var speeds = [18,15,13,10,8,6,5,4,3]
  var scoreMultiplier = [0,40,100,300,1200]
  
  Gfx.bg0.pos(0, -16*4)
  Gfx.bg1.pos(0, -16*4)
  Gfx.bg2.pos(0, -16*4)
  
  while(true){
    var lines = 0
    var level = 0
    var score = 0

    var startX = Field.x + (Field.w/2).floor -2
    var startY = Field.y

    var t = Tetromino.new(startX,startY,TetroTypes[random.int(TetroTypes.count)])

    while(!gameover){
      Field.setScore(score)
      Field.setLevel(level)
      Field.setLines(lines)

      // create a random piece
      var next = Tetromino.new(startX, startY ,TetroTypes[random.int(TetroTypes.count)])
      Field.previewTetro(next.type)
      
      if(!t.canDrop){
        gameover = true
        break
      }

      t.startDropping(speeds[level])

      var delay = 0
      var buttonReleased = true
      var dirReleased = true
      
      while(!t.dropped){
        if(Input.down) {
          t.skip = true
        } else {
          t.skip = false
        }
        if(delay == 0 || dirReleased){
          if(Input.left) t.move(-1,0)
          if(Input.right) t.move(1,0)
          delay = 7
        } else {
          delay = delay - 1
        }
        if(buttonReleased){
          if(Input.a) t.rotate(-1)
          if(Input.b) t.rotate(1)
        }
        buttonReleased = !(Input.a || Input.b)
        dirReleased = !(Input.left || Input.right)
        Sub.step()
      }
      var linesCleared = Field.clearLines()  
      lines = lines + linesCleared
      score = score + (scoreMultiplier[linesCleared] * (level+1)) + t.softDrops
      level = (lines / 10).floor
      t = next
    }

    Field.playGameoverAnimation()
    Sub.wait(15)

    gameover = false
    Field.clear()
  }
}

var Field

class Playfield {

  x { _x }
  y { _y }
  w { _w }
  h { _h }

  construct new() {
    _w = 10
    _h = 20
    _x = 2
    _y = 1
    _clearResult = {}
    Gfx.bg0.tileFill(0,0,50,50,Tiles.wall)
    clear()
    putWindow(_x + _w + 1, _y+3, 6, 3)
    putWindow(_x + _w + 1, _y+6, 6, 3)
    putWindow(_x + _w + 1, _y+9, 6, 3)
    putWindow(_x + _w + 1, _y+13, 6, 6)
  }

  setLevel(n){
    putNumber(18, _y+10, 4, n)
  }

  setScore(n){
    putNumber(18, _y+7, 4, n)
  }

  setLines(n){
    putNumber(18, _y+4, 4, n)
  }

  previewTetro(type){
    if(_preview) _preview.remove(1,14,_y+14,0)
    _preview = type
    _preview.set(1, 14,_y+14,0)
  }

  clear(){
    Gfx.bg1.tileFill(_x,_y,_w,_h,0)
    Gfx.bg0.tileFill(_x,_y,_w,_h,Tiles.hole)
  }

  playGameoverAnimation(){
    for(y in (_y+_h-1).._y){
      for(x in _x..._x+_w){
        Gfx.bg1.tile(x,y, Tiles.wall)
      }
      Sub.wait(3)
    }
  }

  removeLine(y){
    for(x in _x..._x+_w){
      Gfx.bg1.tile(x,y,Tiles.none)
    }
    Sub.wait(5)
    for(cy in (y-1).._y){
      for(x in _x..._x+_w){
        Gfx.bg1.tile(x,cy+1,Gfx.bg1[x,cy])
      }
    }
  }

  clearLines(){
    var lines = []
    for(y in _y..._y+_h){
      var count = 0
      for(x in _x..._x+_w){
        if(Gfx.bg1.hasFlag(x,y, SOLID)) count = count + 1    
      }
      if(count == _w) lines.add(y)
    }
    for(l in lines){
      removeLine(l)
    }
    return lines.count
  }

  putWindow(x,y,w,h){
    Gfx.bg0.tileFill(x+1,y+1,w-2,h-2,Tiles.hole)
    
    for(cy in y+1...y+h-1){
      Gfx.bg1.tile(x,cy,Gfx.tid(3,2))
      Gfx.bg1.tile(x+w-1,cy,Gfx.tid(3,1))
    }
    
    for(cx in x+1...x+w-1){
      Gfx.bg1.tile(cx,y,Gfx.tid(2,1))
      Gfx.bg1.tile(cx,y+h-1,Gfx.tid(2,2))
    }
    
    Gfx.bg1.tile(x,y,Gfx.tid(0,1))
    Gfx.bg1.tile(x+w-1,y,Gfx.tid(1,1))
    Gfx.bg1.tile(x+w-1,y+h-1,Gfx.tid(1,2))
    Gfx.bg1.tile(x,y+h-1,Gfx.tid(0,2))
  }

  putNumber(x,y,digits,num){
    num = num.floor
    var bytes = num.toString.bytes
    for(i in x-digits...x){
      Gfx.bg1.tile(i,y,Tiles.none)
    }
    x = x - bytes.count
    for(b in bytes){
      var tid = Gfx.tid(7+b-48,0)
      Gfx.bg1.tile(x,y,tid)
      x = x + 1
    }
  }
}

var TetroI
var TetroO 
var TetroT
var TetroL
var TetroJ
var TetroS
var TetroZ
var TetroTypes

class TetrominoType {
  construct new(data, tid){
    _data = data
    _tid = tid
  }

  forXY(rot,fn){
    for(cy in 0...4){
      for(cx in 0...4){
        fn.call(cx,cy, _data[rot%_data.count][cy*4+cx])
      }
    }
  }

  set(layer, x,y,rot){
    forXY(rot) { |cx,cy,v| 
      if(v != 0) Gfx.layers[layer].tile(cx+x, cy+y, _tid) 
    }
  }
  remove(layer, x,y,rot){
    forXY(rot) { |cx,cy,v| 
      if(v != 0) Gfx.layers[layer].tile(cx+x, cy+y, 0) 
    }
  }

  fits(x,y,rot){
    var f = true
    forXY(rot) { |cx,cy,v| 
      var solid = Gfx.bg0.hasFlag(x+cx,y+cy, SOLID) || Gfx.bg1.hasFlag(x+cx,y+cy, SOLID)
      if(v != 0 && solid) f = false 
    }
    return f
  }
}

class Tetromino {
  x { _x }
  y { _y }
  rot { _rot }
  dropped { _dropped }
  skip=(v) { _skip = v }
  type { _type }
  softDrops { _softDrops }

  construct new(x,y,type){
    _x = x
    _y = y
    _rot = 0
    _type = type
  }

  canDrop { _type.fits(_x,_y,_rot) }

  move(x,y){
    var success = false
    _type.remove(1, _x, _y, _rot)
    if(_type.fits(_x + x, _y + y, _rot)){
      _x = _x + x
      _y = _y + y
      success = true
    }
    _type.set(1, _x, _y, _rot)
    return success
  }

  rotate(dir){
    var success = false
    var newRot = (_rot+dir)%4
    _type.remove(1, _x, _y, _rot)
    if(_type.fits(_x, _y,newRot)){
      _rot = newRot
      success = true
    }
    _type.set(1,_x, _y, _rot)
    return success
  }

  startDropping(delay){
    var d = delay
    _softDrops = 0
    Sub.run {
      _type.set(1,_x,_y,_rot)
      while(!_dropped){
        if(d == 0 || _skip){
          if(!move(0,1)) _dropped = true
          if(_skip) _softDrops = _softDrops + 1
          d = delay
        } else {
          d = d - 1
        }
        Sub.wait(3)
      }
    }
  }

}

var SOLID = Gfx.flag1

class Tiles {
  static none { 0 }
  static wall { Gfx.tid(1,0) } 
  static hole { Gfx.tid(2,0) }
  static purple { Gfx.tid(3,0) }
  static yellow { Gfx.tid(4,0) }
  static blue { Gfx.tid(5,0) }
  static pink { Gfx.tid(6,0) }
  static grey { Gfx.tid(6,1) }
  static brown { Gfx.tid(5,1) }
  static green { Gfx.tid(4,1) }
}


Super16.init {
  var img = Image.fromFile("assets/tetris.png")
  Gfx.vram(0,0, img)
  img.dispose()
  
  for(tid in [Tiles.wall, Tiles.purple, Tiles.yellow, Tiles.blue, Tiles.pink, Tiles.grey, Tiles.brown, Tiles.green]){
    Gfx.setFlag(SOLID, tid)
  }
  
  Field = Playfield.new()
  
  TetroI = TetrominoType.new([[
    0, 0, 0, 0,
    1, 1, 1, 1,
    0, 0, 0, 0,
    0, 0, 0, 0
  ],[
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 0, 0
  ]], Tiles.yellow)
  TetroJ = TetrominoType.new([[
    0, 0, 0, 0,
    1, 1, 1, 0,
    0, 0, 1, 0,
    0, 0, 0, 0
  ],[
    0, 1, 0, 0,
    0, 1, 0, 0,
    1, 1, 0, 0,
    0, 0, 0, 0
  ],[
    1, 0, 0, 0,
    1, 1, 1, 0,
    0, 0, 0, 0,
    0, 0, 0, 0
  ],[
    0, 1, 1, 0,
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0
  ]], Tiles.purple)
  TetroL = TetrominoType.new([[
    0, 0, 0, 0,
    1, 1, 1, 0,
    1, 0, 0, 0,
    0, 0, 0, 0
  ],[
    1, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0
  ],[
    0, 0, 1, 0,
    1, 1, 1, 0,
    0, 0, 0, 0,
    0, 0, 0, 0
  ],[
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 1, 0,
    0, 0, 0, 0
  ]], Gfx.tid(5,0))
  TetroS = TetrominoType.new([[
    0, 0, 0, 0,
    0, 1, 1, 0,
    1, 1, 0, 0,
    0, 0, 0, 0
  ],[
    1, 0, 0, 0,
    1, 1, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0
  ]], Gfx.tid(6,0))
  TetroZ = TetrominoType.new([[
    0, 0, 0, 0,
    1, 1, 0, 0,
    0, 1, 1, 0,
    0, 0, 0, 0
  ],[
    0, 1, 0, 0,
    1, 1, 0, 0,
    1, 0, 0, 0,
    0, 0, 0, 0
  ]], Gfx.tid(4,1))
  TetroT = TetrominoType.new([[
    0, 0, 0, 0,
    1, 1, 1, 0,
    0, 1, 0, 0,
    0, 0, 0, 0
  ],[
    0, 1, 0, 0,
    1, 1, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0
  ],[
    0, 1, 0, 0,
    1, 1, 1, 0,
    0, 0, 0, 0,
    0, 0, 0, 0
  ],[
    0, 1, 0, 0,
    0, 1, 1, 0,
    0, 1, 0, 0,
    0, 0, 0, 0
  ]], Gfx.tid(5,1))
  TetroO = TetrominoType.new([[
    0, 0, 0, 0,
    0, 1, 1, 0,
    0, 1, 1, 0,
    0, 0, 0, 0
  ]], Gfx.tid(6,1))
  TetroTypes = [TetroI,TetroT,TetroO,TetroS,TetroZ,TetroL,TetroJ]

  Sub.run(CoreLoop)
}
Super16.run()