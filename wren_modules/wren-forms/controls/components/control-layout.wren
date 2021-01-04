import "wren-forms/layouts" for WrapLayoutStrategy

class ControlLayout {

  children { _children }
  strategy { _strategy }
  strategy=(v) { _strategy = v }

  construct new(control){
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