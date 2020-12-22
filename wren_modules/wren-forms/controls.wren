import "wren-forms/utils" for Guard
import "wren-nanovg" for NvgColor, NvgImage, NvgPaint, Winding, NvgFont, TextAlign, NvgContext

class AbstractResource {
  
  path { _path }
  isUsed { _refCount > 0 }
  resource { _obj }

  construct new(path){
    _path = path
    _refCount = 1
    _obj = create()
  }

  acquire(){
    _refCount = _refCount+1
    return _obj
  }

  release(){
    _refCount = _refCount-1
    if(_refCount < 1) dispose()
  }

  // abstract
  dispose(){}
  create(){}
}

class AbstractResourceCache {
  construct new(){
    _resources = {}
  }

  acquire(uri){
    if(_resources.containsKey(uri)) return _resources[uri].resource
    var split = uri.split("::")
    var res = createResource(split[0], split[1])
    _resources[uri] = res
    return res.resource
  }

  release(uri){
    if(!_resources.containsKey(uri)) return
    _resources[uri].release()    
  }

  // abstract
  createResource(type, path){}
}

class ResourceCache is AbstractResourceCache {
  construct new(app){
    Guard.againstNull(app, "FormsApplication")
    super()
    _app = app
  }

  nvgContext { _ctx || (_ctx = _app.resolve(NvgContext)) }

  createResource(type, path){
    if(type == "image") return ImageResource.new(path, nvgContext)
    if(type == "font") return FontResource.new(path, nvgContext)
    Fiber.abort("Unknown resource type %(type)")
  }
}

class ImageResource is AbstractResource {
  construct new(file, ctx){
    _ctx = ctx
    super(file)
  }

  create(){
    return NvgImage.fromFile(_ctx, path)
  }

  dispose(){
    // TODO
  }
}

class FontResource is AbstractResource {
  construct new(file, ctx){
    Guard.againstNull(ctx, "NvgContext")
    _ctx = ctx
    super(file)
  }

  create(){
    return NvgFont.fromFile(_ctx, path)
  }

  dispose(){
    // todo
  }
}

class Renderer {
  construct new(NvgContext){}

}

class VisualStyle {

  construct new(map, inherit){
    _styles = {}
    for(kv in map){
      _styles[kv.key] = kv.value
    }
    _inherit = inherit || _styles 
  }

  [key] { _styles.containsKey(key) ? _styles[key] : _inherit[key] }
  [key]=(v) { _styles[key] = v }
}

class DefaultStyles {

  base { _styleBase }
  flowLayout { _flowLayout }
  button { _button }

  construct new(){
    // var fontIcons = NvgFont.fromFile(ctx, "./examples/podcast_player/res/entypo.ttf")
    // var font = NvgFont.fromFile(ctx, "./examples/podcast_player/res/Roboto-Regular.ttf")
    // var fontBold = NvgFont.fromFile(ctx, "./examples/podcast_player/res/Roboto-Bold.ttf")
    // var fontEmoji = NvgFont.fromFile(ctx, "./examples/podcast_player/res/NotoEmoji-Regular.ttf")
    // ctx.fallbackFont(font, fontEmoji)
    // ctx.fallbackFont(fontBold, fontEmoji)

    _styleBase = VisualStyle.new({
      "font": "font::./examples/podcast_player/res/Roboto-Regular.ttf",
      "foreground": NvgColor.rgba(0,0,0,255),
      "padding": [0, 0],
      "font-size": 12
    }, null)
    _flowLayout = VisualStyle.new({
      "spacing": 20
    }, _styleBase)
    _button = VisualStyle.new({
      "size": [75,23],
      "padding": [10, 10],
      "background": NvgColor.rgba(128,128,128,255)
    }, _styleBase)
  }
}

class BindingBase {
  
  control { _control }
  dataSource { _dataSource }
  dataSource=(v) { _dataSource = v }

  construct new(control){
    _control = control
  }

  configure(config){
    configureProp(config, "source") {|src| dataSource = src }
  }

  configureProp(config, key, fn){
    var val = config[key]
    if(val != null) fn.call(config[key])
  }
  
}

class ListBinding is BindingBase {

  construct new(control){
    super(control)
    _onAdd = Fn.new { |key| onSourceAdd(dataSource.find(key))  }
    _onRemove = Fn.new { |key| onSourceRemove(dataSource.find(key))  }
    _elementConfig = {}
  }

