import "wren-curl" for CURL, CurlHandle, CurlMultiHandle, CurlMessage

class FetchClient {
  construct new(){
    init(100)
  }

  init(threshold){
    _threshold = threshold
    _startTime = 0
    _time = threshold
    _requests = 0
    _multi = CurlMultiHandle.new()
    _message = CurlMessage.new()
    _lookup = {}
  }

  requests { _requests }

  get(url, fn){
    var handle = CurlHandle.new(url)
    addHandle_(handle, fn)
  }

  download(url, path, fn){
    var handle = CurlHandle.download(url, path)
    addHandle_(handle, fn)
  }

  addHandle_(handle, fn){
    _requests = _requests+1
    _lookup[handle.id] = fn
    _multi.addHandle(handle)
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
      _lookup[handle.id].call(handle.responseCode, handle.getData())
      _lookup.remove(handle.id)
      _multi.removeHandle(handle)
      handle.dispose()
    }
  }
}

