// Run an asynchronous HTTP request

import "wren-curl" for CurlHandle, CurlMultiHandle, CurlMessage

var multi = CurlMultiHandle.new()
multi.addHandle(CurlHandle.new("https://www.example.com/"))

var threshold = 100

var running = 1
var message = CurlMessage.new()

var startTime = 0
var time = threshold

while(running > 0){
  running = multi.perform()

  while(multi.readInfo(message)){
    var handle = message.getHandle()
    System.print(handle.getData().toBytes())
  }
}