  configure(config){
    configureProp(config, "element") {|e|
      configureProp(e, "control") {|c| elementClass = c }
      configureProp(e, "config") {|c| elementConfig = c }
    }    
    super.configure(config)
  }

  elementClass=(v) {
    _elementClass = v
  }

  elementConfig=(v){
    _elementConfig.clear()
    for(kv in v){
      _elementConfig[kv.key] = kv.value
    }
  } 

  dataSource=(v) {
    control.controls.clear()
    if(dataSource){
      dataSource.onAdd.unsubscribe(_onAdd)
      dataSource.onRemove.unsubscribe(_onRemove)
      for(e in dataSource){
        onSourceRemove(e)
      }
    }
    super.dataSource = v 
    if(v == null) return
    v.onAdd.subscribe(_onAdd)
    v.onRemove.subscribe(_onRemove)
    for(e in v){
      onSourceAdd(e)
    }
  }

  createElement(elClass){
    if(!elClass) return null 
    return control.application.resolve(elClass)
  }

  onSourceAdd(element){
    var el = createElement(_elementClass)
    if(!el) return
    // add binding to element config
    var config = {}
    for(kv in _elementConfig){ config[kv.key] = kv.value }
    var bindingConfig = config["binding"] = (config["binding"] || {})
    bindingConfig["source"] = element
    el.configure(_elementConfig)
    control.onBindingAdd(el)
  }

  onSourceRemove(element){
    for(c in constrol.controls){
      if(c.dataSource == element){
        control.onBindingRemove(c)
        break
      }
    }
  }
}

class ModelBinding is BindingBase {

  construct new(control){
    super(control)
    _onChange = Fn.new { |key| onChange(key, dataSource[key]) }
    _modelToProp = {}
    _propToModel = {}
  }
  
  configure(config){
    super.configureProp(config, "properties") {|v|
      for(kv in v){
        _propToModel[kv.key] = kv.value
        _modelToProp[kv.value] = kv.key
      }
    }
    super.configure(config)
  }
  
  dataSource=(v) {
    if(dataSource){
      dataSource.onChange.unsubscribe(_onChange)
      for(k in dataSource.keys){
        onChange(k, null)
      }
    }
    super.dataSource = v 
    if(v == null) return
    v.onChange.subscribe(_onChange)
    for(k in v.keys){
      onChange(k, v[k])
    }
  }

  onChange(key, value){
    if(_modelToProp[key]){
      control.onBindingChange(_modelToProp[key], value)
    }
  }
}



class ControlList is Sequence {

  count { _list.count }

  construct new(owner){
    _owner = owner
    _list = []
  }

  add(c){
    _list.add(c)
    if(c.owner_){ c.owner_.controls.remove(c) }
    c.owner_ = _owner
  }

  remove(c){
    var idx = -1
    for(i in 0..._list.count){  
      if(_list[i] == c){
        idx = i
        break
      }
    }
    if(idx != -1){
      c.owner_ = null
      _list.removeAt(idx)
    }
  }

  clear(){
    for(c in _list){
      c.owner_ = null
    }
    _list.clear()
  }

  iterate(val) { _list.iterate(val) }
  iteratorValue(i) { _list.iteratorValue(i) }
  [i] { _list[i] }
}

class SharedResource {
  
  construct new(resourceCache, acquireFn){
    _cache = resourceCache
    _changed = true
    _fn = acquireFn
  }

  uri { _uri }
  uri=(v){
    if(_uri != v){
      if(_uri) _cache.release(_uri)
      _uri = v  
      _res = null   
      _changed = true
    }
  }

  resource {
    uri = _fn.call()
    if(_changed){
      if(!uri) Fiber.abort("Resource not available")
      _res = _cache.acquire(uri)
      _changed = false
    }
    return _res
  }

  release(){
    if(_res){
      _cache.release(_uri)
    }
  }
}

class Control {

  size { _size }
  size=(v) { 
    _size[0] = v[0]
    _size[1] = v[1]
  }
  position { _pos }
  position=(v){
    _pos[0] = v[0]
    _pos[1] = v[1]
  }
  controls { _controls }
  owner_ { _owner }
  owner_=(v) { _owner = v }
  visualStyle { _visualStyle }
  visualStyle=(v) { _visualStyle = v }
  name { _name }
  name=(v) { _name = v }
  application { _app }

  font { _fontResource.uri }
  font=(v) { _fontResource.uri = v }
  fontResource { _fontResource.resource }

