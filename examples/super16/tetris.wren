import "super16" for Super16, Gfx, Time, Sub, Input
import "images" for Image
import "random" for Random

var CoreLoop = Fn.new {
  var gameover = false
  var random = Random.new()
  var speeds = [2]
  var cspeed = 0
  var lines = 0
  var level = 0
  var score = 0
  
  while(true){
    while(!gameover){
      // create a random piece
      var t = Tetromino.new(3,0,TetroTypes[random.int(TetroTypes.count)])
      
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
          delay = 5
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
      Field.clearLines()

    }

    Field.playGameoverAnimation()
    Sub.wait(15)

    gameover = false
    Field.clear()
  }
}

var Field

class Playfield {
  construct new() {
    _w = 10
    _h = 17
    Gfx.bg0.tileFill(0,0,30,_h,Gfx.tid(1,0))
    clear()
  }

  clear(){
    Gfx.bg1.tileFill(2,0,_w,_h,0)
    Gfx.bg0.tileFill(2,0,_w,_h,Gfx.tid(2,0))
    _data = List.filled(_w * _h, false)
  }

  setTile(x,y,tid){ Gfx.bg1.tile(2+x,y,tid) }
  getTile(x,y){ Gfx.bg1[2+x,y] }
  markOccupied(x,y){ _data[y*_w+x] = true }
  markFree(x,y){ _data[y*_w+x] = false }
  mark(x,y,b){ _data[y*_w+x] = b }
  isOccupied(x,y){ 
    if(x < 0 || x >= _w || y < 0 || y >= _h) return true
    return _data[y*_w+x] 
  }

  playGameoverAnimation(){
    for(y in (_h-1)..0){
      for(x in 0..._w){
        Gfx.bg1.tile(2+x,y,Gfx.tid(1,0))
      }
      Sub.wait(3)
    }
  }

  removeLine(y){
    for(x in 0..._w){
      markFree(x,y)
      setTile(x,y,0)
    }
    Sub.wait(5)
    for(cy in (y-1)..0){
      for(x in 0..._w){
        var tid = getTile(x, cy)
        var occ = isOccupied(x, cy)
        setTile(x, cy+1, tid)
        mark(x, cy+1, occ)
      }
    }
  }

  clearLines(){
    var lines = []
    for(y in 0..._h){
      var count = 0
      for(x in 0..._w){
        if(isOccupied(x,y)) count = count + 1    
      }
      if(count == _w) lines.add(y)
    }
    for(l in lines){
      removeLine(l)
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

  set(x,y,rot){
    forXY(rot) { |cx,cy,v| 
      if(v != 0) Field.setTile(cx+x, cy+y, _tid) 
    }
  }
  remove(x,y,rot){
    forXY(rot) { |cx,cy,v| 
      if(v != 0) Field.setTile(cx+x, cy+y, 0) 
    }
  }

  drop(x,y,rot){
    forXY(rot) { |cx,cy,v| 
      if(v != 0) Field.markOccupied(cx+x, cy+y) 
    }
  }

  fits(x,y,rot){
    var f = true
    forXY(rot) { |cx,cy,v| 
      if(v != 0 && Field.isOccupied(x+cx,y+cy)) f = false 
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

  construct new(x,y,type){
    _x = x
    _y = y
    _rot = 0
    _type = type
  }

  canDrop { _type.fits(_x,_y,_rot) }

  move(x,y){
    var success = false
    if(_type.fits(_x + x, _y + y, _rot)){
      _type.remove(_x, _y, _rot)
      _x = _x + x
      _y = _y + y
      _type.set(_x, _y, _rot)
      success = true
    }
    return success
  }

  rotate(dir){
    var success = false
    var newRot = (_rot+dir)%4
    if(_type.fits(_x, _y,newRot)){
      _type.remove(_x, _y, _rot)
      _rot = newRot
      _type.set(_x, _y, _rot)
      success = true
    }
    return success
  }

  startDropping(delay){
    var d = delay
    Sub.run {
      while(!_dropped){
        if(d == 0 || _skip){
          if(!move(0,1)){
            _type.drop(_x,_y,_rot)
            _dropped = true
          }
          d = delay
        } else {
          d = d - 1
        }
        Sub.wait(3)
      }
    }
  }

}

Super16.init {
  var img = Image.fromFile("assets/tetris.png")
  Gfx.vram(0,0, img)
  img.dispose()

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
  ]], Gfx.tid(4,0))
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
  ]], Gfx.tid(3,0))
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