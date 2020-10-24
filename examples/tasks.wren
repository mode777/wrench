class Task {

  static all(lst){
    var results = List.filled(lst.count, null)
    var done = false
    while(!done){
      done = true
      for(i in 0...lst.count){
        var fib = lst[i]
        if(!fib.isDone){
          done = false
          results[i] = fib.call()
        } 
      }
    }
    return results
  }

  static delay(s){
    var t = System.clock
    while(System.clock - t < s) Fiber.yield()
  }

  construct create(fn){
    fromFiber_(Fiber.new(fn))
  }

  construct fromFiber(fib){
    fromFiber_(fib)
  }

  fromFiber_(fib){
    _fiber = fib
  }
  
  getResult(){
    var ret = null
    while(!fib.isDone){
      ret = fib.call()
    }
    return ret
  }

  continue(fib){
    if(!fib.isDone){
      return fib.call()
    }
  }

  await(fib){
    var ret = null
    while(!fib.isDone){
      ret = fib.call()
      if(fib.isDone) break
      Fiber.yield()
    }
    return ret
  }

  
}



var t = Task.create {
  var t1 = Task.create {
    Task.delay(1)
    System.print("Hello from Task 1")
  }

  var t2 = Task.create {
    System.print("Hello from Task 2")
  }

  Task.await(t1)
  Task.delay(1)
  Task.await(t2)
}

//Task.getResult(t)

while(!t.isDone){
  Task.step(t)
}