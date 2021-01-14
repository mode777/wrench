import "wren-gles2" for GL, ClearFlag, BufferType, BufferHint, ShaderType, DataType, EnableCap, PrimitveType, ShaderParam, ProgramParam, TextureTarget, TextureParam, TextureWrapMode, TextureMagFilter, TextureMinFilter, TextureUnit, PixelType, PixelFormat, BlendFacSrc, BlendFacDst, FramebufferTarget, FramebufferAttachment, FramebufferStatus
import "images" for Image
import "buffers" for FloatArray, Uint16Array, Uint8Array, Buffer
import "gles2-util" for Gles2Util, VertexAttribute, VertexIndices 
import "file" for File
import "gles2-app" for Gles2Application
import "wren-sdl" for SDL, SdlEventType, SdlKeyCode

class Time {
}

class Input {
  static a { SDL.isKeyDown(SdlKeyCode.A) }
  static b { SDL.isKeyDown(SdlKeyCode.S) }
  static x { SDL.isKeyDown(SdlKeyCode.Y) }
  static y { SDL.isKeyDown(SdlKeyCode.X) }
  static start { SDL.isKeyDown(SdlKeyCode.Return) }
  static select { SDL.isKeyDown(SdlKeyCode.Space) }
  static left { SDL.isKeyDown(SdlKeyCode.Left) }
  static right { SDL.isKeyDown(SdlKeyCode.Right) }
  static up { SDL.isKeyDown(SdlKeyCode.Up) }
  static down { SDL.isKeyDown(SdlKeyCode.Down) }
}

class Sub {
  static running { __subs.count }
  
  static wait(loops){
    if(loops == 0) return Fiber.yield()
    var c = 0
    while(c < loops){
      c = c+1
      Fiber.yield()
    }
  }
  static step() { Fiber.yield() }

  static init(){
    __subs = []
    __delete = []
  }

  static update(){
    for(i in 0...__subs.count){
      __subs[i].call()
      if(__subs[i].isDone) __delete.add(i)
    }
    for(i in __delete){
      __subs.removeAt(i)
    }
    __delete.clear()
  }
  
  static run(fn) {
    var f = Fiber.new(fn)
    __subs.add(f)
  }
}

class Super16 {
  static app { __app }
  static init(fn){ Super16.init({}, fn) }
  static time { SDL.ticks }
  
  static init(options, fn){
    __app = Gles2Application.new()
    __app.createWindow(800, 480, "Super16")
    __app.setVsync(true)
    Sub.init()
    Gfx.init(options)
    fn.call()
  }

  static run() { Super16.run(null) }

  static run(fn){
    __quit = false
    __frames = 0
    __frameTime = 0

    if(fn){
      Sub.run {
        while(true){
          fn.call()
          Fiber.yield()
        }
      }
    }

    while(!__quit && Sub.running > 0){
      __time = SDL.ticks
      var ev = null
      while(ev = __app.poll()){
        if(ev.type == SdlEventType.Quit) __quit = true
      }
      Gfx.update()
      Gfx.draw()
      Sub.update()
      __app.swap()
      __app.checkErrors()
      
      // var passed = SDL.ticks - __time
      // if(passed < 33.33){
      //   SDL.delay(33.33-passed)
      // }
      __frames = __frames+1
      __frameTime = __frameTime + SDL.ticks - __time
      if(__frames == 100){
        System.print("Frametime %(__frameTime / 100)ms")
        __frames = 0
        __frameTime = 0
      }
    }
  }

}

class Gfx {

  static layerShader { __layerShader } 
  static spriteShader { __spriteShader } 
  static pixelScale { __pixelscale }
  static pixelScale=(v) { __pixelscale=v }
  static spriteBuffer { __spriteBuffer }
  static layerBuffer { __layerBuffer }
  static sprites { __sprites }
  static layers { __layers }
  static bg0 { __bg0 }
  static bg1 { __bg1 }
  static bg2 { __bg2 }
  static bg3 { __bg3 }
  static width { Super16.app.width }
  static height { Super16.app.height }
  static tid(x,y) { (y<<8) | x }


  static vram(x,y,img){
    GL.texSubImage2D(TextureTarget.TEXTURE_2D, 0, 0, 0, img.width, img.height, PixelFormat.RGBA, PixelType.UNSIGNED_BYTE, img.buffer)
  }

