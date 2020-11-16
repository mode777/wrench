import "collections" for Queue

class DefaultCanceller {
  static isCancelled { false }
}

class Canceller {
  isCancelled { _cancelled }
  construct new(){
    _cancelled = false
  }
  cancel(){
    _cancelled = true
  }
}

class Timeout {
  isCancelled { System.clock - _start >= _timeout }

  construct new(time){
    _timeout = time
    _start = System.clock
  }
}

class Task {

  static combine(lst, cancel){
    return Task.new(cancel){
      var intermed = List.filled(lst.count, null)
      var done = false
      while(!done){
        done = true
        for(i in 0...lst.count){
          var t = lst[i]
          if(!t.isDone){
            done = false
            intermed[i] = t.step()
          } 
        }
        Fiber.yield(intermed)
      }
      return lst.map{|x| x.result }.toList
    }
  }

  static combine(lst){ combine(lst, DefaultCanceller) }

  static repeat(times, cancel, fn){
    return Task.new(cancel){|c|
      while((times > 0 || times == -1) && !c.isCancelled){
        fn.call(c)
        if(times > -1){ times = times -1 }
      }
    }
  }

  static repeat(times, fn){ repeat(times, DefaultCanceller, fn) }
  static repeat(fn){ repeat(-1, fn) }

  static delay(s, cancel){
    var t = System.clock
    while(System.clock - t < s && !cancel.isCancelled){
      Fiber.yield()
    } 
  }

  static delay(s){
    delay(s, DefaultCanceller)
  }

  static intervall(delay, cancel, fn){
    return Task.new(cancel) {|c|
      while(!c.isCancelled){
        Task.delay(delay/1000, c)
        fn.call(c)
      }
    }
  }
  static intervall(delay, fn){ intervall(delay, DefaultCanceller, fn) }

  isDone { _fiber.isDone }
  result { _result }

  construct new(cancel, fn){
    _fiber = Fiber.new(fn)
    _cancel = cancel
  }

  construct new(fn){
    _fiber = Fiber.new(fn)
    _cancel = DefaultCanceller
  }

  subscribe(fn){
    _subscription = fn
    return this
  }

  then(fn){
    _callback = fn
    return this
  }

  catch(fn){
    _catch = fn
    return this
  }

  await(){
    while(!isDone){
      step()
      Fiber.yield()
    }
    return _result
  }

  getResult(){
    while(!isDone){
      step()
    }
    return _result
  }

  step(){
    if(_fiber.isDone) return
    var returnVal
    if(_catch){
      returnVal = _fiber.try(_cancel)
    } else {
      returnVal = _fiber.call(_cancel)
    }
    if(_fiber.error){
      handleError_(_fiber.error)
    } else if(returnVal) {
      handleResult_(returnVal)
    }
    return returnVal
  }

  handleResult_(res){
    if(_fiber.isDone){
      _result = res
      if(_callback) _callback.call(res)
    }else{
      if(_subscription) _subscription.call(res)
    }
  }

  handleError_(error){
    _error = error
    if(_catch){
      _catch.call(error)
    } else {
      Fiber.abort(error)
    }
  }
}

class TaskDriver {
  
  task { _task }

  construct new(cancel){
    _tasks = []
    _delete = []
    _task = Task.repeat(-1, cancel) {|c| update_(c) }
  }

  add(task){
    _tasks.add(task)
  }

  update_(c){
    for(i in 0..._tasks.count){
      var t = _tasks[i]
      if(t.isDone) { 
        _delete.insert(0, i)
      } else { 
        t.step() 
      }
    }
    for(i in _delete){
      _tasks.removeAt(i)
    }
    _delete.clear()
    Fiber.yield()
  }
}

class TaskQueue {
    
  task { _task }

  construct new(size, cancel){
    _tasks = Queue.new(size)
    _delete = []
    _task = Task.repeat(-1, cancel) {|c| update_(c) }
  }

  add(task){
    _tasks.enqueue(task)
  }

  update_(c){
    while(_tasks.count == 0) Fiber.yield()
    var t = _tasks.dequeue()
    t.await()
  }
}