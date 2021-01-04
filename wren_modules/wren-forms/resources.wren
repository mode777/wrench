import "wren-forms/utils" for ColorUtils

class Resource {

  id { _id }
  
  construct new(type, cache, id, value){
    _cache = cache
    _id = id
    _value = value
    _refCount = 0
    _type = type
  }

  use(){
    _refCount = _refCount+1
    return _value
  }

  release(){
    _refCount = _refCount-1
    if(_refCount == 0) _cache.destroy(_type, _id, _value)
  }
  
}

class ResourceProvider {
  create(id){}
  destroy(value){}
}

class ResourceCache {
  construct new(){
    _providers = {}
    _resources = {}
  }

  registerProvider(type, provider){
    _providers[type] = provider
  }

  acquire(type, id){
    if(!_resources.containsKey(id)){
      var res = _providers[type].create(id)
      _resources[id] = Resource.new(type, this, id, res)
    }
    return _resources[id].use()
  }

  release(id){
    if(!_resources.containsKey(id)) return
    _resources[id].release()    
  }

  destroy(type, id, value){
    _resources.remove(id)
    _providers[type].destroy(value)
  }
}

class SharedResource {
  
  type { _type }
  type=(v) { _type = type }

  construct new(resourceCache){
    _cache = resourceCache
  }

  construct new(resourceCache, type){
    _cache = resourceCache
    _type = type
  }

  get(v){
    if(_uri != v){
      if(_uri) _cache.release(_uri)
      _uri = v  
      _res = _cache.acquire(_type, _uri)
    } 
    return _res
  }

  dispose(){
    if(_res){
      _cache.release(_uri)
    }
  }
}