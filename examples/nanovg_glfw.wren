import "wren-glfw" for GLFW, Window, WindowHint, GlContextApi, GlApi, Key, Action
import "wren-gles2" for ClearFlag, GL, EnableCap, BlendFacDst, BlendFacSrc, ErrorCode
import "wren-nanovg" for NvgContext, NvgColor, CreateFlags

import "./examples/nvgdemo" for NvgDemo

var WIDTH = 1000
var HEIGHT = 600

var win = Window.new(WIDTH, HEIGHT, "WrenWindow", {
  WindowHint.GLFW_CONTEXT_CREATION_API: GlContextApi.GLFW_EGL_CONTEXT_API,
  WindowHint.GLFW_CLIENT_API: GlApi.GLFW_OPENGL_ES_API,
  WindowHint.GLFW_CONTEXT_VERSION_MAJOR: 2,
  WindowHint.GLFW_CONTEXT_VERSION_MINOR: 0
})

var Blowup = false
var Screenshot = false
var Premult = false

win.keyCallback(Fn.new {|key, scancode, action, mods|
  if(key == Key.GLFW_KEY_ESCAPE && action == Action.GLFW_PRESS) win.shouldClose = true
  if(key == Key.GLFW_KEY_SPACE && (action == Action.GLFW_PRESS || action == Action.GLFW_RELEASE)) Blowup = !Blowup
  if(key == Key.GLFW_KEY_S && action == Action.GLFW_PRESS) Screenshot = true
  if(key == Key.GLFW_KEY_S && action == Action.GLFW_PRESS) Premult = true
})

win.makeContextCurrent()

var ctx = NvgContext.new(CreateFlags.ANTIALIAS)

NvgDemo.loadData(ctx)

GLFW.swapInterval(1)

GLFW.runLoop(Fn.new {
  var t = GLFW.time
  var mpos = win.cursorPos()

  GL.clearColor(0.3, 0.3, 0.32, 1.0)
  GL.clear(ClearFlag.COLOR_BUFFER_BIT | ClearFlag.DEPTH_BUFFER_BIT | ClearFlag.STENCIL_BUFFER_BIT)
  
  GL.enable(EnableCap.BLEND)
  GL.blendFunc(BlendFacDst.SRC_ALPHA, BlendFacDst.ONE_MINUS_SRC_ALPHA)
  GL.enable(EnableCap.CULL_FACE)
  GL.disable(EnableCap.DEPTH_TEST)
  
  ctx.beginFrame(WIDTH, HEIGHT, 1)

  // ctx.beginPath()
  // ctx.rect(100,100, 120,30)
  // ctx.fillColor(NvgColor.rgba(255,192,0,255))
  // ctx.fill()
  
  NvgDemo.renderDemo(ctx, mpos[0], mpos[1], WIDTH, HEIGHT, t, Blowup)
  ctx.endFrame()
  
  GL.enable(EnableCap.DEPTH_TEST)

  //render here
  win.swapBuffers()
  
  var err = GL.getError()
  if(err != ErrorCode.NO_ERROR){
    System.print("GL Error:" + err)
  }
  return !win.shouldClose
})