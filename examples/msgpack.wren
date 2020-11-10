import "wren-msgpack" for MessagePack

var str = MessagePack.serialize(["Hello", true, null, 2.34, ["World"]])
var arr = MessagePack.deserialize(str)
System.print(arr)