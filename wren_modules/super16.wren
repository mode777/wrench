import "wren-gles2" for GL, ClearFlag, BufferType, BufferHint, ShaderType, DataType, EnableCap, PrimitveType, ShaderParam, ProgramParam, TextureTarget, TextureParam, TextureWrapMode, TextureMagFilter, TextureMinFilter, TextureUnit, PixelType, PixelFormat
import "buffers" for FloatArray, Uint16Array, Uint8Array, Buffer
import "gles2-util" for Gles2Util, VertexAttribute, VertexIndices

foreign class SpriteBuffer {
  foreign count

  construct new(shader, count){}

  foreign setShape(i,x, y, w, h, ox, oy)
  foreign setSource(i, x, y, w, h)
  foreign setTranslation(i, x, y)
  foreign setRotation(i, r)
  foreign setScale(i, x, y)
  foreign update()
  foreign draw()
}

// class SpriteBuffer {
//   count { _count }

//   construct new(shader, count){
//     _count = count
//     _coordUvLoc = GL.getAttribLocation(shader, "coordUv")
//     _scaleRotLoc = GL.getAttribLocation(shader, "scaleRot")
//     _transLoc = GL.getAttribLocation(shader, "trans")

//     _constStride = 12 * 4
//     _constAttributes = Buffer.new(_constStride * count)
//     _constBuffer = GL.createBuffer()
//     GL.bindBuffer(BufferType.ARRAY_BUFFER, _constBuffer)
//     GL.bufferData(BufferType.ARRAY_BUFFER, _constAttributes, BufferHint.STREAM_DRAW)
//     initConstAttributes()

//     _varStride = 8*4
//     _varAttributes = Buffer.new(_varStride * count)
//     _varBuffer = GL.createBuffer()
//     GL.bindBuffer(BufferType.ARRAY_BUFFER, _varBuffer)
//     GL.bufferData(BufferType.ARRAY_BUFFER, _varAttributes, BufferHint.STREAM_DRAW)

//     _indices = GL.createBuffer()
//     createIndices()
//   }

//   initConstAttributes(){
//     _constDefaults = Buffer.new(4)
//     _constDefaults.writeUint16(0, 4096)
//     _constDefaults.writeUint16(2, 4096)
//     for(i in 0..._count){
//       var offset = _constStride*i
//       _constDefaults.copyTo(_constAttributes, 0, offset, 4)
//     }
//   }

//   createIndices(){
//     var buffer = Buffer.new(_count*6*2)
//     for(i in 0..._count){
//       var offset = i*6*2
//       var index = i*4
//       buffer.writeUint16(offset, index+3)
//       buffer.writeUint16(offset+2, index+2)
//       buffer.writeUint16(offset+4, index+1)
//       buffer.writeUint16(offset+6, index+3)
//       buffer.writeUint16(offset+8, index+1)
//       buffer.writeUint16(offset+10, index+0)
//     }
//     GL.bindBuffer(BufferType.ELEMENT_ARRAY_BUFFER, _indices)
//     GL.bufferData(BufferType.ELEMENT_ARRAY_BUFFER, buffer, BufferHint.STATIC_DRAW)
//     buffer.dispose()
//     //[3,2,1,3,1,0]
//   }
  
//   setShape(i,x, y, w, h, ox, oy){
//     var offset = _varStride*i
//     _varAttributes.writeInt16(offset, x-ox)
//     _varAttributes.writeInt16(offset+2, y+h-oy)

//     _varAttributes.writeInt16(offset+8, x-ox)
//     _varAttributes.writeInt16(offset+10, y-oy)
    
//     _varAttributes.writeInt16(offset+16, x+w-ox)
//     _varAttributes.writeInt16(offset+18, y-oy)

//     _varAttributes.writeInt16(offset+24, x+w-ox)
//     _varAttributes.writeInt16(offset+26, y+h-oy)
//   }

//   setSource(i, x, y, w, h){
//     var offset = _varStride*i+4
//     _varAttributes.writeInt16(offset, y)
//     _varAttributes.writeInt16(offset+2, x)

//     _varAttributes.writeInt16(offset+8, y+h)
//     _varAttributes.writeInt16(offset+10, x)
    
//     _varAttributes.writeInt16(offset+16, y+h)
//     _varAttributes.writeInt16(offset+18, x+w)

//     _varAttributes.writeInt16(offset+24, y)
//     _varAttributes.writeInt16(offset+26, x+w)
//   }

//   setTranslation(i, x, y){
//     var offset = _varStride*i+8
//     _constAttributes.writeInt16(offset, x)
//     _constAttributes.writeInt16(offset+2, y)
//   }

//   setRotation(i, r){
//     var offset = _constStride*i+4
//     _constAttributes.writeUint16(offset, 10430 * r)
//     // _constAttributes.writeUint16(offset+2, 32768 * (r.cos+1))
//   }

//   setScale(i, x, y){
//     var offset = _constStride*i
//     _constAttributes.writeUint16(offset, 4096 * x)
//     _constAttributes.writeUint16(offset+2, 4096 * y)
//   }

//   copyAttributes(i){
//     var srcOffset = _constStride*i
//     _constAttributes.copyTo(_constAttributes, srcOffset, srcOffset+12, 12)
//     _constAttributes.copyTo(_constAttributes, srcOffset, srcOffset+24, 12)
//     _constAttributes.copyTo(_constAttributes, srcOffset, srcOffset+36, 12)
//   }

//   update(){
//     GL.bindBuffer(BufferType.ARRAY_BUFFER, _varBuffer)
//     GL.bufferSubData(BufferType.ARRAY_BUFFER, 0, _varAttributes.size, _varAttributes)
//     GL.vertexAttribPointer(_coordUvLoc, 4, DataType.SHORT, false, 0, 0)
//     GL.enableVertexAttribArray(_coordUvLoc)

//     for(i in 0..._count){
//       copyAttributes(i)
//     }

//     GL.bindBuffer(BufferType.ARRAY_BUFFER, _constBuffer)
//     GL.bufferSubData(BufferType.ARRAY_BUFFER, 0, _constAttributes.size, _constAttributes)
//     GL.vertexAttribPointer(_scaleRotLoc, 4, DataType.UNSIGNED_SHORT, false, 12, 0)
//     GL.vertexAttribPointer(_transLoc, 2, DataType.SHORT, false, 12, 8)
//     GL.enableVertexAttribArray(_scaleRotLoc)
//     GL.enableVertexAttribArray(_transLoc)
//   }

//   draw(){
//     GL.bindBuffer(BufferType.ELEMENT_ARRAY_BUFFER, _indices)
//     GL.drawElements(PrimitveType.TRIANGLES, _count*6, DataType.UNSIGNED_SHORT, 0)
//   }
// }