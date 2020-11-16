import "buffers" for Buffer, Uint32Array

var b = Buffer.new(19)
b.writeInt8(0, 1)
b.writeInt16(1, 256)
b.writeInt32(3, 20000)
b.writeFloat(7, 0.1)
b.writeDouble(11, 0.1)

System.print([
  b.readInt8(0),
  b.readInt16(1),
  b.readInt32(3),
  b.readFloat(7),
  b.readDouble(11)
])

var arr = Uint32Array.new(4)
arr[0] = 1
arr[1] = 2
arr[2] = 3
arr[3] = 4

System.print(arr.toList)

