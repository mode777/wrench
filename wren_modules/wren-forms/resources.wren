import "wren-nanovg" for NvgFont, NvgColor, NvgImage
import "wren-forms/utils" for ColorUtils

class Resource {

  id { _id }
  
  construct new(cache, id, value){
    _cache = cache
    _id = id
    _value = value
    _refCount = 0
  }

  use(){
    _refCount = _refCount+1
    return _value
  }

  release(){
    _refCount = _refCount-1
    if(_refCount == 0) _cache.destroy(_id, _value)
  }
  
}

class ResourceProvider {
  create(id){}
  destroy(value){}
}

class ResourceCache {
  construct new(provider){
    _provider = provider
    _resources = {}
  }

  acquire(id){
    if(!_resources.containsKey(id)){
      var res = _provider.create(id)
      _resources[id] = Resource.new(this, id, res)
    }
    return _resources[id].use()
  }

  release(id){
    if(!_resources.containsKey(id)) return
    _resources[id].release()    
  }

  destroy(id, value){
    _resources.remove(id)
    _provider.destroy(value)
  }
}

class FontProvider is ResourceProvider {
  construct new(ctx){
    _ctx = ctx
  }
  create(id){ NvgFont.fromFile(id) }
  destroy(font){
    // TODO: implement
    //font.dispose()
  }
}

class ColorProvider is ResourceProvider {
  construct new(){}
  // TODO: Support more paints
  create(id){ ColorUtils.parseColor(id) }
}

class ImageProvider is ResourceProvider {
  create(id){ NvgImage.fromFile(id) }
  destroy(image){
    // TODO: implement
    //image.dispose()
  }
}

class SharedResource {
  
  construct new(resourceCache){
    _cache = resourceCache
  }

  get(v){
    if(_uri != v){
      if(_uri) _cache.release(_uri)
      _uri = v  
      _res = _cache.acquire(_uri)
    } 
    return _res
  }

  dispose(){
    if(_res){
      _cache.release(_uri)
    }
  }
}