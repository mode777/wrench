import "gles2-app" for Gles2Application
import "wren-sdl" for SdlEventType
import "wren-gles2" for GL, ClearFlag, BufferType, BufferHint, ShaderType, DataType, EnableCap, PrimitveType, ShaderParam, ProgramParam, TextureTarget, TextureParam, TextureWrapMode, TextureMagFilter, TextureMinFilter, TextureUnit, PixelType, PixelFormat
import "buffers" for FloatArray, Uint16Array, Uint8Array, Buffer
import "gles2-util" for Gles2Util, VertexAttribute, VertexIndices
import "file" for File
import "shapes" for Rectangle
import "random" for Random
import "super16" for SpriteBuffer

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
    var vertCode = File.read("./examples/gles2/vertex.glsl")
    var fragCode = File.read("./examples/gles2/fragment.glsl")

    _shaderProgram = Gles2Util.compileShader(vertCode, fragCode)
    GL.useProgram(_shaderProgram)
  }

  createTexture(){
    _texture = GL.createTexture()
    GL.bindTexture(TextureTarget.TEXTURE_2D, _texture)

    var level = 0
    var internalFormat = PixelFormat.RGBA
    var width = 2
    var height = 2
    var border = 0
    var srcFormat = PixelFormat.RGBA
    var srcType = PixelType.UNSIGNED_BYTE
    var pixel = Uint8Array.fromList([0, 0, 255, 255, 255, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255])  // opaque blue
    GL.texImage2D(TextureTarget.TEXTURE_2D, level, internalFormat,
                  width, height, border, srcFormat, srcType, pixel)
    GL.texParameteri(TextureTarget.TEXTURE_2D, TextureParam.TEXTURE_MAG_FILTER, TextureMagFilter.LINEAR)
    GL.texParameteri(TextureTarget.TEXTURE_2D, TextureParam.TEXTURE_MIN_FILTER, TextureMinFilter.LINEAR)

    // var image = new Image();
    // image.onload = function() {
    //   GL.bindTexture(gl.TEXTURE_2D, texture);
    //   GL.texImage2D(gl.TEXTURE_2D, level, internalFormat,
    //                 srcFormat, srcType, image);

    //   // WebGL1 has different requirements for power of 2 images
    //   // vs non power of 2 images so check if the image is a
    //   // power of 2 in both dimensions.
    //   if (isPowerOf2(image.width) && isPowerOf2(image.height)) {
    //     // Yes, it's a power of 2. Generate mips.
    //     GL.generateMipmap(gl.TEXTURE_2D);
    //   } else {
    //     // No, it's not a power of 2. Turn off mips and set
    //     // wrapping to clamp to edge
    //     GL.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    //     GL.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    //     GL.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    //   }
    // };
    // image.src = url;
  }

  createBuffers(){
    _random = Random.new(1986)
    _sprBuffer = SpriteBuffer.new(_shaderProgram, 16384) //16384
    for(i in 0..._sprBuffer.count){
      _sprBuffer.setShape(i, 0, 0, 32, 32, 16, 16)
      _sprBuffer.setSource(i, 0,0, 1,1)
      _sprBuffer.setTranslation(i, _random.int(width), _random.int(height))
    }
    _sprBuffer.update()

    _r = 0
    // _sprBuffer.setRotation(0, _r)
    // _sprBuffer.setScale(0, 1, 1)
  }

  render(){
    
    GL.viewport(0,0,width,height)
    GL.clearColor(0.5, 0.5, 0.5, 1.0)
    GL.enable(EnableCap.DEPTH_TEST)
    GL.clear(ClearFlag.COLOR_BUFFER_BIT | ClearFlag.DEPTH_BUFFER_BIT)

    GL.activeTexture(TextureUnit.TEXTURE0)
    GL.bindTexture(TextureTarget.TEXTURE_2D, _texture)
    var location = GL.getUniformLocation(_shaderProgram, "texture")
    GL.uniform1i(location, 0)
    GL.uniform2f(GL.getUniformLocation(_shaderProgram, "size"), width, height)
    _sprBuffer.update()
    _sprBuffer.draw()
    _r = _r + 0.01
    var clock = System.clock
    for(i in 0..._sprBuffer.count){
      _sprBuffer.setRotation(i, _r)
      //_sprBuffer.setScale(i, 1+1-clock%1, 1+1-clock%1)
    }
    // _vertexAttr.enable()
    // _scaleRot.enable()
    // _trans.enable()

    // _sx = _r.sin+1
    // _sy = _r.cos+1
    //_sprBuffer.setScale(0, 1+(_r.sin+1)/4, 1+(_r.cos+1)/4)

    //_texcoordAttr.enable()
    //_indices.draw()
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
      if(_frames == 60){
        System.print("Frametime %(_frameTime * 10)ms")
        _frames = 0
        _frameTime = 0
      }
    }
  }
}

var app = MyApp.new()
app.run()