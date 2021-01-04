import "wren-forms/configuration" for Configuration
import "wren-forms/resources" for ResourceCache
import "containers" for Container

class FormsApplication {

  static current { __instance }
  static initSingleton_() { __instance = FormsApplication.new() }
  static runLoop(form) { 
    __instance.run(form) 
    while(!__instance.shouldQuit){
      __instance.update()
    }
  }
  
  container { _container }
  resourceCache { _resourceCache }
  form { _form }
  eventSource { _eventSource }
  renderer { _renderer }
  window { _window }
  shouldQuit { _quit }
  isRunning { _running }

  construct new(){
    _container = Container.new()
    compose(_container)
  }

  compose(c){
    c.registerInstance(FormsApplication, this)
    c.registerType(ResourceCache)
  }

  run(form){
    _form = form
    _form.attach(this)
    var winFac = resolve("WindowFactory")
    _window = winFac.createWindow(800,480, "MyApp") 
    _container.registerInstance("Window", _window)
    _renderer = resolve("Renderer")
    _eventSource = resolve("EventSource")
    _resourceCache = resolve(ResourceCache)
    _resourceCache.registerProvider("color", resolve("ColorProvider"))
    _resourceCache.registerProvider("font", resolve("FontProvider"))
    _resourceCache.registerProvider("image", resolve("ImageProvider"))

    _quit = false

    _form.attributes["size"] = [_window.width, _window.height]
    _form.layout.perform()

    _running = true
  }

  update(){
    if(!_running) return

    var event = null
    while(event = _eventSource.poll()){
      _form.events.capture(event)
      _quit = _quit || event.type == "quit"
    }
    _renderer.beginDraw()
    _form.renderer.render(_renderer)
    _renderer.finishDraw()
    _window.present()
  }

  resolve(type){ _container.resolve(type) }
}

FormsApplication.initSingleton_()