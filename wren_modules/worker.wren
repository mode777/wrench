import "threads" for Thread, Parent
import "wren-msgpack" for MessagePack, Deserializer
import "tasks" for Task

class WorkerClient {
  construct new(thread){
    _id = 1
    _thread = thread
    _responses = {}
    _errors = {}
  }

  request(type, params){
    var id = _id
    _id = _id+1 
    var payload = { "type": type, "params": params, "id": id }
    _thread.send(MessagePack.serialize(payload))
    _responses[id] = null
    return Task.new {
      while(!_responses[id] && !_errors[id]) Fiber.yield()
      if(_errors.containsKey(id)) {
        var error = _errors[id]
        _errors.remove(id)
        Fiber.abort("Request %(type) returned error: %(error)")
      } else {
        var response = _responses[id]
        _responses.remove(id)
        return response
      }
    }
  }

  perform(){
    while(_thread.count > 0){
      var buffer = _thread.receive()
      var ds = Deserializer.new()
      var response = ds.deserialize(buffer)
      buffer.dispose()
      if(response["error"]){
        _errors[response["id"]] = response["error"]
      } else {
        _responses[response["id"]] = response["content"]
      }
    }
  }
}

class WorkerServer {
  construct new(handlers){
    _handlers = handlers
    _tasks = {}
    _remove = []
  }

  perform(){
    processRequests_()
    driveTasks_()
  }

  processRequests_(){
    while(Parent.count > 0){
      var buffer = Parent.receive()
      var request = MessagePack.deserialize(buffer)
      buffer.dispose()
      if(_handlers[request["type"]]){
        _tasks[request["id"]] = _handlers[request["type"]]
          .call(request["params"])
          .catch { |e,s|
            System.print(e)
            System.print(s)
          }
      } else {
        System.print("No handler found for request %(request["type"])")
      }
    }
  }

  driveTasks_(){
    for(kv in _tasks){
      kv.value.step()
      if(kv.value.isDone){
        if(kv.value.error){
          sendError_(kv.key, kv.value.error)
        } else {
          sendResponse_(kv.key, kv.value.result)
        }
        _remove.add(kv.key)
      }
    }
    for(k in _remove){
      _tasks.remove(k)
    }
    _remove.clear()
  }

  sendResponse_(id, content){
    var response = {"id": id, "content": content}
    Parent.send(MessagePack.serialize(response))
  }

  sendError_(id, error){
    Parent.send(MessagePack.serialize({"id": id, "error": error}))
  }

}