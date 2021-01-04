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