import "nanovg-app" for NanoVgApplication
import "containers" for Container
import "application" for Application
import "wren-nanovg" for NvgContext

import "wren-forms/controls" for FlowLayout, Button, Label, ResourceCache, DefaultStyles
import "wren-forms/resources" for /*ResourceCache,*/ ImageProvider, FontProvider, ColorProvider
import "wren-forms/rendering" for Renderer
import "wren-forms/sdl" for SdlEventFactory

class FormsApplication is NanoVgApplication {

  container { _container }
  imageCache { _imageCache }
  colorCache { _colorCache }
  fontCache { _fontCache }

  construct new(w, h, name){
    super()
    createWindow(w, h, name)
    _container = Container.new()    
    compose(_container)
  }

  compose(c){
    c.registerType(FontProvider, [NvgContext])
    c.registerType(PaintProvider, [NvgContext])
    c.registerType(ImageProvider, [NvgContext])
    c.registerType(Renderer, [NvgContext])
    
    c.registerType("FontCache", ResourceCache, [FontProvider]).asSingleton
    c.registerType("ColorCache", ResourceCache, [ColorProvider]).asSingleton
    c.registerType("ImageCache", ResourceCache, [ImageProvider]).asSingleton
    c.registerType("EventFactory", SdlEventFactory)

    c.registerInstance(Application, this)
    c.registerInstance(FormsApplication, this)
    c.registerInstance(NvgContext, nvgContext)
  }

  handleEvent(sdl){
    super.handleEvent(sdl)
    var ev = _eventFactory.create(sdl)
    _mainForm.captureEvent(ev)
  }

  drawFrame(ctx){
    super.drawFrame(ctx)
    _mainForm.paint(ctx)
  }

  run(formClass){
    _fontCache = resolve("FontCache")
    _imageCache = resolve("ImageCache")
    _colorCache = resolve("ColorCache")

    _eventFactory = resolve("EventFactory")

    _mainForm = _container.resolve(formClass)
    _mainForm.init()
    run()
  }

  resolve(type){ _container.resolve(type) }
}