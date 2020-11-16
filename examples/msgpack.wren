import "wren-msgpack" for MessagePack
import "buffers" for Buffer

var buffer = MessagePack.serialize({
  "a": 1,
  0: null,
  "b": true,
  "c": [5,"d"],
  "d": Buffer.fromString("Hello World")
})

System.print(MessagePack.deserialize(buffer))

//var arr = MessagePack.deserialize(str)
//System.print(arr)