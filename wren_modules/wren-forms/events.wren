class UiEvent {
  
  isHandled { _handled == true }
  target { _target }
  type { _type }
  data { _data }
  bubbles { _bubbles }
  bubbles=(v) { _bubbles = v  }

  construct new(type, data){
    _type = type
    _data = data
    _bubbles = true
  }

  handle(target){
    _target = target
    _handled = true
  } 

  stopPropagation(){ _handled = true }
}

