import "collections" for Queue

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
    var handlers = _handlers[ev[0]]
    if(_debug) System.print("EQ: Dispatch '%(ev[0])'")
    if(handlers){
      for(h in handlers){
        h.call(ev)
      }
    }
    return true
  }
}