import "buffers" for Buffer

foreign class Deserializer {
  construct new(){}

  foreign deserialize_(bufferClass, buffer)

  deserialize(buffer){ 
    var ret = deserialize_(Buffer,buffer) 
    return ret
  }
}

foreign class Serializer {
  construct new(){}
  foreign getBuffer_(buffer)
  foreign packList_(num)
  foreign packMap_(v)
  foreign packBool_(v)
  foreign packDouble_(v)
  foreign packNull_()
  foreign packBuffer_(v)
  foreign packString_(v)
  packValue_(v){
    if(v == null) return packNull_()
    if(v is String) return packString_(v)
    if(v is Num) return packDouble_(v)
    if(v is Bool) return packBool_(v)
    if(v is Buffer) return packBuffer_(v)
    if(v is List) {
      packList_(v.count)
      for(el in v){
        packValue_(el)
      }
      return
    }
    if(v is Map){
      packMap_(v.count)
      for(kv in v){
        packValue_(kv.key)
        packValue_(kv.value)
      }
      return
    }
    Fiber.abort("Object unsupported for serialization %(v)")
  }
  serialize(val){ 
    packValue_(val)
    var b = Buffer.new(0)
    getBuffer_(b)
    return b 
  }
}

// class MsgPackObjType {
//   static Nil { 0x00 }
//   static Boolean { 0x01 }
//   static PositiveInteger { 0x02 }
//   static NegativeInteger { 0x03 }
//   static Float32 { 0x0a }
//   static Float64 { 0x04 }
//   static Str { 0x05 }
//   static Array { 0x06 }
//   static Map { 0x07 }
//   static Bin { 0x08 }
//   static Ext { 0x09 }
// }

class MessagePack {
  static serialize(val){
    __serializer = __serializer || Serializer.new()
    return __serializer.serialize(val)
  }
  static deserialize(val){
    __deserializer = __deserializer || Deserializer.new()
    return __deserializer.deserialize(val)
  }
}