import "gles2-app" for Gles2Application
import "wren-sdl" for SdlEventType
import "wren-gles2" for GL, ClearFlag, BufferType, BufferHint, ShaderType, DataType, EnableCap, PrimitveType, ShaderParam, ProgramParam 
import "buffers" for FloatArray, Uint16Array
import "gles2-util" for Gles2Util, VertexAttribute, VertexIndices

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
    GL.useProgram(_shaderProgram)
  }

  createBuffers(){
    var loc = GL.getAttribLocation(_shaderProgram, "coordinates")
    _vertexAttr = VertexAttribute.fromList(loc, 3, [
      -0.5,0.5,0.0,
      -0.5,-0.5,0.0,
      0.5,-0.5,0.0,
      0.5,0.5,0.0 
    ])
    _indices = VertexIndices.fromList([3,2,1,3,1,0])
  }

  render(){
    GL.viewport(0,0,width,height)
    GL.clearColor(0.5, 0.5, 0.5, 1.0)
    GL.enable(EnableCap.DEPTH_TEST)
    GL.clear(ClearFlag.COLOR_BUFFER_BIT | ClearFlag.DEPTH_BUFFER_BIT)

    _vertexAttr.enable()
    _indices.draw()
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