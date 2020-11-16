
import "wren-msgpack" for MessagePack
import "threads" for Thread, Parent
import "tasks" for Task


class Command {

  static receiveAsync(){
    return Task.new {
      while(Parent.count == 0){
        Fiber.yield()
      }
      var msg = Parent.receive()
      return parse(msg)
    }
  }

  static receiveAsync(thread){
    return Task.new {
      while(thread.count == 0){
        Fiber.yield()
      }
      var msg = thread.receive()
      return parse(msg)
    }
  }

  static send(command){
    Parent.send(command.serialize())
  }

  static sendBinary(buffer){
    Parent.send(buffer)
  }

  static send(thread, command){
    thread.send(command.serialize())
  }

  static sendBinary(thread, buffer){
    thread.send(buffer)
  }

  static register(obj){
    __registry = __registry || {}
    __registry[obj.name] = obj
  }

  static parse(buffer){
    var args = MessagePack.deserialize(buffer)
    __registry = __registry || {}
    if(__registry.containsKey(args["id"])){
      return __registry[args["id"]].new(args)
    } else {
      return Command.new(args)
    }
  }

  args { _args }
  args=(v) { _args = v }

  construct new(args){
    _args = args
  }
  serialize(){
    return MessagePack.serialize(_args)
  }

}