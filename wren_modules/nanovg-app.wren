import "opengl-app" for OpenGlApplication
import "wren-nanovg" for NvgContext, NvgColor, CreateFlags
import "wren-gles2" for GL, ClearFlag, EnableCap, BlendFacDst

class NanoVgApplication is OpenGlApplication {

  nvgContext { _ctx }

  construct new(){
    super()
    _background = [0,0,0]
  }

  setBackground(r,g,b){
    _background[0] = r
    _background[1] = g
    _background[2] = b
  }

  sdlCreateWindow(){
    super.sdlCreateWindow()
    _ctx = NvgContext.new(CreateFlags.ANTIALIAS)
  }

  draw(){
    super.draw()
    GL.clearColor(_background[0],_background[1], _background[2], 1)
    GL.clear(ClearFlag.COLOR_BUFFER_BIT | ClearFlag.DEPTH_BUFFER_BIT | ClearFlag.STENCIL_BUFFER_BIT)
    
    GL.enable(EnableCap.BLEND)
    GL.blendFunc(BlendFacDst.SRC_ALPHA, BlendFacDst.ONE_MINUS_SRC_ALPHA)
    GL.enable(EnableCap.CULL_FACE)
    GL.disable(EnableCap.DEPTH_TEST)
    
    _ctx.beginFrame(width, height, 1)
    drawFrame(_ctx)
    _ctx.endFrame()

  }

  drawFrame(ctx){

  }
}

