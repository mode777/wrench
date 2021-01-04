import "observables" for ObservableCollection

class ControlList is ObservableCollection {

  construct new(control){
    super()
    _control = control
    _list = []
  }

  configure(config){}

  add(c){
    super.add(c)
    if(c.parent){ c.parent.controls.remove(c) }
    c.parent = _control
    c.attach(_control.application)
    _control.layout.perform()
  }

  remove(c){
    var count = super.remove(c)
    if(count > 0){
      c.parent = null
    }
    if(c.isAttached){ c.detach() }
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