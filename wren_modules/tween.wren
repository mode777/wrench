import "tasks" for Task, DefaultCanceller

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