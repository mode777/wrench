import "gles2-app" for Gles2Application
import "wren-sdl" for SdlEventType
import "wren-gles2" for GL, ClearFlag, BufferType, BufferHint, ShaderType, DataType, EnableCap, PrimitveType, ShaderParam, ProgramParam, TextureTarget, TextureParam, TextureWrapMode, TextureMagFilter, TextureMinFilter, TextureUnit, PixelType, PixelFormat, BlendFacSrc, BlendFacDst
import "buffers" for FloatArray, Uint16Array, Uint8Array, Buffer
import "gles2-util" for Gles2Util, VertexAttribute, VertexIndices
import "file" for File
import "shapes" for Rectangle
import "random" for Random
import "super16" for SpriteBuffer
import "images" for Image
import "wren-sdl" for SDL

class MyApp is Gles2Application {
  construct new(){
    super()
    _quit = false
  }

  init(){
    _frameTime = 0
    _frames = 0
    _time = 0
    _random = Random.new(1986)
    createWindow(800, 480, "2d Demo")
    setVsync(false)
    compileShaders()
    createTexture()
    createBuffers()
    initDraw()
  }


  compileShaders(){
    var fragCode = File.read("./examples/gles2/fragment.glsl")
    var vertCode = File.read("./examples/gles2/vertex.glsl")

    _shaderProgram = Gles2Util.compileShader(vertCode, fragCode)
    
    fragCode = File.read("./examples/gles2/fragment_tile.glsl")
    vertCode = File.read("./examples/gles2/vertex_tile.glsl")
    
    _shaderProgram2 = Gles2Util.compileShader(vertCode, fragCode)
  }

  createTexture(){
    //var img = Image.fromFile("assets/character.png")
    var img = Image.fromFile("assets/overworld.png")
    _texture = GL.createTexture()
    GL.bindTexture(TextureTarget.TEXTURE_2D, _texture)

    _texSize = [1024, 1024]
    GL.texImage2D(TextureTarget.TEXTURE_2D, 0, PixelFormat.RGBA, _texSize[0], _texSize[1], 0, PixelFormat.RGBA, PixelType.UNSIGNED_BYTE)
    GL.texParameteri(TextureTarget.TEXTURE_2D, TextureParam.TEXTURE_MAG_FILTER, TextureMagFilter.NEAREST)
    GL.texParameteri(TextureTarget.TEXTURE_2D, TextureParam.TEXTURE_MIN_FILTER, TextureMinFilter.NEAREST)
    
    GL.texSubImage2D(TextureTarget.TEXTURE_2D, 0, 0, 0, img.width, img.height, PixelFormat.RGBA, PixelType.UNSIGNED_BYTE, img.buffer)

    var buffer = Uint8Array.new(32*32*4)
    for(i in 0...(32*32)){
      buffer[i*4] = _random.int(32)
      buffer[i*4+1] = _random.int(32)
    }
    GL.texSubImage2D(TextureTarget.TEXTURE_2D, 0, 512, 512, 32, 32, PixelFormat.RGBA, PixelType.UNSIGNED_BYTE, buffer)

    img.dispose()
  }

  createBuffers(){
    _sprBuffer = SpriteBuffer.new(_shaderProgram, 1024) //16384
    // sprites
    for(i in 0..._sprBuffer.count){
      _sprBuffer.setShape(i, 0, 0, 32, 32, 16, 16)
      _sprBuffer.setSource(i, 16, 0, 16, 16)
      _sprBuffer.setPrio(i, 1+i%4)
      _sprBuffer.setTranslation(i,_random.int(width),_random.int(height))
    }

    // tile layer 0
    _sprBuffer2 = SpriteBuffer.new(_shaderProgram2, 4) //16384
    _sprBuffer2.setShape(0, 0, 0, width, height, 0, 0)
    _sprBuffer2.setSource(0, 0, 0, 25,15)
    _sprBuffer2.setPrio(0, 2)
    _sprBuffer2.setTranslation(0,-512*32,-512*32)

    _sprBuffer2.setShape(1, 0, 0, width, height, 0, 0)
    _sprBuffer2.setSource(1, 1, 0, 25,15)
    _sprBuffer2.setPrio(1, 4)
    _sprBuffer2.setTranslation(1,-513*32,-512*32)

    _sprBuffer2.setShape(2, 0, 0, width, height, 0, 0)
    _sprBuffer2.setSource(2, 1, 0, 25,15)
    _sprBuffer2.setPrio(2, 6)
    _sprBuffer2.setTranslation(2,-513*32,-513*32)

    _sprBuffer2.setShape(3, 0, 0, width, height, 0, 0)
    _sprBuffer2.setSource(3, 1, 0, 25,15)
    _sprBuffer2.setPrio(3, 8)
    _sprBuffer2.setTranslation(3,-512*32,-513*32)

    _r = 0
    _x = -512*32
    _y = -512*32
  }

  initDraw(){
    GL.activeTexture(TextureUnit.TEXTURE0)
    GL.bindTexture(TextureTarget.TEXTURE_2D, _texture)

    GL.useProgram(_shaderProgram)
    GL.uniform2f(GL.getUniformLocation(_shaderProgram, "size"), width, height)
    GL.uniform2f(GL.getUniformLocation(_shaderProgram, "texSize"), _texSize[0], _texSize[1])
    GL.uniform1i(GL.getUniformLocation(_shaderProgram, "texture"), 0)

    GL.useProgram(_shaderProgram2)
    GL.uniform2f(GL.getUniformLocation(_shaderProgram2, "size"), width, height)
    GL.uniform2f(GL.getUniformLocation(_shaderProgram2, "texSize"), _texSize[0], _texSize[1])
    GL.uniform1i(GL.getUniformLocation(_shaderProgram2, "texture"), 0)

  }

  render(){
    GL.viewport(0,0,width,height)
    GL.clearColor(0.5, 0.5, 0.5, 1.0)
    GL.enable(EnableCap.BLEND)
    GL.blendFunc(BlendFacSrc.SRC_ALPHA, BlendFacDst.ONE_MINUS_SRC_ALPHA)
    GL.clear(ClearFlag.COLOR_BUFFER_BIT)

    _sprBuffer2.update()
    _sprBuffer.update()

    _sprBuffer2.draw(2)
    _sprBuffer2.draw(3)
    
    _sprBuffer.draw(1)

    _sprBuffer2.draw(4)
    _sprBuffer2.draw(5)
    
    _sprBuffer.draw(2)
    //GL.uniform1i(GL.getUniformLocation(_shaderProgram, "sw"), 0)
    _sprBuffer2.draw(6)
    _sprBuffer2.draw(7)
    // GL.uniform1i(GL.getUniformLocation(_shaderProgram, "sw"), 1)
    _sprBuffer.draw(3)

    _sprBuffer2.draw(8)
    _sprBuffer2.draw(9)
    
    _sprBuffer.draw(4)
    
    _r = _r + 0.5
    for(i in 0..._sprBuffer.count){
      _sprBuffer.setRotation(i, _r)
    }
    // var s = (System.clock.sin*2) + 3
    // _sprBuffer.setScale(0, s, s)
    // _x = _x - 2
    // _y = _y - 2
    //_sprBuffer2.setTranslation(0, _x, _y)
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
        System.print("Frametime %((_frameTime / _frames))ms")
      }
    }
  }
}

var app = MyApp.new()
app.run()