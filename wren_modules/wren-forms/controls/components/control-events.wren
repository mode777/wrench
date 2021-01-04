import "wren-forms/events" for UiEvent
import "wren-forms/utils" for MapUtils

class ControlEvents {
  construct new(control){
    _handlers = {}
    _control = control
    _children = control.controls
    _bounds = control.bounds
  }

  configure(config){
    config.forEach {|k,v|
      addHandler(k,v)
    }
  }
  
  addHandler(ev, fn){
    var list =_handlers[ev] = (_handlers[ev] || [])
    list.add(fn) 
  }

  // Dispatches an event to all the handlers and then bubbles it up the tree
  dispatch(event){
    var list = _handlers[event.type]
    if(list) {
      for(h in list) h.call(event)
    }
    if(event.bubbles && _control.parent) {
      _control.parent.events.dispatch(event)
    }
  }

  // Processes an event down the tree
  capture(ev){
    if(ev.type == "mousebuttondown"){
      handleMouseDown(ev)
    } else if(ev.type == "mousebuttonup"){
      handleMouseUp(ev)
    } else if(ev.type == "mousemotion"){
      handleMouseMotion(ev)
    }
  }

  handleMouseDown(ev){
    propagateToChildren(ev)
    if(!ev.isHandled && _bounds.box.isInside(ev.data["x"], ev.data["y"])){
      _hasMousedown = true
      ev.handle(_control)
      dispatch(ev)
    }
  }

  handleMouseUp(ev){
    propagateToChildren(ev)
    if(!ev.isHandled && _bounds.box.isInside(ev.data["x"], ev.data["y"])){
      if(_hasMousedown){
        var click = UiEvent.new("click", MapUtils.clone(ev.data))
        click.handle(_control)
        dispatch(click)
      }      
      ev.handle(_control)
      dispatch(ev)
    }    
    _hasMousedown = false
  }

  handleMouseMotion(ev){
    propagateToChildren(ev)
    var handledElsewhere = ev.isHandled
    var isInside = _bounds.box.isInside(ev.data["x"], ev.data["y"])

    // handle move event
    if(!handledElsewhere && isInside){
      ev.handle(_control)
      dispatch(ev)
    }
    
    // handle mouse over event
    if(!handledElsewhere && isInside && !_hasMouseOver){
      _hasMouseover = true
      var inEvent = UiEvent.new("mouseover", MapUtils.clone(ev.data))
      inEvent.handle(_control)
      dispatch(inEvent)
    }
    
    // handle mouse out
    if(!isInside && _hasMouseover) {
      var outEvent = UiEvent.new("mouseout", MapUtils.clone(ev.data))
      outEvent.handle(_control)
      dispatch(outEvent)
      _hasMouseover = false
    }
  }

  propagateToChildren(ev){
    for(i in (_children.count)...0){
      _children[i-1].events.capture(ev)
    }
  }

  dispose(){
    _handlers = null
  }
}