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

class MyApp is Gles2Application {
  construct new(){
    super()
    _quit = false
  }

  init(){
    _frameTime = 0
    _frames = 0
    _time = 0
    createWindow(800, 480, "2d Demo")
    setVsync(false)
    compileShaders()
    createTexture()
    createBuffers()
  }


  compileShaders(){
    //var vertCode = File.read("./examples/gles2/vertex.glsl")
    var vertCode = File.read("./examples/gles2/vertex_tile.glsl")
    //var fragCode = File.read("./examples/gles2/fragment.glsl")
    var fragCode = File.read("./examples/gles2/fragment_tile.glsl")

    _shaderProgram = Gles2Util.compileShader(vertCode, fragCode)
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

    var buffer = Uint8Array.new(16*16*4)
    buffer[0] = 0
    buffer[1] = 1
    GL.texSubImage2D(TextureTarget.TEXTURE_2D, 0, 512, 512, 16, 16, PixelFormat.RGBA, PixelType.UNSIGNED_BYTE, buffer)

    img.dispose()
  }

  createBuffers(){
    _random = Random.new(1986)
    _sprBuffer = SpriteBuffer.new(_shaderProgram, 1) //16384
    _sprBuffer.setShape(0, 0, 0, width, height, 0, 0)

    _sprBuffer.setSource(0, 0, 0, 25,15)
    _sprBuffer.setPrio(0, 1)
    _sprBuffer.setTranslation(0,0,0)
    _sprBuffer.update()
    _r = 0
    _x = -512*32
    _y = -512*32
  }

  render(){
    GL.useProgram(_shaderProgram)
    GL.viewport(0,0,width,height)
    GL.clearColor(0.5, 0.5, 0.5, 1.0)
    GL.enable(EnableCap.BLEND)
    GL.blendFunc(BlendFacSrc.SRC_ALPHA, BlendFacDst.ONE_MINUS_SRC_ALPHA)
    GL.clear(ClearFlag.COLOR_BUFFER_BIT)

    GL.activeTexture(TextureUnit.TEXTURE0)
    GL.bindTexture(TextureTarget.TEXTURE_2D, _texture)
    GL.uniform1i(GL.getUniformLocation(_shaderProgram, "texture"), 0)

    GL.uniform2f(GL.getUniformLocation(_shaderProgram, "size"), width, height)
    GL.uniform2f(GL.getUniformLocation(_shaderProgram, "texSize"), _texSize[0], _texSize[1])
    _sprBuffer.update()
    _sprBuffer.draw(1)
    //_sprBuffer.draw(2)
    //_sprBuffer.draw(3)
    //_sprBuffer.draw(4)
    
    _r = _r + 0.01
    _sprBuffer.setRotation(0, _r)
    var s = (System.clock.sin*2) + 3
    _sprBuffer.setScale(0, s, s)
    // _x = _x - 2
    // _y = _y - 2
    _sprBuffer.setTranslation(0, _x, _y)
  }

  run(){
    init()
    while(!_quit){
      _time = System.clock
      var ev = null
      while(ev = poll()){
        if(ev.type == SdlEventType.Quit) _quit = true
      }
      render()
      checkErrors()
      swap()
      _frames = _frames+1
      _frameTime = _frameTime + System.clock - _time
      if(_frames % 100 == 0){
        System.print("Frametime %((_frameTime / _frames) * 1000)ms")
      }
    }
  }
}

var app = MyApp.new()
app.run()