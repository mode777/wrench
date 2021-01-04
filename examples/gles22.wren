import "gles2-app" for Gles2Application
import "wren-sdl" for SdlEventType
import "wren-gles2" for GL, ClearFlag, BufferType, BufferHint, ShaderType, DataType, EnableCap, PrimitveType, ShaderParam, ProgramParam 
import "buffers" for FloatArray, Uint16Array

class MyApp is Gles2Application {
  construct new(){
    super()
    _quit = false
    run()
  }

  init(){
    createWindow(640, 480, "MyWindow")
    compileShaders()
    createBuffers()
  }

  createBuffers(){

    _indices = [3,2,1,3,1,0]

    _vertexBuffer = GL.createBuffer()
    GL.bindBuffer(BufferType.ARRAY_BUFFER, _vertexBuffer)
    GL.bufferData(BufferType.ARRAY_BUFFER, FloatArray.fromList([
      -0.5,0.5,0.0,
      -0.5,-0.5,0.0,
      0.5,-0.5,0.0,
      0.5,0.5,0.0 
    ]), BufferHint.STATIC_DRAW)

    _indexBuffer = GL.createBuffer()
    GL.bindBuffer(BufferType.ELEMENT_ARRAY_BUFFER, _indexBuffer)
    GL.bufferData(BufferType.ELEMENT_ARRAY_BUFFER, Uint16Array.fromList(_indices), BufferHint.STATIC_DRAW)
  }

  compileShaders(){
    // Vertex shader source code
    var vertCode = "attribute vec3 coordinates;" +
      "void main(void) {" +
          "gl_Position = vec4(coordinates, 1.0);" +
      "}"
    // Fragment shader source code
    var fragCode = "void main(void) {" +
          " gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);" +
      "}"

    _shaderProgram = Gles2Util.compileShader(vertCode, fragCode)
  }

  render(){
    GL.viewport(0,0,width,height)
    GL.clearColor(0.5, 0.5, 0.5, 1.0)
    GL.enable(EnableCap.DEPTH_TEST)
    GL.clear(ClearFlag.COLOR_BUFFER_BIT | ClearFlag.DEPTH_BUFFER_BIT)

    GL.bindBuffer(BufferType.ARRAY_BUFFER, _vertexBuffer)
    var coord = GL.getAttribLocation(_shaderProgram, "coordinates")
    GL.vertexAttribPointer(coord, 3, DataType.FLOAT, false, 0, 0)
    GL.enableVertexAttribArray(coord)

    GL.bindBuffer(BufferType.ELEMENT_ARRAY_BUFFER, _indexBuffer) 
    GL.drawElements(PrimitveType.TRIANGLES, _indices.count, DataType.UNSIGNED_SHORT,0)
  }

  run(){
    init()
    while(!_quit){
      var ev = null
      while(ev = poll()){
        if(ev.type == SdlEventType.Quit) _quit = true
      }
      render()
      checkErrors()
      swap()
    }
  }
}

var app = MyApp.new()
app.run()