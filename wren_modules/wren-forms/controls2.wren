import "events" for Event
import "observables" for ObservableMap, ObservableCollection
import "shapes" for Rectangle
import "wren-sdl" for SdlEventType
import "wren-forms/utils" for MapUtils
import "wren-forms/resources" for SharedResource
import "wren-forms/default-attributes" for DefaultAttributes
import "wren-forms/events" for UiEvent

class Configuration {
  construct new(map){
    _map = map
  }

  property(key, fn){
    var val = _map[key]
    if(val == null) return
    if(val is Map) val = Configuration.new(val)
    fn.call(val)
  }

  forEach(fn){
    for(kv in _map){
      fn.call(kv.key, kv.value)
    }
  }
}

class ControlAttributes is ObservableMap {
  
  construct new(){
    super({})
    _defaults = {}
  }

  attach(control){
    _control = control
  }

  setDefaults(inherited){
    _defaults = inherited
  }

  configure(config){
    config.forEach {|k,v|
      this[k] = v
    }
  }

  [i] { containsKey(i) ? super.get(i) : _defaults[i] }

  dispose(){}
}

class ControlEvents {
  construct new(){
    _handlers = {}
  }

  attach(control){
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

class ControlBounds {
  
  outer { _outer }
  inner { _inner }
  box { _box }

  pos { _attributes["position"] }
  size { _attributes["size"] }
  padding { _attributes["padding"] }
  margin { _attributes["margin"] }

  construct new(){
    _outer = Rectangle.new()
    _inner = Rectangle.new()
    _box = Rectangle.new()
  }

  attach(control){
    _control = control 
    _attributes = _control.attributes
    update()
  }

  update(){
    _outer.set(pos[0]-margin[0], pos[1]-margin[0], size[0]+margin[0]*2, size[1]+margin[1]*2)
    _inner.set(pos[0]+padding[0], pos[1]+padding[1], size[0]-padding[0]*2, size[0]-padding[0]*2)
    _box.set(pos[0], pos[1], size[0], size[1])
  }

  configure(config){}

  dispose(){}

}

class ControlRenderer {

  background { _background.get(_attributes["background-color"]) }
  foreground { _background.get(_attributes["foreground-color"]) }

  construct new(){}

  attach(control){
    _control = control
    _ctx = control.application.nvgContext
    _bounds = control.bounds
    _attributes = control.attributes
    _children = control.controls
    
    var fontCache = control.application.fontCache
    var colorCache = control.application.colorCache
    var imageCache = control.application.imageCache

    _font = SharedResource.new(fontCache)
    _backgroundImage = SharedResource.new(imageCache)
    _foreground = SharedResource.new(colorCache)
    _background = SharedResource.new(colorCache)
  }

  configure(config){}

  render(){
    var box = _bounds.box
    _ctx.beginPath()
    _ctx.fillColor(background)
    _ctx.rect(box[0], box[1], box[2], box[3])
    _ctx.fill()

    for(c in _children){
      c.render()
    }
  }

  dispose(){
    _font.dispose()
    _backgroundImage.dispose()
    _foreground.dispose()
    _background.dispose()
  }
}

class ControlList is ObservableCollection {

  construct new(){
    super()
  }

  attach(control){
    _control = control
    _list = []
  }

  configure(config){}

  add(c){
    super.add(c)
    if(c.parent){ c.parent.controls.remove(c) }
    c.parent = _control
    _control.layout.perform()
  }

  remove(c){
    var count = super.remove(c)
    if(count > 0){
      c.parent = null
    }
    _control.layout.perform()
  }

  clear(){
    for(c in this){
      c.parent = null
    }
    super.clear()
  }

  dispose(){}
}

class WrapLayoutStrategy {
  static perform(controls, innerBox, params){
    var gap = params["space-between"] || 0
    var height = 0
    var x = innerBox.x + gap 
    var y = innerBox.y + gap
    var xend = innerBox.right + gap
    for(c in controls){
      var exend = x + c.bounds.outer.w
      var eyend = y + c.bounds.outer.h
      height = eyend > height ? eyend : height
      if(exend > xend){
        x = innerBox.x + gap 
        y = height+gap
        height = 0 
      }
      c.attributes["position"] = [x,y]
      x = x + c.bounds.outer.w + gap
      c.bounds.update()
    }
  }
}

class ControlLayout {

  children { _children }
  strategy { _strategy }
  strategy=(v) { _strategy = v }

  construct new(){}

  attach(control){
    _control = control
    _children = control.controls
    _bounds = control.bounds
    _attributes = control.attributes
    _attributes.onChange {|k| 
      if(k == "size" || k == "margin" || k == "padding") onChanged()
    }
  }

  configure(config){
    config.property("strategy"){|s|
      if(s is String){
        if(s == "wrap") _strategy = WrapLayoutStrategy
      } else {
        _strategy = s
      }
    }
  }

  perform(){
    if(_strategy) _strategy.perform(_children, _bounds.inner, _attributes)
    for(c in _children){
      c.layout.perform()
    }
  }

  onChanged(){
    _bounds.update()
    if(_control.parent){
      _control.parent.layout.perform()
    } 
  }

  dispose(){}
}

class Control {
  
  application { _app }
  bounds { _bounds }
  events { _events }
  renderer { _renderer }
  attributes { _attributes }
  controls { _controls }
  layout { _layout }
  parent { _parent }
  parent=(v) { _parent = v }

  construct new(app, components){
    _app = app
    _attributes = components["attributes"] || createAttributes()
    _attributes.setDefaults(components["defaults"] || DefaultAttributes)
    _bounds = components["bounds"] || createBounds()
    _events = components["events"] || createEvents()
    _renderer = components["render"] || createRenderer()
    _controls = components["controls"] || createList()
    _layout = components["layout"] || createLayout()
    _attributes.attach(this)
    _bounds.attach(this)
    _events.attach(this)
    _renderer.attach(this)
    _controls.attach(this)
    _layout.attach(this)
  }

  createAttributes(){ ControlAttributes.new() }
  createBounds(){ ControlBounds.new() }
  createEvents(){ ControlEvents.new() }
  createRenderer() { ControlRenderer.new() }
  createList() { ControlList.new() }
  createLayout() { ControlLayout.new() }

  defaultAttributes(){ DefaultAttributes }

  configure(map){
    var conf = Configuration.new(map)
    conf.property("attributes"){ |v| _attributes.configure(v) } 
    conf.property("events"){ |v| _events.configure(v) } 
    conf.property("bounds"){ |v| _bounds.configure(v) } 
    conf.property("render"){ |v| _renderer.configure(v) } 
    conf.property("controls"){ |v| _controls.configure(v) } 
    conf.property("layout"){ |v| _layout.configure(v) } 
  }

  dispose(){
    _attributes.dispose()
    _bounds.dispose()
    _events.dispose()
    _renderer.dispose()
    _controls.dispose()
    _layout.dispose()
  }
}