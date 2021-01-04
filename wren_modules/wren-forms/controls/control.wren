import "wren-forms/controls/components/all" for ControlAttributes, ControlBounds, ControlEvents, ControlLayout, ControlList, ControlRenderer 
import "wren-forms/configuration" for Configuration 
import "wren-forms/default-attributes" for DefaultAttributes 
import "wren-forms/application" for FormsApplication

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

  construct new(){
    _app = FormsApplication.current
    _attributes = createAttributes()
    _attributes.setDefaults(defaultAttributes())
    _bounds = createBounds()
    _events = createEvents()
    _renderer = createRenderer()
    _controls = createList()
    _layout = createLayout()
  }

  createAttributes(){ ControlAttributes.new(this) }
  createBounds(){ ControlBounds.new(this) }
  createEvents(){ ControlEvents.new(this) }
  createRenderer() { ControlRenderer.new(this) }
  createList() { ControlList.new(this) }
  createLayout() { ControlLayout.new(this) }

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

