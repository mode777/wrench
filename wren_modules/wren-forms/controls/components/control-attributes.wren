import "observables" for ObservableMap

class ControlAttributes is ObservableMap {
  
  construct new(control){
    super({})
    _defaults = {}
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