  // internal
  static init(options){
    __width = options["width"] || 800
    __height = options["height"] || 480
    __pixelscale = options["scale"] || 2

    __framebuffer = Framebuffer.new(400, 240)

    var vertCode = File.read("./wren_modules/super16/vertex_tile.glsl")
    var fragCode = File.read("./wren_modules/super16/fragment_tile.glsl")
    __layerShader = Shader.new(vertCode, fragCode, ["size", "texSize", "pixelscale", "tilesize", "texture", "map", "mapSize", "pixelation"])

    fragCode = File.read("./wren_modules/super16/fragment.glsl")
    vertCode = File.read("./wren_modules/super16/vertex.glsl")
    __spriteShader = Shader.new(vertCode, fragCode, ["size", "texSize", "pixelscale", "texture"])

    __spriteBuffer = SpriteBuffer.new(__spriteShader.program, 1024)
    __sprites = []
    for(i in 0...__spriteBuffer.count){
      __sprites.add(Sprite.new(i))
    }
    __layerBuffer = SpriteBuffer.new(__layerShader.program, 4) //16384
    __bg0 = BgLayer.new(128,128, 0, 2)
    __bg1 = BgLayer.new(128,128, 1, 4)
    __bg2 = BgLayer.new(128,128, 2, 6)
    __bg3 = BgLayer.new(128,128, 3, 8)
    __layers = [__bg0, __bg1, __bg2, __bg3]

    __texSize = [1024, 1024]
    __texture = Gles2Util.createTexture(__texSize[0], __texSize[1])    
  }

  static update(){
    __bg0.update()
    __bg1.update()
    __bg2.update()
    __bg3.update()
    __layerBuffer.update()
    __spriteBuffer.update()
  }

  static draw(){
    GL.clearColor(0.5, 0.5, 0.5, 1.0)
    //GL.viewport(0,0,__width,__height)
    __framebuffer.use()
    GL.enable(EnableCap.BLEND)
    GL.blendFunc(BlendFacSrc.SRC_ALPHA, BlendFacDst.ONE_MINUS_SRC_ALPHA)
    GL.clear(ClearFlag.COLOR_BUFFER_BIT)
    
    GL.activeTexture(TextureUnit.TEXTURE0)
    GL.bindTexture(TextureTarget.TEXTURE_2D, __texture)

    __spriteShader.use()
    GL.uniform2f(__spriteShader.locations["size"], __width, __height)
    GL.uniform2f(__spriteShader.locations["texSize"], __texSize[0], __texSize[1])
    GL.uniform1f(__spriteShader.locations["pixelscale"], __pixelscale)
    GL.uniform1i(__spriteShader.locations["texture"], 0)

    __layerShader.use()
    GL.uniform2f(__layerShader.locations["size"], __width, __height)
    GL.uniform2f(__layerShader.locations["texSize"], __texSize[0], __texSize[1])
    GL.uniform1f(__layerShader.locations["pixelscale"], __pixelscale)
    GL.uniform2f(__layerShader.locations["tilesize"], 16, 16)
    GL.uniform1i(__layerShader.locations["texture"], 0)
    GL.uniform1i(__layerShader.locations["map"], 1)
    GL.uniform2f(__layerShader.locations["mapSize"], 128, 128)

    __layerShader.use()
    __bg0.draw(false)
    __bg1.draw(false)

    __spriteShader.use()
    __spriteBuffer.draw(1)

    __layerShader.use()
    __bg0.draw(true)
    __bg1.draw(true)
    
    __spriteShader.use()
    __spriteBuffer.draw(2)
    
    __layerShader.use()
    __bg2.draw(false)
    __bg3.draw(false)
    
    __spriteShader.use()
    __spriteBuffer.draw(3)
    
    __layerShader.use()
    __bg2.draw(true)
    __bg3.draw(true)

    __spriteShader.use()
    __spriteBuffer.draw(4)

    __framebuffer.draw(800, 480)
  }
}

class Framebuffer {
  construct new(w, h){
    _w = w
    _h = h
    _tex = Gles2Util.createTexture(512, 256)
    _fbo = GL.createFramebuffer()
    _program = Shader.new(File.read("./wren_modules/super16/vertex_fbo.glsl"), File.read("./wren_modules/super16/fragment_fbo.glsl"), [])
    _program.use()
    _position = VertexAttribute.fromList(GL.getAttribLocation(_program.program, "position"), 2, [-1,1, -1,-1, 1,-1, 1,1])
    _uv = VertexAttribute.fromList(GL.getAttribLocation(_program.program, "uv"), 2, [0,_h/256, 0,0, _w/512,0, _w/512,_h/256])
    _indices = VertexIndices.fromList([3,2,1,3,1,0])
    GL.bindFramebuffer(FramebufferTarget.FRAMEBUFFER, _fbo)
    GL.framebufferTexture2D(FramebufferTarget.FRAMEBUFFER, FramebufferAttachment.COLOR_ATTACHMENT0, TextureTarget.TEXTURE_2D, _tex, 0)
    var status = GL.checkFramebufferStatus(FramebufferTarget.FRAMEBUFFER)
    if(status != FramebufferStatus.FRAMEBUFFER_COMPLETE) Fiber.abort("Framebuffer incomplete %(status)")
    GL.bindFramebuffer(FramebufferTarget.FRAMEBUFFER, null)
  }

