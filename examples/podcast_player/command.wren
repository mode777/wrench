
import "wren-msgpack" for MessagePack
import "wren-sdl" for SdlThread
import "tasks" for Task


class Command {

  static receiveAsync(){
    return Task.new {

      var msg = SdlThread.waitParentAsync().await()
      return parse(msg)
    }
  }

  static receiveAsync(thread){
    return Task.new {
      var msg = thread.waitMessageAsync().await()
      return parse(msg)
    }
  }

  static send(command){
    SdlThread.sendParent(command.serialize())
  }

  static send(thread, command){
    thread.send(command.serialize())
  }

  static register(obj){
    __registry = __registry || {}
    __registry[obj.name] = obj
  }

  static parse(str){
    var args = MessagePack.deserialize(str)
    __registry = __registry || {}
    if(__registry.containsKey(args[0])){
      return __registry[args[0]].new(args)
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