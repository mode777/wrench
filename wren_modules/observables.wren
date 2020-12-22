import "events" for Event

class ObservableMap {

  data_ { _obj }

  onChange { _change }
  onChange(fn) { _change.subscribe(fn) }

  keys { _obj.keys }
  containsKey(k) { _obj.containsKey(k) }

  construct new(obj){
    _obj = obj
    _change = Event.new()
  }

  construct new(){
    _obj = {}
    _change = Event.new()
  }

  get(i) { _obj[i] }
  set(i,v) {
    _obj[i] = v
    onChange.dispatch(i)
  }

  [i] { _obj[i] }

  [i]=(v) {
    _obj[i] = v
    onChange.dispatch(i)
  }
}

class ObservableCollection is Sequence {

  onAdd { _onAdd }
  onAdd(fn) { _onAdd.subscribe(fn) }

  onRemove { _onRemove }
  onRemove(fn) { _onRemove.subscribe(fn) }

  count { _list.count }
  
  construct new(list){
    _list = list
    init_()
  }

  construct new(){
    _list = []
    init_()
  }

  init_(){
    _onAdd = Event.new()
    _onRemove = Event.new()
  }

  add(item){
    _list.add(item)
    _onAdd.dispatch(item)
  }

  remove(item){
    var count = 0
    while(true){
      var idx = _list.indexOf(item)
      if(idx == -1) return count
      _list.removeAt(idx)
      _onRemove.dispatch(item)
      count = count + 1
    }
  }

  clear(){
    for(item in _list){
      _onRemove.dispatch(item)
    }
    _list.clear()
  }

  contains(item){ _list.indexOf(item) != -1 }

  iterate(val) { _list.iterate(val)  }
  iteratorValue(i) { _list.iteratorValue(i) }
  [i] { _list[i] }
}

class DataSource is ObservableCollection {

  construct new(key){
    super()
    _id = key
    _index = {}
  }

  construct new(list, key){
    super(list)
    _id = key
    _index = {}
    buildIndex()
  }

  key { _id }

  buildIndex(){
    for(item in _list){
      _index[item[_id]] = item 
    }
  }

  find(id){ _index[id] }

  add(item){
    if(_index.containsKey(item[_id])) return
    _index[item[_id]] = item 
    super.add(item)
  }

  remove(item){
    var count = super.remove(item)
    if(count == 0) return count
    _index.remove(item[_id])
    return count
  }

  removeById(id){
    if(!_index.containsKey(id)) return
    var item = find(id)
    _index.remove(id)
    super.remove(item)
  }

  contains(item){ _index.containsKey(item[_id]) }

  clear(){
    super.clear()
    _index = {}
  }

  [key] { find(key) }
}