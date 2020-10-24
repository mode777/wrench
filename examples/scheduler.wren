class Scheduler {
  static wait(s){
    var time = System.clock
    while(System.clock - time < s){
      Fiber.yield()
    }
  }

  construct new(){
    _fibers = []
    _delete = []
  } 

  pending { _fibers.count }

  update(){
    for(i in 0..._fibers.count){
      var fiber = _fibers[i]
      if(fiber.isDone){
        _delete.add(i)
      } else {
        fiber.call()
      }
    }
    for(i in _delete){
      _fibers.removeAt(i)
    }
  }

  add(fiber){
    _fibers.add(fiber)
  }
}

var sched = Scheduler.new()
sched.add(Fiber.new {
  System.print("start")
  Scheduler.wait(3)
  System.print("done")
})

while(sched.pending > 0){
  sched.update()
}
