import "collections" for Queue

class Event {
  construct new(){
    _handlers = []
  }

  subscribe(handler){
    _handlers.add(handler)
  }

  unsubscribe(handler){
    var idx = -1
    for(i in 0..._handlers.count){
      if(_handlers[i] == handler){
        idx = i
        break
      }
    }
    if(idx != -1) _handlers.removeAt(idx)
  }

  dispatch(data){
    for(h in _handlers){
      h.call(data)
    }
  }
}

class EventQueue {

  count { _queue.count  }

  construct new(size){
    _queue = Queue.new(size)
    _handlers = {}
    _debug = false
    _profile = false
  }

  debug=(v) { _debug = v }
  profile=(v) { _profile = v }

  add(event){
    _queue.enqueue(event)
  }

  subscribe(id, handler){
    if(!_handlers.containsKey(id)) _handlers[id] = []
    _handlers[id].add(handler)
  }

  subscribeCombined(ids, handler){
    var count = ids.count
    var ctr = 0
    var ret = List.filled(count, null)
    for(i in 0...count){
      var called = false
      subscribe(ids[i]){|ev|
        if(!called) {
          called = true
          ctr = ctr+1
        }
        ret[i] = ev
        if(ctr == count) handler.call(ret)
      }
    }
  }

  dispatchNext(){
    if(count == 0) return false
    var ev = _queue.dequeue()
    var handlers = _handlers[ev["id"]]
    if(_debug) System.print("EQ: Dispatch '%(ev["id"])'")
    if(handlers){
      for(h in handlers){
        h.call(ev)
      }
    }
    return true
  }
}