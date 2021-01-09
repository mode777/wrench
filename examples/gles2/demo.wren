import "gles2-app" for Gles2Application
import "wren-sdl" for SDL, SdlEventType, SdlKeyCode
import "wren-gles2" for GL, ClearFlag, BufferType, BufferHint, ShaderType, DataType, EnableCap, PrimitveType, ShaderParam, ProgramParam, TextureTarget, TextureParam, TextureWrapMode, TextureMagFilter, TextureMinFilter, TextureUnit, PixelType, PixelFormat, BlendFacSrc, BlendFacDst
import "buffers" for FloatArray, Uint16Array, Uint8Array, Buffer
import "gles2-util" for Gles2Util, VertexAttribute, VertexIndices
import "file" for File
import "shapes" for Rectangle
import "random" for Random
import "super16" for SpriteBuffer, BgLayer, Gfx
import "images" for Image

class MyApp is Gles2Application {
  construct new(){
    super()
    _quit = false
  }

  init(){
    _frameTime = 0
    _frames = 0
    _time = 0
    _r = 0
    _random = Random.new(1986)
    _layersEnb = [true, true, true, true]
    _spritesEnb = true
    _pixelscale = 2
    createWindow(800, 480, "2d Demo")
    setVsync(false)
    Gfx.init()

    subscribe(SdlEventType.Keyup){|ev|
      if(ev.key_sym == SdlKeyCode.Num1) Gfx.pixelScale = 1 //_layersEnb[0] = !_layersEnb[0]
      if(ev.key_sym == SdlKeyCode.Num2) Gfx.pixelScale = 2 //_layersEnb[1] = !_layersEnb[1]
      if(ev.key_sym == SdlKeyCode.Num3) Gfx.pixelScale = 3 //_layersEnb[2] = !_layersEnb[2]
      if(ev.key_sym == SdlKeyCode.Num4) Gfx.pixelScale = 4 //_layersEnb[3] = !_layersEnb[3]
      if(ev.key_sym == SdlKeyCode.Num5) _spritesEnb = !_spritesEnb
      if(ev.key_sym == SdlKeyCode.F) System.print("Frametime %(_frameTime / _frames)ms")
    }

    for(s in Gfx.sprites){
      s.set(16, 16, 16, 0)
      s.prio = 1+_random.int(4)
      s.pos(_random.int(width/2),_random.int(height/2))
    }
  }

  render(){
    Gfx.update()
    Gfx.draw()

    // set layeroffset to -512
    Gfx.bg0.offset(-512, -512)
    Gfx.bg1.offset(-513, -512)
    Gfx.bg2.offset(-513, -513)
    Gfx.bg3.offset(-512, -513)

    _r = _r + 0.05
    // for(s in 1024){
    //   s.rot = _r
    // }
    // var s = (System.clock.sin*2) + 3
    // _sprites.setScale(0, s, s)
    // _x = _x - 2
    // _y = _y - 2
    //_layers.setTranslation(0, _x, _y)
    //_layers.setRotation(0, _r)
  }

  run(){
    init()
    while(!_quit){
      _time = SDL.ticks
      var ev = null
      while(ev = poll()){
        if(ev.type == SdlEventType.Quit) _quit = true
      }
      render()
      checkErrors()
      swap()
      _frames = _frames+1
      _frameTime = _frameTime + SDL.ticks - _time
      if(_frames % 100 == 0){
        System.print("Frametime %(_frameTime / _frames)ms")
      }
    }
  }
}

var app = MyApp.new()
app.run()