  use(){
    GL.bindFramebuffer(FramebufferTarget.FRAMEBUFFER, _fbo)
    Super16.app.checkErrors()

    GL.viewport(0, 0, _w, _h)
    GL.clear(ClearFlag.COLOR_BUFFER_BIT)
  }

  draw(w, h){
    GL.bindFramebuffer(FramebufferTarget.FRAMEBUFFER, null)
    GL.viewport(0, 0, w, h)
    _program.use()
    _position.enable()
    _uv.enable()
    GL.activeTexture(TextureUnit.TEXTURE0)
    GL.bindTexture(TextureTarget.TEXTURE_2D, _tex)
    _indices.draw()
  }
}

class BgLayer {
  
  enabled { _enabled }
  enabled=(v) { _enabled = v }
  mosaic=(v) { _pixel = 2.pow(v) }
  
  construct new(w,h,id,prio){
    _w = w
    _h = h
    _buffer = Buffer.new(w*h*4)
    _uint16 = Uint16Array.fromBuffer(_buffer)
    _uint8 = Uint8Array.fromBuffer(_buffer)
    _texture = Gles2Util.createTexture(w,h)
    _id = id
    _enabled = true
    _prio = prio
    _tilesize = [16,16]
    _pixel = 1
    Gfx.layerBuffer.setShape(id, 0, 0, 2, 2, 1, 1)
    Gfx.layerBuffer.setSource(id, 0, 0, 1,1)
    Gfx.layerBuffer.setPrio(id, prio)
  }

  pos(x,y){
    Gfx.layerBuffer.setTranslation(_id, x, y)
  }
  
  // todo bounds checking
  tile(x,y, tid){
    var offset = (y*_w+x)*2
    _uint16[offset] = tid
  }

  // todo bounds checking
  [x,y] { _uint16[(y*_w+x)*2] }

  // todo bounds checking
  tileFill(x,y,w,h,tid){
    for(cy in y...(y+h)){
      for(cx in x...(x+w)){
        tile(cx,cy,tid)
      }
    }
  }

  // todo bounds checking
  tilePlot(x,y,w,h,list){
    for(cy in y...(y+h)){
      for(cx in x...(x+w)){
        var tid = list[cy*w+cx]
        if(tid != 0) tile(cx,cy,tid)
      }
    }
  }
  
  prio(x,y, isPrio){
    _uint8[(y*_w+x)*4+2] = isPrio ? 1 : 0
  }
  
  update(){
    GL.bindTexture(TextureTarget.TEXTURE_2D, _texture)
    GL.texSubImage2D(TextureTarget.TEXTURE_2D, 0, 0, 0, _w, _h, PixelFormat.RGBA, PixelType.UNSIGNED_BYTE, _buffer)
  }

  draw(drawPrio){
    if(_enabled){
      GL.activeTexture(TextureUnit.TEXTURE1)
      GL.bindTexture(TextureTarget.TEXTURE_2D, _texture)
      GL.uniform1f(Gfx.layerShader.locations["pixelation"], _pixel)
      var add = drawPrio ? 1 : 0
      Gfx.layerBuffer.draw(_prio + add)
    }
  }
}

class Shader {
  locations {_locations }
  program { _program }

  construct new(vertex, fragment, uniforms){
    _program = Gles2Util.compileShader(vertex, fragment)
    _locations = {}
    for(name in uniforms){
      _locations[name] = GL.getUniformLocation(_program, name)
    }
  }

  use(){
    GL.useProgram(_program)
  }
}

class Sprite {
  prio=(v) { Gfx.spriteBuffer.setPrio(_id, v) }
  rot=(v) { Gfx.spriteBuffer.setRotation(_id,v) }
  id { _id }

  construct new(id){
    _id = id
  }

  set(w,h,sx,sy) { set(w,h,sx,sy,w/2, h/2) }
  set(w,h,sx,sy,ox,oy){
    Gfx.spriteBuffer.setShape(_id, 0, 0, w, h, ox, oy)
    Gfx.spriteBuffer.setSource(_id, sx, sy, w, h)
  }

  pos(x,y){
    Gfx.spriteBuffer.setTranslation(_id, x,y)
  }
}

foreign class SpriteBuffer {
  foreign count

  construct new(shader, count){}

  foreign setShape(i,x, y, w, h, ox, oy)
  foreign setSource(i, x, y, w, h)
  foreign setTranslation(i, x, y)
  foreign setRotation(i, r)
  foreign setScale(i, x, y)
  foreign setPrio(i, p)
  foreign getPrio(i)
  foreign update()
  foreign draw(prio)
}