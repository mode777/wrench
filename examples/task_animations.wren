import "nanovg-app" for NanovgApp
import "wren-nanovg" for NvgColor, NvgImage, NvgPaint
import "tasks" for Task, Canceller, DefaultCanceller
import "wren-sdl" for SdlKeyCode

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

var TweenLinear = Fn.new {|c,t,d,b|  c * t / d + b  }
var TweenEaseOutCubic = Fn.new {|c,t,d,b|  c * ((t = t / d - 1) * t * t + 1) + b  }
var TweenEaseInQuad = Fn.new {|c,t,d,b|  c * (t = t / d) * t + b  }
var TweenEaseOutQuad = Fn.new {|c,t,d,b|  -c * (t = t / d) * (t - 2) + b  }
var TweenEaseInOutQuad = Fn.new {|c,t,d,b|  ((t = t / (d / 2)) < 1) ? c / 2 * t * t + b : -c / 2 * ((t = t-1) * (t - 2) - 1) + b  }
var TweenEaseInCubic = Fn.new {|c,t,d,b|  c * (t = t / d) * t * t + b  }
var TweenEaseInOutCubic = Fn.new {|c,t,d,b|  ((t = t / (d / 2)) < 1) ? c / 2 * t * t * t + b  : c / 2 * ((t = t - 2) * t * t + 2) + b  }

class Tween {
  static create(from, to, time, easeFunc, cancel, fn){
    var start = System.clock
    var intermed = List.filled(from.count, 0)
    var deltaV = List.filled(from.count, 0)
    for(i in 0...from.count){
      deltaV[i] = to[i] - from[i] 
    }    
    return Task.new(cancel) {|c|
      var curT = 0
      while(curT < time && !c.isCancelled){
        curT = System.clock - start
        for(i in 0...from.count){
          intermed[i] = easeFunc.call(deltaV[i], curT, time, from[i])
        }
        fn.call(intermed)
        Fiber.yield()
      }
      fn.call(to)
    }
  }
  static create(from, to, time, easeFunc, fn){
    return create(from, to, time, easeFunc, DefaultCanceller, fn)
  }
}

class MyApp is NanovgApp{
  construct new(){
    super(800, 480, "Task Animations")
    _transform = Transform2d.new()
  }

  move(x, y, t, c){
    return Tween.create([_transform.x,_transform.y], [x, y], t, TweenEaseOutQuad, c){|v| 
      _transform.x = v[0] 
      _transform.y = v[1]
    }
  }

  move(x,y){
    _transform.x = x
    _transform.y = y
  }

  center(){
    _transform.originX = 100
    _transform.originY = 100
  }

  runAnimation() {
    center()  
    move(100,100)
    return Task.repeat(-1, _canceller) {|c|
      move(300, 100, 1, c).await()
      move(300, 300, 1, c).await()
      move(100, 300, 1, c).await()
      move(100, 100, 1, c).await()
    }
  }

  onKey(sym, isUp){
    if(sym == SdlKeyCode.Escape && _canceller){
      _canceller.cancel()
      _aniTask.getResult()
    }
    if(sym == SdlKeyCode.Space && isUp){
      if(_canceller){
        _canceller.cancel()
        _aniTask.getResult()
      }
      _canceller = Canceller.new()
      _aniTask = runAnimation()
    }
  }

  update(ctx){
    if(_aniTask){ _aniTask.step() }
    _transform.push(ctx)
    ctx.beginPath()
    ctx.roundedRect(0,0, 200, 200, 50)
    ctx.fillColor(NvgColor.rgba(255,192,0,255))
    ctx.fill()    
    _transform.pop(ctx)
  }
}

var app = MyApp.new()