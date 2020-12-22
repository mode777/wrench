class Application {
  construct new(){
    _stop = false
    _hooks = []
  }

  run(){
    while(!_stop){ update() }
  }

  update(){
    for(h in _hooks){
      h.call()
    }
  }

  registerUpdate(fn){
    _hooks.add(fn)
  }

  stop(){
    _stop = true
  }
}