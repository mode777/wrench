import "wren-sdl" for SDL, SdlWindow, SdlGlContext, SdlWindowFlag, SdlHint, SdlGlAttribute, SdlGlProfile, SdlEvent, SdlEventType
import "wren-gles2" for ClearFlag, GL, EnableCap, BlendFacDst, BlendFacSrc, ErrorCode
import "wren-nanovg" for NvgContext, NvgColor, CreateFlags

class NanovgApp {
  
  width { _w }
  height { _h }
  context { _ctx }
  
  construct new(w, h, title){
    _w = w
    _h = h
    _title = title
    _bgColor = [0.3, 0.3, 0.32, 1.0]
    _event = SdlEvent.new()
    init_()
  }

  init_(){
    SDL.setHint(SdlHint.OpenglEsDriver, "1")
    SDL.setAttribute(SdlGlAttribute.ContextMajorVersion, 2)
    SDL.setAttribute(SdlGlAttribute.ContextMinorVersion, 0)
    SDL.setAttribute(SdlGlAttribute.ContextProfileMask, SdlGlProfile.Es)
    SDL.setAttribute(SdlGlAttribute.RedSize, 5)
    SDL.setAttribute(SdlGlAttribute.GreenSize, 6)
    SDL.setAttribute(SdlGlAttribute.BlueSize, 5)
    SDL.setAttribute(SdlGlAttribute.StencilSize, 1)

    _win = SdlWindow.new(_w, _h, _title, SdlWindowFlag.Opengl|SdlWindowFlag.Shown|SdlWindowFlag.Resizable)
    _glCtx = SdlGlContext.new(_win)
    _win.makeCurrent(_glCtx)
    SDL.setSwapInterval(1)

    _ctx = NvgContext.new(CreateFlags.ANTIALIAS)

    SDL.runLoop { 
      return this.update_() 
    }
  }

  update_(){
    while(SDL.pollEvent(_event)){
      if(_event.type == SdlEventType.Keydown || _event.type == SdlEventType.Keyup){
        onKey(_event.key_sym, _event.type == SdlEventType.Keyup)
      }
      if(_event.type == SdlEventType.Mousebuttondown){
        System.print(_event.mouse_x)
      }
    }

    var t = SDL.ticks / 1000

    GL.clearColor(_bgColor[0],_bgColor[1], _bgColor[2], _bgColor[3])
    GL.clear(ClearFlag.COLOR_BUFFER_BIT | ClearFlag.DEPTH_BUFFER_BIT | ClearFlag.STENCIL_BUFFER_BIT)
    
    GL.enable(EnableCap.BLEND)
    GL.blendFunc(BlendFacDst.SRC_ALPHA, BlendFacDst.ONE_MINUS_SRC_ALPHA)
    GL.enable(EnableCap.CULL_FACE)
    GL.disable(EnableCap.DEPTH_TEST)
    
    _ctx.beginFrame(_w, _h, 1)

    update(_ctx)

    _ctx.endFrame()
    
    GL.enable(EnableCap.DEPTH_TEST)
    _win.swap()
    
    var err = GL.getError()
    if(err != ErrorCode.NO_ERROR){
      System.print("GL Error:" + err)
    }

    return _event.type != SdlEventType.Quit
  }

  update(ctx){

  }

  onKey(sym, isUp){

  }
}

