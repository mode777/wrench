import "wren-curl" for CURL, CurlHandle, CurlMultiHandle, CurlMessage
import "tasks" for Task, Canceller, DefaultCanceller

class FetchClient {
  construct new(){
    init(0)
  }

  init(threshold){
    _threshold = threshold
    _startTime = 0
    _time = threshold
    _requests = 0
    _multi = CurlMultiHandle.new()
    _message = CurlMessage.new()
    _finished = {}
  }

  requests { _requests }

  get(url){
    return Task.new {|c|
      var handle = CurlHandle.new(url)
      return runHandle(url, handle)
    }
  }
  
  download(url, path){
    return Task.new {|c|
      var handle = CurlHandle.download(url, path)
      return runHandle(url, handle)
    }
  }

  runHandle(url, handle){
    addHandle_(handle)

    while(!_finished[handle.id]){
      update()
      Fiber.yield()
    }
    
    removeHandle_(handle)
    
    var status = handle.responseCode
    if(status >= 200 && status < 300){
      return handle.getData()
    }
    handle.dispose()
    Fiber.abort("Request to %(url) returned non-success status code %(status)")
  }

  addHandle_(handle){
    _requests = _requests+1
    _multi.addHandle(handle)
  }

  removeHandle_(handle){
    _finished.remove(handle.id)
    _multi.removeHandle(handle)
  }

  update(){
    if(_time >= _threshold && _requests > 0){
      step_()
      _time = 0
      _startTime = CURL.clock
    }
    _time = CURL.clock - _startTime
  }

  step_() {

    _requests = _multi.perform()

    while(_multi.readInfo(_message)){
      var handle = _message.getHandle()
      _finished[handle.id] = true
    }
  }
}