  backgroundImage { _backgroundImageResource.uri }
  backgroundImage=(v) { _backgroundImageResource.uri = v }
  backgroundImageResource { _backgroundImageResource.resource }

  construct new(app){
    _app = app
    _size = [0,0]
    _pos = [0,0]
    _controls = ControlList.new(this)
    _owner = null
    var cache = app.resolve(ResourceCache)
    _visualStyle = app.resolve(DefaultStyles).base
    _fontResource = SharedResource.new(cache) { _visualStyle["font"] }
    _backgroundImageResource = SharedResource.new(cache) { _visualStyle["background-image"] }
  }

  configure(conf){
    configureProp(conf, "size"){|v| size = v }
    configureProp(conf, "position"){|v| position = v }
    configureProp(conf, "visualStyle"){|v|
    if(v is Map) v = VisualStyle.new(v, _visualStyle)
      _visualStyle = v
    }
  }

  configureProp(config, key, fn){
    var val = config[key]
    if(val != null) fn.call(config[key])
  }

  handleEvent(ev){

  }

  paint(ctx){}


  dispose(){}
}

class Form is Control {
  construct new(app){
    super(app)
  }

  paint(ctx){
    for(c in controls){
      c.paint(ctx)
    }
  }

}

class CollectionControl is Control {

  construct new(app){
    super(app)
  }

  configure(config){
    super.configure(config)
    configureProp(config, "binding"){|cfg|
      _binding = ListBinding.new(this)
      _binding.configure(cfg)
    }
  }

  paint(ctx){
    for(c in controls){
      c.paint(ctx)
    }
  }

  onBindingAdd(element){
    controls.add(element)
  }

  onBindingRemove(element){
    controls.remove(element)
  }
}

class FlowLayout is CollectionControl {
    
  construct new(app){
    super(app)
    visualStyle = app.resolve(DefaultStyles).flowLayout
  }

  onBindingAdd(element){
    super.onBindingAdd(element)
    performLayout()
  }

  onBindingRemove(element){
    super.onBindingRemove(element)
    performLayout()
  }

  performLayout(){
    var gap = visualStyle["spacing"]
    var x = position[0] + gap 
    var y = position[1] + gap
    var xend = x + size[0]
    
    for(c in controls){
      var exend = x + c.size[0]
      var eyend = y + c.size[1]
      if(exend > xend){
        x = position[0] + gap 
        y = eyend+gap 
      }
      c.position = [x,y]
      x = x + c.size[0] + gap      
    }
  }
}

class BindableControl is Control {
  construct new(app){
    super(app)
  }

  configure(config){
    super.configure(config)
    configureProp(config, "binding"){|cfg|
      _binding = ModelBinding.new(this)
      _binding.configure(cfg)
    }
  }

  onBindingChange(key, value){

  }
}

class Label is BindableControl {
  construct new(app){
    super(app)
    visualStyle = app.resolve(DefaultStyles).base
  }

  text=(v) { _text = v }
  text { _text }

  onBindingChange(key, value){
    super.onBindingChange(key, value)
    if(key == "text") text = value 
  }
}

class Button is BindableControl {
  construct new(app){
    super(app)
    visualStyle = app.resolve(DefaultStyles).button
  }

  text=(v) { _text = v }
  text { _text }

  onBindingChange(key, value){
    super.onBindingChange(key, value)
    if(key == "text") text = value 
    if(key == "background-image") visualStyle["background-image"] = "image::%(value)"
    //if(key == "background-image") 
  }

  paint(ctx){
    ctx.beginPath()
    if(visualStyle["borderRadius"] && visualStyle["borderRadius"] != 0){
      ctx.roundedRect(position[0],position[1], size[0], size[1], visualStyle["borderRadius"])
    } else {
      ctx.rect(position[0],position[1], size[0], size[1])
    }
    if(visualStyle["background-image"]){
      var imgPaint = NvgPaint.imagePattern(ctx, position[0],position[1],size[0],size[1], 0, backgroundImageResource, 1)
      ctx.fillPaint(imgPaint)
    } else {
      ctx.fillColor(visualStyle["background"])
    }
    ctx.fill()
    if(text){
      ctx.fontFace(fontResource)
      ctx.fontSize(visualStyle["font-size"])
      ctx.fillColor(visualStyle["foreground"])
      ctx.textBox(position[0]+visualStyle["padding"][0], position[1]+visualStyle["padding"][1], size[0], text)
    }
  }

  dispose(){
    // TODO: Dispose image
  }
}