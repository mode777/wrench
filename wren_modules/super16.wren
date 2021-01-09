import "wren-gles2" for GL, ClearFlag, BufferType, BufferHint, ShaderType, DataType, EnableCap, PrimitveType, ShaderParam, ProgramParam, TextureTarget, TextureParam, TextureWrapMode, TextureMagFilter, TextureMinFilter, TextureUnit, PixelType, PixelFormat, BlendFacSrc, BlendFacDst
import "images" for Image
import "buffers" for FloatArray, Uint16Array, Uint8Array, Buffer
import "gles2-util" for Gles2Util, VertexAttribute, VertexIndices
import "file" for File
import "random" for Random

class Gfx {

  static layerShader { __layerShader } 
  static spriteShader { __spriteShader } 
  static bg0 { __bg0 }
  static bg1 { __bg1 }
  static bg2 { __bg2 }
  static bg3 { __bg3 }
  static pixelScale { __pixelscale }
  static pixelScale=(v) { __pixelscale=v }
  static spriteBuffer { __spriteBuffer }
  static layerBuffer { __layerBuffer }
  static sprites { __sprites }

  static init(){
    __width = 800
    __height = 480
    __pixelscale = 2

    var vertCode = File.read("./examples/gles2/vertex_tile.glsl")
    var fragCode = File.read("./examples/gles2/fragment_tile.glsl")
    __layerShader = Shader.new(vertCode, fragCode, ["size", "texSize", "pixelscale", "tilesize", "texture", "offset", "map", "mapSize"])

    fragCode = File.read("./examples/gles2/fragment.glsl")
    vertCode = File.read("./examples/gles2/vertex.glsl")
    __spriteShader = Shader.new(vertCode, fragCode, ["size", "texSize", "pixelscale", "texture"])

    __spriteBuffer = SpriteBuffer.new(__spriteShader.program, 1024)
    __sprites = []
    for(i in 0...__spriteBuffer.count){
      __sprites.add(Sprite.new(i))
    }
    __layerBuffer = SpriteBuffer.new(__layerShader.program, 4) //16384
    __bg0 = BgLayer.new(0, 2)
    __bg1 = BgLayer.new(1, 4)
    __bg2 = BgLayer.new(2, 6)
    __bg3 = BgLayer.new(3, 8)

    __texSize = [1024, 1024]
    __texture = Gles2Util.createTexture(__texSize[0], __texSize[1])
    
    // load image to vram
    var img = Image.fromFile("assets/vram.png")
    GL.texSubImage2D(TextureTarget.TEXTURE_2D, 0, 0, 0, img.width, img.height, PixelFormat.RGBA, PixelType.UNSIGNED_BYTE, img.buffer)
    img.dispose()

    __map0 = TileMap.new(128,128)
    __map1 = TileMap.new(128,128)
    __map2 = TileMap.new(128,128)
    __map3 = TileMap.new(128,128)

    var maps = [__map0, __map1, __map2, __map3]

    for(m in maps){
      for(y in 0...32){
        for(x in 0...32){
          m.tile(x,y,x,y)
          m.prio(x,y, x%2 == 0 ? true : false)
        }
      }
    }

    // __map = Gles2Util.createTexture(128,128)

    // var random = Random.new(1986)
    // var buffer = Uint8Array.new(32*32*4)
    // for(i in 0...(32*32)){
    //   buffer[i*4] = 32 - i % 32
    //   buffer[i*4+1] = i / 32
    //   buffer[i*4+2] = i % 2
    // }
    // GL.texSubImage2D(TextureTarget.TEXTURE_2D, 0, 0, 0, 32, 32, PixelFormat.RGBA, PixelType.UNSIGNED_BYTE, buffer)

  }

  static update(){
    __map0.update()
    __map1.update()
    __map2.update()
    __map3.update()
    __layerBuffer.update()
    __spriteBuffer.update()
  }

  static draw(){
    GL.viewport(0,0,__width,__height)
    GL.clearColor(0.5, 0.5, 0.5, 1.0)
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
    __map0.use()
    __bg0.draw(false)
    // __map1.use()
    // __bg1.draw(false)

    // __spriteShader.use()
    // __spriteBuffer.draw(1)

    // __layerShader.use()
    // __map0.use()
    // __bg0.draw(true)
    // __map1.use()
    // __bg1.draw(true)
    
    // __spriteShader.use()
    // __spriteBuffer.draw(2)
    
    // __layerShader.use()
    // __map2.use()
    // __bg2.draw(false)
    // __map3.use()
    // __bg3.draw(false)
    
    // __spriteShader.use()
    // __spriteBuffer.draw(3)
    
    // __layerShader.use()
    // __map2.use()
    // __bg2.draw(true)
    // __map3.use()
    // __bg3.draw(true)

    // __spriteShader.use()
    // __spriteBuffer.draw(4)
  }
}

class TileMap {
  construct new(w,h){
    _w = w
    _h = h
    _buffer = Buffer.new(w*h*4)
    _uint16 = Uint16Array.fromBuffer(_buffer)
    _uint8 = Uint8Array.fromBuffer(_buffer)
    _texture = Gles2Util.createTexture(w,h)
  }

  tile(x,y, sx, sy){
    var offset = (y*_w+x)*4
    _uint8[offset] = sx
    _uint8[offset+1] = sy
  }

  prio(x,y, isPrio){
    _uint8[(y*_w+x)*4+2] = isPrio ? 1 : 0
  }

  update(){
    GL.bindTexture(TextureTarget.TEXTURE_2D, _texture)
    GL.texSubImage2D(TextureTarget.TEXTURE_2D, 0, 0, 0, _w, _h, PixelFormat.RGBA, PixelType.UNSIGNED_BYTE, _buffer)
  }

  use(){
    GL.activeTexture(TextureUnit.TEXTURE1)
    GL.bindTexture(TextureTarget.TEXTURE_2D, _texture)
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

class BgLayer {
  
  enabled { _enabled }
  enabled=(v) { _enabled = v }
  
  construct new(id, prio){
    _id = id
    _ox = 0
    _oy = 0
    _enabled = true
    _prio = prio
    Gfx.layerBuffer.setShape(id, 0, 0, 2, 2, 1, 1)
    Gfx.layerBuffer.setSource(id, 0, 0, 1,1)
    Gfx.layerBuffer.setPrio(id, prio)
  }

  offset(x,y){
    _ox = x
    _oy = y
  }

  draw(drawPrio){
    if(_enabled){
      GL.uniform2f(Gfx.layerShader.locations["offset"], _ox, _oy)
      var add = drawPrio ? 1 : 0
      Gfx.layerBuffer.draw(_prio + add)
    }
  }
}

class Sprite {
  prio=(v) { Gfx.spriteBuffer.setPrio(_id, v) }
  rot=(v) { Gfx.spriteBuffer.setRotation(_id,v) }

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