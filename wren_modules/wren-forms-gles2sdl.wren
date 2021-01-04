import "wren-nanovg" for NvgContext, NvgImage, NvgColor, NvgFont, CreateFlags 
import "wren-sdl" for SDL, SdlEventType, SdlEvent, SdlHint, SdlGlAttribute, SdlGlProfile, SdlWindow, SdlWindowFlag, SdlGlContext
import "wren-gles2" for ClearFlag, GL, EnableCap, BlendFacDst, BlendFacSrc, ErrorCode
import "wren-forms/resources" for ResourceProvider, ResourceCache
import "wren-forms/events" for UiEvent
import "wren-forms/utils" for ColorUtils
import "wren-forms/application" for FormsApplication
import "shapes" for Rectangle

class NvgFontProvider is ResourceProvider {
  construct new(renderer){
    _ctx = renderer.nvgContext
  }
  create(id){ NvgFont.fromFile(_ctx, id) }
  destroy(font){
    // TODO: implement
    //font.dispose()
  }
}

class NvgColorProvider is ResourceProvider {
  construct new(){}
  // TODO: Support more paints
  create(id){ 
    var color = ColorUtils.parseColor(id) 
    return NvgColor.rgba(color[0], color[1], color[2], color[3])
  }
}

class NvgImageProvider is ResourceProvider {
  construct new(renderer){
    _ctx = renderer.nvgContext
  }
  create(id){ NvgImage.fromFile(id) }
  destroy(image){
    // TODO: implement
    //image.dispose()
  }
}

var SdlEventToName = {
  SdlEventType.Quit : "quit",
  SdlEventType.Terminating : "terminating",
  SdlEventType.Lowmemory : "lowmemory",
  SdlEventType.Willenterbackground : "willenterbackground",
  SdlEventType.Didenterbackground : "didenterbackground",
  SdlEventType.Willenterforeground : "willenterforeground",
  SdlEventType.Didenterforeground : "didenterforeground",
  /* Display Events */
  SdlEventType.Displayevent : "displayevent",
  /* Window Events */
  SdlEventType.Windowevent : "windowevent",
  SdlEventType.Syswmevent : "syswmevent",
  /* Keyboard Events */
  SdlEventType.Keydown : "keydown",
  SdlEventType.Keyup : "keyup",
  SdlEventType.Textediting : "textediting",
  SdlEventType.Textinput : "textinput",
  SdlEventType.Keymapchanged : "keymapchanged",
  /* Mouse Events */
  SdlEventType.Mousemotion : "mousemotion",
  SdlEventType.Mousebuttondown : "mousebuttondown",
  SdlEventType.Mousebuttonup : "mousebuttonup",
  SdlEventType.Mousewheel : "mousewheel",
  /* Joystick Events */
  SdlEventType.Joyaxismotion : "joyaxismotion",
  SdlEventType.Joyballmotion : "joyballmotion",
  SdlEventType.Joyhatmotion : "joyhatmotion",
  SdlEventType.Joybuttondown : "joybuttondown",
  SdlEventType.Joybuttonup : "joybuttonup",
  SdlEventType.Joydeviceadded : "joydeviceadded",
  SdlEventType.Joydeviceremoved : "joydeviceremoved",
  /* Game Controller Events */
  SdlEventType.Controlleraxismotion : "controlleraxismotion",
  SdlEventType.Controllerbuttondown : "controllerbuttondown",
  SdlEventType.Controllerbuttonup : "controllerbuttonup",
  SdlEventType.Controllerdeviceadded : "controllerdeviceadded",
  SdlEventType.Controllerdeviceremoved : "controllerdeviceremoved",
  SdlEventType.Controllerdeviceremapped : "controllerdeviceremapped",
  /* Touch Events */
  SdlEventType.Fingerdown : "fingerdown",
  SdlEventType.Fingerup : "fingerup",
  SdlEventType.Fingermotion : "fingermotion",
  /* Gesture Events */
  SdlEventType.Dollargesture : "dollargesture",
  SdlEventType.Dollarrecord : "dollarrecord",
  SdlEventType.Multigesture : "multigesture",
  /* Clipboard Events */
  SdlEventType.Clipboardupdate : "clipboardupdate",
  /* Drag And Drop Events */
  SdlEventType.Dropfile : "dropfile",
  SdlEventType.Droptext : "droptext",
  SdlEventType.Dropbegin : "dropbegin",
  SdlEventType.Dropcomplete : "dropcomplete",
  /* Audio Hotplug Events */
  SdlEventType.Audiodeviceadded : "audiodeviceadded",
  SdlEventType.Audiodeviceremoved : "audiodeviceremoved",
  /* Sensor Events */
  SdlEventType.Sensorupdate : "sensorupdate",
  /* Render Events */
  SdlEventType.Rendertargetsreset : "rendertargetsreset",
  SdlEventType.Renderdevicereset : "renderdevicereset",
}

