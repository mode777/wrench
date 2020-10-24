// Run an asynchronous HTTP request

import "wren-curl" for CURL, CurlHandle, CurlMultiHandle, CurlMessage

var multi = CurlMultiHandle.new()
multi.addHandle(CurlHandle.new("https://www.example.com/"))

var threshold = 100

var running = 1
var message = CurlMessage.new()

var startTime = 0
var time = threshold

var DoStep = Fn.new {
  running = multi.perform()

  while(multi.readInfo(message)){
    var handle = message.getHandle()
    var content = handle.getData()
    System.print(handle.responseCode)
    multi.removeHandle(handle)
    handle.dispose()
  }

  multi.wait(1000)
}

CURL.runLoop(Fn.new {
  if(time >= threshold){
    DoStep.call()
    time = 0
    startTime = CURL.clock
  }
  time = CURL.clock - startTime
  return running > 0
})