class SdlEventSource {
  construct new(){
    _event = SdlEvent.new()
  }

  // public
  poll(){
    // This will skip events not handled by create 
    while(true){
      var success = SDL.pollEvent(_event)
      if(!success) return null
      var formsEvent = create(_event)
      if(formsEvent) return formsEvent
    }
  }

  // private
  create(sdl){
    var name = SdlEventToName[sdl.type]
    if(sdl.type == SdlEventType.Quit){
      return UiEvent.new(name, {})
    }
    if(sdl.type == SdlEventType.Mousemotion){
      return UiEvent.new(name, {
        "x": sdl.motion_x,
        "y": sdl.motion_y,
        "xrel": sdl.motion_xrel,
        "yrel": sdl.motion_yrel,
        "state": sdl.motion_state,
      })
    } else if(sdl.type == SdlEventType.Mousebuttondown || sdl.type == SdlEventType.Mousebuttonup){
      return UiEvent.new(name, {
        "x": sdl.button_x,
        "y": sdl.button_y,
        "button": sdl.button_button,
        "clicks": sdl.button_clicks,
      })
    } else if(sdl.type == SdlEventType.Mousewheel){
      return UiEvent.new(name, {
        "x": sdl.wheel_x,
        "y": sdl.wheel_y,
        "direction": sdl.wheel_direction
      })
    }
  } 
}

class Gles2Window {

  sdlWindow { _win }
  width { _win.width }
  height { _win.height }

  construct new(win, glContext){
    _win = win
    _glContext = glContext
  }

  present(){
    _win.swap()
  }
}

class SdlWindowFactory {

  construct new(){}

  createWindow(w,h,name){
    SDL.setHint(SdlHint.OpenglEsDriver, "1")
    SDL.setAttribute(SdlGlAttribute.ContextMajorVersion, 2)
    SDL.setAttribute(SdlGlAttribute.ContextMinorVersion, 0)
    SDL.setAttribute(SdlGlAttribute.ContextProfileMask, SdlGlProfile.Es)
    SDL.setAttribute(SdlGlAttribute.RedSize, 5)
    SDL.setAttribute(SdlGlAttribute.GreenSize, 6)
    SDL.setAttribute(SdlGlAttribute.BlueSize, 5)
    SDL.setAttribute(SdlGlAttribute.StencilSize, 1)
    _win = SdlWindow.new(w, h, name, SdlWindowFlag.Opengl)
    _glCtx = SdlGlContext.new(_win)
    _win.makeCurrent(_glCtx)
    SDL.setSwapInterval(1)
    return Gles2Window.new(_win, _glCtx)
  }
}

class NanoVgRenderer {

  nvgContext { _ctx }

  construct new(gles2Win){
    _win = gles2Win.sdlWindow
    _ctx = NvgContext.new(CreateFlags.ANTIALIAS)
  }

  beginDraw(){
    GL.clear(ClearFlag.COLOR_BUFFER_BIT | ClearFlag.DEPTH_BUFFER_BIT | ClearFlag.STENCIL_BUFFER_BIT)
    
    GL.enable(EnableCap.BLEND)
    GL.blendFunc(BlendFacDst.SRC_ALPHA, BlendFacDst.ONE_MINUS_SRC_ALPHA)
    GL.enable(EnableCap.CULL_FACE)
    GL.disable(EnableCap.DEPTH_TEST)
    
    _ctx.beginFrame(_win.width, _win.height, 1)
  }

  finishDraw(){
    _ctx.endFrame()
    var err = GL.getError()
      if(err != ErrorCode.NO_ERROR){
        System.print("GL Error:" + err)
    }
  }

  rectangle(rect, fill) { rectangle(rect, fill,null,null) }
  rectangle(rect, fill, stroke, width){
    _ctx.beginPath()
    _ctx.rect(rect.x, rect.y, rect.w, rect.h)
    if(fill){
      fill is NvgColor ? _ctx.fillColor(fill) : _ctx.fillPaint(fill)
      _ctx.fill()
    }
    if(stroke){
      stroke is NvgColor ? _ctx.strokeColor(fill) : null
      _ctx.strokeWidth(width)
      _ctx.stroke()
    }
  }
}

class Gles2SdlHost {
  static use(){ host(FormsApplication.current) }

  static host(app){
    var c = app.container
    c.registerType("FontProvider", NvgFontProvider, ["Renderer"])
    c.registerType("ColorProvider", NvgColorProvider, [])
    c.registerType("ImageProvider", NvgImageProvider, ["Renderer"])
    c.registerType("EventSource", SdlEventSource, []).asSingleton
    c.registerType("WindowFactory", SdlWindowFactory, []).asSingleton
    c.registerType("Renderer", NanoVgRenderer, ["Window"]).asSingleton
  }
}

